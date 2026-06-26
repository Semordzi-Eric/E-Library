<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h2 class="text-2xl font-bold text-text-main">Manage Books</h2>
      <button @click="openUploadModal" class="bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded-lg font-medium flex items-center gap-2 transition-colors">
        <PlusIcon class="w-5 h-5" />
        Upload New Book
      </button>
    </div>

    <!-- Data Table -->
    <div class="bg-surface border border-gray-200 rounded-xl shadow-sm overflow-hidden">
      <div v-if="loadingBooks" class="p-6">
        <div class="space-y-4">
          <div v-for="n in 5" :key="n" class="animate-pulse flex items-center gap-4">
            <div class="h-12 w-8 bg-gray-200 rounded"></div>
            <div class="flex-1 space-y-2">
              <div class="h-4 bg-gray-200 rounded w-1/4"></div>
              <div class="h-3 bg-gray-200 rounded w-1/6"></div>
            </div>
            <div class="h-6 bg-gray-200 rounded-full w-24"></div>
            <div class="h-4 bg-gray-200 rounded w-20"></div>
          </div>
        </div>
      </div>
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Book Details</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Category</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Stats</th>
            <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-text-muted uppercase tracking-wider sticky right-0 bg-gray-50 z-10">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-if="books.length === 0">
            <td colspan="4" class="px-6 py-12 text-center">
              <div class="flex flex-col items-center justify-center text-gray-500">
                <div class="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center mb-3">
                  <PlusIcon class="w-6 h-6 text-gray-400" />
                </div>
                <p class="text-lg font-medium text-gray-900">No books found</p>
                <p class="text-sm mt-1 mb-4">You haven't uploaded any books yet.</p>
                <button @click="openUploadModal" class="text-sm text-primary font-semibold hover:underline">Upload your first book</button>
              </div>
            </td>
          </tr>
          <tr v-for="book in books" :key="book.id" class="hover:bg-gray-50 transition-colors group">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex items-center">
                <div class="flex-shrink-0 h-12 w-8 bg-gray-200 rounded overflow-hidden">
                  <img v-if="book.cover_url" :src="book.cover_url" loading="lazy" class="h-full w-full object-cover" />
                </div>
                <div class="ml-4">
                  <div class="text-sm font-bold text-text-main">{{ book.title }}</div>
                  <div class="text-sm text-text-muted mb-1">{{ book.author }}</div>
                  <!-- Mobile only actions -->
                  <div class="flex items-center gap-3 sm:hidden mt-1">
                    <button @click="openEditModal(book)" class="text-xs text-primary hover:text-primary-dark font-medium">Edit</button>
                    <button @click="deleteBook(book.id)" class="text-xs text-red-600 hover:text-red-900 font-medium">Delete</button>
                  </div>
                </div>
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                {{ book.category }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-text-muted">
              <div>{{ book.reads_count || 0 }} Reads</div>
              <div>{{ book.downloads_count || 0 }} Downloads</div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium sticky right-0 bg-white z-10 border-l border-gray-50">
              <div class="flex items-center justify-end gap-3">
                <button @click="openEditModal(book)" class="text-primary hover:text-primary-dark font-semibold transition-colors">Edit</button>
                <button @click="deleteBook(book.id)" class="text-red-600 hover:text-red-900 transition-colors">Delete</button>
              </div>
            </td>
          </tr>
        </tbody>
        </table>
      </div>
      
      <div v-if="hasMore && !loadingBooks" class="p-4 flex justify-center border-t border-gray-200">
        <button 
          @click="fetchBooks(true)" 
          :disabled="loadingMore"
          class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary disabled:opacity-50"
        >
          {{ loadingMore ? 'Loading...' : 'Load More Books' }}
        </button>
      </div>
    </div>

    <!-- Upload Modal -->
    <div v-if="showUploadModal" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="closeModal"></div>
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
        
        <div class="inline-block align-bottom bg-surface rounded-xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full">
          <div class="bg-surface px-4 pt-5 pb-4 sm:p-6 sm:pb-4 border-b border-gray-200">
            <h3 class="text-lg leading-6 font-bold text-text-main" id="modal-title">{{ isEditing ? 'Edit Book' : 'Upload New Book' }}</h3>
          </div>
          
          <form @submit.prevent="uploadBook" class="p-6 space-y-6">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <div class="col-span-1 sm:col-span-2">
                <label class="block text-sm font-medium text-text-main mb-1">Title</label>
                <input v-model.trim="form.title" type="text" required class="block w-full border border-gray-300 rounded-lg py-2.5 px-3 focus:ring-primary focus:border-primary">
              </div>
              <div>
                <label class="block text-sm font-medium text-text-main mb-1">Author</label>
                <input v-model.trim="form.author" type="text" required class="block w-full border border-gray-300 rounded-lg py-2.5 px-3 focus:ring-primary focus:border-primary">
              </div>
              <div>
                <label class="block text-sm font-medium text-text-main mb-1">Category</label>
                <select v-model="form.category" required class="block w-full border border-gray-300 rounded-lg py-2.5 px-3 focus:ring-primary focus:border-primary">
                  <option value="Personal Development">Personal Development</option>
                  <option value="Leadership">Leadership</option>
                  <option value="Productivity">Productivity</option>
                  <option value="Finance">Finance</option>
                  <option value="Wellness">Wellness</option>
                  <option value="Career Growth">Career Growth</option>
                </select>
              </div>
              <div class="col-span-1 sm:col-span-2">
                <label class="block text-sm font-medium text-text-main mb-1">Description</label>
                <textarea v-model.trim="form.description" rows="3" class="block w-full border border-gray-300 rounded-lg py-2 px-3 focus:ring-primary focus:border-primary"></textarea>
              </div>
              <div class="col-span-1 sm:col-span-2">
                <label class="block text-sm font-medium text-text-main mb-1">PDF File <span v-if="isEditing" class="text-gray-400 font-normal">(Leave empty to keep current)</span></label>
                <div class="relative">
                  <input @change="handlePdfChange" :required="!isEditing" type="file" accept="application/pdf" class="block w-full text-sm text-gray-500 file:mr-4 file:py-2.5 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-primary hover:file:bg-blue-100">
                  <div v-if="isExtracting" class="absolute right-2 top-2 text-sm text-blue-600 flex items-center bg-white px-2 py-1 rounded shadow-sm border border-blue-100">
                    <svg class="animate-spin w-4 h-4 mr-1.5" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
                    Extracting book info...
                  </div>
                </div>
              </div>
              <div class="col-span-1 sm:col-span-2">
                <label class="block text-sm font-medium text-text-main mb-1">Cover Image (Optional)</label>
                <div class="flex items-center gap-4">
                  <input @change="handleCoverChange" type="file" accept="image/*" class="block w-full text-sm text-gray-500 file:mr-4 file:py-2.5 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-primary hover:file:bg-blue-100">
                  <div v-if="coverPreviewUrl" class="flex items-center gap-2 flex-shrink-0">
                    <img :src="coverPreviewUrl" loading="lazy" class="h-16 w-12 object-cover rounded shadow border border-gray-200" alt="Cover preview" />
                    <span class="text-xs text-green-600 font-medium bg-green-50 px-2 py-1 rounded-md">Cover ready</span>
                  </div>
                </div>
              </div>
              <div class="col-span-1 sm:col-span-2 flex items-center mt-2">
                <input v-model="form.allowDownload" type="checkbox" id="download" class="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded">
                <label for="download" class="ml-2 block text-sm text-text-main">Allow staff to download this file</label>
              </div>
            </div>
            
            <div v-if="uploadError" class="text-sm text-red-600 mt-2">{{ uploadError }}</div>
            
            <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse -mx-6 -mb-6 mt-6 border-t border-gray-200">
              <button type="submit" :disabled="uploading" class="w-full inline-flex justify-center rounded-lg border border-transparent shadow-sm px-4 py-2 bg-primary text-base font-medium text-white hover:bg-primary-dark focus:outline-none disabled:opacity-50 sm:ml-3 sm:w-auto sm:text-sm">
                {{ uploading ? 'Saving...' : (isEditing ? 'Save Changes' : 'Upload & Save') }}
              </button>
              <button @click="closeModal" type="button" :disabled="uploading" class="mt-3 w-full inline-flex justify-center rounded-lg border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none disabled:opacity-50 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { PlusIcon } from '@lucide/vue'
import { supabase } from '../../services/supabase'

import { useToastStore } from '../../stores/toast'
import * as pdfjsLib from 'pdfjs-dist'
import workerSrc from 'pdfjs-dist/build/pdf.worker.mjs?url'

// Initialize PDF.js worker
pdfjsLib.GlobalWorkerOptions.workerSrc = workerSrc || `https://cdnjs.cloudflare.com/ajax/libs/pdf.js/${pdfjsLib.version}/pdf.worker.min.mjs`

const toastStore = useToastStore()
const showUploadModal = ref(false)
const books = ref<any[]>([])
const loadingBooks = ref(true)
const loadingMore = ref(false)
const page = ref(0)
const PAGE_SIZE = 50
const hasMore = ref(true)

const uploading = ref(false)
const uploadError = ref('')
const isExtracting = ref(false)
const coverPreviewUrl = ref('')

const form = ref({
  title: '',
  author: '',
  category: 'Personal Development',
  description: '',
  allowDownload: false
})

const coverFile = ref<File | null>(null)
const pdfFile = ref<File | null>(null)

const isEditing = ref(false)
const editingBookId = ref<string | null>(null)

const openUploadModal = () => {
  isEditing.value = false
  editingBookId.value = null
  form.value = { title: '', author: '', category: 'Personal Development', description: '', allowDownload: false }
  coverPreviewUrl.value = ''
  coverFile.value = null
  pdfFile.value = null
  showUploadModal.value = true
}

const openEditModal = (book: any) => {
  isEditing.value = true
  editingBookId.value = book.id
  form.value = { 
    title: book.title, 
    author: book.author, 
    category: book.category || 'Personal Development', 
    description: book.description || '', 
    allowDownload: book.download_allowed 
  }
  coverPreviewUrl.value = book.cover_url || ''
  coverFile.value = null
  pdfFile.value = null
  showUploadModal.value = true
}

const fetchBooks = async (isLoadMore = false) => {
  if (isLoadMore) {
    loadingMore.value = true
    page.value++
  } else {
    loadingBooks.value = true
    page.value = 0
    books.value = []
  }

  const from = page.value * PAGE_SIZE
  const to = from + PAGE_SIZE - 1

  const { data, count, error } = await supabase
    .from('books')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, to)
    
  if (data) {
    const bookIds = data.map(b => b.id)
    
    // Fetch stats
    const { data: sessions } = await supabase.from('reading_sessions').select('book_id').in('book_id', bookIds)
    const { data: downloads } = await supabase.from('downloads').select('book_id').in('book_id', bookIds)

    const sessionCounts = (sessions || []).reduce((acc, curr) => {
      acc[curr.book_id] = (acc[curr.book_id] || 0) + 1
      return acc
    }, {} as Record<string, number>)

    const downloadCounts = (downloads || []).reduce((acc, curr) => {
      acc[curr.book_id] = (acc[curr.book_id] || 0) + 1
      return acc
    }, {} as Record<string, number>)

    const enrichedBooks = data.map(b => ({
      ...b,
      reads_count: sessionCounts[b.id] || 0,
      downloads_count: downloadCounts[b.id] || 0
    }))

    books.value = isLoadMore ? [...books.value, ...enrichedBooks] : enrichedBooks
    hasMore.value = count ? (from + data.length) < count : false
  }
  if (error) toastStore.error(error.message)
  
  loadingBooks.value = false
  loadingMore.value = false
}

