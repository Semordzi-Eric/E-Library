<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4">

    <!-- Card -->
    <div class="relative w-full max-w-md">
      <div class="auth-card rounded-2xl p-8">

        <!-- Logo / Brand -->
        <div class="text-center mb-7">
          <div class="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-blue-600 mb-4 shadow-md">
            <svg class="w-7 h-7 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
            </svg>
          </div>
          <h1 class="text-2xl font-bold text-gray-900 tracking-tight">Korba E-Library</h1>
          <p class="text-gray-500 text-sm mt-1">{{ pageSubtitle }}</p>
        </div>

        <!-- Tab switcher -->
        <div v-if="!showOtpInput && !showForgotPassword && !showForgotSuccess" class="flex bg-gray-100 rounded-xl p-1 mb-6">
          <button
            @click="switchToLogin"
            :class="['flex-1 py-2 text-sm font-medium rounded-lg transition-all duration-200', !isSignUp ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500 hover:text-gray-700']"
          >
            Sign In
          </button>
          <button
            @click="switchToSignUp"
            :class="['flex-1 py-2 text-sm font-medium rounded-lg transition-all duration-200', isSignUp ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500 hover:text-gray-700']"
          >
            New Account
          </button>
        </div>

        <!-- ===== SIGN IN FORM ===== -->
        <form v-if="!isSignUp && !showForgotPassword && !showForgotSuccess && !showOtpInput" @submit.prevent="handleLogin" class="space-y-4">
          <div class="space-y-3">
            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1.5">Name or Email</label>
              <input
                id="login-name"
                v-model="loginName"
                type="text"
                required
                placeholder="Full name or work email"
                class="auth-input"
                autocomplete="username"
              />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1.5">Password</label>
              <div class="relative">
                <input
                  id="login-password"
                  v-model="loginPassword"
                  :type="showPassword ? 'text' : 'password'"
                  required
                  placeholder="Enter your password"
                  class="auth-input pr-10"
                />
                <button type="button" @click="showPassword = !showPassword" class="absolute inset-y-0 right-3 flex items-center text-gray-400 hover:text-gray-600">
                  <svg v-if="!showPassword" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                  <svg v-else class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
                </button>
              </div>
            </div>
          </div>

          <div class="flex justify-end">
            <button type="button" @click="showForgotPassword = true" class="text-xs text-blue-600 hover:text-blue-700 font-medium transition-colors">
              Forgot password?
            </button>
          </div>

          <button type="submit" :disabled="loading" class="auth-btn">
            <span v-if="loading" class="flex items-center justify-center gap-2">
              <svg class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
              Signing in...
            </span>
            <span v-else>Sign In</span>
          </button>

          <p v-if="errorMessage" class="error-msg">{{ errorMessage }}</p>
        </form>

        <!-- ===== SIGN UP FORM ===== -->
        <form v-if="isSignUp && !showOtpInput && !showForgotPassword" @submit.prevent="handleSignUp" class="space-y-4">
          <div class="space-y-3">
            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1.5">Full Name *</label>
              <input v-model="signupName" type="text" required placeholder="John Asante" class="auth-input" />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1.5">Department *</label>
              <select v-model="signupDepartment" required class="auth-input">
                <option value="" disabled>Select Department</option>
                <option value="Human Resources">Human Resources</option>
                <option value="Finance">Finance</option>
                <option value="Service Development">Service Development</option>
                <option value="Service Acquisition">Service Acquisition</option>
                <option value="Service Management">Service Management</option>
                <option value="Compliance">Compliance</option>
                <option value="Corporate Business">Corporate Business</option>
                <option value="Retail">Retail</option>
                <option value="Revenue Assurance & Internal Audit">Revenue Assurance & Internal Audit</option>
                <option value="CEO's office">CEO's office</option>
                <option value="Projects">Projects</option>
              </select>
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1.5">Work Email *</label>
              <input v-model="signupEmail" type="email" required placeholder="Your korba Mail" class="auth-input" />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1.5">Password *</label>
              <div class="relative">
                <input v-model="signupPassword" :type="showPassword ? 'text' : 'password'" required placeholder="Min. 8 characters" class="auth-input pr-10" minlength="8" />
                <button type="button" @click="showPassword = !showPassword" class="absolute inset-y-0 right-3 flex items-center text-gray-400 hover:text-gray-600">
                  <svg v-if="!showPassword" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                  <svg v-else class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
                </button>
              </div>
            </div>
          </div>

          <button type="submit" :disabled="loading" class="auth-btn">
            <span v-if="loading" class="flex items-center justify-center gap-2">
              <svg class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
              Creating account...
            </span>
            <span v-else>Create Account</span>
          </button>

          <p v-if="errorMessage" class="error-msg">{{ errorMessage }}</p>
        </form>

        <!-- ===== OTP VERIFICATION SCREEN ===== -->
        <div v-if="showOtpInput" class="space-y-6">
          <div class="text-center">
            <div class="inline-flex items-center justify-center w-14 h-14 rounded-full bg-green-100 border border-green-200 mb-4">
              <svg class="w-7 h-7 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
            </div>
            <h3 class="text-gray-900 font-semibold text-lg">Check your email</h3>
            <p class="text-gray-500 text-sm mt-1">We sent a 6-digit verification code to<br/><span class="text-blue-600 font-medium">{{ signupEmail }}</span></p>
          </div>

          <form @submit.prevent="handleVerifyOtp" class="space-y-4">
            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1.5 text-center">Enter Verification Code</label>
              <input
                v-model="otpCode"
                type="text"
                inputmode="numeric"
                maxlength="6"
                placeholder="000000"
                class="auth-input text-center text-2xl tracking-[0.5em] font-bold"
                required
              />
            </div>
            <button type="submit" :disabled="loading || otpCode.length < 6" class="auth-btn">
              <span v-if="loading" class="flex items-center justify-center gap-2">
                <svg class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
                Verifying...
              </span>
              <span v-else>Verify &amp; Activate Account</span>
            </button>

            <p v-if="errorMessage" class="error-msg">{{ errorMessage }}</p>

            <div class="text-center">
              <button type="button" @click="showOtpInput = false; isSignUp = true; errorMessage = ''" class="text-xs text-gray-400 hover:text-gray-600 transition-colors">
                ← Back to sign up
              </button>
            </div>
          </form>
        </div>

        <!-- ===== FORGOT PASSWORD FORM ===== -->
        <div v-if="showForgotPassword && !showForgotSuccess" class="space-y-4">
          <button @click="showForgotPassword = false; errorMessage = ''" class="flex items-center gap-1.5 text-gray-500 hover:text-gray-800 text-sm transition-colors mb-2">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
            Back to Sign In
          </button>
          <div>
            <h3 class="text-gray-900 font-semibold text-lg mb-1">Reset Password</h3>
            <p class="text-gray-500 text-sm">Enter your work email address and we'll send you a reset link.</p>
          </div>
          <form @submit.prevent="handleForgotPassword" class="space-y-4">
            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1.5">Work Email</label>
              <input v-model="forgotEmail" type="email" required placeholder="you@company.com" class="auth-input" />
            </div>
            <button type="submit" :disabled="loading" class="auth-btn">
              <span v-if="loading" class="flex items-center justify-center gap-2">
                <svg class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
                Sending...
              </span>
              <span v-else>Send Reset Link</span>
            </button>
            <p v-if="errorMessage" class="error-msg">{{ errorMessage }}</p>
          </form>
        </div>

        <!-- ===== FORGOT PASSWORD SUCCESS ===== -->
        <div v-if="showForgotSuccess" class="text-center space-y-4 py-4">
          <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-100 border border-green-200 mb-2">
            <svg class="w-8 h-8 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
          </div>
          <h3 class="text-gray-900 font-semibold text-lg">Reset link sent!</h3>
          <p class="text-gray-500 text-sm">Check your inbox at <span class="text-blue-600 font-medium">{{ forgotEmail }}</span> and follow the link to reset your password.</p>
          <button @click="showForgotSuccess = false; showForgotPassword = false; errorMessage = ''" class="auth-btn mt-4">
            Back to Sign In
          </button>
        </div>

      </div>

      <p class="text-center text-gray-400 text-xs mt-6">© {{ new Date().getFullYear() }} Korba HR Platform. All rights reserved.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../../services/supabase'
