<template>
  <div class="space-y-8">
    <!-- Welcome Section -->
    <section>
      <h2 class="text-2xl font-bold text-text-main tracking-tight">Welcome back, {{ authStore.greetingName }}!</h2>
      <p class="text-text-muted mt-1">Here is what's happening with your reading goals.</p>
    </section>

    <!-- Stats Grid -->
    <section class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-text-muted">Books Started</p>
          <p class="text-3xl font-bold text-text-main mt-2">{{ stats.booksStarted }}</p>
        </div>
        <div class="w-12 h-12 rounded-full bg-blue-50 flex items-center justify-center">
          <BookOpenIcon class="w-6 h-6 text-primary" />
        </div>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-text-muted">Reading Hours</p>
          <p class="text-3xl font-bold text-text-main mt-2">{{ stats.readingHours }}h</p>
        </div>
        <div class="w-12 h-12 rounded-full bg-indigo-50 flex items-center justify-center">
          <ClockIcon class="w-6 h-6 text-indigo-600" />
        </div>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-text-muted">Completion</p>
          <p class="text-3xl font-bold text-text-main mt-2">{{ stats.avgCompletion }}%</p>
        </div>
        <div class="w-12 h-12 rounded-full bg-green-50 flex items-center justify-center">
          <DownloadIcon class="w-6 h-6 text-green-600" />
        </div>
      </div>
    </section>

    <!-- Continue Reading -->
    <section>
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-semibold text-text-main">Continue Reading</h3>
        <router-link to="/library" class="text-sm font-medium text-primary hover:text-primary-dark">
          View all
        </router-link>
      </div>
      
      <div v-if="loading" class="text-gray-500 py-4">Loading your reading sessions...</div>
      <div v-else-if="recentSessions.length === 0" class="bg-surface border border-dashed border-gray-300 rounded-xl p-8 text-center text-gray-500">
        <p>You haven't started reading any books yet.</p>
        <router-link to="/library" class="mt-4 inline-block text-primary hover:underline">Browse Library</router-link>
      </div>
      <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div v-for="session in recentSessions" :key="session.id" @click="router.push(`/read/${session.books.id}`)" class="bg-surface border border-gray-200 rounded-xl p-4 flex gap-4 hover:border-gray-300 transition-colors group cursor-pointer shadow-sm">
          <div class="w-24 h-32 bg-gray-200 rounded-md flex-shrink-0 bg-cover bg-center" :style="session.books.cover_url ? { backgroundImage: `url(${session.books.cover_url})` } : {}">
            <div v-if="!session.books.cover_url" class="w-full h-full flex items-center justify-center text-gray-400">No Cover</div>
          </div>
          <div class="flex flex-col flex-1 py-1">
            <div class="text-xs font-medium text-primary mb-1">{{ session.books.category }}</div>
            <h4 class="font-bold text-text-main line-clamp-2">{{ session.books.title }}</h4>
            <p class="text-sm text-text-muted mt-1">{{ session.books.author }}</p>
            <div class="mt-auto">
              <div class="flex items-center justify-between text-xs text-text-muted mb-1">
                <span>Page {{ session.current_page || 1 }} of {{ session.total_pages || '?' }}</span>
                <span>{{ session.progress_percentage || 0 }}%</span>
              </div>
              <div class="w-full bg-gray-200 rounded-full h-1.5">
                <div class="bg-primary h-1.5 rounded-full" :style="{ width: `${session.progress_percentage || 0}%` }"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { BookOpenIcon, ClockIcon, DownloadIcon } from '@lucide/vue'
import { useAuthStore } from '../../stores/auth'
import { supabase } from '../../services/supabase'

const authStore = useAuthStore()
const router = useRouter()

const loading = ref(true)
const recentSessions = ref<any[]>([])
const stats = ref({
  booksStarted: 0,
  readingHours: 0,
  avgCompletion: 0
})

onMounted(async () => {
  if (!authStore.user) return
  
  loading.value = true
  
  // Fetch reading sessions with book details
  const { data, error } = await supabase
    .from('reading_sessions')
    .select('*, books(*)')
    .eq('user_id', authStore.user.id)
    .order('last_read_at', { ascending: false })
    .limit(4)
    
  if (data && !error) {
    recentSessions.value = data
  }
  
  // Compute overall stats
  const { data: allSessions } = await supabase
    .from('reading_sessions')
    .select('time_spent_seconds, progress_percentage')
    .eq('user_id', authStore.user.id)
    
  if (allSessions && allSessions.length > 0) {
    stats.value.booksStarted = allSessions.length
    
    const totalSeconds = allSessions.reduce((acc, curr) => acc + (curr.time_spent_seconds || 0), 0)
    stats.value.readingHours = Math.round(totalSeconds / 3600 * 10) / 10 // 1 decimal
    
    const totalProgress = allSessions.reduce((acc, curr) => acc + (curr.progress_percentage || 0), 0)
    stats.value.avgCompletion = Math.round(totalProgress / allSessions.length)
  }
  
  loading.value = false
})
</script>
