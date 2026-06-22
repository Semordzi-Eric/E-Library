<template>
  <aside class="w-64 bg-surface border-r border-gray-200 flex flex-col h-full">
    <!-- Logo -->
    <div class="h-16 flex items-center px-6 border-b border-gray-200">
      <h1 class="text-xl font-bold text-text-main flex items-center gap-2">
        <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center">
          <BookOpenIcon class="w-4 h-4 text-white" />
        </div>
        Korba E-Library
      </h1>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
      <!-- Employee section label -->
      <p class="px-3 text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-2">Menu</p>

      <router-link
        v-for="item in navItems"
        :key="item.name"
        :to="item.path"
        class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-150 group"
        :class="[
          $route.path.startsWith(item.path) || $route.path === item.path
            ? 'bg-blue-50 text-primary shadow-sm'
            : 'text-text-muted hover:bg-gray-50 hover:text-text-main'
        ]"
      >
        <component :is="item.icon" class="w-5 h-5 flex-shrink-0 transition-transform group-hover:scale-110" />
        {{ item.name }}

        <!-- Active indicator dot -->
        <span v-if="$route.path === item.path || $route.path.startsWith(item.path)" class="ml-auto w-1.5 h-1.5 rounded-full bg-primary"></span>
      </router-link>

      <!-- Admin section label -->
      <p v-if="authStore.role === 'admin'" class="px-3 text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-5 mb-2">Administration</p>
    </nav>

    <!-- User profile card at bottom -->
    <div class="p-4 border-t border-gray-200">
      <div class="flex items-center gap-3 p-3 rounded-xl bg-gray-50 hover:bg-gray-100 transition-colors cursor-default mb-2">
        <div class="w-9 h-9 rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 text-white flex items-center justify-center font-bold text-sm flex-shrink-0 shadow-sm">
          {{ authStore.initials }}
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-semibold text-text-main truncate">{{ authStore.displayName }}</p>
          <div class="flex items-center gap-1.5 mt-0.5">
            <span class="inline-block w-1.5 h-1.5 rounded-full flex-shrink-0" :class="authStore.role === 'admin' ? 'bg-purple-500' : 'bg-green-500'"></span>
            <p class="text-xs text-text-muted capitalize truncate">{{ authStore.role === 'admin' ? 'Administrator' : 'Employee' }}</p>
          </div>
        </div>
      </div>

      <button @click="handleLogout" class="flex items-center gap-3 px-3 py-2 w-full rounded-xl text-sm font-medium text-gray-500 hover:bg-red-50 hover:text-red-600 transition-colors">
        <LogOutIcon class="w-4 h-4" />
        Sign Out
      </button>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { BookOpenIcon, LayoutDashboardIcon, LibraryIcon, LogOutIcon, UploadIcon, UsersIcon, BarChartIcon, ActivityIcon } from '@lucide/vue'
import { useAuthStore } from '../../stores/auth'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const router = useRouter()

const navItems = computed(() => {
  const items: { name: string; path: string; icon: any }[] = [
    { name: 'Dashboard', path: '/dashboard', icon: LayoutDashboardIcon },
    { name: 'Library', path: '/library', icon: LibraryIcon },
  ]

  if (authStore.role === 'admin') {
    items.push(
      { name: 'Manage Books', path: '/admin/books', icon: UploadIcon },
      { name: 'Employees', path: '/admin/users', icon: UsersIcon },
      { name: 'Reports', path: '/admin/reports', icon: BarChartIcon },
      { name: 'Activity Logs', path: '/admin/activity', icon: ActivityIcon },
    )
  }

  return items
})

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}
</script>
