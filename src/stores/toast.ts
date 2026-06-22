import { defineStore } from 'pinia'
import { ref } from 'vue'

export type ToastType = 'success' | 'error' | 'info'

export interface Toast {
  id: string
  message: string
  type: ToastType
}

export const useToastStore = defineStore('toast', () => {
  const toasts = ref<Toast[]>([])

  const addToast = (message: string, type: ToastType = 'info') => {
    const id = Math.random().toString(36).substring(2, 9)
    toasts.value.push({ id, message, type })
    
    setTimeout(() => {
      removeToast(id)
    }, 5000)
  }

  const removeToast = (id: string) => {
    toasts.value = toasts.value.filter(t => t.id !== id)
  }

  const success = (msg: string) => addToast(msg, 'success')
  const error = (msg: string) => addToast(msg, 'error')
  const info = (msg: string) => addToast(msg, 'info')

  return { toasts, addToast, removeToast, success, error, info }
})
