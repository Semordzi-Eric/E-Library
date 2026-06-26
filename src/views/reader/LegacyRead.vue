<template>
  <div
    class="h-screen bg-gray-900 flex flex-col overflow-hidden text-white select-none"
    @contextmenu.prevent
    @keydown.ctrl.s.prevent
    @keydown.ctrl.p.prevent
    @keydown.meta.s.prevent
    @keydown.meta.p.prevent
    tabindex="0"
    ref="readerEl"
  >
    <!-- Reader Top Bar -->
    <header class="h-14 border-b border-gray-700/60 px-6 flex items-center justify-between shrink-0 bg-gray-900/95 backdrop-blur-sm z-10">
      <div class="flex items-center gap-4">
        <button @click="router.back()" class="p-2 hover:bg-gray-800 active:scale-90 active:bg-gray-700 rounded-lg transition-all text-gray-400 hover:text-white">
          <ArrowLeftIcon class="w-5 h-5" />
        </button>
        <div>
          <h1 class="font-bold text-sm line-clamp-1 text-white">{{ bookTitle }}</h1>
          <p class="text-xs text-gray-400">Page {{ currentPage }} of {{ pageCount || '...' }}</p>
        </div>
      </div>

      <div class="flex items-center gap-3">
        <!-- Progress pill -->
        <div v-if="pageCount > 1" class="hidden sm:flex items-center gap-2 bg-gray-800 rounded-full px-3 py-1.5 border border-gray-700">
          <div class="w-24 h-1.5 bg-gray-700 rounded-full overflow-hidden">
            <div class="h-full bg-blue-500 rounded-full transition-all duration-500" :style="{ width: `${progressPercent}%` }"></div>
          </div>
          <span class="text-xs text-gray-400 font-medium">{{ progressPercent }}%</span>
        </div>

        <!-- Zoom controls -->
        <div class="flex items-center bg-gray-800 rounded-lg overflow-hidden border border-gray-700">
          <button @click="zoomOut" class="p-2 hover:bg-gray-700 active:scale-90 active:bg-gray-600 text-gray-300 transition-all" title="Zoom Out">
            <ZoomOutIcon class="w-4 h-4" />
          </button>
          <div class="px-3 text-xs font-medium text-gray-300 border-x border-gray-700 min-w-[48px] text-center">
            {{ Math.round(scale * 100) }}%
          </div>
          <button @click="zoomIn" class="p-2 hover:bg-gray-700 active:scale-90 active:bg-gray-600 text-gray-300 transition-all" title="Zoom In">
            <ZoomInIcon class="w-4 h-4" />
          </button>
        </div>
      </div>
    </header>

    <!-- PDF Viewer Area -->
    <main
      class="flex-1 overflow-auto bg-[#323639] flex justify-center p-4 relative"
      @contextmenu.prevent
    >
      <!-- Loading overlay -->
      <div v-if="loading" class="absolute inset-0 flex items-center justify-center bg-gray-900/70 backdrop-blur-sm z-20">
        <div class="flex flex-col items-center gap-4">
          <Loader2Icon class="w-8 h-8 animate-spin text-blue-400" />
          <p class="text-sm font-medium text-gray-300">Loading Document (Legacy Engine)...</p>
        </div>
      </div>

      <!-- Error state -->
      <div v-if="loadError" class="absolute inset-0 flex items-center justify-center z-20">
        <div class="text-center space-y-3">
          <div class="w-16 h-16 rounded-full bg-red-500/20 flex items-center justify-center mx-auto">
            <AlertCircleIcon class="w-8 h-8 text-red-400" />
          </div>
          <p class="text-white font-semibold">Failed to load document</p>
          <p class="text-sm text-gray-400">Please try again or contact your administrator.</p>
          <button @click="router.back()" class="mt-2 px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg text-sm transition-colors">
            Go Back
          </button>
        </div>
      </div>

      <!-- PDF embed -->
      <div class="shadow-2xl max-w-full flex items-center justify-center" @contextmenu.prevent>
        <canvas ref="pdfCanvas" class="transition-all duration-200 pointer-events-none" :style="{ width: Math.round(800 * scale) + 'px' }"></canvas>
      </div>
    </main>

    <!-- Reader Bottom Bar (Navigation) -->
    <footer class="h-14 border-t border-gray-700/60 px-6 flex items-center justify-between shrink-0 bg-gray-900/95 backdrop-blur-sm z-10 gap-4">
      <!-- Left: Page jump -->
      <div class="hidden sm:flex items-center gap-2 text-xs text-gray-500">
        <span>Go to page</span>
        <input
          v-model.number="jumpPage"
          type="number"
          :min="1"
          :max="pageCount"
          @keydown.enter="doJumpPage"
          class="w-14 px-2 py-1 bg-gray-800 border border-gray-700 rounded text-gray-300 text-center text-xs focus:outline-none focus:border-blue-500"
        />
      </div>

      <!-- Center: Nav buttons -->
      <div class="flex items-center gap-4 mx-auto">
        <button
          @click="prevPage"
          :disabled="currentPage <= 1 || loading"
          class="p-2 hover:bg-gray-800 active:scale-90 active:bg-gray-700 rounded-full transition-all disabled:opacity-30 disabled:cursor-not-allowed"
        >
          <ChevronLeftIcon class="w-6 h-6" />
        </button>

        <div class="text-sm font-medium text-gray-300 w-28 text-center">
          {{ currentPage }} / {{ pageCount || '?' }}
        </div>

        <button
          @click="nextPage"
          :disabled="currentPage >= pageCount || loading"
          class="p-2 hover:bg-gray-800 active:scale-90 active:bg-gray-700 rounded-full transition-all disabled:opacity-30 disabled:cursor-not-allowed"
        >
          <ChevronRightIcon class="w-6 h-6" />
        </button>
      </div>

      <!-- Right: keyboard hint -->
      <div class="hidden sm:flex items-center gap-1 text-xs text-gray-600">
        <kbd class="px-1.5 py-0.5 bg-gray-800 border border-gray-700 rounded text-gray-500">←</kbd>
        <kbd class="px-1.5 py-0.5 bg-gray-800 border border-gray-700 rounded text-gray-500">→</kbd>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'

