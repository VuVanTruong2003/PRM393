/// Hồ sơ người dùng lưu trên Firestore (users/{uid}/profile/me).
class UserProfile {
  const UserProfile({
    this.displayName = '',
    this.avatarUrl,
    this.currencyCode = 'VND',
    this.timezone = 'Asia/Ho_Chi_Minh',
  });

  final String displayName;
  final String? avatarUrl;
  final String currencyCode;
  final String timezone;

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    String? currencyCode,
    String? timezone,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currencyCode: currencyCode ?? this.currencyCode,
      timezone: timezone ?? this.timezone,
    );
  }

  static const String docId = 'me';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'currencyCode': currencyCode,
      'timezone': timezone,
    };
  }

  static UserProfile fromMap(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return const UserProfile();
    return UserProfile(
      displayName: data['displayName'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      currencyCode: data['currencyCode'] as String? ?? 'VND',
      timezone: data['timezone'] as String? ?? 'Asia/Ho_Chi_Minh',
    );
  }
}
