insert into public.profiles (
  id,
  display_name,
  handle,
  avatar_url,
  verified
) values
  (
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'Nova Atelier',
    'novaatelier',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=320&q=80',
    true
  ),
  (
    '0d129fd1-b4a4-4d79-a4db-ea9c5a76b63e',
    'Kaito Labs',
    'kaitolabs',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=320&q=80',
    true
  ),
  (
    'f373017b-65c5-4b3b-ae92-5b040dfd4152',
    'Mira Vale',
    'miravale',
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=320&q=80',
    false
  )
on conflict (id) do update set
  display_name = excluded.display_name,
  handle = excluded.handle,
  avatar_url = excluded.avatar_url,
  verified = excluded.verified;

insert into public.collections (
  id,
  creator_id,
  title,
  description,
  cover_url,
  floor_eth,
  volume_eth,
  item_count
) values
  (
    '9a96852d-1190-4b77-ac3d-1b77e57db3e7',
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'Celestial Cybernauts',
    'Chromed space travelers crossing neon galaxies.',
    'https://images.unsplash.com/photo-1634193295627-1cdddf751ebf?auto=format&fit=crop&w=900&q=80',
    1.8,
    420.6,
    2400
  ),
  (
    'dd308d1f-c030-4998-af62-08f01ad3ccbb',
    '0d129fd1-b4a4-4d79-a4db-ea9c5a76b63e',
    'Prism District',
    'Generative architecture for metaverse collectors.',
    'https://images.unsplash.com/photo-1519608487953-e999c86e7455?auto=format&fit=crop&w=900&q=80',
    0.92,
    182.1,
    760
  ),
  (
    '2f7907ff-6c52-4499-b51c-42682f524c12',
    'f373017b-65c5-4b3b-ae92-5b040dfd4152',
    'Synthetic Flora',
    'Botanical collectibles grown from algorithmic pigments.',
    'https://images.unsplash.com/photo-1618005198919-d3d4b5a92ead?auto=format&fit=crop&w=900&q=80',
    0.64,
    95.4,
    512
  )
on conflict (id) do update set
  creator_id = excluded.creator_id,
  title = excluded.title,
  description = excluded.description,
  cover_url = excluded.cover_url,
  floor_eth = excluded.floor_eth,
  volume_eth = excluded.volume_eth,
  item_count = excluded.item_count;

insert into public.nft_items (
  id,
  collection_id,
  owner_id,
  token_id,
  title,
  description,
  image_url,
  price_eth,
  highest_bid_eth,
  likes,
  status,
  ends_at
) values
  (
    '725bf110-afbf-4ff9-ad42-908f44ad037b',
    '9a96852d-1190-4b77-ac3d-1b77e57db3e7',
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'CYBER-08',
    'Astral Runner #08',
    'A reflective explorer built for deep-space auctions.',
    'https://images.unsplash.com/photo-1635322966219-b75ed372eb01?auto=format&fit=crop&w=900&q=80',
    2.4,
    2.72,
    128,
    'ending_soon',
    now() + interval '7 hours 24 minutes'
  ),
  (
    'adf82e3e-5e63-4da2-ae72-a49a0d98fc57',
    'dd308d1f-c030-4998-af62-08f01ad3ccbb',
    '0d129fd1-b4a4-4d79-a4db-ea9c5a76b63e',
    'PRISM-31',
    'Neon Habitat #31',
    'A luminous modular home floating above the chain.',
    'https://images.unsplash.com/photo-1634986666676-ec8fd927c23d?auto=format&fit=crop&w=900&q=80',
    1.3,
    1.47,
    92,
    'live',
    now() + interval '18 hours 12 minutes'
  ),
  (
    'c19f5027-5155-4b6d-9ac8-53308d447379',
    '2f7907ff-6c52-4499-b51c-42682f524c12',
    'f373017b-65c5-4b3b-ae92-5b040dfd4152',
    'FLORA-14',
    'Glass Orchid #14',
    'An iridescent flower rendered in reactive gradients.',
    'https://images.unsplash.com/photo-1617791160505-6f00504e3519?auto=format&fit=crop&w=900&q=80',
    0.84,
    0.91,
    77,
    'fixed_price',
    null
  ),
  (
    '5082cb20-08d4-4926-9e57-81b9675fbdb2',
    '9a96852d-1190-4b77-ac3d-1b77e57db3e7',
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'CYBER-02',
    'Solar Mask #02',
    'A ceremonial mask for collectors of rare light.',
    'https://images.unsplash.com/photo-1633533452148-a9657d2c9a5f?auto=format&fit=crop&w=900&q=80',
    3.18,
    3.44,
    211,
    'ending_soon',
    now() + interval '3 hours 9 minutes'
  )
on conflict (id) do update set
  collection_id = excluded.collection_id,
  owner_id = excluded.owner_id,
  token_id = excluded.token_id,
  title = excluded.title,
  description = excluded.description,
  image_url = excluded.image_url,
  price_eth = excluded.price_eth,
  highest_bid_eth = excluded.highest_bid_eth,
  likes = excluded.likes,
  status = excluded.status,
  ends_at = excluded.ends_at;

