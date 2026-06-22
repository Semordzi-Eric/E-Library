-- Database Performance Indexes for Scale

-- 1. Profiles Table Indexes
-- Index on role to quickly find admins vs employees
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);

-- 2. Books Table Indexes
-- Index on category for fast filtering in Library
CREATE INDEX IF NOT EXISTS idx_books_category ON public.books(category);
-- Index on reads_count for sorting by 'Most Popular'
CREATE INDEX IF NOT EXISTS idx_books_reads_count ON public.books(reads_count DESC);
-- Index on created_at for sorting by 'Most Recent'
CREATE INDEX IF NOT EXISTS idx_books_created_at ON public.books(created_at DESC);

-- 3. Reading Sessions Table Indexes
-- Index on user_id for fast loading of the Dashboard
CREATE INDEX IF NOT EXISTS idx_reading_sessions_user_id ON public.reading_sessions(user_id);
-- Index on book_id
CREATE INDEX IF NOT EXISTS idx_reading_sessions_book_id ON public.reading_sessions(book_id);
-- Index on last_read_at for sorting recent reading sessions in the Dashboard
CREATE INDEX IF NOT EXISTS idx_reading_sessions_last_read_at ON public.reading_sessions(last_read_at DESC);

-- Note: The above indexes will drastically improve query performance when the tables reach >10k rows.
