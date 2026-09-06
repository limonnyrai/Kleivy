-- КЛЕЙВИ ЧАТ — SQL для статусов, онлайна, редактирования,
-- удаления сообщений и блокировки пользователей.
-- Выполняй в Supabase SQL Editor.

-- 1. Статусы сообщений
alter table public.messages
add column if not exists read_at timestamptz null;

alter table public.messages
add column if not exists edited_at timestamptz null;

alter table public.messages
add column if not exists deleted_at timestamptz null;

-- 2. Онлайн / последний визит
alter table public.profiles
add column if not exists online boolean not null default false;

alter table public.profiles
add column if not exists last_seen timestamptz null;

-- 3. Таблица блокировок.
-- ВАЖНО: оба поля UUID, чтобы не получить ошибку text = uuid.
create table if not exists public.blocked_users (
    id uuid primary key default gen_random_uuid(),
    blocker_id uuid not null references auth.users(id) on delete cascade,
    blocked_id uuid not null references auth.users(id) on delete cascade,
    created_at timestamptz not null default now(),
    unique(blocker_id, blocked_id),
    check (blocker_id <> blocked_id)
);

create index if not exists blocked_users_blocker_idx
on public.blocked_users(blocker_id);

create index if not exists blocked_users_blocked_idx
on public.blocked_users(blocked_id);

-- 4. RLS
alter table public.blocked_users enable row level security;

drop policy if exists "blocked_users_select_own" on public.blocked_users;
create policy "blocked_users_select_own"
on public.blocked_users
for select
to authenticated
using (blocker_id = auth.uid());

drop policy if exists "blocked_users_insert_own" on public.blocked_users;
create policy "blocked_users_insert_own"
on public.blocked_users
for insert
to authenticated
with check (blocker_id = auth.uid());

drop policy if exists "blocked_users_delete_own" on public.blocked_users;
create policy "blocked_users_delete_own"
on public.blocked_users
for delete
to authenticated
using (blocker_id = auth.uid());

-- 5. Для realtime UPDATE сообщений.
-- Если таблица messages уже добавлена в supabase_realtime, ничего делать не надо.
-- Иначе можно добавить её:
do $$
begin
    alter publication supabase_realtime add table public.messages;
exception
    when duplicate_object then null;
end $$;

-- После выполнения проверь, что у profiles и messages RLS разрешает
-- пользователю читать/обновлять ТОЛЬКО нужные ему строки.


-- 6. Убираем ограничение 50 МБ именно на уровне bucket chat-media.
-- Если bucket уже существует, лимит становится NULL.
update storage.buckets
set file_size_limit = null
where id = 'chat-media';

