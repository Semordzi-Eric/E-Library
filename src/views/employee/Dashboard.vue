<template>
  <div class="space-y-8">
    <!-- Welcome Section -->
    <section>
      <h2 class="text-2xl font-bold text-text-main tracking-tight">Welcome back!</h2>
      <p class="text-text-muted mt-1">Here is what's happening with your reading goals.</p>
    </section>

    <!-- Stats Grid -->
    <section class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-text-muted">Books Read</p>
          <p class="text-3xl font-bold text-text-main mt-2">12</p>
        </div>
        <div class="w-12 h-12 rounded-full bg-blue-50 flex items-center justify-center">
          <BookOpenIcon class="w-6 h-6 text-primary" />
        </div>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-text-muted">Reading Hours</p>
          <p class="text-3xl font-bold text-text-main mt-2">34h</p>
        </div>
        <div class="w-12 h-12 rounded-full bg-indigo-50 flex items-center justify-center">
          <ClockIcon class="w-6 h-6 text-indigo-600" />
        </div>
      </div>
      <div class="bg-surface p-6 rounded-xl border border-gray-200 shadow-sm flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-text-muted">Downloads</p>
          <p class="text-3xl font-bold text-text-main mt-2">5</p>
        </div>
        <div class="w-12 h-12 rounded-full bg-green-50 flex items-center justify-center">
          <DownloadIcon class="w-6 h-6 text-green-600" />
        </div>
      </div>
    </section>

    <!-- Continue Reading -->
    <section>
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-semibold text-text-main">Continue Reading</h3>
        <router-link to="/library" class="text-sm font-medium text-primary hover:text-primary-dark">
          View all
        </router-link>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Mock Book Card -->
        <div class="bg-surface border border-gray-200 rounded-xl p-4 flex gap-4 hover:border-gray-300 transition-colors group cursor-pointer shadow-sm">
          <div class="w-24 h-32 bg-gray-200 rounded-md flex-shrink-0 bg-cover bg-center" style="background-image: url('https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=300')"></div>
          <div class="flex flex-col flex-1 py-1">
            <div class="text-xs font-medium text-primary mb-1">Leadership</div>
            <h4 class="font-bold text-text-main line-clamp-2">The Effective Executive</h4>
            <p class="text-sm text-text-muted mt-1">Peter F. Drucker</p>
            <div class="mt-auto">
              <div class="flex items-center justify-between text-xs text-text-muted mb-1">
                <span>Page 45 of 200</span>
                <span>22%</span>
              </div>
              <div class="w-full bg-gray-200 rounded-full h-1.5">
                <div class="bg-primary h-1.5 rounded-full" style="width: 22%"></div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Mock Book Card -->
        <div class="bg-surface border border-gray-200 rounded-xl p-4 flex gap-4 hover:border-gray-300 transition-colors group cursor-pointer shadow-sm">
          <div class="w-24 h-32 bg-gray-200 rounded-md flex-shrink-0 bg-cover bg-center" style="background-image: url('https://images.unsplash.com/photo-1554774853-719586f82d77?auto=format&fit=crop&q=80&w=300')"></div>
          <div class="flex flex-col flex-1 py-1">
            <div class="text-xs font-medium text-indigo-600 mb-1">HR Policies</div>
            <h4 class="font-bold text-text-main line-clamp-2">2026 Employee Handbook</h4>
            <p class="text-sm text-text-muted mt-1">Human Resources Dept</p>
            <div class="mt-auto">
              <div class="flex items-center justify-between text-xs text-text-muted mb-1">
                <span>Page 10 of 42</span>
                <span>24%</span>
              </div>
              <div class="w-full bg-gray-200 rounded-full h-1.5">
                <div class="bg-indigo-600 h-1.5 rounded-full" style="width: 24%"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { BookOpenIcon, ClockIcon, DownloadIcon } from '@lucide/vue'
</script>