import { ArrowLeftIcon, ZoomInIcon, ZoomOutIcon, ChevronLeftIcon, ChevronRightIcon, Loader2Icon, AlertCircleIcon } from '@lucide/vue'
import { useAuthStore } from '../../stores/auth'
import { supabase } from '../../services/supabase'

import * as pdfjsLib from 'pdfjs-dist/legacy/build/pdf.mjs'
import workerSrc from 'pdfjs-dist/legacy/build/pdf.worker.mjs?url'

// Set the worker specifically to the legacy build
pdfjsLib.GlobalWorkerOptions.workerSrc = workerSrc

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const readerEl = ref<HTMLElement | null>(null)
const pdfCanvas = ref<HTMLCanvasElement | null>(null)

let pdfDocument: any = null
let renderTask: any = null

const loading = ref(true)
const loadError = ref(false)
const currentPage = ref(1)
const pageCount = ref(1)
const scale = ref(1.0)
const bookTitle = ref('Loading...')
const jumpPage = ref<number>(1)

let sessionId: string | null = null
let bookId: string = ''
const trackingInterval = 10000 // 10 seconds
let sessionInterval: any
let pageEnterTime = Date.now()

const progressPercent = computed(() => {
  if (pageCount.value <= 1) return 0
  return Math.round((currentPage.value / pageCount.value) * 100)
})

// ── Block keyboard download shortcuts ──
const blockShortcuts = (e: KeyboardEvent) => {
  if ((e.ctrlKey || e.metaKey) && ['s', 'p', 'u'].includes(e.key.toLowerCase())) {
    e.preventDefault()
    e.stopPropagation()
    return false
  }
  // Arrow key navigation
  if (e.key === 'ArrowRight' || e.key === 'ArrowDown') nextPage()
  if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') prevPage()
}

