import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/marketplace_models.dart';
import '../theme/app_theme.dart';

class NftCard extends StatelessWidget {
  const NftCard({
    super.key,
    required this.asset,
    this.featured = false,
  });

  final NftAsset asset;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: featured ? 360 : 280,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.16),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CachedNetworkImage(
                      imageUrl: asset.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const _ImageFallback(),
                      placeholder: (_, __) => const _ImageFallback(),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _StatusPill(asset: asset),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.36),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: AppTheme.accent,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text('${asset.likes}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            asset.collection.title,
            style: textTheme.labelLarge?.copyWith(color: AppTheme.secondary),
          ),
          const SizedBox(height: 6),
          Text(
            asset.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PriceBlock(
                label: asset.isLiveAuction ? 'Current bid' : 'Price',
                value:
                    '${asset.isLiveAuction ? asset.highestBidEth : asset.priceEth} ETH',
              ),
              const Spacer(),
              if (asset.endsAt != null)
                _PriceBlock(
                  label: 'Ends',
                  value: DateFormat('h:mm a').format(asset.endsAt!),
                  alignEnd: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.asset});

  final NftAsset asset;

  @override
  Widget build(BuildContext context) {
    final label = switch (asset.status) {
      AuctionStatus.endingSoon => 'Ending soon',
      AuctionStatus.fixedPrice => 'Buy now',
      AuctionStatus.live => 'Live auction',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: AppTheme.muted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.accent],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 42),
    );
  }
}
