import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '../services/supabase'
import type { User } from '@supabase/supabase-js'

export interface UserProfile {
  id: string
  name: string | null
  employee_id: string | null
  department: string | null
  title: string | null
  role: 'admin' | 'employee'
  created_at: string
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const profile = ref<UserProfile | null>(null)
  const loading = ref(true)

  const role = computed(() => profile.value?.role ?? null)
  const displayName = computed(() => profile.value?.name || user.value?.email || 'User')
  const greetingName = computed(() => {
    if (profile.value?.name) {
      return profile.value.name.trim().split(' ')[0]
    }
    if (user.value?.email) {
      return user.value.email.split('@')[0]
    }
    return 'User'
  })
  const initials = computed(() => {
    const name = displayName.value
    const parts = name.trim().split(' ')
    if (parts.length >= 2) return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
    return name.substring(0, 2).toUpperCase()
  })

  async function initializeAuth() {
    loading.value = true
    const { data } = await supabase.auth.getSession()
    if (data.session) {
      user.value = data.session.user
      await fetchProfile(data.session.user.id)
    }

    supabase.auth.onAuthStateChange(async (_event, session) => {
      user.value = session?.user || null
      if (user.value) {
        await fetchProfile(user.value.id)
      } else {
        profile.value = null
      }
    })
    loading.value = false
  }

  async function fetchProfile(userId: string) {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single()

    if (data && !error) {
      profile.value = data as UserProfile
    } else {
      // Profile missing (likely verified via email link). Auto-create using metadata.
      const meta = user.value?.user_metadata || {}
      
      const newProfile = {
        id: userId,
        employee_id: `EMP-${userId.substring(0, 8).toUpperCase()}`,
        name: meta.name || null,
        department: meta.department || null,
        title: 'Staff',
        role: 'employee'
      }
      
      const { data: inserted, error: insertError } = await supabase
        .from('profiles')
        .insert([newProfile])
        .select()
        .single()
        
      if (inserted && !insertError) {
        profile.value = inserted as UserProfile
      } else {
        // Fallback if insert fails
        profile.value = {
          ...newProfile,
          employee_id: null,
          created_at: new Date().toISOString()
        } as UserProfile
      }
    }
  }

  async function logout() {
    await supabase.auth.signOut()
    user.value = null
    profile.value = null
  }

  async function updatePassword(newPassword: string) {
    const { error } = await supabase.auth.updateUser({ password: newPassword })
    if (error) throw error
  }

  async function resetPasswordForEmail(email: string) {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`
    })
    if (error) throw error
  }

  return {
    user,
    profile,
    role,
    displayName,
    greetingName,
    initials,
    loading,
    initializeAuth,
    fetchProfile,
    logout,
    updatePassword,
    resetPasswordForEmail
  }
})
