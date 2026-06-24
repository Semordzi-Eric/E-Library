import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  build: {
    // Increase the chunk size limit to silence the warning (default is 500)
    chunkSizeWarningLimit: 1500,
    rollupOptions: {
      output: {
        // Manually split large dependencies into their own chunks
        manualChunks(id) {
          if (id.includes('node_modules')) {
            // Put pdfjs-dist in its own chunk since it's very large
            if (id.includes('pdfjs-dist')) {
              return 'pdfjs-vendor';
            }
            return 'vendor';
          }
        }
      }
    }
  }
})
