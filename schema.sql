-- =====================================================================
-- JerseyWala.pk — database setup
-- Run this ONCE in: Supabase dashboard -> SQL Editor -> New query -> paste -> Run
-- It is safe to run again later (it will not delete your products).
-- =====================================================================

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- 1. TABLES
-- ---------------------------------------------------------------------

-- People who are allowed to manage the store.
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  description text not null default '',
  specifications text not null default '',          -- one "Label: Value" per line
  club text not null default '',
  category_id uuid references public.categories(id) on delete set null,
  price numeric(10,2) not null check (price >= 0),
  sale_price numeric(10,2) check (sale_price is null or (sale_price >= 0 and sale_price < price)),
  sizes text[] not null default '{}',
  stock integer not null default 0 check (stock >= 0),
  is_sold_out boolean not null default false,
  is_featured boolean not null default false,
  is_new_arrival boolean not null default false,
  is_best_seller boolean not null default false,
  is_published boolean not null default true,
  images text[] not null default '{}',               -- public image URLs, first = main image
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists products_created_at_idx on public.products (created_at desc);
create index if not exists products_club_idx on public.products (club);
create index if not exists products_category_idx on public.products (category_id);

-- Store settings: always exactly ONE row (id = 1).
create table if not exists public.store_settings (
  id integer primary key default 1 check (id = 1),
  instagram_username text not null default 'jerseywala.pk',
  email text not null default '',
  phone text not null default '',
  whatsapp text not null default '',
  address text not null default '',
  slogan text not null default 'Wear Your Passion.',
  facebook_url text not null default '',
  tiktok_url text not null default '',
  youtube_url text not null default '',
  about_text text not null default '',
  hero_image_url text not null default '',
  updated_at timestamptz not null default now()
);

insert into public.store_settings (id) values (1) on conflict (id) do nothing;

-- Keep products.updated_at fresh automatically.
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists products_set_updated_at on public.products;
create trigger products_set_updated_at
  before update on public.products
  for each row execute function public.set_updated_at();

drop trigger if exists settings_set_updated_at on public.store_settings;
create trigger settings_set_updated_at
  before update on public.store_settings
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- 2. "Is this person an admin?" helper
-- ---------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

-- ---------------------------------------------------------------------
-- 3. ROW LEVEL SECURITY (this is what keeps your store safe)
--    Visitors can only READ published products.
--    Only users listed in the "admins" table can add / edit / delete.
-- ---------------------------------------------------------------------
alter table public.admins enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.store_settings enable row level security;

-- admins: a logged-in user may only see their own row. Nobody can write
-- from the website; admins are added from the SQL Editor only.
drop policy if exists "admins can read own row" on public.admins;
create policy "admins can read own row" on public.admins
  for select to authenticated
  using (user_id = auth.uid());

-- categories
drop policy if exists "anyone can read categories" on public.categories;
create policy "anyone can read categories" on public.categories
  for select to anon, authenticated using (true);

drop policy if exists "admins insert categories" on public.categories;
create policy "admins insert categories" on public.categories
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admins update categories" on public.categories;
create policy "admins update categories" on public.categories
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admins delete categories" on public.categories;
create policy "admins delete categories" on public.categories
  for delete to authenticated using (public.is_admin());

-- products
drop policy if exists "anyone can read published products" on public.products;
create policy "anyone can read published products" on public.products
  for select to anon, authenticated
  using (is_published = true or public.is_admin());

drop policy if exists "admins insert products" on public.products;
create policy "admins insert products" on public.products
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admins update products" on public.products;
create policy "admins update products" on public.products
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admins delete products" on public.products;
create policy "admins delete products" on public.products
  for delete to authenticated using (public.is_admin());

-- store settings
drop policy if exists "anyone can read settings" on public.store_settings;
create policy "anyone can read settings" on public.store_settings
  for select to anon, authenticated using (true);

drop policy if exists "admins insert settings" on public.store_settings;
create policy "admins insert settings" on public.store_settings
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admins update settings" on public.store_settings;
create policy "admins update settings" on public.store_settings
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

-- ---------------------------------------------------------------------
-- 4. IMAGE STORAGE (bucket named "product-images")
--    Everyone can VIEW images. Only admins can upload / replace / delete.
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'product-images',
  'product-images',
  true,
  5242880,  -- 5 MB per image
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "public can view product images" on storage.objects;
create policy "public can view product images" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'product-images');

drop policy if exists "admins upload product images" on storage.objects;
create policy "admins upload product images" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'product-images' and public.is_admin());

drop policy if exists "admins update product images" on storage.objects;
create policy "admins update product images" on storage.objects
  for update to authenticated
  using (bucket_id = 'product-images' and public.is_admin())
  with check (bucket_id = 'product-images' and public.is_admin());

drop policy if exists "admins delete product images" on storage.objects;
create policy "admins delete product images" on storage.objects
  for delete to authenticated
  using (bucket_id = 'product-images' and public.is_admin());

-- ---------------------------------------------------------------------
-- 5. Starter categories (you can rename / add / delete them in the admin)
-- ---------------------------------------------------------------------
insert into public.categories (name, slug) values
  ('Club Jerseys', 'club-jerseys'),
  ('National Teams', 'national-teams'),
  ('Retro Classics', 'retro-classics'),
  ('Kids Kits', 'kids-kits'),
  ('Training Wear', 'training-wear')
on conflict (slug) do nothing;
