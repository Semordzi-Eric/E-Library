<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h2 class="text-2xl font-bold text-text-main">Company Library</h2>
      <div class="flex items-center gap-3">
        <select class="border border-gray-300 rounded-lg text-sm py-2 px-3 bg-surface focus:ring-primary focus:border-primary">
          <option>All Categories</option>
          <option>Leadership</option>
          <option>HR Policies</option>
          <option>Compliance</option>
          <option>Technology</option>
        </select>
        <select class="border border-gray-300 rounded-lg text-sm py-2 px-3 bg-surface focus:ring-primary focus:border-primary">
          <option>Most Recent</option>
          <option>Most Popular</option>
          <option>Alphabetical</option>
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

    <div v-else class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-6">
      <BookCard 
        v-for="book in mockBooks" 
        :key="book.id" 
        :book="book" 
        @click="openReader(book.id)"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import BookCard from '../../components/library/BookCard.vue'

const router = useRouter()
const loading = ref(true)

// Mock Data to visualize the layout until Supabase is populated
const mockBooks = ref([
  { id: '1', title: 'The Effective Executive', author: 'Peter F. Drucker', category: 'Leadership', cover_url: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400' },
  { id: '2', title: '2026 Employee Handbook', author: 'Human Resources', category: 'HR Policies', cover_url: 'https://images.unsplash.com/photo-1554774853-719586f82d77?w=400' },
  { id: '3', title: 'Cybersecurity Best Practices', author: 'IT Department', category: 'Technology', cover_url: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=400' },
  { id: '4', title: 'Code of Conduct & Ethics', author: 'Legal Team', category: 'Compliance', cover_url: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=400' },
  { id: '5', title: 'Q3 Financial Report Guidelines', author: 'Finance Dept', category: 'Finance', cover_url: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400' },
  { id: '6', title: 'Radical Candor', author: 'Kim Scott', category: 'Leadership', cover_url: 'https://images.unsplash.com/photo-1517404215738-15263e9f9178?w=400' },
  { id: '7', title: 'Remote Work Ergonomics', author: 'Health & Safety', category: 'HR Policies', cover_url: 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=400' },
])

onMounted(() => {
  // Simulate network fetch
  setTimeout(() => {
    loading.value = false
  }, 800)
})

const openReader = (id: string) => {
  router.push(`/read/${id}`)
}
</script>
