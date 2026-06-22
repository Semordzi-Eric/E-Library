-- Tracking Schema: Audit Logs and Downloads

-- 1. Safely create audit_logs
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  action text NOT NULL,
  resource text NOT NULL,
  timestamp timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Allow users to insert their own logs
DROP POLICY IF EXISTS "Users can insert own logs" ON public.audit_logs;
CREATE POLICY "Users can insert own logs" ON public.audit_logs FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow admins to read logs
DROP POLICY IF EXISTS "Admins can read logs" ON public.audit_logs;
CREATE POLICY "Admins can read logs" ON public.audit_logs FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- 2. Safely create downloads table
CREATE TABLE IF NOT EXISTS public.downloads (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  book_id uuid REFERENCES public.books(id) ON DELETE CASCADE NOT NULL,
  timestamp timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.downloads ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can insert own downloads" ON public.downloads;
CREATE POLICY "Users can insert own downloads" ON public.downloads FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can read downloads" ON public.downloads;
CREATE POLICY "Admins can read downloads" ON public.downloads FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- 3. RPC for logging downloads securely
CREATE OR REPLACE FUNCTION log_download(p_user_id uuid, p_book_id uuid)
RETURNS void AS $$
BEGIN
  -- Insert into downloads
  INSERT INTO public.downloads(user_id, book_id) VALUES (p_user_id, p_book_id);
  
  -- Increment books download count
  UPDATE public.books SET downloads_count = downloads_count + 1 WHERE id = p_book_id;
  
  -- Log to audit
  INSERT INTO public.audit_logs(user_id, action, resource) VALUES (p_user_id, 'DOWNLOAD', p_book_id::text);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
