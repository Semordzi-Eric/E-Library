<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 via-blue-950 to-slate-900 py-12 px-4 relative overflow-hidden">
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <div class="absolute w-96 h-96 rounded-full bg-blue-600 opacity-10 blur-3xl -top-20 -left-20"></div>
      <div class="absolute w-72 h-72 rounded-full bg-purple-600 opacity-10 blur-3xl -bottom-10 -right-10"></div>
    </div>

    <div class="relative z-10 w-full max-w-md">
      <div class="glass-card rounded-2xl p-8 shadow-2xl">
        <!-- Logo -->
        <div class="text-center mb-8">
          <div class="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-blue-600/20 border border-blue-500/30 mb-4">
            <svg class="w-8 h-8 text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
            </svg>
          </div>
          <h1 class="text-2xl font-bold text-white tracking-tight">Set New Password</h1>
          <p class="text-slate-400 text-sm mt-1">Enter your new password below</p>
        </div>

        <!-- Success state -->
        <div v-if="success" class="text-center space-y-4 py-4">
          <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-500/15 border border-green-500/30 mb-2">
            <svg class="w-8 h-8 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
          </div>
          <h3 class="text-white font-semibold text-lg">Password updated!</h3>
          <p class="text-slate-400 text-sm">Your password has been changed. Redirecting you to the app...</p>
        </div>

        <!-- Error: no valid session -->
        <div v-else-if="invalidSession" class="text-center space-y-4 py-4">
          <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-red-500/15 border border-red-500/30 mb-2">
            <svg class="w-8 h-8 text-red-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
          </div>
          <h3 class="text-white font-semibold text-lg">Link expired or invalid</h3>
          <p class="text-slate-400 text-sm">This password reset link has expired or already been used.</p>
          <router-link to="/login" class="auth-btn inline-block text-center mt-4">
            Back to Sign In
          </router-link>
        </div>

        <!-- Reset form -->
        <form v-else @submit.prevent="handleReset" class="space-y-4">
          <div>
            <label class="block text-xs font-medium text-slate-400 mb-1.5">New Password</label>
            <div class="relative">
              <input
                v-model="newPassword"
                :type="showPassword ? 'text' : 'password'"
                required
                minlength="8"
                placeholder="Min. 8 characters"
                class="auth-input pr-10"
              />
              <button type="button" @click="showPassword = !showPassword" class="absolute inset-y-0 right-3 flex items-center text-slate-500 hover:text-slate-300">
                <svg v-if="!showPassword" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                <svg v-else class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
              </button>
            </div>
          </div>
          <div>
            <label class="block text-xs font-medium text-slate-400 mb-1.5">Confirm New Password</label>
            <input
              v-model="confirmPassword"
              :type="showPassword ? 'text' : 'password'"
              required
              minlength="8"
              placeholder="Re-enter password"
              class="auth-input"
            />
          </div>

          <!-- Password strength indicator -->
          <div class="space-y-1">
            <div class="flex gap-1">
              <div v-for="i in 4" :key="i" class="h-1 flex-1 rounded-full transition-all duration-300" :class="strengthColor(i)"></div>
            </div>
            <p class="text-xs text-slate-500">{{ strengthLabel }}</p>
          </div>

          <button type="submit" :disabled="loading || newPassword !== confirmPassword" class="auth-btn">
            <span v-if="loading" class="flex items-center justify-center gap-2">
              <svg class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
              Updating...
            </span>
            <span v-else>Update Password</span>
          </button>

          <p v-if="newPassword && confirmPassword && newPassword !== confirmPassword" class="text-xs text-red-400 text-center">Passwords do not match</p>
          <p v-if="errorMessage" class="error-msg">{{ errorMessage }}</p>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../../services/supabase'
import { useAuthStore } from '../../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const newPassword = ref('')
const confirmPassword = ref('')
const showPassword = ref(false)
const loading = ref(false)
const errorMessage = ref('')
const success = ref(false)
const invalidSession = ref(false)

onMounted(async () => {
  // Supabase redirects with the session in the URL hash after password reset
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) {
    invalidSession.value = true
  }
})

const passwordStrength = computed(() => {
  const p = newPassword.value
  if (!p) return 0
  let score = 0
  if (p.length >= 8) score++
  if (/[A-Z]/.test(p)) score++
  if (/[0-9]/.test(p)) score++
  if (/[^A-Za-z0-9]/.test(p)) score++
  return score
})

const strengthLabel = computed(() => {
  const labels = ['', 'Weak', 'Fair', 'Good', 'Strong']
  return newPassword.value ? labels[passwordStrength.value] : ''
})

const strengthColor = (index: number) => {
  if (!newPassword.value || index > passwordStrength.value) return 'bg-slate-700'
  const colors = ['', 'bg-red-500', 'bg-yellow-500', 'bg-blue-500', 'bg-green-500']
  return colors[passwordStrength.value]
}

const handleReset = async () => {
  if (newPassword.value !== confirmPassword.value) return
  if (newPassword.value.length < 8) {
    errorMessage.value = 'Password must be at least 8 characters.'
    return
  }
  try {
    loading.value = true
    errorMessage.value = ''

    await authStore.updatePassword(newPassword.value)
    success.value = true

    setTimeout(() => {
      router.push('/dashboard')
    }, 2000)
  } catch (error: any) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.glass-card {
  background: rgba(15, 23, 42, 0.7);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.08);
}
.auth-input {
  @apply w-full px-3 py-3 bg-slate-800/60 border border-slate-700/60 rounded-xl text-white text-sm placeholder-slate-500 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500/30 transition-all duration-200;
}
.auth-btn {
  @apply w-full py-3 px-4 bg-blue-600 hover:bg-blue-500 active:scale-[0.98] text-white font-semibold rounded-xl text-sm transition-all duration-200 disabled:opacity-60 disabled:cursor-not-allowed shadow-lg shadow-blue-900/30;
}
.error-msg {
  @apply mt-2 text-center text-sm text-red-400 bg-red-500/10 border border-red-500/20 rounded-lg py-2 px-3;
}
</style>
