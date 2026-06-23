<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h2 class="text-2xl font-bold text-text-main">Staff Activity</h2>
      <button @click="refreshAll" class="flex items-center gap-2 text-sm font-medium text-primary hover:text-primary-dark transition-colors">
        <RefreshCwIcon class="w-4 h-4" :class="{ 'animate-spin': isRefreshing }" />
        Refresh
      </button>
    </div>

    <!-- Reading Sessions Table -->
    <div class="bg-surface border border-gray-200 rounded-xl shadow-sm overflow-hidden">
      <div class="px-6 py-4 border-b border-gray-200 bg-gray-50 flex items-center justify-between">
        <h3 class="text-base font-bold text-text-main">Reading Sessions</h3>
        <span class="text-xs text-gray-500">{{ sessions.length }} records</span>
      </div>

      <div v-if="loadingSessions" class="p-8 text-center text-gray-500">
        <Loader2Icon class="w-5 h-5 animate-spin mx-auto mb-2 text-primary" />
        Loading sessions...
      </div>
      <div class="overflow-x-auto">
        <table v-if="!loadingSessions" class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Staff</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Book</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Progress</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Time Spent</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Last Active</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-if="sessions.length === 0">
              <td colspan="5" class="px-6 py-8 text-center text-gray-500">No reading sessions yet.</td>
            </tr>
            <tr v-for="session in sessions" :key="session.id" class="hover:bg-gray-50 transition-colors">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 text-white flex items-center justify-center text-xs font-bold flex-shrink-0">
                    {{ getInitials(session.profiles?.name) }}
                  </div>
                  <div>
                    <p class="text-sm font-semibold text-gray-900">{{ session.profiles?.name || 'Unknown' }}</p>
                    <p class="text-xs text-gray-500">{{ session.profiles?.department || '' }}</p>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4">
                <p class="text-sm font-medium text-gray-900 max-w-[180px] truncate">{{ session.books?.title || 'Unknown Book' }}</p>
                <p class="text-xs text-gray-500">{{ session.books?.category || '' }}</p>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center gap-2">
                  <div class="w-20 h-1.5 bg-gray-200 rounded-full overflow-hidden">
                    <div class="h-full bg-blue-500 rounded-full" :style="{ width: `${session.progress_percentage || 0}%` }"></div>
                  </div>
                  <span class="text-xs font-medium text-gray-700">{{ session.progress_percentage || 0 }}%</span>
                </div>
                <p class="text-xs text-gray-400 mt-0.5">Pg. {{ session.current_page || 1 }} of {{ session.total_pages || '?' }}</p>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="text-sm font-medium text-gray-900">{{ formatTime(session.time_spent_seconds) }}</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(session.last_read_at) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Audit Log Table -->
    <div class="bg-surface border border-gray-200 rounded-xl shadow-sm overflow-hidden">
      <div class="px-6 py-4 border-b border-gray-200 bg-gray-50 flex items-center justify-between">
        <h3 class="text-base font-bold text-text-main">System Event Log</h3>
        <div class="flex items-center gap-2">
          <select v-model="filterAction" class="border border-gray-300 rounded-lg text-xs py-1.5 px-2.5 bg-white focus:ring-primary focus:border-primary">
            <option value="">All Actions</option>
            <option value="LOGIN">Logins</option>
            <option value="READ_START">Read Started</option>
            <option value="READ_END">Read Ended</option>
            <option value="PAGE_TURN">Page Turns</option>
          </select>
          <span class="text-xs text-gray-500">{{ filteredLogs.length }} entries</span>
        </div>
      </div>

      <div v-if="loadingLogs" class="p-8 text-center text-gray-500">
        <Loader2Icon class="w-5 h-5 animate-spin mx-auto mb-2 text-primary" />
        Loading activity...
      </div>
      <div class="overflow-x-auto">
        <table v-if="!loadingLogs" class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Time</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Staff</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Action</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Details</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-if="filteredLogs.length === 0">
              <td colspan="4" class="px-6 py-8 text-center text-gray-500">No activity recorded yet.</td>
            </tr>
            <tr v-for="log in filteredLogs" :key="log.id" class="hover:bg-gray-50 transition-colors">
              <td class="px-6 py-4 whitespace-nowrap text-xs text-gray-500">
                {{ formatDate(log.timestamp) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <p class="text-sm font-medium text-gray-900">{{ log.profiles?.name || 'Unknown' }}</p>
                <p class="text-xs text-gray-500">{{ log.profiles?.department || '' }}</p>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2.5 py-0.5 inline-flex text-xs font-semibold rounded-full" :class="actionBadge(log.action)">
                  {{ log.action }}
                </span>
              </td>
              <td class="px-6 py-4 text-sm text-gray-500 max-w-xs truncate">
                {{ log.resource }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { RefreshCwIcon, Loader2Icon } from '@lucide/vue'
import { supabase } from '../../services/supabase'

const loadingLogs = ref(true)
const loadingSessions = ref(true)
const isRefreshing = ref(false)
const logs = ref<any[]>([])
const sessions = ref<any[]>([])
const filterAction = ref('')

const fetchLogs = async () => {
  loadingLogs.value = true
  const { data, error } = await supabase
    .from('audit_logs')
    .select('*, profiles(name, department)')
    .order('timestamp', { ascending: false })
    .limit(200)
  if (data) logs.value = data
  if (error) console.error('Error fetching logs:', error)
  loadingLogs.value = false
}

const fetchSessions = async () => {
  loadingSessions.value = true
  const { data, error } = await supabase
    .from('reading_sessions')
    .select('*, profiles(name, department), books(title, category)')
    .order('last_read_at', { ascending: false })
    .limit(100)
  if (data) sessions.value = data
  if (error) console.error('Error fetching sessions:', error)
  loadingSessions.value = false
}

const refreshAll = async () => {
  isRefreshing.value = true
  await Promise.all([fetchLogs(), fetchSessions()])
  isRefreshing.value = false
}

onMounted(() => refreshAll())

const filteredLogs = computed(() => {
  if (!filterAction.value) return logs.value
  return logs.value.filter(l => l.action === filterAction.value)
})

const getInitials = (name?: string) => {
  if (!name) return '?'
  const parts = name.trim().split(' ')
  if (parts.length >= 2) return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
  return name.substring(0, 2).toUpperCase()
}

const formatTime = (seconds: number) => {
  if (!seconds || seconds < 60) return seconds ? `${seconds}s` : '—'
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  if (h > 0) return `${h}h ${m}m`
  return `${m} mins`
}

const formatDate = (dateStr: string) => {
  if (!dateStr) return '—'
  const d = new Date(dateStr)
  return d.toLocaleString(undefined, { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
}

const actionBadge = (action: string) => {
  const map: Record<string, string> = {
    LOGIN: 'bg-green-100 text-green-800',
    READ_START: 'bg-blue-100 text-blue-800',
    READ_END: 'bg-indigo-100 text-indigo-800',
    PAGE_TURN: 'bg-yellow-100 text-yellow-800',
    DOWNLOAD: 'bg-red-100 text-red-800',
  }
  return map[action] || 'bg-gray-100 text-gray-700'
}
</script>
