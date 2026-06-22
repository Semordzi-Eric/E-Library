-- =============================================================
-- Korba E-Library — Auth & Security Migration (COMPLETE)
-- Run this ENTIRE script in your Supabase SQL Editor
-- Dashboard → SQL Editor → New query → Paste → Run
-- =============================================================

-- ── 1. INSERT policy on profiles (CRITICAL — fixes sign-up RLS error) ──
-- New users must be able to insert their own profile during registration.
-- Without this, sign-up silently creates the auth user but fails to save
-- profile data (name, dept, employee_id), causing a 42501 RLS violation.

-- Drop old conflicting policy if it exists
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ── 2. UNIQUE constraint on profiles.name (for name-based login) ──
-- Ensures no two employees share the exact same full name.
-- Run only if not already added (safe to re-run):
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'profiles_name_unique'
  ) THEN
    ALTER TABLE public.profiles
      ADD CONSTRAINT profiles_name_unique UNIQUE (name);
  END IF;
END $$;

-- ── 3. RPC: look up a user's email by profile ID ──
-- Used by the name-based login flow to silently resolve the auth email.
-- SECURITY DEFINER lets the anon/authenticated role read auth.users.
CREATE OR REPLACE FUNCTION public.get_user_email_by_profile_id(p_id uuid)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_email text;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = p_id;
  RETURN v_email;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_user_email_by_profile_id(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_email_by_profile_id(uuid) TO anon;

-- ── 4. audit_logs table (creates if missing) ──
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'audit_logs'
  ) THEN
    CREATE TABLE public.audit_logs (
      id uuid NOT NULL DEFAULT uuid_generate_v4(),
      user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
      action text NOT NULL,
      resource text,
      timestamp timestamp with time zone DEFAULT timezone('utc'::text, now()),
      PRIMARY KEY (id)
    );
    ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

    CREATE POLICY "Admins can read audit logs" ON public.audit_logs
      FOR SELECT USING (
        (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
      );

    CREATE POLICY "Users can insert own audit logs" ON public.audit_logs
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- ── 5. (Optional) Restrict PDF downloads via storage signed URLs ──
-- Uncomment if you want PDFs served via expiring signed URLs (more secure):
--
-- UPDATE storage.buckets SET public = false WHERE id = 'documents';
-- DROP POLICY IF EXISTS "Documents are publicly accessible" ON storage.objects;
-- CREATE POLICY "Authenticated users can read documents" ON storage.objects
--   FOR SELECT USING (bucket_id = 'documents' AND auth.role() = 'authenticated');
--
-- If you enable this, store only the storage path in books.file_url
-- (e.g. 'documents/mybook.pdf') — the app will generate signed URLs.

-- =============================================================
-- VERIFICATION: Run these queries to confirm everything is set up:
-- SELECT conname FROM pg_constraint WHERE conname = 'profiles_name_unique';
-- SELECT routine_name FROM information_schema.routines WHERE routine_name = 'get_user_email_by_profile_id';
-- SELECT policyname FROM pg_policies WHERE tablename = 'profiles';
-- =============================================================
