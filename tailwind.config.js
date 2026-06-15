/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        background: '#f9fafb', // light gray
        surface: '#ffffff', // white
        primary: {
          DEFAULT: '#3b82f6', // muted blue
          dark: '#2563eb',
        },
        text: {
          main: '#1f2937', // charcoal
          muted: '#6b7280',
        }
      },
      fontFamily: {
        sans: ['Inter', 'Helvetica', 'Arial', 'sans-serif'],
      }
    },
  },
  plugins: [],
}