onMounted(() => {
  fetchBooks()
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})

const handleKeydown = (e: KeyboardEvent) => {
  if (e.key === 'Escape' && showUploadModal.value) {
    closeModal()
  }
}

const handleCoverChange = (e: Event) => {
  const target = e.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    coverFile.value = target.files[0]
    if (coverPreviewUrl.value) URL.revokeObjectURL(coverPreviewUrl.value)
    coverPreviewUrl.value = URL.createObjectURL(target.files[0])
  }
}

const handlePdfChange = async (e: Event) => {
  const target = e.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    pdfFile.value = target.files[0]
    await extractPdfInfo(target.files[0])
  }
}

const extractPdfInfo = async (file: File) => {
  try {
    isExtracting.value = true
    const arrayBuffer = await file.arrayBuffer()
    const loadingTask = pdfjsLib.getDocument({ data: arrayBuffer })
    const pdf = await loadingTask.promise
    
    // Extract metadata
    const metadata = await pdf.getMetadata()
    let hasTitle = false
    if (metadata?.info) {
      const info = metadata.info as any;
      if (info.Title) {
        form.value.title = info.Title
        hasTitle = true
      }
      if (info.Author) form.value.author = info.Author
    }
    
    // Fallback to filename if no embedded title
    if (!hasTitle) {
      form.value.title = file.name.replace(/\.pdf$/i, '').replace(/[-_]/g, ' ')
    }

    // Render Cover Page
    const page = await pdf.getPage(1)
    const viewport = page.getViewport({ scale: 1.5 })
    
    const canvas = document.createElement('canvas')
    const ctx = canvas.getContext('2d')
    canvas.width = viewport.width
    canvas.height = viewport.height
    
    if (ctx) {
      await page.render({ canvasContext: ctx, viewport } as any).promise
      
      const blob = await new Promise<Blob | null>(resolve => canvas.toBlob(resolve, 'image/jpeg', 0.8))
      if (blob) {
        const generatedCover = new File([blob], 'cover.jpg', { type: 'image/jpeg' })
        coverFile.value = generatedCover
        if (coverPreviewUrl.value) URL.revokeObjectURL(coverPreviewUrl.value)
        coverPreviewUrl.value = URL.createObjectURL(blob)
      }
    }

    // Extract some text for description
    const textContent = await page.getTextContent()
    const textItems = textContent.items.map((item: any) => item.str).join(' ')
    const snippet = textItems.substring(0, 500).trim()
    if (snippet && !form.value.description) {
      form.value.description = snippet + (textItems.length >= 500 ? '...' : '')
    }

  } catch (err) {
    console.error("Failed to parse PDF:", err)
    toastStore.error("Could not automatically extract PDF info. You can fill it manually.")
  } finally {
    isExtracting.value = false
  }
}

