<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h2 class="text-2xl font-bold text-text-main">Employee Management</h2>
    </div>

    <!-- Data Table -->
    <div class="bg-surface border border-gray-200 rounded-xl shadow-sm overflow-hidden">
      <div v-if="loading" class="p-8 text-center text-gray-500">
        Loading employees...
      </div>
      <table v-else class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Employee</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Role</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Department</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Reading Stats</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Joined</th>
            <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-text-muted uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-if="profiles.length === 0">
            <td colspan="6" class="px-6 py-8 text-center text-gray-500">No employees found.</td>
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
                <option value="employee">Employee</option>
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
              <button @click="deleteProfile(profile.id)" class="text-red-600 hover:text-red-900">Remove Access</button>
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
          {{ loadingMore ? 'Loading...' : 'Load More Employees' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../../services/supabase'
import { useToastStore } from '../../stores/toast'

const toastStore = useToastStore()
const loading = ref(true)
const loadingMore = ref(false)
const profiles = ref<any[]>([])

const page = ref(0)
const PAGE_SIZE = 50
const hasMore = ref(true)

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

  const { data, count, error } = await supabase
    .from('profiles')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to)

  if (data) {
    const profileIds = data.map(p => p.id)
    const { data: sessions } = await supabase
      .from('reading_sessions')
      .select('user_id, time_spent_seconds')
      .in('user_id', profileIds)

    const profilesWithStats = data.map(p => {
      const userSessions = sessions?.filter(s => s.user_id === p.id) || []
      const totalTime = userSessions.reduce((acc, curr) => acc + (curr.time_spent_seconds || 0), 0)
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
  if (confirm('Are you sure you want to remove this employee\'s profile access? Note: They will not be able to log in to the app until a new profile is created.')) {
    const { error } = await supabase.from('profiles').delete().eq('id', id)
    if (error) {
      toastStore.error("Error: " + error.message)
    } else {
      toastStore.success("Employee access removed")
      await fetchProfiles()
    }
  }
}
</script>
