<template>
  <div class="h-screen bg-gray-900 flex flex-col overflow-hidden text-white">
    <!-- Reader Top Bar -->
    <header class="h-16 border-b border-gray-700 px-6 flex items-center justify-between shrink-0 bg-gray-900 z-10">
      <div class="flex items-center gap-4">
        <button @click="router.back()" class="p-2 hover:bg-gray-800 rounded-lg transition-colors text-gray-400 hover:text-white">
          <ArrowLeftIcon class="w-5 h-5" />
        </button>
        <div>
          <h1 class="font-bold text-sm line-clamp-1">Reading: {{ bookTitle }}</h1>
          <p class="text-xs text-gray-400">Page {{ currentPage }} of {{ pageCount }}</p>
        </div>
      </div>
      
      <div class="flex items-center gap-4">
        <!-- Controls -->
        <div class="flex items-center bg-gray-800 rounded-lg overflow-hidden border border-gray-700">
          <button @click="zoomOut" class="p-2 hover:bg-gray-700 text-gray-300 transition-colors">
            <ZoomOutIcon class="w-4 h-4" />
          </button>
          <div class="px-3 text-xs font-medium text-gray-300 border-x border-gray-700">
            {{ Math.round(scale * 100) }}%
          </div>
          <button @click="zoomIn" class="p-2 hover:bg-gray-700 text-gray-300 transition-colors">
            <ZoomInIcon class="w-4 h-4" />
          </button>
        </div>
      </div>
    </header>

    <!-- PDF Viewer Area -->
    <main class="flex-1 overflow-auto bg-[#323639] flex justify-center p-4 relative" @scroll="handleScroll">
      <div v-if="loading" class="absolute inset-0 flex items-center justify-center bg-gray-900/50 backdrop-blur-sm z-20">
        <div class="flex flex-col items-center gap-4">
          <Loader2Icon class="w-8 h-8 animate-spin text-primary" />
          <p class="text-sm font-medium">Loading Document...</p>
        </div>
      </div>
      
      <div class="shadow-2xl max-w-full">
        <VuePdfEmbed
          v-if="pdfSource"
          :source="pdfSource"
          :page="currentPage"
          :style="{ transform: `scale(${scale})`, transformOrigin: 'top center' }"
          @loaded="onLoaded"
          class="transition-transform duration-200"
        />
      </div>
    </main>

    <!-- Reader Bottom Bar (Navigation) -->
    <footer class="h-14 border-t border-gray-700 px-6 flex items-center justify-center shrink-0 bg-gray-900 z-10 gap-6">
      <button 
        @click="prevPage" 
        :disabled="currentPage <= 1"
        class="p-2 hover:bg-gray-800 rounded-full transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <ChevronLeftIcon class="w-6 h-6" />
      </button>
      
      <div class="text-sm font-medium text-gray-300 w-24 text-center">
        {{ currentPage }} / {{ pageCount || '?' }}
      </div>

      <button 
        @click="nextPage" 
        :disabled="currentPage >= pageCount"
        class="p-2 hover:bg-gray-800 rounded-full transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <ChevronRightIcon class="w-6 h-6" />
      </button>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import VuePdfEmbed from 'vue-pdf-embed'
import { ArrowLeftIcon, ZoomInIcon, ZoomOutIcon, ChevronLeftIcon, ChevronRightIcon, Loader2Icon } from '@lucide/vue'

// Note: To use pdfjs-dist worker properly in Vite
import * as pdfjsLib from 'pdfjs-dist'
pdfjsLib.GlobalWorkerOptions.workerSrc = `https://cdnjs.cloudflare.com/ajax/libs/pdf.js/${pdfjsLib.version}/pdf.worker.min.js`

const router = useRouter()
const route = useRoute()

const pdfSource = ref('')
const loading = ref(true)
const currentPage = ref(1)
const pageCount = ref(1)
const scale = ref(1.0)
const bookTitle = ref('Loading...')

onMounted(() => {
  // In a real app, fetch the book metadata from Supabase using route.params.id
  // Then use the file_url from the storage bucket to set pdfSource
  const bookId = route.params.id
  bookTitle.value = bookId === '1' ? 'The Effective Executive' : 'Employee Handbook'
  
  // Use a placeholder PDF for demonstration
  pdfSource.value = 'https://raw.githubusercontent.com/mozilla/pdf.js/ba2edeae/web/compressed.tracemonkey-pldi-09.pdf'
})

const onLoaded = (doc: any) => {
  pageCount.value = doc.numPages
  loading.value = false
}

const zoomIn = () => { if (scale.value < 2.5) scale.value += 0.25 }
const zoomOut = () => { if (scale.value > 0.5) scale.value -= 0.25 }
const prevPage = () => { if (currentPage.value > 1) currentPage.value-- }
const nextPage = () => { if (currentPage.value < pageCount.value) currentPage.value++ }

// Simple heartbeat placeholder for analytics
let sessionInterval: any
onMounted(() => {
  sessionInterval = setInterval(() => {
    console.log('Heartbeat: saving reading session...')
  }, 30000)
})

import { onUnmounted } from 'vue'
onUnmounted(() => {
  clearInterval(sessionInterval)
})
</script>