insert into public.bids (
  id,
  nft_item_id,
  bidder_id,
  bid_eth
) values
  (
    '0888e60a-ed11-45ed-b53c-bbba3422acfe',
    '725bf110-afbf-4ff9-ad42-908f44ad037b',
    '0d129fd1-b4a4-4d79-a4db-ea9c5a76b63e',
    2.72
  ),
  (
    'e442f6a1-5693-44e5-af98-08029079ea40',
    'adf82e3e-5e63-4da2-ae72-a49a0d98fc57',
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    1.47
  )
on conflict (id) do update set
  nft_item_id = excluded.nft_item_id,
  bidder_id = excluded.bidder_id,
  bid_eth = excluded.bid_eth;

insert into public.activity_events (
  id,
  actor_id,
  nft_item_id,
  event_type,
  asset_title,
  eth_value,
  created_at
) values
  (
    '541dfd3d-b56c-4792-aab8-fd9f99b075f6',
    '0d129fd1-b4a4-4d79-a4db-ea9c5a76b63e',
    '725bf110-afbf-4ff9-ad42-908f44ad037b',
    'bid',
    'Astral Runner #08',
    2.72,
    now() - interval '14 minutes'
  ),
  (
    'f296faab-7fd3-4860-9767-adcd79aa6672',
    'f373017b-65c5-4b3b-ae92-5b040dfd4152',
    'c19f5027-5155-4b6d-9ac8-53308d447379',
    'sale',
    'Glass Orchid #14',
    0.84,
    now() - interval '1 hour 6 minutes'
  ),
  (
    '6e6b0292-1c98-4c5d-8f0b-b7000dfb9f60',
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    '5082cb20-08d4-4926-9e57-81b9675fbdb2',
    'listed',
    'Solar Mask #02',
    3.18,
    now() - interval '3 hours 41 minutes'
  )
on conflict (id) do update set
  actor_id = excluded.actor_id,
  nft_item_id = excluded.nft_item_id,
  event_type = excluded.event_type,
  asset_title = excluded.asset_title,
  eth_value = excluded.eth_value,
  created_at = excluded.created_at;

insert into public.order_preferences (
  profile_id,
  delivery_window,
  packaging_preference,
  allow_substitutions,
  contactless_delivery,
  notes
) values
  (
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'Evening',
    'Reusable bags',
    true,
    false,
    'Leave rescued food at the front desk.'
  )
on conflict (profile_id) do update set
  delivery_window = excluded.delivery_window,
  packaging_preference = excluded.packaging_preference,
  allow_substitutions = excluded.allow_substitutions,
  contactless_delivery = excluded.contactless_delivery,
  notes = excluded.notes;

insert into public.saved_products (
  profile_id,
  product_id,
  product_title,
  product_image_url,
  price_eth
) values
  (
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    '725bf110-afbf-4ff9-ad42-908f44ad037b',
    'Astral Runner #08',
    'https://images.unsplash.com/photo-1635322966219-b75ed372eb01?auto=format&fit=crop&w=900&q=80',
    2.4
  ),
  (
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'c19f5027-5155-4b6d-9ac8-53308d447379',
    'Glass Orchid #14',
    'https://images.unsplash.com/photo-1617791160505-6f00504e3519?auto=format&fit=crop&w=900&q=80',
    0.84
  )
on conflict (profile_id, product_id) do update set
  product_title = excluded.product_title,
  product_image_url = excluded.product_image_url,
  price_eth = excluded.price_eth;

insert into public.notifications (
  id,
  profile_id,
  title,
  body,
  type,
  is_read,
  created_at
) values
  (
    '53839bd9-4000-4f41-9833-e1d58e2f6e84',
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'Welcome to EcoHub',
    'Your profile, saved products, tracker, and notifications are synced.',
    'general',
    false,
    now() - interval '20 minutes'
  ),
  (
    '78a2c88d-29c2-46ee-9077-0cb83d47d14c',
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'Order settings ready',
    'Reusable packaging and delivery preferences are active.',
    'order',
    true,
    now() - interval '2 hours'
  )
on conflict (id) do update set
  title = excluded.title,
  body = excluded.body,
  type = excluded.type,
  is_read = excluded.is_read,
  created_at = excluded.created_at;

insert into public.waste_records (
  id,
  profile_id,
  record_type,
  quantity,
  unit,
  created_at
) values
  (
    '2e0c3b01-b137-4a6f-b2a9-281836843f38',
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'waste_reduced',
    12.5,
    'kg',
    now() - interval '2 days'
  ),
  (
    'de828407-59de-4015-a547-654de306266d',
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'recycled_item',
    42,
    'items',
    now() - interval '4 days'
  ),
  (
    'b68670b3-a836-41ab-bdbf-d4ce4ba6fe33',
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'food_saved',
    8.2,
    'kg',
    now() - interval '8 days'
  )
on conflict (id) do update set
  profile_id = excluded.profile_id,
  record_type = excluded.record_type,
  quantity = excluded.quantity,
  unit = excluded.unit,
  created_at = excluded.created_at;

insert into public.support_issues (
  id,
  profile_id,
  subject,
  message,
  status,
  created_at
) values
  (
    '068f9aa4-e531-45aa-a075-6c1bdcaa35d6',
    '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
    'Sample pickup question',
    'Can I update the preferred pickup window after placing an order?',
    'open',
    now() - interval '1 day'
  )
on conflict (id) do update set
  subject = excluded.subject,
  message = excluded.message,
  status = excluded.status,
  created_at = excluded.created_at;

select public.recalculate_eco_score(
  '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
  'Seed data recalculation'
);
