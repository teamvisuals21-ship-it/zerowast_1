import 'package:flutter/material.dart';

import '../data/marketplace_repository.dart';
import '../models/marketplace_models.dart';
import '../theme/app_theme.dart';
import '../widgets/collection_card.dart';
import '../widgets/nft_card.dart';
import '../widgets/stat_chip.dart';

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({
    super.key,
    required this.repository,
  });

  final MarketplaceRepository repository;

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  late final Future<MarketplaceSnapshot> _marketplaceFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _marketplaceFuture = widget.repository.loadMarketplace();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [
              Color(0x5520E3B2),
              Color(0x227C5CFF),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<MarketplaceSnapshot>(
            future: _marketplaceFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final marketplace = snapshot.data!;
              final filteredAssets = _filterAssets(marketplace.assets);

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      isUsingDemoData: marketplace.isUsingDemoData,
                      onQueryChanged: (value) {
                        setState(() => _query = value);
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _HeroSection(
                      assets: marketplace.assets,
                      collections: marketplace.collections,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: _query.isEmpty ? 'Live auctions' : 'Search result',
                      actionText: '${filteredAssets.length} items',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _AuctionRail(assets: filteredAssets),
                  ),
                  SliverToBoxAdapter(
                    child: _DesktopGrid(
                      collections: marketplace.collections,
                      activity: marketplace.activity,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<NftAsset> _filterAssets(List<NftAsset> assets) {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return assets;
    }

    return assets.where((asset) {
      return asset.title.toLowerCase().contains(normalizedQuery) ||
          asset.collection.title.toLowerCase().contains(normalizedQuery) ||
          asset.owner.handle.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isUsingDemoData,
    required this.onQueryChanged,
  });

  final bool isUsingDemoData;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 760;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Wrap(
        spacing: 18,
        runSpacing: 18,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.blur_on, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                'Niftio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              if (isUsingDemoData) ...[
                const SizedBox(width: 12),
                const _DemoBadge(),
              ],
            ],
          ),
          SizedBox(
            width: isWide ? 420 : MediaQuery.sizeOf(context).width - 48,
            child: TextField(
              onChanged: onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'Search collections, NFTs, or creators',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (isWide)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Explore'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Stats'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('Connect wallet'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Demo data',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.secondary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.assets,
    required this.collections,
  });

  final List<NftAsset> assets;
  final List<NftCollection> collections;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width > 900;
    final leadingAsset = assets.isNotEmpty ? assets.first : null;
    final topCollection = collections.isNotEmpty ? collections.first : null;
    final heroCopy = Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.78),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover, collect, and sell extraordinary NFTs',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'A premium marketplace experience for live auctions, digital collectibles, and verified creators.',
            style: textTheme.titleMedium?.copyWith(
              color: AppTheme.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text('Start exploring'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Create NFT'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              StatChip(
                label: 'Listed NFTs',
                value: '${assets.length * 128}+',
                icon: Icons.grid_view_rounded,
              ),
              StatChip(
                label: 'Top volume',
                value: '${topCollection?.volumeEth.toStringAsFixed(0) ?? '0'} ETH',
                icon: Icons.show_chart_rounded,
              ),
              const StatChip(
                label: 'Creators',
                value: '18K+',
                icon: Icons.verified_rounded,
              ),
            ],
          ),
        ],
      ),
    );
    final featuredCard = leadingAsset == null
        ? const SizedBox.shrink()
        : SizedBox(
            width: isWide ? 390 : double.infinity,
            height: 520,
            child: NftCard(asset: leadingAsset, featured: true),
          );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 6, child: heroCopy),
                const SizedBox(width: 22),
                featuredCard,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heroCopy,
                if (leadingAsset != null) ...[
                  const SizedBox(height: 22),
                  featuredCard,
                ],
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
  });

  final String title;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Spacer(),
          Text(
            actionText,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: AppTheme.secondary),
          ),
        ],
      ),
    );
  }
}

class _AuctionRail extends StatelessWidget {
  const _AuctionRail({required this.assets});

  final List<NftAsset> assets;

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Text('No NFTs matched your search.'),
        ),
      );
    }

    return SizedBox(
      height: 440,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: assets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) => NftCard(asset: assets[index]),
      ),
    );
  }
}

class _DesktopGrid extends StatelessWidget {
  const _DesktopGrid({
    required this.collections,
    required this.activity,
  });

  final List<NftCollection> collections;
  final List<ActivityEvent> activity;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 900;
    final collectionsPanel = _TopCollections(collections: collections);
    final activityPanel = _ActivityPanel(activity: activity);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: collectionsPanel),
                const SizedBox(width: 22),
                Expanded(flex: 4, child: activityPanel),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                collectionsPanel,
                const SizedBox(height: 22),
                activityPanel,
              ],
            ),
    );
  }
}

class _TopCollections extends StatelessWidget {
  const _TopCollections({required this.collections});

  final List<NftCollection> collections;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Top collections',
      child: Column(
        children: [
          for (final entry in collections.asMap().entries) ...[
            CollectionCard(
              collection: entry.value,
              rank: entry.key + 1,
            ),
            if (entry.key != collections.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({required this.activity});

  final List<ActivityEvent> activity;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Recent activity',
      child: Column(
        children: [
          for (final event in activity) ...[
            _ActivityTile(event: event),
            if (event != activity.last) const Divider(height: 24),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.event});

  final ActivityEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.18),
          child: Icon(
            _iconForType(event.type),
            color: AppTheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${event.type.toUpperCase()} - ${event.assetTitle}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '@${event.actor.handle} ${_relativeTime(event.createdAt)}',
                style: textTheme.bodySmall?.copyWith(color: AppTheme.muted),
              ),
            ],
          ),
        ),
        Text(
          '${event.ethValue.toStringAsFixed(2)} ETH',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

IconData _iconForType(String type) {
  switch (type) {
    case 'sale':
      return Icons.shopping_bag_outlined;
    case 'bid':
      return Icons.gavel_outlined;
    case 'listed':
    default:
      return Icons.sell_outlined;
  }
}

String _relativeTime(DateTime createdAt) {
  final difference = DateTime.now().difference(createdAt);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  return '${difference.inDays}d ago';
}
