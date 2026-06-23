<template>
  <div class="space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <h2 class="text-2xl font-bold text-text-main">Staff Management</h2>
      <div class="relative w-full sm:w-72">
        <input 
          v-model="searchQuery" 
          @input="handleSearch"
          type="text" 
          placeholder="Search by name..." 
          class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-primary focus:border-primary outline-none transition-all"
        />
        <SearchIcon class="w-4 h-4 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
      </div>
    </div>

    <!-- Data Table -->
    <div class="bg-surface border border-gray-200 rounded-xl shadow-sm overflow-hidden">
      <div v-if="loading" class="p-8 text-center text-gray-500">
        Loading staff...
      </div>
      <table v-else class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Staff</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Role</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Department</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Reading Stats</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Joined</th>
            <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-text-muted uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-if="profiles.length === 0">
            <td colspan="6" class="px-6 py-8 text-center text-gray-500">No staff found.</td>
          </tr>
          <tr v-for="profile in profiles" :key="profile.id">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex items-center">
                <div class="h-10 w-10 rounded-full bg-primary flex items-center justify-center text-white font-bold">
                  {{ profile.name?.substring(0,2).toUpperCase() || 'EMP' }}
                </div>
                <div class="ml-4">
                  <div class="text-sm font-bold text-text-main">{{ profile.name || 'Unknown' }}</div>
                  <div class="text-sm text-text-muted">{{ profile.employee_id || 'No ID' }}</div>
                </div>
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <select v-model="profile.role" @change="updateRole(profile.id, profile.role)" class="text-sm border-gray-300 rounded-md focus:ring-primary focus:border-primary">
                <option value="admin">Admin</option>
                <option value="employee">Staff</option>
              </select>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-text-muted">
              {{ profile.department || 'N/A' }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-text-muted">
              <div v-if="profile.booksStarted !== undefined">
                <div class="font-medium text-gray-900">{{ formatTime(profile.totalReadingTime || 0) }} read</div>
                <div class="text-xs">{{ profile.booksStarted }} books started</div>
              </div>
              <span v-else class="text-gray-400">Loading...</span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-text-muted">
              {{ new Date(profile.created_at).toLocaleDateString() }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <div class="flex items-center justify-end gap-3">
                <button @click="openActivityModal(profile)" class="text-primary hover:text-primary-dark transition-colors font-semibold">View Activity</button>
                <button @click="deleteProfile(profile.id)" class="text-red-600 hover:text-red-900 transition-colors">Remove Access</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
      
      <div v-if="hasMore && !loading" class="p-4 flex justify-center border-t border-gray-200">
        <button 
          @click="fetchProfiles(true)" 
          :disabled="loadingMore"
          class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary disabled:opacity-50"
        >
          {{ loadingMore ? 'Loading...' : 'Load More Staff' }}
        </button>
      </div>
    </div>

    <!-- Activity Modal -->
    <div v-if="showActivityModal" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="closeActivityModal"></div>
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
        
        <div class="inline-block align-bottom bg-surface rounded-xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full">
          <div class="bg-surface px-6 pt-5 pb-4 border-b border-gray-200 flex items-center justify-between">
            <h3 class="text-lg leading-6 font-bold text-text-main flex items-center gap-2" id="modal-title">
              <ActivityIcon class="w-5 h-5 text-primary" />
              Activity History: {{ selectedProfile?.name }}
            </h3>
            <button @click="closeActivityModal" class="text-gray-400 hover:text-gray-500 transition-colors">
              <XIcon class="w-5 h-5" />
            </button>
          </div>
          
          <div class="p-6">
            <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4 mb-4">
              <div class="flex space-x-6 border-b border-gray-200 w-full sm:w-auto">
                <button @click="activeTab = 'sessions'" :class="activeTab === 'sessions' ? 'text-primary border-b-2 border-primary font-bold' : 'text-gray-500 hover:text-gray-700 font-medium'" class="pb-2 px-1 transition-colors">Reading Sessions</button>
                <button @click="activeTab = 'logs'" :class="activeTab === 'logs' ? 'text-primary border-b-2 border-primary font-bold' : 'text-gray-500 hover:text-gray-700 font-medium'" class="pb-2 px-1 transition-colors">Event Logs</button>
              </div>
              <button @click="downloadCsv" class="flex items-center justify-center gap-2 text-sm bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg transition-colors font-semibold shadow-sm w-full sm:w-auto">
                <DownloadIcon class="w-4 h-4" />
                Export CSV
              </button>
            </div>

            <div v-if="loadingActivity" class="py-16 text-center text-gray-500">
              Loading data...
            </div>
            
            <div v-else-if="activeTab === 'sessions'" class="max-h-[60vh] overflow-y-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50 sticky top-0">
                  <tr>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Book Title</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Start Time</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Duration</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Progress</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 bg-white">
                  <tr v-if="userSessions.length === 0"><td colspan="4" class="py-8 text-center text-sm text-gray-500">No reading sessions recorded.</td></tr>
                  <tr v-for="s in userSessions" :key="s.id" class="hover:bg-gray-50 transition-colors">
                    <td class="px-4 py-3 text-sm font-medium text-gray-900">{{ s.books?.title || 'Unknown Book' }}</td>
                    <td class="px-4 py-3 text-sm text-gray-500">{{ new Date(s.start_time).toLocaleString() }}</td>
                    <td class="px-4 py-3 text-sm text-gray-500">{{ formatTime(s.duration) }}</td>
                    <td class="px-4 py-3 text-sm text-gray-500">
                      <div class="flex items-center gap-2">
                        <div class="w-16 h-1.5 bg-gray-200 rounded-full overflow-hidden">
                          <div class="h-full bg-primary rounded-full" :style="{ width: `${s.completion_percentage || 0}%` }"></div>
                        </div>
                        <span>{{ s.completion_percentage || 0 }}%</span>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div v-else-if="activeTab === 'logs'" class="max-h-[60vh] overflow-y-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50 sticky top-0">
                  <tr>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Time</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Details</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 bg-white">
                  <tr v-if="userLogs.length === 0"><td colspan="3" class="py-8 text-center text-sm text-gray-500">No events recorded.</td></tr>
                  <tr v-for="l in userLogs" :key="l.id" class="hover:bg-gray-50 transition-colors">
                    <td class="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">{{ new Date(l.timestamp).toLocaleString() }}</td>
                    <td class="px-4 py-3 text-sm font-semibold text-gray-900">{{ l.action }}</td>
                    <td class="px-4 py-3 text-sm text-gray-500">{{ l.resource }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { SearchIcon, ActivityIcon, XIcon, DownloadIcon } from '@lucide/vue'
import { supabase } from '../../services/supabase'
import { useToastStore } from '../../stores/toast'

const toastStore = useToastStore()
const loading = ref(true)
const loadingMore = ref(false)
const profiles = ref<any[]>([])

const page = ref(0)
const PAGE_SIZE = 50
const hasMore = ref(true)

const searchQuery = ref('')
let searchTimeout: any = null

const showActivityModal = ref(false)
const selectedProfile = ref<any>(null)
const activeTab = ref('sessions')
const loadingActivity = ref(false)
const userSessions = ref<any[]>([])
const userLogs = ref<any[]>([])

const handleSearch = () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    fetchProfiles()
  }, 300)
}