import { useAuthStore } from '../../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

// UI State
const isSignUp = ref(false)
const showOtpInput = ref(false)
const showForgotPassword = ref(false)
const showForgotSuccess = ref(false)
const showPassword = ref(false)

// Login fields
const loginName = ref('')
const loginPassword = ref('')

// Sign up fields
const signupName = ref('')
const signupDepartment = ref('')
const signupEmail = ref('')
const signupPassword = ref('')

// OTP field
const otpCode = ref('')

// Forgot password
const forgotEmail = ref('')

// Feedback
const loading = ref(false)
const errorMessage = ref('')

const pageSubtitle = computed(() => {
  if (showOtpInput.value) return 'Verify your email address'
  if (showForgotPassword.value || showForgotSuccess.value) return 'Account recovery'
  return isSignUp.value ? 'Create your staff account' : 'Sign in to access your resources'
})

function switchToLogin() {
  isSignUp.value = false
  errorMessage.value = ''
  showOtpInput.value = false
}

function switchToSignUp() {
  isSignUp.value = true
  errorMessage.value = ''
  showOtpInput.value = false
}

// ── LOGIN: accepts name OR email ──
const handleLogin = async () => {
  const input = loginName.value.trim()
  if (!input) {
    errorMessage.value = 'Please enter your name or email.'
    return
  }
  try {
    loading.value = true
    errorMessage.value = ''

    const isEmail = input.includes('@')
    let emailToUse = ''

    if (isEmail) {
      // Direct email login — use as-is
      emailToUse = input
    } else {
      // Name-based login: look up their email via profile
      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('id')
        .ilike('name', input)
        .limit(1)
        .maybeSingle()  // returns null (not 406) when no row found

      if (profileError) {
        throw new Error('Database error. Please try again or contact your administrator.')
      }
      if (!profileData) {
        throw new Error('No account found with that name. Check your spelling or use your email instead.')
      }

      const { data: emailData, error: emailError } = await supabase
        .rpc('get_user_email_by_profile_id', { p_id: profileData.id })

      if (emailError || !emailData) {
        throw new Error('Could not retrieve account details. Please contact your administrator.')
      }
      emailToUse = emailData
    }

    // Sign in
    const { data, error } = await supabase.auth.signInWithPassword({
      email: emailToUse,
      password: loginPassword.value,
    })

    if (error) {
      if (error.message.toLowerCase().includes('invalid login credentials')) {
        throw new Error('Incorrect password or email. Please try again.')
      }
      throw error
    }

    // Log the login event
    if (data.session) {
      await supabase.from('audit_logs').insert({
        user_id: data.session.user.id,
        action: 'LOGIN',
        resource: 'System'
      }).then()
    }

    await authStore.initializeAuth()
    router.push('/dashboard')
  } catch (error: any) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}

