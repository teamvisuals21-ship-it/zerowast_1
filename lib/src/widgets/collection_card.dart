import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/marketplace_models.dart';
import '../theme/app_theme.dart';

class CollectionCard extends StatelessWidget {
  const CollectionCard({
    super.key,
    required this.collection,
    required this.rank,
  });

  final NftCollection collection;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '#$rank',
              style: textTheme.titleMedium?.copyWith(
                color: AppTheme.secondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CachedNetworkImage(
              imageUrl: collection.coverUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const _ImageFallback(),
              placeholder: (_, __) => const _ImageFallback(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${collection.creator.handle}',
                  style: textTheme.bodySmall?.copyWith(color: AppTheme.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${collection.floorEth.toStringAsFixed(2)} ETH',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${collection.volumeEth.toStringAsFixed(1)} vol',
                style: textTheme.bodySmall?.copyWith(color: AppTheme.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceElevated,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppTheme.muted),
    );
  }
}