const formatTime = (seconds: number) => {
  if (!seconds) return '0h 0m'
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  if (h > 0) return `${h}h ${m}m`
  return `${m}m`
}

const fetchProfiles = async (isLoadMore = false) => {
  if (isLoadMore) {
    loadingMore.value = true
    page.value++
  } else {
    loading.value = true
    page.value = 0
    profiles.value = []
  }

  const from = page.value * PAGE_SIZE
  const to = from + PAGE_SIZE - 1

  let query = supabase
    .from('profiles')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to)

  if (searchQuery.value.trim()) {
    query = query.ilike('name', `%${searchQuery.value.trim()}%`)
  }

  const { data, count, error } = await query

  if (data) {
    const profileIds = data.map(p => p.id)
    const { data: sessions } = await supabase
      .from('reading_sessions')
      .select('user_id, duration')
      .in('user_id', profileIds)

    const profilesWithStats = data.map(p => {
      const userSessions = sessions?.filter(s => s.user_id === p.id) || []
      const totalTime = userSessions.reduce((acc, curr) => acc + (curr.duration || 0), 0)
      return {
        ...p,
        booksStarted: userSessions.length,
        totalReadingTime: totalTime
      }
    })

    profiles.value = isLoadMore ? [...profiles.value, ...profilesWithStats] : profilesWithStats
    hasMore.value = count ? (from + data.length) < count : false
  }
  if (error) {
    toastStore.error(error.message)
  }

  loading.value = false
  loadingMore.value = false
}

onMounted(() => fetchProfiles())

const updateRole = async (id: string, newRole: string) => {
  const { error } = await supabase.from('profiles').update({ role: newRole }).eq('id', id)
  if (error) {
    toastStore.error("Error updating role: " + error.message)
    await fetchProfiles() // revert
  } else {
    toastStore.success("Role updated successfully")
  }
}

const deleteProfile = async (id: string) => {
  if (confirm('Are you sure you want to remove this staff member\'s profile access? Note: They will not be able to log in to the app until a new profile is created.')) {
    const { error } = await supabase.from('profiles').delete().eq('id', id)
    if (error) {
      toastStore.error("Error: " + error.message)
    } else {
      toastStore.success("Staff access removed")
      await fetchProfiles()
    }
  }
}

const openActivityModal = async (profile: any) => {
  selectedProfile.value = profile
  showActivityModal.value = true
  loadingActivity.value = true
  activeTab.value = 'sessions'
  
  const [sessionsRes, logsRes] = await Promise.all([
    supabase.from('reading_sessions').select('*, books(title)').eq('user_id', profile.id).order('start_time', { ascending: false }),
    supabase.from('audit_logs').select('*').eq('user_id', profile.id).order('timestamp', { ascending: false })
  ])
  
  userSessions.value = sessionsRes.data || []
  userLogs.value = logsRes.data || []
  loadingActivity.value = false
}

const closeActivityModal = () => {
  showActivityModal.value = false
  selectedProfile.value = null
}

const downloadCsv = () => {
  let csvContent = "data:text/csv;charset=utf-8,\n"
  
  if (activeTab.value === 'sessions') {
    csvContent += "Book Title,Start Time,Duration (seconds),Completion Percentage\n"
    userSessions.value.forEach(s => {
      const row = [
        `"${(s.books?.title || '').replace(/"/g, '""')}"`,
        `"${new Date(s.start_time).toLocaleString()}"`,
        s.duration || 0,
        s.completion_percentage || 0
      ].join(',')
      csvContent += row + "\n"
    })
  } else {
    csvContent += "Time,Action,Resource\n"
    userLogs.value.forEach(l => {
      const row = [
        `"${new Date(l.timestamp).toLocaleString()}"`,
        `"${l.action}"`,
        `"${(l.resource || '').replace(/"/g, '""')}"`
      ].join(',')
      csvContent += row + "\n"
    })
  }
  
  const encodedUri = encodeURI(csvContent)
  const link = document.createElement("a")
  link.setAttribute("href", encodedUri)
  link.setAttribute("download", `${selectedProfile.value?.name}_${activeTab.value}_report.csv`)
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}
</script>
