-- ============================================================
--  Kleivy Cloud Fix — apply this in Supabase SQL Editor
--  (Dashboard -> SQL Editor -> New query -> Run)
--  Run as the owner/Postgres role (not the anon key).
-- ============================================================

-- 1) Add media columns to channel_messages (for files/images in channels)
ALTER TABLE public.channel_messages
  ADD COLUMN IF NOT EXISTS media_url  TEXT,
  ADD COLUMN IF NOT EXISTS media_name TEXT,
  ADD COLUMN IF NOT EXISTS media_type TEXT,
  ADD COLUMN IF NOT EXISTS media_size BIGINT;

-- 2) Storage buckets needed by the app
insert into storage.buckets (id, name, public)
values
  ('chat-media', 'chat-media', true),
  ('avatars', 'avatars', true),
  ('channel-avatars', 'channel-avatars', true)
on conflict (id) do nothing;

-- 3) Storage policies: let any authenticated user upload/read files
drop policy if exists "public read chat-media"  on storage.objects;
drop policy if exists "auth upload chat-media"  on storage.objects;
drop policy if exists "public read avatars"     on storage.objects;
drop policy if exists "auth upload avatars"     on storage.objects;
drop policy if exists "public read channel-avatars" on storage.objects;
drop policy if exists "auth upload channel-avatars" on storage.objects;

create policy "public read chat-media"
  on storage.objects for select
  using (bucket_id = 'chat-media');
create policy "auth upload chat-media"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'chat-media');

create policy "public read avatars"
  on storage.objects for select
  using (bucket_id = 'avatars');
create policy "auth upload avatars"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'avatars');

create policy "public read channel-avatars"
  on storage.objects for select
  using (bucket_id = 'channel-avatars');
create policy "auth upload channel-avatars"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'channel-avatars');

-- 4) Ensure a profile is created automatically after signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, name, username, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', 'Пользователь'),
    coalesce(new.raw_user_meta_data->>'username', 'user_' || substr(new.id::text, 1, 8)),
    new.email
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 5) RLS helper: allow users to read/update their own profile & manage contacts
alter table public.profiles enable row level security;
drop policy if exists "select own profile" on public.profiles;
drop policy if exists "update own profile" on public.profiles;
create policy "select own profile" on public.profiles
  for select using (true);
create policy "update own profile" on public.profiles
  for update using (auth.uid() = id);
