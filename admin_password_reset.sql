-- =============================================================
-- Admin Password Reset RPC
-- Run this script in your Supabase SQL Editor
-- Dashboard → SQL Editor → New query → Paste → Run
-- =============================================================

-- Ensure pgcrypto is enabled (needed for bcrypt hashing)
create extension if not exists pgcrypto;

-- Create the function
create or replace function public.admin_reset_password(p_user_id uuid, p_new_password text)
returns void
language plpgsql
security definer -- Elevates privileges so it can modify auth.users
set search_path = public, extensions
as $$
begin
  -- 1. Check if the caller is an admin
  if not exists (select 1 from public.profiles where id = auth.uid() and role = 'admin') then
    raise exception 'Unauthorized: Only administrators can reset passwords.';
  end if;

  -- 2. Update the user's password in auth.users
  -- Note: Supabase uses bcrypt (gen_salt('bf'))
  update auth.users
  set encrypted_password = crypt(p_new_password, gen_salt('bf')),
      updated_at = now()
  where id = p_user_id;

  -- Raise an error if the user wasn't found (0 rows affected)
  if not found then
    raise exception 'User not found.';
  end if;
end;
$$;

-- Grant execution permissions
grant execute on function public.admin_reset_password(uuid, text) to authenticated;
