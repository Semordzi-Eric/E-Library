<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h2 class="text-2xl font-bold text-text-main">Manage Books</h2>
      <button @click="showUploadModal = true" class="bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded-lg font-medium flex items-center gap-2 transition-colors">
        <PlusIcon class="w-5 h-5" />
        Upload New Book
      </button>
    </div>

    <!-- Data Table Mock -->
    <div class="bg-surface border border-gray-200 rounded-xl shadow-sm overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Book Details</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Category</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-text-muted uppercase tracking-wider">Stats</th>
            <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-text-muted uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="n in 5" :key="n">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex items-center">
                <div class="flex-shrink-0 h-12 w-8 bg-gray-200 rounded"></div>
                <div class="ml-4">
                  <div class="text-sm font-bold text-text-main">Sample Book Title {{n}}</div>
                  <div class="text-sm text-text-muted">Author Name</div>
                </div>
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                Leadership
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-text-muted">
              <div>124 Reads</div>
              <div>45 Downloads</div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <button class="text-primary hover:text-primary-dark mr-3">Edit</button>
              <button class="text-red-600 hover:text-red-900">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Upload Modal -->
    <div v-if="showUploadModal" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="showUploadModal = false"></div>
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
        
        <div class="inline-block align-bottom bg-surface rounded-xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full">
          <div class="bg-surface px-4 pt-5 pb-4 sm:p-6 sm:pb-4 border-b border-gray-200">
            <h3 class="text-lg leading-6 font-bold text-text-main" id="modal-title">Upload New Book</h3>
          </div>
          
          <form @submit.prevent="uploadBook" class="p-6 space-y-6">
            <div class="grid grid-cols-2 gap-6">
              <div class="col-span-2">
                <label class="block text-sm font-medium text-text-main mb-1">Title</label>
                <input type="text" required class="block w-full border border-gray-300 rounded-lg py-2 px-3 focus:ring-primary focus:border-primary">
              </div>
              <div>
                <label class="block text-sm font-medium text-text-main mb-1">Author</label>
                <input type="text" required class="block w-full border border-gray-300 rounded-lg py-2 px-3 focus:ring-primary focus:border-primary">
              </div>
              <div>
                <label class="block text-sm font-medium text-text-main mb-1">Category</label>
                <select class="block w-full border border-gray-300 rounded-lg py-2 px-3 focus:ring-primary focus:border-primary">
                  <option>Leadership</option>
                  <option>HR Policies</option>
                  <option>Compliance</option>
                  <option>Technology</option>
                </select>
              </div>
              <div class="col-span-2">
                <label class="block text-sm font-medium text-text-main mb-1">Description</label>
                <textarea rows="3" class="block w-full border border-gray-300 rounded-lg py-2 px-3 focus:ring-primary focus:border-primary"></textarea>
              </div>
              <div>
                <label class="block text-sm font-medium text-text-main mb-1">Cover Image</label>
                <input type="file" accept="image/*" class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-primary hover:file:bg-blue-100">
              </div>
              <div>
                <label class="block text-sm font-medium text-text-main mb-1">PDF File</label>
                <input type="file" accept="application/pdf" class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-primary hover:file:bg-blue-100">
              </div>
              <div class="col-span-2 flex items-center mt-2">
                <input type="checkbox" id="download" class="h-4 w-4 text-primary focus:ring-primary border-gray-300 rounded">
                <label for="download" class="ml-2 block text-sm text-text-main">Allow employees to download this file</label>
              </div>
            </div>
            
            <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse -mx-6 -mb-6 mt-6 border-t border-gray-200">
              <button type="submit" class="w-full inline-flex justify-center rounded-lg border border-transparent shadow-sm px-4 py-2 bg-primary text-base font-medium text-white hover:bg-primary-dark focus:outline-none sm:ml-3 sm:w-auto sm:text-sm">
                Upload & Save
              </button>
              <button @click="showUploadModal = false" type="button" class="mt-3 w-full inline-flex justify-center rounded-lg border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">
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
import { ref } from 'vue'
import { PlusIcon } from '@lucide/vue'

const showUploadModal = ref(false)

const uploadBook = () => {
  // In a real app, this would use supabase.storage.from('documents').upload()
  // and then insert into the 'books' table.
  showUploadModal.value = false
  alert("Book uploaded successfully!")
}
</script>