const renderPage = async (num: number) => {
  if (!pdfDocument || !pdfCanvas.value) return
  
  loading.value = true
  
  try {
    const page = await pdfDocument.getPage(num)
    const ctx = pdfCanvas.value.getContext('2d')
    if (!ctx) return
    
    // Hardcoded scale multiplier to render crisp on high DPI screens
    const viewport = page.getViewport({ scale: 2.0 })
    
    pdfCanvas.value.width = viewport.width
    pdfCanvas.value.height = viewport.height
    
    const renderContext = {
      canvasContext: ctx,
      viewport: viewport
    }
    
    // Cancel previous render if exists
    if (renderTask) {
      try { await renderTask.cancel() } catch(e) {}
    }
    
    renderTask = page.render(renderContext)
    await renderTask.promise
    
  } catch (err: any) {
    if (err.name !== 'RenderingCancelledException') {
      console.error('PDF Render Error:', err)
      loadError.value = true
    }
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  bookId = route.params.id as string
  document.addEventListener('keydown', blockShortcuts, true)

  readerEl.value?.focus()

  const { data: book } = await supabase
    .from('books')
    .select('*')
    .eq('id', bookId)
    .single()

  if (book) {
    bookTitle.value = book.title

    if (book.file_url) {
      try {
        const loadingTask = pdfjsLib.getDocument(book.file_url)
        pdfDocument = await loadingTask.promise
        pageCount.value = pdfDocument.numPages
        
        // Wait to set currentPage if we get it from session, otherwise render 1
      } catch (err) {
        console.error('Failed to load PDF via legacy engine:', err)
        loadError.value = true
        loading.value = false
      }
    }

    setTimeout(() => {
      supabase.rpc('increment_reads_count', { book_id: bookId }).then()
    }, 5000)

    if (authStore.user) {
      await supabase.from('audit_logs').insert({
        user_id: authStore.user.id,
        action: 'READ_START',
        resource: book.title
      }).then()
    }
  }

  if (authStore.user) {
    const { data: session } = await supabase
      .from('reading_sessions')
      .select('*')
      .eq('user_id', authStore.user.id)
      .eq('book_id', bookId)
      .single()

    if (session) {
      sessionId = session.id
      currentPage.value = session.current_page || 1
      jumpPage.value = currentPage.value
    } else {
      const { data: newSession } = await supabase
        .from('reading_sessions')
        .insert({
          user_id: authStore.user.id,
          book_id: bookId,
          current_page: 1,
          time_spent_seconds: 0
        })
        .select()
        .single()

      if (newSession) sessionId = newSession.id
    }
  }

  // Render initial page
  if (pdfDocument) {
    await renderPage(currentPage.value)
  }

  pageEnterTime = Date.now()
  sessionInterval = setInterval(syncProgress, trackingInterval)
})

watch(currentPage, async (newVal) => {
  if (pdfDocument) {
    await renderPage(newVal)
  }
})

const zoomIn = () => { if (scale.value < 2.5) scale.value = Math.round((scale.value + 0.25) * 100) / 100 }
const zoomOut = () => { if (scale.value > 0.5) scale.value = Math.round((scale.value - 0.25) * 100) / 100 }

const prevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
    jumpPage.value = currentPage.value
    logPageTurn('prev')
    syncProgress()
  }
}

const nextPage = () => {
  if (currentPage.value < pageCount.value) {
    currentPage.value++
    jumpPage.value = currentPage.value
    logPageTurn('next')
    syncProgress()
  }
}

const doJumpPage = () => {
  const p = Math.max(1, Math.min(pageCount.value, jumpPage.value || 1))
  currentPage.value = p
  jumpPage.value = p
  syncProgress()
}

const logPageTurn = async (direction: string) => {
  if (!authStore.user || !bookTitle.value) return
  const timeOnPage = Math.round((Date.now() - pageEnterTime) / 1000)
  pageEnterTime = Date.now()

  await supabase.from('audit_logs').insert({
    user_id: authStore.user.id,
    action: 'PAGE_TURN',
    resource: `${bookTitle.value} | Page ${currentPage.value} | ${direction} | ${timeOnPage}s`
  }).then()
}

const syncProgress = async () => {
  if (!sessionId || pageCount.value <= 1) return

  await supabase.rpc('update_reading_session', {
    p_session_id: sessionId,
    p_current_page: currentPage.value,
    p_total_pages: pageCount.value,
    p_progress_percentage: progressPercent.value,
    p_time_added: trackingInterval / 1000
  })
}

onUnmounted(() => {
  document.removeEventListener('keydown', blockShortcuts, true)
  clearInterval(sessionInterval)
  syncProgress()
  
  if (renderTask) {
    try { renderTask.cancel() } catch(e) {}
  }

  if (authStore.user && bookTitle.value) {
    supabase.from('audit_logs').insert({
      user_id: authStore.user.id,
      action: 'READ_END',
      resource: `${bookTitle.value} | Page ${currentPage.value}`
    }).then()
  }
})
</script>

<style scoped>
.pointer-events-none {
  -webkit-user-select: none;
  user-select: none;
  pointer-events: none;
}
main::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}
main::-webkit-scrollbar-track { background: #1f2937; }
main::-webkit-scrollbar-thumb { background: #4b5563; border-radius: 3px; }
main::-webkit-scrollbar-thumb:hover { background: #6b7280; }
</style>
