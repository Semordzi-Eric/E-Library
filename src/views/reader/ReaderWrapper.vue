<template>
  <ModernReader v-if="isModern" />
  <LegacyReader v-else-if="isLegacy" />
  
  <div v-else class="h-screen bg-gray-900 flex items-center justify-center text-white">
    <div class="flex flex-col items-center gap-4">
      <svg class="w-8 h-8 animate-spin text-blue-400" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
      <p class="text-sm font-medium text-gray-300">Initializing Reader...</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, defineAsyncComponent } from 'vue'

const ModernReader = defineAsyncComponent(() => import('./Read.vue'))
const LegacyReader = defineAsyncComponent(() => import('./LegacyRead.vue'))

const isModern = ref(false)
const isLegacy = ref(false)

const checkBrowser = () => {
  try {
    // PDF.js v4+ relies heavily on modern features like Promise.withResolvers and private fields.
    // Checking for Promise.withResolvers is a good proxy for Safari 17.4+ / modern browsers.
    return typeof (Promise as any).withResolvers !== 'undefined'
  } catch (e) {
    return false
  }
}

onMounted(() => {
  if (checkBrowser()) {
    isModern.value = true
  } else {
    isLegacy.value = true
  }
})
</script>
