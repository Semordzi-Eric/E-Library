-- Create profiles table (extends auth.users)
CREATE TABLE public.profiles (
  id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  employee_id text,
  name text,
  department text,
  title text,
  role text DEFAULT 'employee'::text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  PRIMARY KEY (id)
);

-- Enable RLS for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to read all profiles (needed for admin view and general display)
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles
  FOR SELECT USING (true);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Allow admins to update any profile
CREATE POLICY "Admins can update any profile" ON public.profiles
  FOR UPDATE USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
  );

-- Create books table
CREATE TABLE public.books (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  author text NOT NULL,
  category text NOT NULL,
  description text,
  cover_url text,
  file_url text NOT NULL,
  allow_download boolean DEFAULT false,
  created_by uuid REFERENCES public.profiles(id),
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  reads_count integer DEFAULT 0,
  downloads_count integer DEFAULT 0,
  PRIMARY KEY (id)
);

-- Enable RLS for books
ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;

-- Allow everyone to read books
CREATE POLICY "Books are viewable by everyone" ON public.books
  FOR SELECT USING (true);

-- Allow admins to insert/update/delete books
CREATE POLICY "Admins can insert books" ON public.books
  FOR INSERT WITH CHECK (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "Admins can update books" ON public.books
  FOR UPDATE USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "Admins can delete books" ON public.books
  FOR DELETE USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
  );

-- Create reading_sessions table to track user progress
CREATE TABLE public.reading_sessions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  book_id uuid NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
  current_page integer DEFAULT 1,
  total_pages integer,
  progress_percentage integer DEFAULT 0,
  last_read_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  time_spent_seconds integer DEFAULT 0,
  UNIQUE(user_id, book_id),
  PRIMARY KEY (id)
);

-- Enable RLS for reading_sessions
ALTER TABLE public.reading_sessions ENABLE ROW LEVEL SECURITY;

-- Allow users to manage their own reading sessions
CREATE POLICY "Users can manage their own reading sessions" ON public.reading_sessions
  FOR ALL USING (auth.uid() = user_id);

-- Create storage bucket for documents and covers
INSERT INTO storage.buckets (id, name, public) VALUES ('documents', 'documents', true);

-- Storage policies for documents bucket
CREATE POLICY "Documents are publicly accessible" ON storage.objects
  FOR SELECT USING (bucket_id = 'documents');

CREATE POLICY "Admins can upload documents" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'documents' AND 
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "Admins can update documents" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'documents' AND 
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
  );

CREATE POLICY "Admins can delete documents" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'documents' AND 
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
  );

-- RPC Functions
CREATE OR REPLACE FUNCTION update_reading_session(
  p_session_id uuid,
  p_current_page integer,
  p_total_pages integer,
  p_progress_percentage integer,
  p_time_added integer
) RETURNS void AS $$
BEGIN
  UPDATE public.reading_sessions
  SET 
    current_page = p_current_page,
    total_pages = p_total_pages,
    progress_percentage = p_progress_percentage,
    time_spent_seconds = time_spent_seconds + p_time_added,
    last_read_at = timezone('utc'::text, now())
  WHERE id = p_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION increment_reads_count(p_book_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE public.books
  SET reads_count = reads_count + 1
  WHERE id = p_book_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
