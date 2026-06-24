import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  build: {
    // Increase the chunk size limit to silence the warning (default is 500)
    chunkSizeWarningLimit: 1500
  }
})
