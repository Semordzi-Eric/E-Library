<template>
  <aside 
    :class="[
      'fixed inset-y-0 left-0 z-50 transform transition-all duration-300 md:relative md:translate-x-0 bg-surface border-r border-gray-200 flex flex-col h-full',
      isOpen ? 'translate-x-0' : '-translate-x-full',
      isCollapsed ? 'w-20' : 'w-64'
    ]"
  >
    <!-- Logo -->
    <div class="h-16 flex items-center justify-between px-6 border-b border-gray-200 transition-all duration-300" :class="{ 'px-0 justify-center flex-col gap-1 py-2 h-auto min-h-[64px]': isCollapsed }">
      <h1 v-if="!isCollapsed" class="text-xl font-bold text-text-main flex items-center gap-2">
        <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center">
          <BookOpenIcon class="w-4 h-4 text-white" />
        </div>
        Korba E-Library
      </h1>
      <div v-else class="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center flex-shrink-0" title="Korba E-Library">
        <BookOpenIcon class="w-4 h-4 text-white" />
      </div>

      <button @click="isCollapsed = !isCollapsed" class="hidden md:flex p-1.5 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors" :class="{ 'mt-1': isCollapsed }">
        <ChevronLeftIcon v-if="!isCollapsed" class="w-5 h-5" />
        <ChevronRightIcon v-else class="w-5 h-5" />
      </button>

      <button @click="$emit('close')" class="md:hidden p-2 text-gray-500 hover:bg-gray-100 rounded-lg">
        <XIcon class="w-5 h-5" />
      </button>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
      <!-- Staff section label -->
      <p v-if="!isCollapsed" class="px-3 text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-2">Menu</p>
      <div v-else class="h-4"></div>

      <router-link
        v-for="item in navItems"
        :key="item.name"
        :to="item.path"
        :title="isCollapsed ? item.name : ''"
        class="flex items-center gap-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-150 group active:scale-[0.98] active:bg-gray-100"
        :class="[
          $route.path.startsWith(item.path) || $route.path === item.path
            ? 'bg-blue-50 text-primary shadow-sm'
            : 'text-text-muted hover:bg-gray-50 hover:text-text-main',
          isCollapsed ? 'justify-center px-0' : 'px-3'
        ]"
      >
        <component :is="item.icon" class="w-5 h-5 flex-shrink-0 transition-transform group-hover:scale-110" />
        <span v-if="!isCollapsed">{{ item.name }}</span>

        <!-- Active indicator dot -->
        <span v-if="!isCollapsed && ($route.path === item.path || $route.path.startsWith(item.path))" class="ml-auto w-1.5 h-1.5 rounded-full bg-primary"></span>
      </router-link>

      <!-- Admin section label -->
      <p v-if="authStore.role === 'admin' && !isCollapsed" class="px-3 text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-5 mb-2">Administration</p>
      <div v-if="authStore.role === 'admin' && isCollapsed" class="h-4 border-t border-gray-100 mt-2"></div>
    </nav>

    <!-- User profile card at bottom -->
    <div class="p-4 border-t border-gray-200" :class="{ 'px-2': isCollapsed }">
      <div class="flex items-center gap-3 p-3 rounded-xl bg-gray-50 hover:bg-gray-100 transition-colors cursor-default mb-2" :class="{ 'justify-center px-0 py-2': isCollapsed }" :title="isCollapsed ? authStore.displayName : ''">
        <div class="w-9 h-9 rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 text-white flex items-center justify-center font-bold text-sm flex-shrink-0 shadow-sm">
          {{ authStore.initials }}
        </div>
        <div v-if="!isCollapsed" class="flex-1 min-w-0">
          <p class="text-sm font-semibold text-text-main truncate">{{ authStore.displayName }}</p>
          <div class="flex items-center gap-1.5 mt-0.5">
            <span class="inline-block w-1.5 h-1.5 rounded-full flex-shrink-0" :class="authStore.role === 'admin' ? 'bg-purple-500' : 'bg-green-500'"></span>
            <p class="text-xs text-text-muted capitalize truncate">{{ authStore.role === 'admin' ? 'Administrator' : 'Staff' }}</p>
          </div>
        </div>
      </div>

      <button @click="handleLogout" :title="isCollapsed ? 'Sign Out' : ''" class="flex items-center gap-3 py-2 w-full rounded-xl text-sm font-medium text-gray-500 hover:bg-red-50 hover:text-red-600 transition-colors" :class="{ 'justify-center px-0': isCollapsed, 'px-3': !isCollapsed }">
        <LogOutIcon class="w-4 h-4" />
        <span v-if="!isCollapsed">Sign Out</span>
      </button>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { BookOpenIcon, LayoutDashboardIcon, LibraryIcon, LogOutIcon, UploadIcon, UsersIcon, BarChartIcon, ActivityIcon, XIcon, ChevronLeftIcon, ChevronRightIcon } from '@lucide/vue'
import { useAuthStore } from '../../stores/auth'
import { useRouter } from 'vue-router'

defineProps<{ isOpen: boolean }>()
defineEmits(['close'])

const authStore = useAuthStore()
const router = useRouter()
const isCollapsed = ref(false)

const navItems = computed(() => {
  const items: { name: string; path: string; icon: any }[] = [
    { name: 'Dashboard', path: '/dashboard', icon: LayoutDashboardIcon },
    { name: 'Library', path: '/library', icon: LibraryIcon },
  ]

  if (authStore.role === 'admin') {
    items.push(
      { name: 'Manage Books', path: '/admin/books', icon: UploadIcon },
      { name: 'Staff', path: '/admin/users', icon: UsersIcon },
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
