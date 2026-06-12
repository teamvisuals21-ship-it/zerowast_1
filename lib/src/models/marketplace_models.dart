enum AuctionStatus {
  live,
  endingSoon,
  fixedPrice,
}

class CreatorProfile {
  const CreatorProfile({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.verified,
  });

  final String id;
  final String name;
  final String handle;
  final String avatarUrl;
  final bool verified;

  factory CreatorProfile.fromMap(Map<String, dynamic> map) {
    return CreatorProfile(
      id: map['id'] as String,
      name: map['display_name'] as String? ?? 'Unknown creator',
      handle: map['handle'] as String? ?? 'unknown',
      avatarUrl: map['avatar_url'] as String? ?? '',
      verified: map['verified'] as bool? ?? false,
    );
  }
}

class NftCollection {
  const NftCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.floorEth,
    required this.volumeEth,
    required this.itemCount,
    required this.creator,
  });

  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final double floorEth;
  final double volumeEth;
  final int itemCount;
  final CreatorProfile creator;

  factory NftCollection.fromMap(Map<String, dynamic> map) {
    return NftCollection(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Untitled collection',
      description: map['description'] as String? ?? '',
      coverUrl: map['cover_url'] as String? ?? '',
      floorEth: (map['floor_eth'] as num?)?.toDouble() ?? 0,
      volumeEth: (map['volume_eth'] as num?)?.toDouble() ?? 0,
      itemCount: map['item_count'] as int? ?? 0,
      creator: CreatorProfile.fromMap(
        (map['creator'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class NftAsset {
  const NftAsset({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.priceEth,
    required this.highestBidEth,
    required this.likes,
    required this.endsAt,
    required this.status,
    required this.collection,
    required this.owner,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double priceEth;
  final double highestBidEth;
  final int likes;
  final DateTime? endsAt;
  final AuctionStatus status;
  final NftCollection collection;
  final CreatorProfile owner;

  bool get isLiveAuction => status != AuctionStatus.fixedPrice;

  factory NftAsset.fromMap(Map<String, dynamic> map) {
    return NftAsset(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Untitled NFT',
      description: map['description'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      priceEth: (map['price_eth'] as num?)?.toDouble() ?? 0,
      highestBidEth: (map['highest_bid_eth'] as num?)?.toDouble() ?? 0,
      likes: map['likes'] as int? ?? 0,
      endsAt: DateTime.tryParse(map['ends_at'] as String? ?? ''),
      status: _statusFromString(map['status'] as String?),
      collection: NftCollection.fromMap(
        (map['collection'] as Map<String, dynamic>?) ?? const {},
      ),
      owner: CreatorProfile.fromMap(
        (map['owner'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.type,
    required this.assetTitle,
    required this.ethValue,
    required this.createdAt,
    required this.actor,
  });

  final String id;
  final String type;
  final String assetTitle;
  final double ethValue;
  final DateTime createdAt;
  final CreatorProfile actor;

  factory ActivityEvent.fromMap(Map<String, dynamic> map) {
    return ActivityEvent(
      id: map['id'] as String,
      type: map['event_type'] as String? ?? 'listed',
      assetTitle: map['asset_title'] as String? ?? 'NFT',
      ethValue: (map['eth_value'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      actor: CreatorProfile.fromMap(
        (map['actor'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

AuctionStatus _statusFromString(String? value) {
  switch (value) {
    case 'ending_soon':
      return AuctionStatus.endingSoon;
    case 'fixed_price':
      return AuctionStatus.fixedPrice;
    case 'live':
    default:
      return AuctionStatus.live;
  }
}
