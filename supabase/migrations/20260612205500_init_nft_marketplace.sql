create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  wallet_address text unique,
  display_name text not null,
  handle text not null unique,
  bio text default '',
  avatar_url text default '',
  verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.collections (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text not null default '',
  cover_url text not null default '',
  floor_eth numeric(18, 6) not null default 0 check (floor_eth >= 0),
  volume_eth numeric(18, 6) not null default 0 check (volume_eth >= 0),
  item_count integer not null default 0 check (item_count >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.nft_items (
  id uuid primary key default gen_random_uuid(),
  collection_id uuid not null references public.collections(id) on delete cascade,
  owner_id uuid not null references public.profiles(id) on delete cascade,
  token_id text not null,
  chain text not null default 'ethereum',
  title text not null,
  description text not null default '',
  image_url text not null default '',
  metadata_url text default '',
  price_eth numeric(18, 6) not null default 0 check (price_eth >= 0),
  highest_bid_eth numeric(18, 6) not null default 0 check (highest_bid_eth >= 0),
  likes integer not null default 0 check (likes >= 0),
  status text not null default 'live'
    check (status in ('live', 'ending_soon', 'fixed_price')),
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (collection_id, token_id)
);

create table if not exists public.bids (
  id uuid primary key default gen_random_uuid(),
  nft_item_id uuid not null references public.nft_items(id) on delete cascade,
  bidder_id uuid not null references public.profiles(id) on delete cascade,
  bid_eth numeric(18, 6) not null check (bid_eth > 0),
  created_at timestamptz not null default now()
);

create table if not exists public.favorites (
  profile_id uuid not null references public.profiles(id) on delete cascade,
  nft_item_id uuid not null references public.nft_items(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (profile_id, nft_item_id)
);

create table if not exists public.activity_events (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid not null references public.profiles(id) on delete cascade,
  nft_item_id uuid references public.nft_items(id) on delete set null,
  event_type text not null check (event_type in ('listed', 'bid', 'sale')),
  asset_title text not null,
  eth_value numeric(18, 6) not null default 0 check (eth_value >= 0),
  created_at timestamptz not null default now()
);

create index if not exists collections_creator_id_idx
  on public.collections(creator_id);

create index if not exists collections_volume_eth_idx
  on public.collections(volume_eth desc);

create index if not exists nft_items_collection_id_idx
  on public.nft_items(collection_id);

create index if not exists nft_items_owner_id_idx
  on public.nft_items(owner_id);

create index if not exists nft_items_created_at_idx
  on public.nft_items(created_at desc);

create index if not exists activity_events_created_at_idx
  on public.activity_events(created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists set_collections_updated_at on public.collections;
create trigger set_collections_updated_at
before update on public.collections
for each row execute function public.set_updated_at();

drop trigger if exists set_nft_items_updated_at on public.nft_items;
create trigger set_nft_items_updated_at
before update on public.nft_items
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.collections enable row level security;
alter table public.nft_items enable row level security;
alter table public.bids enable row level security;
alter table public.favorites enable row level security;
alter table public.activity_events enable row level security;

drop policy if exists "Profiles are public" on public.profiles;
create policy "Profiles are public"
on public.profiles for select
using (true);

drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile"
on public.profiles for insert
with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
on public.profiles for update
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "Collections are public" on public.collections;
create policy "Collections are public"
on public.collections for select
using (true);

drop policy if exists "Creators can manage their collections" on public.collections;
create policy "Creators can manage their collections"
on public.collections for all
using (auth.uid() = creator_id)
with check (auth.uid() = creator_id);

drop policy if exists "NFTs are public" on public.nft_items;
create policy "NFTs are public"
on public.nft_items for select
using (true);

drop policy if exists "Owners can manage their NFTs" on public.nft_items;
create policy "Owners can manage their NFTs"
on public.nft_items for all
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

drop policy if exists "Bids are public" on public.bids;
create policy "Bids are public"
on public.bids for select
using (true);

drop policy if exists "Authenticated users can bid" on public.bids;
create policy "Authenticated users can bid"
on public.bids for insert
with check (auth.role() = 'authenticated' and auth.uid() = bidder_id);

drop policy if exists "Users can view favorites" on public.favorites;
create policy "Users can view favorites"
on public.favorites for select
using (auth.uid() = profile_id);

drop policy if exists "Users can manage favorites" on public.favorites;
create policy "Users can manage favorites"
on public.favorites for all
using (auth.uid() = profile_id)
with check (auth.uid() = profile_id);

drop policy if exists "Activity is public" on public.activity_events;
create policy "Activity is public"
on public.activity_events for select
using (true);

insert into storage.buckets (id, name, public)
values ('nft-media', 'nft-media', true)
on conflict (id) do nothing;

drop policy if exists "NFT media is publicly readable" on storage.objects;
create policy "NFT media is publicly readable"
on storage.objects for select
using (bucket_id = 'nft-media');

drop policy if exists "Authenticated users can upload NFT media" on storage.objects;
create policy "Authenticated users can upload NFT media"
on storage.objects for insert
with check (bucket_id = 'nft-media' and auth.role() = 'authenticated');

drop policy if exists "Owners can update their NFT media" on storage.objects;
create policy "Owners can update their NFT media"
on storage.objects for update
using (bucket_id = 'nft-media' and owner = auth.uid())
with check (bucket_id = 'nft-media' and owner = auth.uid());

drop policy if exists "Owners can delete their NFT media" on storage.objects;
create policy "Owners can delete their NFT media"
on storage.objects for delete
using (bucket_id = 'nft-media' and owner = auth.uid());
