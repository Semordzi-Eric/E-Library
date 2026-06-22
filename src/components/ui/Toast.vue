<template>
  <div class="fixed top-4 right-4 z-50 flex flex-col gap-2 pointer-events-none">
    <TransitionGroup name="toast">
      <div 
        v-for="toast in toastStore.toasts" 
        :key="toast.id"
        class="pointer-events-auto flex items-center p-4 mb-2 w-full max-w-sm text-gray-900 bg-white rounded-lg shadow-lg border-l-4"
        :class="{
          'border-green-500': toast.type === 'success',
          'border-red-500': toast.type === 'error',
          'border-blue-500': toast.type === 'info'
        }"
        role="alert"
      >
        <div class="inline-flex items-center justify-center shrink-0 w-8 h-8 rounded-lg"
          :class="{
            'text-green-500 bg-green-100': toast.type === 'success',
            'text-red-500 bg-red-100': toast.type === 'error',
            'text-blue-500 bg-blue-100': toast.type === 'info'
          }">
          <CheckCircleIcon v-if="toast.type === 'success'" class="w-5 h-5" />
          <AlertCircleIcon v-if="toast.type === 'error'" class="w-5 h-5" />
          <InfoIcon v-if="toast.type === 'info'" class="w-5 h-5" />
        </div>
        <div class="ml-3 text-sm font-medium">{{ toast.message }}</div>
        <button 
          @click="toastStore.removeToast(toast.id)" 
          type="button" 
          class="ml-auto -mx-1.5 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg p-1.5 hover:bg-gray-100 inline-flex items-center justify-center h-8 w-8 transition-colors"
        >
          <XIcon class="w-4 h-4" />
        </button>
      </div>
    </TransitionGroup>
  </div>
</template>

<script setup lang="ts">
import { useToastStore } from '../../stores/toast'
import { CheckCircleIcon, AlertCircleIcon, InfoIcon, XIcon } from '@lucide/vue'

const toastStore = useToastStore()
</script>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}
.toast-enter-from {
  opacity: 0;
  transform: translateX(30px);
}
.toast-leave-to {
  opacity: 0;
  transform: translateY(-30px);
}
</style>
