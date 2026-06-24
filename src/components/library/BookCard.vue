<template>
  <div class="bg-surface border border-gray-200 rounded-xl overflow-hidden hover:shadow-md active:scale-[0.97] active:shadow-sm active:bg-gray-50 transition-all duration-200 group flex flex-col cursor-pointer h-full">
    <div class="aspect-[2/3] w-full bg-gray-100 relative overflow-hidden">
      <img v-if="book.cover_url" :src="book.cover_url" :alt="book.title" class="w-full h-full object-cover" />
      <div v-else class="w-full h-full flex items-center justify-center bg-gray-200 text-gray-400">
        <BookIcon class="w-12 h-12" />
      </div>
      <div class="absolute inset-0 bg-black/40 opacity-0 lg:group-hover:opacity-100 transition-opacity flex items-center justify-center backdrop-blur-[2px]">
        <div class="bg-primary text-white px-6 py-2 rounded-full font-medium transition-transform transform scale-95 lg:group-hover:scale-100 flex items-center gap-2 shadow-lg">
          <BookOpenIcon class="w-4 h-4" />
          Read Now
        </div>
      </div>
    </div>
    <div class="p-4 flex flex-col flex-1">
      <div class="text-xs font-semibold tracking-wide uppercase mb-1" :class="categoryColor">
        {{ book.category }}
      </div>
      <h3 class="font-bold text-text-main line-clamp-2 leading-snug mb-1" :title="book.title">
        {{ book.title }}
      </h3>
      <p class="text-sm text-text-muted mt-auto">
        {{ book.author }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { BookIcon, BookOpenIcon } from '@lucide/vue'

const props = defineProps<{
  book: {
    id: string
    title: string
    author: string
    category: string
    cover_url?: string
  }
}>()

const categoryColor = computed(() => {
  const colors: Record<string, string> = {
    'Leadership': 'text-primary',
    'HR Policies': 'text-indigo-600',
    'Technology': 'text-emerald-600',
    'Finance': 'text-amber-600',
    'Compliance': 'text-rose-600'
  }
  return colors[props.book.category] || 'text-gray-600'
})
</script>
