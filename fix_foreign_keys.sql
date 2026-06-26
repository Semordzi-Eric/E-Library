-- Drop existing foreign key constraints on the book_id column
ALTER TABLE public.reading_sessions DROP CONSTRAINT IF EXISTS reading_sessions_book_id_fkey;
ALTER TABLE public.downloads DROP CONSTRAINT IF EXISTS downloads_book_id_fkey;
ALTER TABLE public.bookmarks DROP CONSTRAINT IF EXISTS bookmarks_book_id_fkey;
ALTER TABLE public.assignments DROP CONSTRAINT IF EXISTS assignments_book_id_fkey;

-- Re-add them with ON DELETE CASCADE
ALTER TABLE public.reading_sessions 
  ADD CONSTRAINT reading_sessions_book_id_fkey 
  FOREIGN KEY (book_id) 
  REFERENCES public.books(id) 
  ON DELETE CASCADE;

ALTER TABLE public.downloads 
  ADD CONSTRAINT downloads_book_id_fkey 
  FOREIGN KEY (book_id) 
  REFERENCES public.books(id) 
  ON DELETE CASCADE;

ALTER TABLE public.bookmarks 
  ADD CONSTRAINT bookmarks_book_id_fkey 
  FOREIGN KEY (book_id) 
  REFERENCES public.books(id) 
  ON DELETE CASCADE;

ALTER TABLE public.assignments 
  ADD CONSTRAINT assignments_book_id_fkey 
  FOREIGN KEY (book_id) 
  REFERENCES public.books(id) 
  ON DELETE CASCADE;
