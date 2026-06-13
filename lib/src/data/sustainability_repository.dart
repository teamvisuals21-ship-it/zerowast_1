import 'dart:async';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/marketplace_models.dart';
import '../models/sustainability_models.dart';

class SustainabilityRepository {
  const SustainabilityRepository({
    required this.useSupabase,
  });

  final bool useSupabase;

  static const _demoUserId = '98af08d5-8e4d-45f3-9c8f-1f26cce611c2';
  static UserProfile _demoProfile = const UserProfile(
    id: _demoUserId,
    displayName: 'Nova Atelier',
    handle: 'novaatelier',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=320&q=80',
    photoPath: '',
    verified: true,
  );
  static final Set<String> _demoSavedProductIds = <String>{};
  static OrderPreferences _demoPreferences =
      OrderPreferences.defaults(_demoUserId);
  static final List<AppNotification> _demoNotifications = [
    AppNotification(
      id: 'demo-notification-1',
      title: 'Waste tracker updated',
      body: 'Your monthly waste reduction increased by 4.5 kg.',
      type: 'tracker',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 16)),
    ),
    AppNotification(
      id: 'demo-notification-2',
      title: 'Eco score milestone',
      body: 'You reached 780 eco points. Keep going!',
      type: 'score',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];
  static final List<WasteRecord> _demoWasteRecords = [
    WasteRecord(
      id: 'demo-waste-1',
      type: 'waste_reduced',
      quantity: 12.5,
      unit: 'kg',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WasteRecord(
      id: 'demo-waste-2',
      type: 'recycled_item',
      quantity: 42,
      unit: 'items',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    WasteRecord(
      id: 'demo-waste-3',
      type: 'food_saved',
      quantity: 8.2,
      unit: 'kg',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];
  static final List<SupportIssue> _demoIssues = [];

  Future<SustainabilitySnapshot> loadDashboard({
    required List<NftAsset> availableProducts,
  }) async {
    if (!useSupabase) {
      return _demoSnapshot(availableProducts);
    }

    try {
      final userId = await _currentUserId();
      final client = Supabase.instance.client;
      final profile = await _loadOrCreateProfile(userId);

      final responses = await Future.wait([
        client.from('saved_products').select().eq('profile_id', userId),
        client
            .from('order_preferences')
            .select()
            .eq('profile_id', userId)
            .maybeSingle(),
        client
            .from('notifications')
            .select()
            .eq('profile_id', userId)
            .order('created_at', ascending: false)
            .limit(20),
        client
            .from('waste_records')
            .select()
            .eq('profile_id', userId)
            .order('created_at', ascending: false),
        client
            .from('eco_score_history')
            .select()
            .eq('profile_id', userId)
            .order('created_at', ascending: false)
            .limit(12),
        client
            .from('eco_scores')
            .select('score, profile:profiles(display_name, avatar_url)')
            .order('score', ascending: false)
            .limit(10),
        client
            .from('support_issues')
            .select()
            .eq('profile_id', userId)
            .order('created_at', ascending: false)
            .limit(10),
      ]);

      final savedRows = _rows(responses[0]);
      final savedProductIds = savedRows
          .map((row) => row['product_id'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      final records = _rows(responses[3]).map(WasteRecord.fromMap).toList();

      return SustainabilitySnapshot(
        profile: profile,
        savedProductIds: savedProductIds,
        savedProducts: _productsByIds(availableProducts, savedProductIds),
        orderPreferences: responses[1] == null
            ? OrderPreferences.defaults(userId)
            : OrderPreferences.fromMap(responses[1] as Map<String, dynamic>),
        notifications:
            _rows(responses[2]).map(AppNotification.fromMap).toList(),
        wasteRecords: records,
        wasteSummary: WasteSummary.fromRecords(records),
        ecoScoreHistory:
            _rows(responses[4]).map(EcoScoreEntry.fromMap).toList(),
        ecoRanking: _rows(responses[5]).map(EcoRankingEntry.fromMap).toList(),
        supportIssues: _rows(responses[6]).map(SupportIssue.fromMap).toList(),
        isUsingDemoData: false,
      );
    } catch (_) {
      return _demoSnapshot(availableProducts);
    }
  }

  Stream<List<AppNotification>> watchNotifications() async* {
    if (!useSupabase) {
      yield _demoNotifications;
      return;
    }

    final userId = await _currentUserId();
    yield* Supabase.instance.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('profile_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(AppNotification.fromMap).toList());
  }

  Future<UserProfile> uploadProfilePhoto(XFile file) async {
    final bytes = await file.readAsBytes();
    final extension = _validateImage(file.name, bytes);

    if (!useSupabase) {
      _demoProfile = _demoProfile.copyWith(
        avatarUrl: file.path,
        photoPath: 'demo/${file.name}',
      );
      return _demoProfile;
    }

    try {
      final userId = await _currentUserId();
      final client = Supabase.instance.client;
      final currentProfile = await _loadOrCreateProfile(userId);
      final path =
          'profiles/$userId/avatar-${DateTime.now().millisecondsSinceEpoch}.$extension';

      await client.storage.from('profile-photos').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: _contentTypeForExtension(extension),
              upsert: true,
            ),
          );

      if (currentProfile.photoPath.isNotEmpty) {
        await client.storage
            .from('profile-photos')
            .remove([currentProfile.photoPath]);
      }

      final publicUrl = client.storage.from('profile-photos').getPublicUrl(path);
      await client.from('profiles').update({
        'avatar_url': publicUrl,
        'profile_photo_path': path,
      }).eq('id', userId);

      return currentProfile.copyWith(
        avatarUrl: publicUrl,
        photoPath: path,
      );
    } catch (error) {
      throw FeatureException('Could not upload profile photo: $error');
    }
  }

  Future<UserProfile> deleteProfilePhoto() async {
    if (!useSupabase) {
      _demoProfile = _demoProfile.copyWith(avatarUrl: '', photoPath: '');
      return _demoProfile;
    }

    try {
      final userId = await _currentUserId();
      final client = Supabase.instance.client;
      final currentProfile = await _loadOrCreateProfile(userId);

      if (currentProfile.photoPath.isNotEmpty) {
        await client.storage
            .from('profile-photos')
            .remove([currentProfile.photoPath]);
      }

      await client.from('profiles').update({
        'avatar_url': '',
        'profile_photo_path': '',
      }).eq('id', userId);

      return currentProfile.copyWith(avatarUrl: '', photoPath: '');
    } catch (error) {
      throw FeatureException('Could not delete profile photo: $error');
    }
  }

  Future<bool> toggleSavedProduct(NftAsset product, bool isSaved) async {
    if (!useSupabase) {
      if (isSaved) {
        _demoSavedProductIds.remove(product.id);
        return false;
      }
      _demoSavedProductIds.add(product.id);
      return true;
    }

    try {
      final userId = await _currentUserId();
      final client = Supabase.instance.client;

      if (isSaved) {
        await client
            .from('saved_products')
            .delete()
            .eq('profile_id', userId)
            .eq('product_id', product.id);
        return false;
      }

      await client.from('saved_products').upsert({
        'profile_id': userId,
        'product_id': product.id,
        'product_title': product.title,
        'product_image_url': product.imageUrl,
        'price_eth': product.priceEth,
      });
      return true;
    } catch (error) {
      throw FeatureException('Could not update saved product: $error');
    }
  }

  Future<OrderPreferences> saveOrderPreferences(
    OrderPreferences preferences,
  ) async {
    if (!useSupabase) {
      _demoPreferences = preferences;
      return preferences;
    }

    try {
      final userId = await _currentUserId();
      final updated = preferences.profileId == userId
          ? preferences
          : preferences.copyWith();
      await Supabase.instance.client.from('order_preferences').upsert({
        ...updated.toMap(),
        'profile_id': userId,
      });
      return OrderPreferences.fromMap({
        ...updated.toMap(),
        'profile_id': userId,
      });
    } catch (error) {
      throw FeatureException('Could not save order settings: $error');
    }
  }

  Future<SupportIssue> submitSupportIssue({
    required String subject,
    required String message,
  }) async {
    final normalizedSubject = subject.trim();
    final normalizedMessage = message.trim();

    if (normalizedSubject.length < 4) {
      throw const FeatureException('Issue subject must be at least 4 letters.');
    }
    if (normalizedMessage.length < 10) {
      throw const FeatureException('Please describe the issue in more detail.');
    }

    if (!useSupabase) {
      final issue = SupportIssue(
        id: 'demo-issue-${DateTime.now().millisecondsSinceEpoch}',
        subject: normalizedSubject,
        message: normalizedMessage,
        status: 'open',
        createdAt: DateTime.now(),
      );
      _demoIssues.insert(0, issue);
      return issue;
    }

    try {
      final userId = await _currentUserId();
      final response = await Supabase.instance.client
          .from('support_issues')
          .insert({
            'profile_id': userId,
            'subject': normalizedSubject,
            'message': normalizedMessage,
          })
          .select()
          .single();
      return SupportIssue.fromMap(response);
    } catch (error) {
      throw FeatureException('Could not submit support issue: $error');
    }
  }

  Future<void> markNotificationRead(String id, bool isRead) async {
    if (!useSupabase) {
      final index =
          _demoNotifications.indexWhere((notification) => notification.id == id);
      if (index != -1) {
        final current = _demoNotifications[index];
        _demoNotifications[index] = AppNotification(
          id: current.id,
          title: current.title,
          body: current.body,
          type: current.type,
          isRead: isRead,
          createdAt: current.createdAt,
        );
      }
      return;
    }

    try {
      final userId = await _currentUserId();
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': isRead})
          .eq('profile_id', userId)
          .eq('id', id);
    } catch (error) {
      throw FeatureException('Could not update notification: $error');
    }
  }

  Future<WasteRecord> addWasteRecord({
    required String type,
    required double quantity,
  }) async {
    if (quantity <= 0) {
      throw const FeatureException('Quantity must be greater than zero.');
    }

    final unit = type == 'recycled_item' ? 'items' : 'kg';

    if (!useSupabase) {
      final record = WasteRecord(
        id: 'demo-waste-${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        quantity: quantity,
        unit: unit,
        createdAt: DateTime.now(),
      );
      _demoWasteRecords.insert(0, record);
      _demoNotifications.insert(
        0,
        AppNotification(
          id: 'demo-notification-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Eco activity recorded',
          body: 'Your $type record has updated the waste tracker.',
          type: 'tracker',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
      return record;
    }

    try {
      final userId = await _currentUserId();
      final response = await Supabase.instance.client
          .from('waste_records')
          .insert({
            'profile_id': userId,
            'record_type': type,
            'quantity': quantity,
            'unit': unit,
          })
          .select()
          .single();
      return WasteRecord.fromMap(response);
    } catch (error) {
      throw FeatureException('Could not add waste tracker record: $error');
    }
  }

  Future<String> _currentUserId() async {
    if (!useSupabase) {
      return _demoUserId;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw const FeatureException('Please sign in to use this feature.');
    }
    return user.id;
  }

  Future<UserProfile> _loadOrCreateProfile(String userId) async {
    final client = Supabase.instance.client;
    final existing =
        await client.from('profiles').select().eq('id', userId).maybeSingle();

    if (existing != null) {
      return UserProfile.fromMap(existing);
    }

    final email = client.auth.currentUser?.email ?? 'eco-member@example.com';
    final handle = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final response = await client
        .from('profiles')
        .insert({
          'id': userId,
          'display_name': handle.isEmpty ? 'Eco member' : handle,
          'handle': '$handle-${userId.substring(0, 6)}',
        })
        .select()
        .single();
    return UserProfile.fromMap(response);
  }

  SustainabilitySnapshot _demoSnapshot(List<NftAsset> availableProducts) {
    final savedProducts = _productsByIds(availableProducts, _demoSavedProductIds);
    final summary = WasteSummary.fromRecords(_demoWasteRecords);
    final score = _calculateDemoScore(summary, _demoSavedProductIds.length);

    return SustainabilitySnapshot(
      profile: _demoProfile,
      savedProductIds: _demoSavedProductIds,
      savedProducts: savedProducts,
      orderPreferences: _demoPreferences,
      notifications: _demoNotifications,
      wasteRecords: _demoWasteRecords,
      wasteSummary: summary,
      ecoScoreHistory: [
        EcoScoreEntry(
          id: 'demo-score-now',
          score: score,
          reason: 'Automatic score from waste, food, recycling, and saves.',
          createdAt: DateTime.now(),
        ),
        EcoScoreEntry(
          id: 'demo-score-last',
          score: score - 42,
          reason: 'Previous score checkpoint.',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
      ecoRanking: [
        EcoRankingEntry(
          profileName: _demoProfile.displayName,
          avatarUrl: _demoProfile.avatarUrl,
          score: score,
        ),
        const EcoRankingEntry(
          profileName: 'Mira Vale',
          avatarUrl:
              'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=320&q=80',
          score: 690,
        ),
        const EcoRankingEntry(
          profileName: 'Kaito Labs',
          avatarUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=320&q=80',
          score: 642,
        ),
      ],
      supportIssues: _demoIssues,
      isUsingDemoData: true,
    );
  }

  List<Map<String, dynamic>> _rows(Object? value) {
    final rows = value as List<dynamic>? ?? const [];
    return rows.cast<Map<String, dynamic>>();
  }

  List<NftAsset> _productsByIds(List<NftAsset> products, Set<String> ids) {
    return products.where((product) => ids.contains(product.id)).toList();
  }

  int _calculateDemoScore(WasteSummary summary, int savedProducts) {
    return 500 +
        (summary.totalWasteReducedKg * 4).round() +
        (summary.totalFoodSavedKg * 5).round() +
        (summary.totalRecycledItems * 2) +
        (savedProducts * 12);
  }

  String _validateImage(String fileName, Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const FeatureException('Selected image is empty.');
    }
    if (bytes.length > 5 * 1024 * 1024) {
      throw const FeatureException('Image must be smaller than 5 MB.');
    }

    final extension = fileName.split('.').last.toLowerCase();
    const allowed = {'jpg', 'jpeg', 'png', 'webp'};
    if (!allowed.contains(extension)) {
      throw const FeatureException('Use a JPG, PNG, or WebP profile photo.');
    }
    return extension == 'jpeg' ? 'jpg' : extension;
  }

  String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
