-- =====================================================================
-- JerseyWala.pk — ORDERS system
-- Run AFTER schema.sql, in: Supabase -> SQL Editor -> New query -> paste -> Run
-- Safe to run more than once.
-- =====================================================================

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number bigint generated always as identity,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,                       -- copied from the product at order time
  unit_price numeric(10,2) not null check (unit_price >= 0),
  size text not null default '',
  quantity integer not null check (quantity between 1 and 10),
  total numeric(10,2) generated always as (unit_price * quantity) stored,
  status text not null default 'new'
    check (status in ('new', 'confirmed', 'shipped', 'delivered', 'cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists orders_created_at_idx on public.orders (created_at desc);
create index if not exists orders_status_idx on public.orders (status);

drop trigger if exists orders_set_updated_at on public.orders;
create trigger orders_set_updated_at
  before update on public.orders
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- Security: visitors can NOT read or write the orders table directly.
-- Only admins can see / change / delete orders.
-- ---------------------------------------------------------------------
alter table public.orders enable row level security;

drop policy if exists "admins read orders" on public.orders;
create policy "admins read orders" on public.orders
  for select to authenticated using (public.is_admin());

drop policy if exists "admins update orders" on public.orders;
create policy "admins update orders" on public.orders
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admins delete orders" on public.orders;
create policy "admins delete orders" on public.orders
  for delete to authenticated using (public.is_admin());

-- ---------------------------------------------------------------------
-- How customers create an order: this function is the ONLY door.
-- It checks the product, and takes the name and price from the database
-- (so nobody can fake a price from their browser).
-- ---------------------------------------------------------------------
create or replace function public.place_order(p_product_id uuid, p_size text, p_quantity integer)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  prod public.products;
  num bigint;
begin
  select * into prod from public.products where id = p_product_id and is_published = true;
  if not found then
    raise exception 'Product not found';
  end if;
  if prod.is_sold_out or prod.stock <= 0 then
    raise exception 'Product is sold out';
  end if;
  if p_quantity is null or p_quantity < 1 or p_quantity > least(prod.stock, 10) then
    raise exception 'Invalid quantity';
  end if;

  insert into public.orders (product_id, product_name, unit_price, size, quantity)
  values (
    prod.id,
    prod.name,
    case when prod.sale_price is not null and prod.sale_price < prod.price then prod.sale_price else prod.price end,
    left(coalesce(p_size, ''), 10),
    p_quantity
  )
  returning order_number into num;

  return num;
end;
$$;

revoke all on function public.place_order(uuid, text, integer) from public;
grant execute on function public.place_order(uuid, text, integer) to anon, authenticated;

-- ---------------------------------------------------------------------
-- Stock updates itself when YOU confirm / cancel an order in the admin:
--   new -> confirmed (or shipped / delivered)  = stock goes DOWN
--   confirmed / shipped / delivered -> cancelled = stock goes back UP
-- ---------------------------------------------------------------------
create or replace function public.orders_adjust_stock()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.product_id is not null then
    if old.status in ('new', 'cancelled') and new.status in ('confirmed', 'shipped', 'delivered') then
      update public.products set stock = greatest(stock - new.quantity, 0) where id = new.product_id;
    elsif old.status in ('confirmed', 'shipped', 'delivered') and new.status in ('new', 'cancelled') then
      update public.products set stock = stock + new.quantity where id = new.product_id;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists orders_stock_trigger on public.orders;
create trigger orders_stock_trigger
  after update of status on public.orders
  for each row execute function public.orders_adjust_stock();
