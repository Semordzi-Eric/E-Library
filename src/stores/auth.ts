import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '../services/supabase'
import type { User } from '@supabase/supabase-js'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const role = ref<'admin' | 'employee' | null>(null)
  const loading = ref(true)

  async function initializeAuth() {
    loading.value = true
    const { data } = await supabase.auth.getSession()
    if (data.session) {
      user.value = data.session.user
      await fetchRole(data.session.user.id)
    }
    
    supabase.auth.onAuthStateChange(async (_event, session) => {
      user.value = session?.user || null
      if (user.value) {
        await fetchRole(user.value.id)
      } else {
        role.value = null
      }
    })
    loading.value = false
  }

  async function fetchRole(userId: string) {
    const { data, error } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', userId)
      .single()
      
    if (data && !error) {
      role.value = data.role as 'admin' | 'employee'
    } else {
      role.value = 'employee' // default fallback
    }
  }

  async function logout() {
    await supabase.auth.signOut()
    user.value = null
    role.value = null
  }

  return {
    user,
    role,
    loading,
    initializeAuth,
    logout
  }
})
