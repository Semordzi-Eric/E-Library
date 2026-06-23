-- =============================================================
-- Korba E-Library — Admin Stats Migration
-- Run this script in your Supabase SQL Editor
-- Dashboard → SQL Editor → New query → Paste → Run
-- =============================================================

-- Allow administrators to read all reading sessions across the app.
-- This is required to display employee reading stats on the Admin portal.

DROP POLICY IF EXISTS "Admins can view all reading sessions" ON public.reading_sessions;

CREATE POLICY "Admins can view all reading sessions" ON public.reading_sessions
  FOR SELECT USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
  );

-- Note: The existing policy "Users can manage their own reading sessions"
-- remains active and protects users from seeing other users' data.
