<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h2 class="text-2xl font-bold text-text-main">Platform Reports</h2>
    </div>

    <!-- Overview Stats -->
    <section class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-6">
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <p class="text-sm font-medium text-text-muted">Total Books</p>
        <p class="text-2xl font-bold text-text-main mt-2">{{ totalBooks }}</p>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <p class="text-sm font-medium text-text-muted">Total Staff</p>
        <p class="text-2xl font-bold text-text-main mt-2">{{ totalUsers }}</p>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <p class="text-sm font-medium text-text-muted">Total Reads</p>
        <p class="text-2xl font-bold text-text-main mt-2">{{ totalReads }}</p>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <p class="text-sm font-medium text-text-muted">Sessions</p>
        <p class="text-2xl font-bold text-text-main mt-2">{{ totalSessions }}</p>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <p class="text-sm font-medium text-text-muted">Reading Time</p>
        <p class="text-2xl font-bold text-text-main mt-2">{{ formatTime(totalReadingTime) }}</p>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <p class="text-sm font-medium text-text-muted">Avg Completion</p>
        <p class="text-2xl font-bold text-text-main mt-2">{{ avgCompletion }}%</p>
      </div>
    </section>

    <!-- Charts -->
    <section class="grid grid-cols-1 lg:grid-cols-2 gap-6" v-if="!loading">
      <!-- Top Row: Activity Trend & Top Books -->
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm col-span-1 lg:col-span-2">
        <h3 class="text-lg font-bold text-text-main mb-4">30-Day Reading Activity</h3>
        <div class="h-64">
          <Line v-if="lineChartData" :data="lineChartData" :options="lineOptions" />
        </div>
      </div>
      
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <h3 class="text-lg font-bold text-text-main mb-4">Top Books (Reads)</h3>
        <div class="h-64">
          <Bar v-if="barChartData" :data="barChartData" :options="barOptions" />
        </div>
      </div>
      
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <h3 class="text-lg font-bold text-text-main mb-4">Top Departments</h3>
        <div class="h-64 flex justify-center">
          <Pie v-if="deptChartData" :data="deptChartData" :options="pieOptions" />
        </div>
      </div>

      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm col-span-1 lg:col-span-2">
        <h3 class="text-lg font-bold text-text-main mb-4">Most Active Readers</h3>
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Staff Name</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Department</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Sessions</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Time Spent</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="reader in topReaders" :key="reader.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 text-sm font-medium text-gray-900">{{ reader.name }}</td>
                <td class="px-6 py-4 text-sm text-gray-500">{{ reader.department }}</td>
                <td class="px-6 py-4 text-sm text-gray-500">{{ reader.sessions }}</td>
                <td class="px-6 py-4 text-sm text-gray-500">{{ formatTime(reader.time) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../../services/supabase'
import { Bar, Pie, Line } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ArcElement, LineElement, PointElement } from 'chart.js'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ArcElement, LineElement, PointElement)

const loading = ref(true)

const totalBooks = ref(0)
const totalUsers = ref(0)
const totalReads = ref(0)
const totalSessions = ref(0)
const totalReadingTime = ref(0)
const avgCompletion = ref(0)

const barChartData = ref<any>(null)
const pieChartData = ref<any>(null)
const lineChartData = ref<any>(null)
const deptChartData = ref<any>(null)
const topReaders = ref<any[]>([])

const formatTime = (seconds: number) => {
  if (!seconds) return '0h 0m'
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  if (h > 0) return `${h}h ${m}m`
  return `${m}m`
}

const barOptions = {
  responsive: true,
  maintainAspectRatio: false
}
const pieOptions = {
  responsive: true,
  maintainAspectRatio: false
}
const lineOptions = {
  responsive: true,
  maintainAspectRatio: false,
  scales: {
    y: {
      beginAtZero: true,
      ticks: { stepSize: 1 }
    }
  }
}

