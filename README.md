# HR E-Library & Reading Analytics Platform

A production-ready enterprise digital library for HR departments to manage, distribute, and track employee engagement with company literature, policies, manuals, and learning resources.

## 🚀 Tech Stack

**Frontend:**
- **Framework:** Vue 3 (Composition API) + Vite
- **Language:** TypeScript
- **State Management:** Pinia
- **Routing:** Vue Router
- **Styling:** Tailwind CSS (Editorial aesthetic: Inter font, clean layouts)
- **Icons:** Lucide Vue
- **PDF Viewer:** `vue-pdf-embed` powered by PDF.js

**Backend (Supabase):**
- **Database:** PostgreSQL with Row Level Security (RLS)
- **Authentication:** Supabase Auth (Email/Password)
- **Storage:** Supabase Storage (Buckets for PDFs and Cover Images)

## ✨ Core Features

### For Employees:
- **Secure Access:** Role-based authentication ensuring employees only see their allowed materials.
- **Library Grid:** Browse books by category, search by title, or filter by popularity.
- **In-App Reader:** Distraction-free, full-screen PDF reader with zoom controls and pagination.
- **Reading Dashboard:** Personal statistics tracking reading hours, books completed, and a "Continue Reading" quick-access shelf.

### For HR Administrators:
- **Resource Management:** Upload new books, assign categories, write descriptions, and upload cover images and PDF files securely.
- **Access Control:** Granular control over which books can be downloaded vs. strictly read-only online.
- **Reading Analytics (Pending):** Track engagement metrics such as most read categories, total reading time across the organization, and compliance completion rates.

## 🛠️ Local Development Setup

### Prerequisites
- Node.js (v18+ recommended)
- A Supabase Project (Create one for free at [supabase.com](https://supabase.com))

### 1. Database Setup
1. Open the `supabase/schema.sql` file.
2. Copy the entire SQL script.
3. Paste and run the script inside your Supabase project's **SQL Editor**. This will automatically generate all tables, RLS policies, and storage buckets.

### 2. Environment Variables
Create a `.env.local` file in the root of the project and add your Supabase credentials:
```env
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-public-key
```

### 3. Install Dependencies
```bash
npm install
```

### 4. Run Development Server
```bash
npm run dev
```
The app will be available at `http://localhost:5173`.

## 📦 Deployment (Netlify)

This project is configured to be deployed easily on Netlify.
1. Connect your GitHub repository to Netlify.
2. Set the **Build Command** to `npm run build`.
3. Set the **Publish Directory** to `dist`.
4. Ensure you add the `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` to the **Environment Variables** in the Netlify site settings.

## 🔒 Security Notes
- All backend data is protected by Supabase Row Level Security (RLS). 
- PDF documents are stored in a private bucket (`documents`) requiring active authentication to read or download.
- Cover images are stored in a public bucket (`covers`) for fast loading in the library grid.