const closeModal = () => {
  showUploadModal.value = false
  uploadError.value = ''
  form.value = { title: '', author: '', category: 'Personal Development', description: '', allowDownload: false }
  coverFile.value = null
  pdfFile.value = null
  isEditing.value = false
  editingBookId.value = null
  isExtracting.value = false
  if (coverPreviewUrl.value && coverPreviewUrl.value.startsWith('blob:')) {
    URL.revokeObjectURL(coverPreviewUrl.value)
  }
  coverPreviewUrl.value = ''
}

const uploadBook = async () => {
  if (!isEditing.value && !pdfFile.value) {
    uploadError.value = "PDF file is required."
    return
  }
  
  uploading.value = true
  uploadError.value = ''
  
  try {
    const timeId = new Date().getTime()
    
    // Upload PDF
    let pdfPublicUrl = undefined
    if (pdfFile.value) {
      const pdfPath = `pdfs/${timeId}_${pdfFile.value.name}`
      const { error: pdfError } = await supabase.storage
        .from('documents')
        .upload(pdfPath, pdfFile.value)
        
      if (pdfError) throw pdfError
      
      const { data: pdfUrlData } = supabase.storage.from('documents').getPublicUrl(pdfPath)
      pdfPublicUrl = pdfUrlData.publicUrl
    }
    
    // Upload Cover if provided
    let coverUrl = undefined
    if (coverFile.value) {
      const coverPath = `covers/${timeId}_${coverFile.value.name}`
      const { error: coverError } = await supabase.storage
        .from('covers')
        .upload(coverPath, coverFile.value)
        
      if (coverError) throw coverError
      const { data: coverUrlData } = supabase.storage.from('covers').getPublicUrl(coverPath)
      coverUrl = coverUrlData.publicUrl
    }
    
    const bookData: any = {
      title: form.value.title,
      author: form.value.author,
      category: form.value.category,
      description: form.value.description,
      download_allowed: form.value.allowDownload,
    }

    if (pdfPublicUrl) bookData.file_url = pdfPublicUrl
    if (coverUrl !== undefined) bookData.cover_url = coverUrl
    
    if (isEditing.value && editingBookId.value) {
      const { error: updateError } = await supabase.from('books').update(bookData).eq('id', editingBookId.value)
      if (updateError) throw updateError
      toastStore.success("Book updated successfully")
    } else {
      const { error: insertError } = await supabase.from('books').insert(bookData)
      if (insertError) throw insertError
      toastStore.success("Book uploaded successfully")
    }
    
    await fetchBooks()
    closeModal()
  } catch (error: any) {
    uploadError.value = error.message || 'An error occurred during save.'
  } finally {
    uploading.value = false
  }
}

const deleteBook = async (id: string) => {
  if (confirm('Are you sure you want to delete this book?')) {
    const { error } = await supabase.from('books').delete().eq('id', id)
    if (error) {
      toastStore.error("Failed to delete book: " + error.message)
    } else {
      toastStore.success("Book deleted successfully")
      await fetchBooks()
    }
  }
}
</script>
