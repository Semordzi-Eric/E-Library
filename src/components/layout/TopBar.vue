<template>
  <header class="h-16 bg-surface border-b border-gray-200 flex items-center justify-between px-6">
    <div class="flex-1 max-w-xl">
      <div class="relative">
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <SearchIcon class="h-5 w-5 text-gray-400" />
        </div>
        <input
          type="text"
          placeholder="Search books, policies, authors..."
          class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg leading-5 bg-gray-50 placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-primary focus:border-primary sm:text-sm transition-colors"
        />
      </div>
    </div>
    <div class="flex items-center gap-4 ml-6">
      <button class="p-2 text-gray-400 hover:text-gray-500 relative">
        <BellIcon class="h-6 w-6" />
        <span class="absolute top-1.5 right-1.5 block h-2.5 w-2.5 rounded-full bg-red-500 ring-2 ring-white"></span>
      </button>
      <div class="flex items-center gap-3 pl-4 border-l border-gray-200">
        <div class="w-8 h-8 rounded-full bg-primary text-white flex items-center justify-center font-semibold text-sm">
          {{ userInitials }}
        </div>
        <div class="hidden md:block text-sm">
          <p class="font-medium text-text-main capitalize">{{ authStore.role || 'Employee' }}</p>
          <p class="text-text-muted text-xs truncate w-32">{{ userEmail }}</p>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { SearchIcon, BellIcon } from '@lucide/vue'
import { useAuthStore } from '../../stores/auth'

const authStore = useAuthStore()

const userEmail = computed(() => authStore.user?.email || 'user@company.com')
const userInitials = computed(() => {
  const email = userEmail.value
  return email.substring(0, 2).toUpperCase()
})
</script>
