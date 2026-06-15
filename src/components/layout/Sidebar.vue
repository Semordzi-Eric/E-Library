<template>
  <aside class="w-64 bg-surface border-r border-gray-200 flex flex-col h-full">
    <div class="h-16 flex items-center px-6 border-b border-gray-200">
      <h1 class="text-xl font-bold text-text-main flex items-center gap-2">
        <BookOpenIcon class="w-6 h-6 text-primary" />
        HR E-Library
      </h1>
    </div>
    <nav class="flex-1 px-4 py-6 space-y-2">
      <router-link
        v-for="item in navItems"
        :key="item.name"
        :to="item.path"
        class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors"
        :class="[
          $route.path === item.path
            ? 'bg-blue-50 text-primary'
            : 'text-text-muted hover:bg-gray-50 hover:text-text-main'
        ]"
      >
        <component :is="item.icon" class="w-5 h-5" />
        {{ item.name }}
      </router-link>
    </nav>
    <div class="p-4 border-t border-gray-200">
      <button @click="handleLogout" class="flex items-center gap-3 px-3 py-2 w-full rounded-lg text-sm font-medium text-text-muted hover:bg-red-50 hover:text-red-600 transition-colors">
        <LogOutIcon class="w-5 h-5" />
        Sign Out
      </button>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { BookOpenIcon, LayoutDashboardIcon, LibraryIcon, LogOutIcon, UploadIcon, UsersIcon, BarChartIcon } from '@lucide/vue'
import { useAuthStore } from '../../stores/auth'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const router = useRouter()

const navItems = computed(() => {
  const items = [
    { name: 'Dashboard', path: '/dashboard', icon: LayoutDashboardIcon },
    { name: 'Library', path: '/library', icon: LibraryIcon },
  ]
  
  if (authStore.role === 'admin') {
    items.push(
      { name: 'Manage Books', path: '/admin/books', icon: UploadIcon },
      { name: 'Employees', path: '/admin/users', icon: UsersIcon },
      { name: 'Reports', path: '/admin/reports', icon: BarChartIcon },
    )
  }
  
  return items
})

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}
</script>
