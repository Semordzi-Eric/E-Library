<template>
  <header class="h-16 bg-surface border-b border-gray-200 flex items-center justify-between px-6 relative z-50">
    <!-- Search -->
    <div class="flex-1 max-w-xl">
      <div class="relative">
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <SearchIcon class="h-4 w-4 text-gray-400" />
        </div>
        <input
          v-model="libraryStore.searchQuery"
          type="text"
          placeholder="Search books or authors..."
          class="block w-full pl-10 pr-3 py-2 border border-gray-200 rounded-lg leading-5 bg-gray-50 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary sm:text-sm transition-all"
        />
      </div>
    </div>

    <!-- Right side -->
    <div class="flex items-center gap-3 ml-6">
      <!-- Notification bell -->
      <button class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors relative">
        <BellIcon class="h-5 w-5" />
        <span class="absolute top-1.5 right-1.5 block h-2 w-2 rounded-full bg-red-500 ring-2 ring-white"></span>
      </button>

      <!-- User avatar + dropdown -->
      <div class="relative" ref="dropdownRef">
        <button
          @click="dropdownOpen = !dropdownOpen"
          class="flex items-center gap-3 pl-3 border-l border-gray-200 hover:opacity-80 transition-opacity"
        >
          <div class="w-9 h-9 rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 text-white flex items-center justify-center font-bold text-sm shadow-sm">
            {{ authStore.initials }}
          </div>
          <div class="hidden md:block text-left">
            <p class="text-sm font-semibold text-text-main leading-tight">{{ authStore.displayName }}</p>
            <p class="text-xs text-text-muted capitalize">{{ roleLabel }}</p>
          </div>
          <ChevronDownIcon class="hidden md:block w-4 h-4 text-gray-400 transition-transform duration-200" :class="{ 'rotate-180': dropdownOpen }" />
        </button>

        <!-- Dropdown menu -->
        <Transition name="dropdown">
          <div v-if="dropdownOpen" class="absolute right-0 mt-2 w-56 bg-white rounded-xl shadow-xl border border-gray-100 py-2 overflow-hidden">
            <div class="px-4 py-3 border-b border-gray-100">
              <p class="text-sm font-semibold text-gray-900 truncate">{{ authStore.displayName }}</p>
              <p class="text-xs text-gray-500 mt-0.5">{{ authStore.profile?.department || 'Staff' }}</p>
              <span class="inline-flex items-center mt-1.5 px-2 py-0.5 rounded-full text-xs font-medium" :class="authStore.role === 'admin' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'">
                {{ roleLabel }}
              </span>
            </div>

            <button @click="openChangePassword" class="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors">
              <KeyIcon class="w-4 h-4 text-gray-400" />
              Change Password
            </button>

            <div class="my-1 border-t border-gray-100"></div>

            <button @click="handleLogout" class="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 transition-colors">
              <LogOutIcon class="w-4 h-4" />
              Sign Out
            </button>
          </div>
        </Transition>
      </div>
    </div>
  </header>

  <!-- Change Password Modal -->
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="showChangePassword" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeChangePassword"></div>
        <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6">
          <div class="flex items-center justify-between mb-5">
            <h3 class="text-lg font-bold text-gray-900">Change Password</h3>
            <button @click="closeChangePassword" class="p-1 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors">
              <XIcon class="w-5 h-5" />
            </button>
          </div>

          <form @submit.prevent="submitChangePassword" class="space-y-4">
            <div>
              <label class="block text-xs font-medium text-gray-500 mb-1.5">New Password</label>
              <div class="relative">
                <input
                  v-model="cpNewPassword"
                  :type="cpShowPw ? 'text' : 'password'"
                  required
                  minlength="8"
                  placeholder="Min. 8 characters"
                  class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 transition-all pr-10"
                />
                <button type="button" @click="cpShowPw = !cpShowPw" class="absolute inset-y-0 right-3 flex items-center text-gray-400 hover:text-gray-600">
                  <EyeIcon v-if="!cpShowPw" class="w-4 h-4" />
                  <EyeOffIcon v-else class="w-4 h-4" />
                </button>
              </div>
            </div>
            <div>
              <label class="block text-xs font-medium text-gray-500 mb-1.5">Confirm New Password</label>
              <input
                v-model="cpConfirmPassword"
                :type="cpShowPw ? 'text' : 'password'"
                required
                minlength="8"
                placeholder="Re-enter password"
                class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/20 transition-all"
              />
            </div>
            <p v-if="cpNewPassword && cpConfirmPassword && cpNewPassword !== cpConfirmPassword" class="text-xs text-red-500">Passwords do not match</p>
            <p v-if="cpError" class="text-xs text-red-500 bg-red-50 rounded-lg py-2 px-3">{{ cpError }}</p>
            <p v-if="cpSuccess" class="text-xs text-green-600 bg-green-50 rounded-lg py-2 px-3">{{ cpSuccess }}</p>

            <button
              type="submit"
              :disabled="cpLoading || (cpNewPassword !== cpConfirmPassword)"
              class="w-full py-2.5 px-4 bg-primary hover:bg-primary-dark text-white font-semibold rounded-xl text-sm transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="cpLoading">Updating...</span>
              <span v-else>Update Password</span>
            </button>
          </form>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { SearchIcon, BellIcon, ChevronDownIcon, LogOutIcon, KeyIcon, XIcon, EyeIcon, EyeOffIcon } from '@lucide/vue'
import { useAuthStore } from '../../stores/auth'
import { useLibraryStore } from '../../stores/library'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const libraryStore = useLibraryStore()
const router = useRouter()

const dropdownOpen = ref(false)
const dropdownRef = ref<HTMLElement | null>(null)

const roleLabel = computed(() => {
  const r = authStore.role
  if (r === 'admin') return 'Administrator'
  return 'Staff'
})

// Close dropdown when clicking outside
const handleClickOutside = (e: MouseEvent) => {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target as Node)) {
    dropdownOpen.value = false
  }
}
onMounted(() => document.addEventListener('mousedown', handleClickOutside))
onUnmounted(() => document.removeEventListener('mousedown', handleClickOutside))

const handleLogout = async () => {
  dropdownOpen.value = false
  await authStore.logout()
  router.push('/login')
}

// ── Change Password Modal ──
const showChangePassword = ref(false)
const cpNewPassword = ref('')
const cpConfirmPassword = ref('')
const cpShowPw = ref(false)
const cpLoading = ref(false)
const cpError = ref('')
const cpSuccess = ref('')

const openChangePassword = () => {
  dropdownOpen.value = false
  showChangePassword.value = true
  cpNewPassword.value = ''
  cpConfirmPassword.value = ''
  cpError.value = ''
  cpSuccess.value = ''
}

const closeChangePassword = () => {
  showChangePassword.value = false
}

const submitChangePassword = async () => {
  if (cpNewPassword.value !== cpConfirmPassword.value) return
  try {
    cpLoading.value = true
    cpError.value = ''
    cpSuccess.value = ''
    await authStore.updatePassword(cpNewPassword.value)
    cpSuccess.value = 'Password updated successfully!'
    setTimeout(() => closeChangePassword(), 1800)
  } catch (err: any) {
    cpError.value = err.message
  } finally {
    cpLoading.value = false
  }
}
</script>

<style scoped>
.dropdown-enter-active,
.dropdown-leave-active {
  transition: all 0.15s ease;
  transform-origin: top right;
}
.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: scale(0.95) translateY(-4px);
}

.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s ease;
}
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
</style>
