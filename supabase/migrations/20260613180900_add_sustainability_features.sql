alter table public.profiles
  add column if not exists profile_photo_path text default '';

create table if not exists public.saved_products (
  profile_id uuid not null references public.profiles(id) on delete cascade,
  product_id uuid not null references public.nft_items(id) on delete cascade,
  product_title text not null,
  product_image_url text not null default '',
  price_eth numeric(18, 6) not null default 0 check (price_eth >= 0),
  created_at timestamptz not null default now(),
  primary key (profile_id, product_id)
);

create table if not exists public.order_preferences (
  profile_id uuid primary key references public.profiles(id) on delete cascade,
  delivery_window text not null default 'Evening'
    check (delivery_window in ('Morning', 'Afternoon', 'Evening', 'Weekend')),
  packaging_preference text not null default 'Reusable bags'
    check (packaging_preference in ('Reusable bags', 'Compostable', 'No packaging')),
  allow_substitutions boolean not null default true,
  contactless_delivery boolean not null default false,
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.support_issues (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  subject text not null check (char_length(subject) >= 4),
  message text not null check (char_length(message) >= 10),
  status text not null default 'open'
    check (status in ('open', 'in_progress', 'resolved', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null default '',
  type text not null default 'general',
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.waste_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  record_type text not null
    check (record_type in ('waste_reduced', 'recycled_item', 'food_saved', 'donation')),
  quantity numeric(18, 3) not null check (quantity > 0),
  unit text not null default 'kg',
  created_at timestamptz not null default now()
);

create table if not exists public.eco_scores (
  profile_id uuid primary key references public.profiles(id) on delete cascade,
  score integer not null default 0 check (score >= 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.eco_score_history (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  score integer not null check (score >= 0),
  reason text not null default 'Automatic recalculation',
  created_at timestamptz not null default now()
);

create index if not exists saved_products_profile_id_idx
  on public.saved_products(profile_id, created_at desc);

create index if not exists support_issues_profile_id_idx
  on public.support_issues(profile_id, created_at desc);

create index if not exists notifications_profile_unread_idx
  on public.notifications(profile_id, is_read, created_at desc);

create index if not exists waste_records_profile_type_idx
  on public.waste_records(profile_id, record_type, created_at desc);

create index if not exists eco_scores_score_idx
  on public.eco_scores(score desc);

create index if not exists eco_score_history_profile_idx
  on public.eco_score_history(profile_id, created_at desc);

drop trigger if exists set_order_preferences_updated_at on public.order_preferences;
create trigger set_order_preferences_updated_at
before update on public.order_preferences
for each row execute function public.set_updated_at();

drop trigger if exists set_support_issues_updated_at on public.support_issues;
create trigger set_support_issues_updated_at
before update on public.support_issues
for each row execute function public.set_updated_at();

create or replace function public.recalculate_eco_score(target_profile_id uuid, reason text)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  waste_points integer := 0;
  recycled_points integer := 0;
  food_points integer := 0;
  donation_points integer := 0;
  saved_points integer := 0;
  total_score integer := 0;
begin
  select coalesce(round(sum(quantity * 4))::integer, 0)
  into waste_points
  from public.waste_records
  where profile_id = target_profile_id
    and record_type = 'waste_reduced';

  select coalesce(round(sum(quantity * 2))::integer, 0)
  into recycled_points
  from public.waste_records
  where profile_id = target_profile_id
    and record_type = 'recycled_item';

  select coalesce(round(sum(quantity * 5))::integer, 0)
  into food_points
  from public.waste_records
  where profile_id = target_profile_id
    and record_type = 'food_saved';

  select coalesce(round(sum(quantity * 6))::integer, 0)
  into donation_points
  from public.waste_records
  where profile_id = target_profile_id
    and record_type = 'donation';

  select count(*)::integer * 12
  into saved_points
  from public.saved_products
  where profile_id = target_profile_id;

  total_score := greatest(
    0,
    500 + waste_points + recycled_points + food_points + donation_points + saved_points
  );

  insert into public.eco_scores(profile_id, score, updated_at)
  values (target_profile_id, total_score, now())
  on conflict (profile_id) do update set
    score = excluded.score,
    updated_at = excluded.updated_at;

  insert into public.eco_score_history(profile_id, score, reason)
  values (target_profile_id, total_score, reason);

  return total_score;
end;
$$;

create or replace function public.refresh_eco_score_from_waste()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_profile_id uuid;
  score integer;
begin
  target_profile_id := coalesce(new.profile_id, old.profile_id);
  score := public.recalculate_eco_score(target_profile_id, 'Waste tracker updated');

  if tg_op = 'INSERT' then
    insert into public.notifications(profile_id, title, body, type)
    values (
      target_profile_id,
      'Waste tracker updated',
      'Your totals and Eco Score were recalculated.',
      'tracker'
    );
  end if;

  return coalesce(new, old);
end;
$$;

create or replace function public.refresh_eco_score_from_saved_product()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_profile_id uuid;
begin
  target_profile_id := coalesce(new.profile_id, old.profile_id);
  perform public.recalculate_eco_score(target_profile_id, 'Saved products updated');

  if tg_op in ('INSERT', 'DELETE') then
    insert into public.notifications(profile_id, title, body, type)
    values (
      target_profile_id,
      'Saved products updated',
      'Your saved products and Eco Score are synced.',
      'saved_product'
    );
  end if;

  return coalesce(new, old);
end;
$$;

drop trigger if exists refresh_eco_score_after_waste_change on public.waste_records;
create trigger refresh_eco_score_after_waste_change
after insert or update or delete on public.waste_records
for each row execute function public.refresh_eco_score_from_waste();

drop trigger if exists refresh_eco_score_after_saved_change on public.saved_products;
create trigger refresh_eco_score_after_saved_change
after insert or update or delete on public.saved_products
for each row execute function public.refresh_eco_score_from_saved_product();

alter table public.saved_products enable row level security;
alter table public.order_preferences enable row level security;
alter table public.support_issues enable row level security;
alter table public.notifications enable row level security;
alter table public.waste_records enable row level security;
alter table public.eco_scores enable row level security;
alter table public.eco_score_history enable row level security;

drop policy if exists "Users can manage saved products" on public.saved_products;
create policy "Users can manage saved products"
on public.saved_products for all
using (auth.uid() = profile_id)
with check (auth.uid() = profile_id);

drop policy if exists "Users can manage order preferences" on public.order_preferences;
create policy "Users can manage order preferences"
on public.order_preferences for all
using (auth.uid() = profile_id)
with check (auth.uid() = profile_id);

drop policy if exists "Users can read their support issues" on public.support_issues;
create policy "Users can read their support issues"
on public.support_issues for select
using (auth.uid() = profile_id);

drop policy if exists "Users can submit support issues" on public.support_issues;
create policy "Users can submit support issues"
on public.support_issues for insert
with check (auth.uid() = profile_id);

drop policy if exists "Users can read their notifications" on public.notifications;
create policy "Users can read their notifications"
on public.notifications for select
using (auth.uid() = profile_id);

drop policy if exists "Users can update their notifications" on public.notifications;
create policy "Users can update their notifications"
on public.notifications for update
using (auth.uid() = profile_id)
with check (auth.uid() = profile_id);

drop policy if exists "Users can read their waste records" on public.waste_records;
create policy "Users can read their waste records"
on public.waste_records for select
using (auth.uid() = profile_id);

drop policy if exists "Users can add waste records" on public.waste_records;
create policy "Users can add waste records"
on public.waste_records for insert
with check (auth.uid() = profile_id);

drop policy if exists "Eco score ranking is public" on public.eco_scores;
create policy "Eco score ranking is public"
on public.eco_scores for select
using (true);

drop policy if exists "Users can read their score history" on public.eco_score_history;
create policy "Users can read their score history"
on public.eco_score_history for select
using (auth.uid() = profile_id);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'profile-photos',
  'profile-photos',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Profile photos are publicly readable" on storage.objects;
create policy "Profile photos are publicly readable"
on storage.objects for select
using (bucket_id = 'profile-photos');

drop policy if exists "Users can upload their profile photos" on storage.objects;
create policy "Users can upload their profile photos"
on storage.objects for insert
with check (
  bucket_id = 'profile-photos'
  and auth.role() = 'authenticated'
  and (storage.foldername(name))[1] = 'profiles'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "Users can update their profile photos" on storage.objects;
create policy "Users can update their profile photos"
on storage.objects for update
using (
  bucket_id = 'profile-photos'
  and owner = auth.uid()
)
with check (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = 'profiles'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "Users can delete their profile photos" on storage.objects;
create policy "Users can delete their profile photos"
on storage.objects for delete
using (
  bucket_id = 'profile-photos'
  and owner = auth.uid()
);
