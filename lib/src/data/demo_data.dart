import '../models/marketplace_models.dart';

const _creatorNova = CreatorProfile(
  id: '98af08d5-8e4d-45f3-9c8f-1f26cce611c2',
  name: 'Nova Atelier',
  handle: 'novaatelier',
  avatarUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=320&q=80',
  verified: true,
);

const _creatorKaito = CreatorProfile(
  id: '0d129fd1-b4a4-4d79-a4db-ea9c5a76b63e',
  name: 'Kaito Labs',
  handle: 'kaitolabs',
  avatarUrl:
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=320&q=80',
  verified: true,
);

const _creatorMira = CreatorProfile(
  id: 'f373017b-65c5-4b3b-ae92-5b040dfd4152',
  name: 'Mira Vale',
  handle: 'miravale',
  avatarUrl:
      'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=320&q=80',
  verified: false,
);

const _collectionCelestial = NftCollection(
  id: '9a96852d-1190-4b77-ac3d-1b77e57db3e7',
  title: 'Celestial Cybernauts',
  description: 'Chromed space travelers crossing neon galaxies.',
  coverUrl:
      'https://images.unsplash.com/photo-1634193295627-1cdddf751ebf?auto=format&fit=crop&w=900&q=80',
  floorEth: 1.8,
  volumeEth: 420.6,
  itemCount: 2400,
  creator: _creatorNova,
);

const _collectionPrism = NftCollection(
  id: 'dd308d1f-c030-4998-af62-08f01ad3ccbb',
  title: 'Prism District',
  description: 'Generative architecture for metaverse collectors.',
  coverUrl:
      'https://images.unsplash.com/photo-1519608487953-e999c86e7455?auto=format&fit=crop&w=900&q=80',
  floorEth: 0.92,
  volumeEth: 182.1,
  itemCount: 760,
  creator: _creatorKaito,
);

const _collectionFlora = NftCollection(
  id: '2f7907ff-6c52-4499-b51c-42682f524c12',
  title: 'Synthetic Flora',
  description: 'Botanical collectibles grown from algorithmic pigments.',
  coverUrl:
      'https://images.unsplash.com/photo-1618005198919-d3d4b5a92ead?auto=format&fit=crop&w=900&q=80',
  floorEth: 0.64,
  volumeEth: 95.4,
  itemCount: 512,
  creator: _creatorMira,
);

final demoCollections = <NftCollection>[
  _collectionCelestial,
  _collectionPrism,
  _collectionFlora,
];

final demoAssets = <NftAsset>[
  NftAsset(
    id: '725bf110-afbf-4ff9-ad42-908f44ad037b',
    title: 'Astral Runner #08',
    description: 'A reflective explorer built for deep-space auctions.',
    imageUrl:
        'https://images.unsplash.com/photo-1635322966219-b75ed372eb01?auto=format&fit=crop&w=900&q=80',
    priceEth: 2.4,
    highestBidEth: 2.72,
    likes: 128,
    endsAt: DateTime.now().add(const Duration(hours: 7, minutes: 24)),
    status: AuctionStatus.endingSoon,
    collection: _collectionCelestial,
    owner: _creatorNova,
  ),
  NftAsset(
    id: 'adf82e3e-5e63-4da2-ae72-a49a0d98fc57',
    title: 'Neon Habitat #31',
    description: 'A luminous modular home floating above the chain.',
    imageUrl:
        'https://images.unsplash.com/photo-1634986666676-ec8fd927c23d?auto=format&fit=crop&w=900&q=80',
    priceEth: 1.3,
    highestBidEth: 1.47,
    likes: 92,
    endsAt: DateTime.now().add(const Duration(hours: 18, minutes: 12)),
    status: AuctionStatus.live,
    collection: _collectionPrism,
    owner: _creatorKaito,
  ),
  NftAsset(
    id: 'c19f5027-5155-4b6d-9ac8-53308d447379',
    title: 'Glass Orchid #14',
    description: 'An iridescent flower rendered in reactive gradients.',
    imageUrl:
        'https://images.unsplash.com/photo-1617791160505-6f00504e3519?auto=format&fit=crop&w=900&q=80',
    priceEth: 0.84,
    highestBidEth: 0.91,
    likes: 77,
    endsAt: null,
    status: AuctionStatus.fixedPrice,
    collection: _collectionFlora,
    owner: _creatorMira,
  ),
  NftAsset(
    id: '5082cb20-08d4-4926-9e57-81b9675fbdb2',
    title: 'Solar Mask #02',
    description: 'A ceremonial mask for collectors of rare light.',
    imageUrl:
        'https://images.unsplash.com/photo-1633533452148-a9657d2c9a5f?auto=format&fit=crop&w=900&q=80',
    priceEth: 3.18,
    highestBidEth: 3.44,
    likes: 211,
    endsAt: DateTime.now().add(const Duration(hours: 3, minutes: 9)),
    status: AuctionStatus.endingSoon,
    collection: _collectionCelestial,
    owner: _creatorNova,
  ),
];

final demoActivity = <ActivityEvent>[
  ActivityEvent(
    id: '541dfd3d-b56c-4792-aab8-fd9f99b075f6',
    type: 'bid',
    assetTitle: 'Astral Runner #08',
    ethValue: 2.72,
    createdAt: DateTime.now().subtract(const Duration(minutes: 14)),
    actor: _creatorKaito,
  ),
  ActivityEvent(
    id: 'f296faab-7fd3-4860-9767-adcd79aa6672',
    type: 'sale',
    assetTitle: 'Glass Orchid #14',
    ethValue: 0.84,
    createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 6)),
    actor: _creatorMira,
  ),
  ActivityEvent(
    id: '6e6b0292-1c98-4c5d-8f0b-b7000dfb9f60',
    type: 'listed',
    assetTitle: 'Solar Mask #02',
    ethValue: 3.18,
    createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 41)),
    actor: _creatorNova,
  ),
];
