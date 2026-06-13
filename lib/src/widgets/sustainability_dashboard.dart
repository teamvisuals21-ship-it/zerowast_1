import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../data/sustainability_repository.dart';
import '../models/marketplace_models.dart';
import '../models/sustainability_models.dart';
import '../theme/app_theme.dart';

class SustainabilityDashboard extends StatelessWidget {
  const SustainabilityDashboard({
    super.key,
    required this.snapshot,
    required this.availableProducts,
    required this.repository,
    required this.onRefresh,
  });

  final SustainabilitySnapshot snapshot;
  final List<NftAsset> availableProducts;
  final SustainabilityRepository repository;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 980;
    final dashboardChildren = [
      ProfilePhotoPanel(
        profile: snapshot.profile,
        repository: repository,
        onRefresh: onRefresh,
      ),
      SavedProductsPanel(
        savedProducts: snapshot.savedProducts,
        savedProductIds: snapshot.savedProductIds,
        availableProducts: availableProducts,
        repository: repository,
        onRefresh: onRefresh,
      ),
      OrderSettingsPanel(
        preferences: snapshot.orderPreferences,
        repository: repository,
        onRefresh: onRefresh,
      ),
      HelpCenterPanel(
        repository: repository,
        issues: snapshot.supportIssues,
        onRefresh: onRefresh,
      ),
      WasteTrackerPanel(
        summary: snapshot.wasteSummary,
        repository: repository,
        onRefresh: onRefresh,
      ),
      EcoScorePanel(
        history: snapshot.ecoScoreHistory,
        ranking: snapshot.ecoRanking,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'User dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const Spacer(),
              if (snapshot.isUsingDemoData)
                const _StatusBadge(label: 'Demo fallback'),
            ],
          ),
          const SizedBox(height: 18),
          if (isWide)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dashboardChildren.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) => dashboardChildren[index],
            )
          else
            Column(
              children: [
                for (final child in dashboardChildren) ...[
                  child,
                  if (child != dashboardChildren.last) const SizedBox(height: 18),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class FixedNotificationBar extends StatelessWidget {
  const FixedNotificationBar({
    super.key,
    required this.repository,
    required this.fallbackNotifications,
    required this.onRefresh,
  });

  final SustainabilityRepository repository;
  final List<AppNotification> fallbackNotifications;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 24,
      child: StreamBuilder<List<AppNotification>>(
        stream: repository.watchNotifications(),
        initialData: fallbackNotifications,
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? fallbackNotifications;
          final unreadCount = notifications
              .where((notification) => !notification.isRead)
              .length;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: AppTheme.surface,
                  isScrollControlled: true,
                  builder: (_) => _NotificationsSheet(
                    notifications: notifications,
                    repository: repository,
                    onRefresh: onRefresh,
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.26),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_active_outlined),
                        if (unreadCount > 0)
                          Positioned(
                            right: -8,
                            top: -8,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    const Text('Alerts'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfilePhotoPanel extends StatefulWidget {
  const ProfilePhotoPanel({
    super.key,
    required this.profile,
    required this.repository,
    required this.onRefresh,
  });

  final UserProfile profile;
  final SustainabilityRepository repository;
  final VoidCallback onRefresh;

  @override
  State<ProfilePhotoPanel> createState() => _ProfilePhotoPanelState();
}

class _ProfilePhotoPanelState extends State<ProfilePhotoPanel> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      title: 'Profile photo',
      icon: Icons.account_circle_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(profile: widget.profile, radius: 42),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profile.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      '@${widget.profile.handle}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Upload JPG, PNG, or WebP images up to 5 MB. Photos are stored in Supabase Storage and reused across the app.',
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
          ),
          const Spacer(),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _uploadPhoto,
                icon: _isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file_outlined),
                label: const Text('Upload / update'),
              ),
              OutlinedButton.icon(
                onPressed: _isBusy || widget.profile.avatarUrl.isEmpty
                    ? null
                    : _deletePhoto,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (image == null) {
      return;
    }

    await _runAction(() => widget.repository.uploadProfilePhoto(image));
  }

  Future<void> _deletePhoto() async {
    await _runAction(widget.repository.deleteProfilePhoto);
  }

  Future<void> _runAction(Future<Object?> Function() action) async {
    setState(() => _isBusy = true);
    try {
      await action();
      if (mounted) {
        _showSnack(context, 'Profile photo updated.');
      }
      widget.onRefresh();
    } catch (error) {
      if (mounted) {
        _showSnack(context, error.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}

class SavedProductsPanel extends StatelessWidget {
  const SavedProductsPanel({
    super.key,
    required this.savedProducts,
    required this.savedProductIds,
    required this.availableProducts,
    required this.repository,
    required this.onRefresh,
  });

  final List<NftAsset> savedProducts;
  final Set<String> savedProductIds;
  final List<NftAsset> availableProducts;
  final SustainabilityRepository repository;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final previewProducts =
        savedProducts.isEmpty ? availableProducts.take(3).toList() : savedProducts;

    return _DashboardPanel(
      title: 'Saved products',
      icon: Icons.bookmark_added_outlined,
      child: Column(
        children: [
          Expanded(
            child: previewProducts.isEmpty
                ? const Center(child: Text('No products available yet.'))
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final product = previewProducts[index];
                      final isSaved = savedProductIds.contains(product.id);
                      return _SavedProductTile(
                        product: product,
                        isSaved: isSaved,
                        repository: repository,
                        onRefresh: onRefresh,
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: previewProducts.length,
                  ),
          ),
          if (savedProducts.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tap a heart on any product to persist it after logout/login.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.muted),
              ),
            ),
        ],
      ),
    );
  }
}

class _SavedProductTile extends StatefulWidget {
  const _SavedProductTile({
    required this.product,
    required this.isSaved,
    required this.repository,
    required this.onRefresh,
  });

  final NftAsset product;
  final bool isSaved;
  final SustainabilityRepository repository;
  final VoidCallback onRefresh;

  @override
  State<_SavedProductTile> createState() => _SavedProductTileState();
}

class _SavedProductTileState extends State<_SavedProductTile> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: widget.product.imageUrl,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const _ImageFallback(size: 52),
            placeholder: (_, __) => const _ImageFallback(size: 52),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                '${widget.product.priceEth.toStringAsFixed(2)} ETH',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.muted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _isBusy ? null : _toggle,
          icon: Icon(
            widget.isSaved ? Icons.favorite : Icons.favorite_border,
            color: widget.isSaved ? AppTheme.accent : AppTheme.muted,
          ),
        ),
      ],
    );
  }

  Future<void> _toggle() async {
    setState(() => _isBusy = true);
    try {
      await widget.repository.toggleSavedProduct(widget.product, widget.isSaved);
      widget.onRefresh();
    } catch (error) {
      if (mounted) {
        _showSnack(context, error.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}

class OrderSettingsPanel extends StatefulWidget {
  const OrderSettingsPanel({
    super.key,
    required this.preferences,
    required this.repository,
    required this.onRefresh,
  });

  final OrderPreferences preferences;
  final SustainabilityRepository repository;
  final VoidCallback onRefresh;

  @override
  State<OrderSettingsPanel> createState() => _OrderSettingsPanelState();
}

class _OrderSettingsPanelState extends State<OrderSettingsPanel> {
  late OrderPreferences _preferences;
  late final TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences;
    _notesController = TextEditingController(text: _preferences.notes);
  }

  @override
  void didUpdateWidget(OrderSettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preferences != widget.preferences) {
      _preferences = widget.preferences;
      _notesController.text = widget.preferences.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      title: 'Order settings',
      icon: Icons.tune_outlined,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _preferences.deliveryWindow,
            decoration: const InputDecoration(labelText: 'Delivery window'),
            items: const ['Morning', 'Afternoon', 'Evening', 'Weekend']
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _preferences = _preferences.copyWith(deliveryWindow: value);
                });
              }
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _preferences.packagingPreference,
            decoration: const InputDecoration(labelText: 'Packaging'),
            items: const ['Reusable bags', 'Compostable', 'No packaging']
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _preferences =
                      _preferences.copyWith(packagingPreference: value);
                });
              }
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _preferences.allowSubstitutions,
            onChanged: (value) {
              setState(() {
                _preferences = _preferences.copyWith(allowSubstitutions: value);
              });
            },
            title: const Text('Allow substitutions'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _preferences.contactlessDelivery,
            onChanged: (value) {
              setState(() {
                _preferences = _preferences.copyWith(contactlessDelivery: value);
              });
            },
            title: const Text('Contactless delivery'),
          ),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Delivery notes',
              hintText: 'Gate code, pickup preference, or allergies',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Saving...' : 'Save settings'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updated = _preferences.copyWith(notes: _notesController.text);
      await widget.repository.saveOrderPreferences(updated);
      widget.onRefresh();
      if (mounted) {
        _showSnack(context, 'Order settings saved.');
      }
    } catch (error) {
      if (mounted) {
        _showSnack(context, error.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class HelpCenterPanel extends StatefulWidget {
  const HelpCenterPanel({
    super.key,
    required this.repository,
    required this.issues,
    required this.onRefresh,
  });

  final SustainabilityRepository repository;
  final List<SupportIssue> issues;
  final VoidCallback onRefresh;

  @override
  State<HelpCenterPanel> createState() => _HelpCenterPanelState();
}

class _HelpCenterPanelState extends State<HelpCenterPanel> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      title: 'Help Center',
      icon: Icons.support_agent_outlined,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _StatusBadge(label: 'Support: 01747104029'),
          const SizedBox(height: 12),
          const _FaqItem(
            question: 'How do saved products work?',
            answer:
                'Saved products are stored in Supabase and loaded again after login.',
          ),
          const _FaqItem(
            question: 'How is Eco Score calculated?',
            answer:
                'The score is recalculated from saved food, recycled items, donations, and reduced waste.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Issue subject'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Report issue',
              hintText: 'Describe the problem you found',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitIssue,
            icon: const Icon(Icons.send_outlined),
            label: Text(_isSubmitting ? 'Submitting...' : 'Submit issue'),
          ),
          const SizedBox(height: 12),
          Text(
            'Live support is available every day from 9 AM to 10 PM. For urgent order problems, call the support number above.',
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
          ),
          if (widget.issues.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Recent reports',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            for (final issue in widget.issues.take(2))
              Text('- ${issue.subject} (${issue.status})'),
          ],
        ],
      ),
    );
  }

  Future<void> _submitIssue() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.repository.submitSupportIssue(
        subject: _subjectController.text,
        message: _messageController.text,
      );
      _subjectController.clear();
      _messageController.clear();
      widget.onRefresh();
      if (mounted) {
        _showSnack(context, 'Support issue submitted.');
      }
    } catch (error) {
      if (mounted) {
        _showSnack(context, error.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class WasteTrackerPanel extends StatefulWidget {
  const WasteTrackerPanel({
    super.key,
    required this.summary,
    required this.repository,
    required this.onRefresh,
  });

  final WasteSummary summary;
  final SustainabilityRepository repository;
  final VoidCallback onRefresh;

  @override
  State<WasteTrackerPanel> createState() => _WasteTrackerPanelState();
}

class _WasteTrackerPanelState extends State<WasteTrackerPanel> {
  final _quantityController = TextEditingController(text: '1');
  String _type = 'waste_reduced';
  bool _isAdding = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthTotal = widget.summary.monthlyWasteReducedKg.entries.isEmpty
        ? 0.0
        : widget.summary.monthlyWasteReducedKg.entries.last.value;

    return _DashboardPanel(
      title: 'Waste tracker',
      icon: Icons.recycling_outlined,
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(
                label: 'Waste reduced',
                value: '${widget.summary.totalWasteReducedKg.toStringAsFixed(1)} kg',
              ),
              _MetricPill(
                label: 'Recycled items',
                value: '${widget.summary.totalRecycledItems}',
              ),
              _MetricPill(
                label: 'Food saved',
                value: '${widget.summary.totalFoodSavedKg.toStringAsFixed(1)} kg',
              ),
              _MetricPill(
                label: 'This month',
                value: '${monthTotal.toStringAsFixed(1)} kg',
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Record type'),
            items: const {
              'waste_reduced': 'Waste reduced',
              'recycled_item': 'Recycled items',
              'food_saved': 'Food saved',
              'donation': 'Donation',
            }
                .entries
                .map((entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _type = value);
              }
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _type == 'recycled_item' ? 'Items' : 'Kilograms',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isAdding ? null : _addRecord,
              icon: const Icon(Icons.add_chart_outlined),
              label: Text(_isAdding ? 'Adding...' : 'Add record'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addRecord() async {
    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null) {
      _showSnack(context, 'Enter a valid quantity.', isError: true);
      return;
    }

    setState(() => _isAdding = true);
    try {
      await widget.repository.addWasteRecord(type: _type, quantity: quantity);
      widget.onRefresh();
      if (mounted) {
        _showSnack(context, 'Tracker updated and Eco Score recalculated.');
      }
    } catch (error) {
      if (mounted) {
        _showSnack(context, error.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }
}

class EcoScorePanel extends StatelessWidget {
  const EcoScorePanel({
    super.key,
    required this.history,
    required this.ranking,
  });

  final List<EcoScoreEntry> history;
  final List<EcoRankingEntry> ranking;

  @override
  Widget build(BuildContext context) {
    final currentScore = history.isEmpty ? 0 : history.first.score;

    return _DashboardPanel(
      title: 'Eco Score',
      icon: Icons.emoji_events_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$currentScore',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.secondary,
                ),
          ),
          Text(
            'Automatic score from saved food, recycling, donations, and reduced waste.',
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
          ),
          const SizedBox(height: 12),
          Text(
            'History',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          for (final entry in history.take(2))
            Text(
              '${DateFormat.MMMd().format(entry.createdAt)} - ${entry.score}: ${entry.reason}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 12),
          Text(
            'Ranking',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final rank = ranking[index];
                return Row(
                  children: [
                    SizedBox(width: 28, child: Text('#${index + 1}')),
                    _RankingAvatar(rank: rank),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        rank.profileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('${rank.score}'),
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: ranking.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({
    required this.notifications,
    required this.repository,
    required this.onRefresh,
  });

  final List<AppNotification> notifications;
  final SustainabilityRepository repository;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.74,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: notifications.isEmpty
                    ? const Center(child: Text('No notifications yet.'))
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              notification.isRead
                                  ? Icons.mark_email_read_outlined
                                  : Icons.mark_email_unread_outlined,
                              color: notification.isRead
                                  ? AppTheme.muted
                                  : AppTheme.secondary,
                            ),
                            title: Text(notification.title),
                            subtitle: Text(notification.body),
                            trailing: TextButton(
                              onPressed: () async {
                                await repository.markNotificationRead(
                                  notification.id,
                                  !notification.isRead,
                                );
                                onRefresh();
                              },
                              child: Text(
                                notification.isRead
                                    ? 'Mark unread'
                                    : 'Mark read',
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(),
                        itemCount: notifications.length,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 430,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.84),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.secondary),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.profile,
    required this.radius,
  });

  final UserProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = profile.avatarUrl.startsWith('http');

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.surfaceElevated,
      backgroundImage: hasNetworkImage ? NetworkImage(profile.avatarUrl) : null,
      child: hasNetworkImage
          ? null
          : Text(
              profile.displayName.isEmpty
                  ? '?'
                  : profile.displayName[0].toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
    );
  }
}

class _RankingAvatar extends StatelessWidget {
  const _RankingAvatar({required this.rank});

  final EcoRankingEntry rank;

  @override
  Widget build(BuildContext context) {
    if (rank.avatarUrl.startsWith('http')) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(rank.avatarUrl),
      );
    }
    return const CircleAvatar(
      radius: 16,
      backgroundColor: AppTheme.surfaceElevated,
      child: Icon(Icons.person_outline, size: 16),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 142,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(question),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            answer,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.secondary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppTheme.surfaceElevated,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppTheme.muted),
    );
  }
}

void _showSnack(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
    ),
  );
}
