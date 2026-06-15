<template>
  <div class="min-h-screen flex items-center justify-center bg-background py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8 bg-surface p-8 rounded-xl shadow-sm border border-gray-100">
      <div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-text-main">
          HR E-Library
        </h2>
        <p class="mt-2 text-center text-sm text-text-muted">
          {{ isSignUp ? 'Create your employee account' : 'Sign in to access your resources' }}
        </p>
      </div>
      <form class="mt-8 space-y-6" @submit.prevent="handleSubmit">
        <div class="rounded-md shadow-sm -space-y-px">
          
          <!-- Sign Up Extra Fields -->
          <template v-if="isSignUp">
            <div>
              <label for="name" class="sr-only">Full Name</label>
              <input id="name" type="text" required v-model="name" class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-primary focus:border-primary focus:z-10 sm:text-sm" placeholder="Full Name" />
            </div>
            <div>
              <label for="employee-id" class="sr-only">Employee ID</label>
              <input id="employee-id" type="text" required v-model="employeeId" class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-primary focus:border-primary focus:z-10 sm:text-sm" placeholder="Employee ID (e.g., EMP-101)" />
            </div>
            <div>
              <label for="department" class="sr-only">Department</label>
              <input id="department" type="text" required v-model="department" class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-primary focus:border-primary focus:z-10 sm:text-sm" placeholder="Department" />
            </div>
          </template>

          <!-- Email and Password (Used in both) -->
          <div>
            <label for="email-address" class="sr-only">Email address</label>
            <input id="email-address" name="email" type="email" autocomplete="email" required v-model="email" class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-primary focus:border-primary focus:z-10 sm:text-sm" :class="!isSignUp ? 'rounded-t-md' : ''" placeholder="Email address" />
          </div>
          <div>
            <label for="password" class="sr-only">Password</label>
            <input id="password" name="password" type="password" autocomplete="current-password" required v-model="password" class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-primary focus:border-primary focus:z-10 sm:text-sm" placeholder="Password" />
          </div>
        </div>

        <div class="flex items-center justify-between">
          <div class="text-sm">
            <button type="button" @click="isSignUp = !isSignUp" class="font-medium text-primary hover:text-primary-dark">
              {{ isSignUp ? 'Already have an account? Sign in' : 'Need an account? Sign up' }}
            </button>
          </div>
        </div>

        <div>
          <button type="submit" :disabled="loading" class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-primary hover:bg-primary-dark focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary disabled:opacity-50 transition-colors">
            <span class="absolute left-0 inset-y-0 flex items-center pl-3">
              <LockIcon class="h-5 w-5 text-blue-200 group-hover:text-blue-100" aria-hidden="true" />
            </span>
            {{ loading ? 'Processing...' : (isSignUp ? 'Create Account' : 'Sign in') }}
          </button>
        </div>
        
        <p v-if="successMessage" class="mt-2 text-center text-sm text-green-600 font-medium">
          {{ successMessage }}
        </p>
        <p v-if="errorMessage" class="mt-2 text-center text-sm text-red-600">
          {{ errorMessage }}
        </p>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../../services/supabase'
import { LockIcon } from '@lucide/vue'
import { useAuthStore } from '../../stores/auth'

const isSignUp = ref(false)

// Form Fields
const name = ref('')
const employeeId = ref('')
const department = ref('')
const email = ref('')
const password = ref('')

const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const router = useRouter()
const authStore = useAuthStore()

const handleSubmit = async () => {
  if (isSignUp.value) {
    await handleSignUp()
  } else {
    await handleLogin()
  }
}

const handleLogin = async () => {
  try {
    loading.value = true
    errorMessage.value = ''
    successMessage.value = ''
    
    const { error } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })
    
    if (error) throw error
    
    // Explicitly initialize auth to fetch the user role
    await authStore.initializeAuth()
    router.push('/dashboard')
  } catch (error: any) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}

const handleSignUp = async () => {
  try {
    loading.value = true
    errorMessage.value = ''
    successMessage.value = ''
    
    // 1. Create user in Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: email.value,
      password: password.value,
    })
    
    if (authError) throw authError
    
    // 2. If successful, insert their profile data into the profiles table
    if (authData.user) {
      const { error: profileError } = await supabase.from('profiles').insert([
        {
          id: authData.user.id,
          employee_id: employeeId.value,
          name: name.value,
          department: department.value,
          title: 'Employee',
          role: 'employee' // Default role
        }
      ])
      
      if (profileError) {
        console.error("Profile creation error:", profileError)
        throw new Error("Account created, but failed to save profile data. Please contact admin.")
      }
    }
    
    successMessage.value = 'Account created successfully! You can now log in.'
    isSignUp.value = false // Switch back to login view
    
  } catch (error: any) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}
</script>
