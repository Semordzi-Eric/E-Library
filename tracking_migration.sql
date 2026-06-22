-- Fix reading_sessions table for tracking
ALTER TABLE public.reading_sessions 
ADD COLUMN IF NOT EXISTS current_page integer DEFAULT 1,
ADD COLUMN IF NOT EXISTS time_spent_seconds integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS progress_percentage integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_read_at timestamp with time zone DEFAULT timezone('utc'::text, now());

-- Create the update_reading_session RPC
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
    time_spent_seconds = time_spent_seconds + p_time_added,
    progress_percentage = GREATEST(progress_percentage, p_progress_percentage),
    last_read_at = timezone('utc'::text, now())
  WHERE id = p_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
