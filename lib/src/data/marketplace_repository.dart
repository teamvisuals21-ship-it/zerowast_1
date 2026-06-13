import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/marketplace_models.dart';
import 'demo_data.dart';

class MarketplaceSnapshot {
  const MarketplaceSnapshot({
    required this.assets,
    required this.collections,
    required this.activity,
    required this.isUsingDemoData,
  });

  final List<NftAsset> assets;
  final List<NftCollection> collections;
  final List<ActivityEvent> activity;
  final bool isUsingDemoData;
}

class MarketplaceRepository {
  const MarketplaceRepository({
    required this.useSupabase,
  });

  final bool useSupabase;

  Future<MarketplaceSnapshot> loadMarketplace() async {
    if (!useSupabase) {
      return _demoSnapshot();
    }

    try {
      final client = Supabase.instance.client;

      final responses = await Future.wait([
        client
            .from('nft_items')
            .select(_assetSelect)
            .order('created_at', ascending: false)
            .limit(12),
        client
            .from('collections')
            .select(_collectionSelect)
            .order('volume_eth', ascending: false)
            .limit(8),
        client
            .from('activity_events')
            .select(_activitySelect)
            .order('created_at', ascending: false)
            .limit(8),
      ]);

      return MarketplaceSnapshot(
        assets: _rows(responses[0]).map(NftAsset.fromMap).toList(),
        collections: _rows(responses[1]).map(NftCollection.fromMap).toList(),
        activity: _rows(responses[2]).map(ActivityEvent.fromMap).toList(),
        isUsingDemoData: false,
      );
    } catch (_) {
      return _demoSnapshot();
    }
  }

  MarketplaceSnapshot _demoSnapshot() {
    return MarketplaceSnapshot(
      assets: demoAssets,
      collections: demoCollections,
      activity: demoActivity,
      isUsingDemoData: true,
    );
  }

  List<Map<String, dynamic>> _rows(Object value) {
    final rows = value as List<dynamic>;
    return rows.cast<Map<String, dynamic>>();
  }
}

const _creatorColumns = '''
id,
display_name,
handle,
avatar_url,
verified
''';

const _collectionSelect = '''
id,
title,
description,
cover_url,
floor_eth,
volume_eth,
item_count,
creator:profiles!collections_creator_id_fkey($_creatorColumns)
''';

const _assetSelect = '''
id,
title,
description,
image_url,
price_eth,
highest_bid_eth,
likes,
ends_at,
status,
collection:collections!nft_items_collection_id_fkey(
  id,
  title,
  description,
  cover_url,
  floor_eth,
  volume_eth,
  item_count,
  creator:profiles!collections_creator_id_fkey($_creatorColumns)
),
owner:profiles!nft_items_owner_id_fkey($_creatorColumns)
''';

const _activitySelect = '''
id,
event_type,
asset_title,
eth_value,
created_at,
actor:profiles!activity_events_actor_id_fkey($_creatorColumns)
''';
