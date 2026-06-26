-- 1. Profiles Table
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  employee_id text unique not null,
  name text not null,
  department text,
  title text,
  role text default 'employee'::text not null
);
alter table public.profiles enable row level security;
create policy "Public profiles are viewable by everyone." on profiles for select using (true);
create policy "Users can insert own profile." on profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile." on profiles for update using (auth.uid() = id);

-- 2. Books Table
create table public.books (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  author text not null,
  category text,
  description text,
  cover_url text,
  file_url text not null,
  file_size integer,
  version_number text,
  download_allowed boolean default false,
  tags text[],
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
alter table public.books enable row level security;
create policy "Books are viewable by authenticated users." on books for select using (auth.role() = 'authenticated');
create policy "Admins can insert books." on books for insert with check (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "Admins can update books." on books for update using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "Admins can delete books." on books for delete using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- 3. Reading Sessions Table
create table public.reading_sessions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) not null,
  book_id uuid references public.books(id) on delete cascade not null,
  start_time timestamp with time zone default timezone('utc'::text, now()) not null,
  end_time timestamp with time zone,
  duration integer default 0,
  pages_visited integer[],
  completion_percentage numeric default 0
);
alter table public.reading_sessions enable row level security;
create policy "Users can read own sessions." on reading_sessions for select using (auth.uid() = user_id);
create policy "Admins can read all sessions." on reading_sessions for select using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "Users can insert own sessions." on reading_sessions for insert with check (auth.uid() = user_id);
create policy "Users can update own sessions." on reading_sessions for update using (auth.uid() = user_id);

-- 4. Downloads Table
create table public.downloads (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) not null,
  book_id uuid references public.books(id) on delete cascade not null,
  timestamp timestamp with time zone default timezone('utc'::text, now()) not null,
  ip_address text,
  device text
);
alter table public.downloads enable row level security;
create policy "Users can read own downloads." on downloads for select using (auth.uid() = user_id);
create policy "Admins can read all downloads." on downloads for select using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "Users can insert own downloads." on downloads for insert with check (auth.uid() = user_id);

-- 5. Bookmarks Table
create table public.bookmarks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) not null,
  book_id uuid references public.books(id) on delete cascade not null,
  page_number integer not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (user_id, book_id)
);
alter table public.bookmarks enable row level security;
create policy "Users manage own bookmarks." on bookmarks for all using (auth.uid() = user_id);

-- 6. Assignments Table
create table public.assignments (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) not null,
  book_id uuid references public.books(id) on delete cascade not null,
  assigned_date timestamp with time zone default timezone('utc'::text, now()) not null,
  completed boolean default false,
  completion_percentage numeric default 0
);
alter table public.assignments enable row level security;
create policy "Users can read own assignments." on assignments for select using (auth.uid() = user_id);
create policy "Admins can manage all assignments." on assignments for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- 7. Audit Logs Table
create table public.audit_logs (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) not null,
  action text not null,
  resource text not null,
  timestamp timestamp with time zone default timezone('utc'::text, now()) not null
);
alter table public.audit_logs enable row level security;
create policy "Admins can read audit logs." on audit_logs for select using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "System can insert audit logs." on audit_logs for insert with check (true); -- Usually restricted via functions

-- Create buckets for storage
insert into storage.buckets (id, name, public) values ('covers', 'covers', true);
insert into storage.buckets (id, name, public) values ('documents', 'documents', false);

-- Storage Policies
create policy "Cover images are publicly accessible." on storage.objects for select using ( bucket_id = 'covers' );
create policy "Anyone can upload a cover." on storage.objects for insert with check ( bucket_id = 'covers' );
create policy "Authenticated users can read documents." on storage.objects for select using ( bucket_id = 'documents' and auth.role() = 'authenticated' );
create policy "Admins can upload documents." on storage.objects for insert with check ( bucket_id = 'documents' and exists (select 1 from public.profiles where id = auth.uid() and role = 'admin') );
