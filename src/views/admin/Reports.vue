<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h2 class="text-2xl font-bold text-text-main">Platform Reports</h2>
    </div>

    <!-- Overview Stats -->
    <section class="grid grid-cols-1 md:grid-cols-4 gap-6">
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <p class="text-sm font-medium text-text-muted">Total Books</p>
        <p class="text-3xl font-bold text-text-main mt-2">{{ totalBooks }}</p>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <p class="text-sm font-medium text-text-muted">Total Staff</p>
        <p class="text-3xl font-bold text-text-main mt-2">{{ totalUsers }}</p>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <p class="text-sm font-medium text-text-muted">Total Reads</p>
        <p class="text-3xl font-bold text-text-main mt-2">{{ totalReads }}</p>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <p class="text-sm font-medium text-text-muted">Reading Sessions</p>
        <p class="text-3xl font-bold text-text-main mt-2">{{ totalSessions }}</p>
      </div>
    </section>

    <!-- Charts -->
    <section class="grid grid-cols-1 lg:grid-cols-2 gap-6" v-if="!loading">
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <h3 class="text-lg font-bold text-text-main mb-4">Top Books (Reads)</h3>
        <div class="h-64">
          <Bar v-if="barChartData" :data="barChartData" :options="barOptions" />
        </div>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm">
        <h3 class="text-lg font-bold text-text-main mb-4">Books by Category</h3>
        <div class="h-64 flex justify-center">
          <Pie v-if="pieChartData" :data="pieChartData" :options="pieOptions" />
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../../services/supabase'
import { Bar, Pie } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ArcElement } from 'chart.js'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ArcElement)

const loading = ref(true)

const totalBooks = ref(0)
const totalUsers = ref(0)
const totalReads = ref(0)
const totalSessions = ref(0)

const barChartData = ref<any>(null)
const pieChartData = ref<any>(null)

const barOptions = {
  responsive: true,
  maintainAspectRatio: false
}
const pieOptions = {
  responsive: true,
  maintainAspectRatio: false
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
  const { data: books } = await supabase.from('books').select('title, reads_count, category').order('reads_count', { ascending: false })
  
  if (books) {
    totalReads.value = books.reduce((acc, curr) => acc + (curr.reads_count || 0), 0)
    
    // Bar Chart Data (Top 5)
    const topBooks = books.slice(0, 5)
    barChartData.value = {
      labels: topBooks.map(b => b.title.length > 20 ? b.title.substring(0,20)+'...' : b.title),
      datasets: [
        {
          label: 'Reads',
          backgroundColor: '#3b82f6', // primary
          data: topBooks.map(b => b.reads_count || 0)
        }
      ]
    }
    
    // Pie Chart Data (Category breakdown)
    const catMap = books.reduce((acc, curr) => {
      acc[curr.category] = (acc[curr.category] || 0) + 1
      return acc
    }, {} as Record<string, number>)
    
    const colors = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6']
    
    pieChartData.value = {
      labels: Object.keys(catMap),
      datasets: [
        {
          backgroundColor: Object.keys(catMap).map((_, i) => colors[i % colors.length]),
          data: Object.values(catMap)
        }
      ]
    }
  }
  
  loading.value = false
})
</script>
