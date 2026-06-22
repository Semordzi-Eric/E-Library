<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h2 class="text-2xl font-bold text-text-main">Company Library</h2>
      <div class="flex items-center gap-3">
        <select v-model="selectedCategory" class="border border-gray-300 rounded-lg text-sm py-2 px-3 bg-surface focus:ring-primary focus:border-primary">
          <option value="">All Categories</option>
          <option value="Leadership">Leadership</option>
          <option value="HR Policies">HR Policies</option>
          <option value="Compliance">Compliance</option>
          <option value="Technology">Technology</option>
          <option value="Finance">Finance</option>
        </select>
        <select v-model="selectedSort" class="border border-gray-300 rounded-lg text-sm py-2 px-3 bg-surface focus:ring-primary focus:border-primary">
          <option value="recent">Most Recent</option>
          <option value="popular">Most Popular</option>
          <option value="alpha">Alphabetical</option>
        </select>
      </div>
    </div>

    <!-- Book Grid -->
    <div v-if="loading" class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-6">
      <div v-for="n in 10" :key="n" class="animate-pulse flex flex-col bg-surface border border-gray-100 rounded-xl overflow-hidden">
        <div class="aspect-[2/3] bg-gray-200"></div>
        <div class="p-4 space-y-3">
          <div class="h-3 bg-gray-200 rounded w-1/2"></div>
          <div class="h-4 bg-gray-200 rounded w-full"></div>
          <div class="h-3 bg-gray-200 rounded w-2/3"></div>
        </div>
      </div>
    </div>

    <div v-else-if="filteredBooks.length === 0" class="flex flex-col items-center justify-center py-20 text-gray-500">
      <p class="text-lg">No books found.</p>
    </div>

    <div v-else class="space-y-8">
      <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-6">
        <BookCard 
          v-for="book in filteredBooks" 
          :key="book.id" 
          :book="book" 
          @click="openReader(book.id)"
        />
      </div>

      <div v-if="hasMore" class="flex justify-center pt-6">
        <button 
          @click="fetchBooks(true)" 
          :disabled="loadingMore"
          class="px-6 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary disabled:opacity-50 transition-colors"
        >
          {{ loadingMore ? 'Loading...' : 'Load More Books' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import BookCard from '../../components/library/BookCard.vue'
import { supabase } from '../../services/supabase'
import { useLibraryStore } from '../../stores/library'
import { useToastStore } from '../../stores/toast'

const router = useRouter()
const libraryStore = useLibraryStore()
const toastStore = useToastStore()

const loading = ref(true)
const loadingMore = ref(false)
const books = ref<any[]>([])
const hasMore = ref(true)
const page = ref(0)
const PAGE_SIZE = 50

const selectedCategory = ref('')
const selectedSort = ref('recent')

// For UI binding
const filteredBooks = ref<any[]>([])

const fetchBooks = async (isLoadMore = false) => {
  if (isLoadMore) {
    loadingMore.value = true
    page.value++
  } else {
    loading.value = true
    page.value = 0
    books.value = []
  }

  const from = page.value * PAGE_SIZE
  const to = from + PAGE_SIZE - 1

  try {
    let query = supabase.from('books').select('*', { count: 'exact' })

    if (libraryStore.searchQuery) {
      query = query.or(`title.ilike.%${libraryStore.searchQuery}%,author.ilike.%${libraryStore.searchQuery}%`)
    }
    if (selectedCategory.value) {
      query = query.eq('category', selectedCategory.value)
    }

    if (selectedSort.value === 'recent') {
      query = query.order('created_at', { ascending: false })
    } else if (selectedSort.value === 'popular') {
      query = query.order('reads_count', { ascending: false })
    } else if (selectedSort.value === 'alpha') {
      query = query.order('title', { ascending: true })
    }

    const { data, count, error } = await query.range(from, to)

    if (error) throw error

    if (data) {
      books.value = isLoadMore ? [...books.value, ...data] : data
      filteredBooks.value = books.value
      hasMore.value = count ? (from + data.length) < count : false
    }
  } catch (err: any) {
    toastStore.error("Failed to load books: " + err.message)
  } finally {
    loading.value = false
    loadingMore.value = false
  }
}

onMounted(() => fetchBooks())

watch([() => libraryStore.searchQuery, selectedCategory, selectedSort], () => {
  fetchBooks(false)
})

const openReader = (id: string) => {
  router.push(`/read/${id}`)
}
</script>