// ── SIGN UP: create account, send OTP ──
const handleSignUp = async () => {
  if (!signupName.value.trim()) {
    errorMessage.value = 'Full name is required.'
    return
  }

  // Check name uniqueness before proceeding
  const { data: existing, error: nameCheckError } = await supabase
    .from('profiles')
    .select('id')
    .ilike('name', signupName.value.trim())
    .limit(1)
    .maybeSingle()  // returns null (not 406) when no match

  if (!nameCheckError && existing) {
    errorMessage.value = 'An account with this name already exists. If this is you, please sign in.'
    return
  }

  try {
    loading.value = true
    errorMessage.value = ''

    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: signupEmail.value,
      password: signupPassword.value,
      options: {
        data: {
          name: signupName.value.trim(),
          department: signupDepartment.value
        }
      }
    })

    if (authError) throw authError

    if (authData.session) {
      // Email confirmation is turned off in Supabase — user is already logged in!
      await authStore.initializeAuth()
      router.push('/dashboard')
    } else {
      // Email confirmation is turned on — show OTP screen or ask to check email
      showOtpInput.value = true
      isSignUp.value = false
    }

  } catch (error: any) {
    if (error.message?.includes('already registered')) {
      errorMessage.value = 'This email is already registered. Please sign in instead.'
    } else {
      errorMessage.value = error.message
    }
  } finally {
    loading.value = false
  }
}

// ── OTP VERIFICATION ──
const handleVerifyOtp = async () => {
  try {
    loading.value = true
    errorMessage.value = ''

    const { data: verifyData, error } = await supabase.auth.verifyOtp({
      email: signupEmail.value,
      token: otpCode.value,
      type: 'signup'
    })

    if (error) throw error

    // Insert profile now that the user is fully authenticated
    if (verifyData?.user) {
      const { error: profileError } = await supabase.from('profiles').insert([{
        id: verifyData.user.id,
        employee_id: `EMP-${verifyData.user.id.substring(0, 8).toUpperCase()}`,
        name: signupName.value.trim(),
        department: signupDepartment.value,
        title: 'Staff',
        role: 'employee'
      }])
      
      if (profileError) {
        console.error('Profile creation error during OTP verification:', profileError)
      }
    }

    // OTP verified — sign them in automatically
    await authStore.initializeAuth()
    router.push('/dashboard')

  } catch (error: any) {
    if (error.message?.includes('expired') || error.message?.includes('invalid')) {
      errorMessage.value = 'Invalid or expired code. Please request a new one.'
    } else {
      errorMessage.value = error.message
    }
  } finally {
    loading.value = false
  }
}

// ── FORGOT PASSWORD ──
const handleForgotPassword = async () => {
  try {
    loading.value = true
    errorMessage.value = ''

    await authStore.resetPasswordForEmail(forgotEmail.value)
    showForgotSuccess.value = true
    showForgotPassword.value = false

  } catch (error: any) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* Card */
.auth-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.07), 0 10px 40px -10px rgba(0,0,0,0.12);
}

/* Input */
.auth-input {
  @apply w-full px-3 py-2.5 bg-white border border-gray-300 rounded-xl text-gray-900 text-sm placeholder-gray-400
         focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 transition-all duration-200;
}

/* Button */
.auth-btn {
  @apply w-full py-2.5 px-4 bg-blue-600 hover:bg-blue-700 active:scale-[0.98] text-white font-semibold
         rounded-xl text-sm transition-all duration-200 disabled:opacity-60 disabled:cursor-not-allowed shadow-sm;
}

/* Error message */
.error-msg {
  @apply mt-2 text-center text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg py-2 px-3;
}
</style>
