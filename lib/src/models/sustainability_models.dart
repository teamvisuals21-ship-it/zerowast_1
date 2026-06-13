import 'marketplace_models.dart';

class FeatureException implements Exception {
  const FeatureException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.handle,
    required this.avatarUrl,
    required this.photoPath,
    required this.verified,
  });

  final String id;
  final String displayName;
  final String handle;
  final String avatarUrl;
  final String photoPath;
  final bool verified;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String? ?? '',
      displayName: map['display_name'] as String? ?? 'Eco member',
      handle: map['handle'] as String? ?? 'eco-member',
      avatarUrl: map['avatar_url'] as String? ?? '',
      photoPath: map['profile_photo_path'] as String? ?? '',
      verified: map['verified'] as bool? ?? false,
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? handle,
    String? avatarUrl,
    String? photoPath,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      photoPath: photoPath ?? this.photoPath,
      verified: verified,
    );
  }
}

class OrderPreferences {
  const OrderPreferences({
    required this.profileId,
    required this.deliveryWindow,
    required this.packagingPreference,
    required this.allowSubstitutions,
    required this.contactlessDelivery,
    required this.notes,
  });

  final String profileId;
  final String deliveryWindow;
  final String packagingPreference;
  final bool allowSubstitutions;
  final bool contactlessDelivery;
  final String notes;

  factory OrderPreferences.defaults(String profileId) {
    return OrderPreferences(
      profileId: profileId,
      deliveryWindow: 'Evening',
      packagingPreference: 'Reusable bags',
      allowSubstitutions: true,
      contactlessDelivery: false,
      notes: '',
    );
  }

  factory OrderPreferences.fromMap(Map<String, dynamic> map) {
    return OrderPreferences(
      profileId: map['profile_id'] as String? ?? '',
      deliveryWindow: map['delivery_window'] as String? ?? 'Evening',
      packagingPreference:
          map['packaging_preference'] as String? ?? 'Reusable bags',
      allowSubstitutions: map['allow_substitutions'] as bool? ?? true,
      contactlessDelivery: map['contactless_delivery'] as bool? ?? false,
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'delivery_window': deliveryWindow,
      'packaging_preference': packagingPreference,
      'allow_substitutions': allowSubstitutions,
      'contactless_delivery': contactlessDelivery,
      'notes': notes,
    };
  }

  OrderPreferences copyWith({
    String? deliveryWindow,
    String? packagingPreference,
    bool? allowSubstitutions,
    bool? contactlessDelivery,
    String? notes,
  }) {
    return OrderPreferences(
      profileId: profileId,
      deliveryWindow: deliveryWindow ?? this.deliveryWindow,
      packagingPreference: packagingPreference ?? this.packagingPreference,
      allowSubstitutions: allowSubstitutions ?? this.allowSubstitutions,
      contactlessDelivery: contactlessDelivery ?? this.contactlessDelivery,
      notes: notes ?? this.notes,
    );
  }
}

class SupportIssue {
  const SupportIssue({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;

  factory SupportIssue.fromMap(Map<String, dynamic> map) {
    return SupportIssue(
      id: map['id'] as String? ?? '',
      subject: map['subject'] as String? ?? 'Support request',
      message: map['message'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
      createdAt: parseDate(map['created_at']),
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Notification',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      isRead: map['is_read'] as bool? ?? false,
      createdAt: parseDate(map['created_at']),
    );
  }
}

class WasteRecord {
  const WasteRecord({
    required this.id,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.createdAt,
  });

  final String id;
  final String type;
  final double quantity;
  final String unit;
  final DateTime createdAt;

  factory WasteRecord.fromMap(Map<String, dynamic> map) {
    return WasteRecord(
      id: map['id'] as String? ?? '',
      type: map['record_type'] as String? ?? 'waste_reduced',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'kg',
      createdAt: parseDate(map['created_at']),
    );
  }
}

class WasteSummary {
  const WasteSummary({
    required this.totalWasteReducedKg,
    required this.totalRecycledItems,
    required this.totalFoodSavedKg,
    required this.monthlyWasteReducedKg,
  });

  final double totalWasteReducedKg;
  final int totalRecycledItems;
  final double totalFoodSavedKg;
  final Map<String, double> monthlyWasteReducedKg;

  factory WasteSummary.fromRecords(List<WasteRecord> records) {
    var wasteReduced = 0.0;
    var recycledItems = 0;
    var foodSaved = 0.0;
    final monthly = <String, double>{};

    for (final record in records) {
      final monthKey =
          '${record.createdAt.year}-${record.createdAt.month.toString().padLeft(2, '0')}';

      switch (record.type) {
        case 'recycled_item':
          recycledItems += record.quantity.round();
          break;
        case 'food_saved':
          foodSaved += record.quantity;
          monthly[monthKey] = (monthly[monthKey] ?? 0) + record.quantity;
          break;
        case 'donation':
        case 'waste_reduced':
        default:
          wasteReduced += record.quantity;
          monthly[monthKey] = (monthly[monthKey] ?? 0) + record.quantity;
          break;
      }
    }

    return WasteSummary(
      totalWasteReducedKg: wasteReduced,
      totalRecycledItems: recycledItems,
      totalFoodSavedKg: foodSaved,
      monthlyWasteReducedKg: monthly,
    );
  }
}

class EcoScoreEntry {
  const EcoScoreEntry({
    required this.id,
    required this.score,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final int score;
  final String reason;
  final DateTime createdAt;

  factory EcoScoreEntry.fromMap(Map<String, dynamic> map) {
    return EcoScoreEntry(
      id: map['id'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      reason: map['reason'] as String? ?? 'Score update',
      createdAt: parseDate(map['created_at']),
    );
  }
}

class EcoRankingEntry {
  const EcoRankingEntry({
    required this.profileName,
    required this.avatarUrl,
    required this.score,
  });

  final String profileName;
  final String avatarUrl;
  final int score;

  factory EcoRankingEntry.fromMap(Map<String, dynamic> map) {
    final profile = map['profile'] as Map<String, dynamic>? ?? const {};
    return EcoRankingEntry(
      profileName: profile['display_name'] as String? ?? 'Eco member',
      avatarUrl: profile['avatar_url'] as String? ?? '',
      score: map['score'] as int? ?? 0,
    );
  }
}

class SustainabilitySnapshot {
  const SustainabilitySnapshot({
    required this.profile,
    required this.savedProductIds,
    required this.savedProducts,
    required this.orderPreferences,
    required this.notifications,
    required this.wasteRecords,
    required this.wasteSummary,
    required this.ecoScoreHistory,
    required this.ecoRanking,
    required this.supportIssues,
    required this.isUsingDemoData,
  });

  final UserProfile profile;
  final Set<String> savedProductIds;
  final List<NftAsset> savedProducts;
  final OrderPreferences orderPreferences;
  final List<AppNotification> notifications;
  final List<WasteRecord> wasteRecords;
  final WasteSummary wasteSummary;
  final List<EcoScoreEntry> ecoScoreHistory;
  final List<EcoRankingEntry> ecoRanking;
  final List<SupportIssue> supportIssues;
  final bool isUsingDemoData;

  int get unreadNotificationCount =>
      notifications.where((notification) => !notification.isRead).length;
}

DateTime parseDate(Object? value) {
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}