onMounted(async () => {
  loading.value = true
  
  // Fetch overall counts
  const { count: bCount } = await supabase.from('books').select('*', { count: 'exact', head: true })
  totalBooks.value = bCount || 0
  
  const { count: pCount } = await supabase.from('profiles').select('*', { count: 'exact', head: true })
  totalUsers.value = pCount || 0
  
  const { count: sCount } = await supabase.from('reading_sessions').select('*', { count: 'exact', head: true })
  totalSessions.value = sCount || 0
  
  // Fetch book metrics for charts
  const { data: books } = await supabase.from('books').select('id, title, category')
  const { data: sessions } = await supabase.from('reading_sessions').select('*, profiles(name, department)')
  
  if (books && sessions) {
    // 1. Compute summary stats from sessions
    const totalTime = sessions.reduce((sum, s) => sum + (s.time_spent_seconds || s.duration || 0), 0)
    totalReadingTime.value = totalTime

    const totalCompletion = sessions.reduce((sum, s) => sum + (s.progress_percentage || s.completion_percentage || 0), 0)
    avgCompletion.value = sessions.length ? Math.round(totalCompletion / sessions.length) : 0

    // 2. Book Reads
    const sessionCounts = sessions.reduce((acc, curr) => {
      acc[curr.book_id] = (acc[curr.book_id] || 0) + 1
      return acc
    }, {} as Record<string, number>)

    const enrichedBooks = books.map(b => ({
      ...b,
      reads_count: sessionCounts[b.id] || 0
    })).sort((a, b) => b.reads_count - a.reads_count)

    totalReads.value = enrichedBooks.reduce((acc, curr) => acc + curr.reads_count, 0)
    
    // Bar Chart Data (Top Books)
    const topBooks = enrichedBooks.slice(0, 5)
    barChartData.value = {
      labels: topBooks.map(b => b.title.length > 20 ? b.title.substring(0,20)+'...' : b.title),
      datasets: [{
        label: 'Reads',
        backgroundColor: '#3b82f6',
        data: topBooks.map(b => b.reads_count)
      }]
    }
    
    const colors = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#6366f1', '#ec4899', '#14b8a6']

    // 3. Department Pie Chart
    const deptMap = sessions.reduce((acc, curr) => {
      const dept = curr.profiles?.department || 'Unknown'
      acc[dept] = (acc[dept] || 0) + 1
      return acc
    }, {} as Record<string, number>)
    
    deptChartData.value = {
      labels: Object.keys(deptMap),
      datasets: [{
        backgroundColor: Object.keys(deptMap).map((_, i) => colors[i % colors.length]),
        data: Object.values(deptMap)
      }]
    }

    // 4. Line Chart (Last 30 Days)
    const last30Days = [...Array(30)].map((_, i) => {
      const d = new Date()
      d.setDate(d.getDate() - (29 - i))
      return d.toISOString().split('T')[0]
    })

    const dayCounts = sessions.reduce((acc, curr) => {
      const day = (curr.start_time || curr.created_at || '').split('T')[0]
      if (day) acc[day] = (acc[day] || 0) + 1
      return acc
    }, {} as Record<string, number>)

    lineChartData.value = {
      labels: last30Days.map(d => d.substring(5)), // MM-DD
      datasets: [{
        label: 'Sessions Started',
        borderColor: '#3b82f6',
        backgroundColor: 'rgba(59, 130, 246, 0.1)',
        data: last30Days.map(d => dayCounts[d] || 0),
        fill: true,
        tension: 0.3
      }]
    }

    // 5. Most Active Readers
    const readersMap = sessions.reduce((acc, curr) => {
      const id = curr.user_id
      if (!acc[id]) {
        acc[id] = { id, name: curr.profiles?.name || 'Unknown', department: curr.profiles?.department || '', sessions: 0, time: 0 }
      }
      acc[id].sessions++
      acc[id].time += (curr.time_spent_seconds || curr.duration || 0)
      return acc
    }, {} as Record<string, any>)

    topReaders.value = Object.values(readersMap).sort((a: any, b: any) => b.time - a.time).slice(0, 5)
  }
  
  loading.value = false
})
</script>
