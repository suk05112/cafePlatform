import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cafeplatform/model/gifticon.dart';
import 'package:cafeplatform/model/user.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _user;

  User? get user => _user;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  List<Gifticon>? _cachedGifticons;
  DateTime? _gifticonCacheTime;

  List<Gifticon>? get cachedGifticons => _cachedGifticons;

  bool get isGifticonCacheValid {
    if (_cachedGifticons == null || _gifticonCacheTime == null) return false;
    return DateTime.now().difference(_gifticonCacheTime!).inHours < 1;
  }

  void setGifticonCache(List<Gifticon> gifticons) {
    _cachedGifticons = gifticons;
    _gifticonCacheTime = DateTime.now();
  }

  void invalidateGifticonCache() {
    _cachedGifticons = null;
    _gifticonCacheTime = null;
  }

  // 스토리지 초기화 완료를 외부에서 await할 수 있도록 노출
  late final Future<void> initialized;

  UserProvider() {
    initialized = _loadUserFromStorage().then((_) {});
  }

  /// Set the user and save it to storage
  Future<void> setUser(User user) async {
    _user = user;
    await _saveUserToStorage(user);
    notifyListeners();
  }

  /// 초기화 완료 후 메모리의 _user를 반환. 초기화 전이면 완료될 때까지 대기.
  Future<User?> fetchUser() async {
    await initialized;
    return _user;
  }

  /// Save the user to secure storage (private method)
  Future<void> _saveUserToStorage(User user) async {
    try {
      final userJson = jsonEncode({
        'user_id': user.user_id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone_number,
        'uid': user.uid,
      });
      await _storage.write(key: "user", value: userJson);
      _isLoggedIn = true;
    } catch (e) {
    }
  }

  /// Load the user from secure storage (private method)
  Future<User?> _loadUserFromStorage() async {
    try {
      final userJson = await _storage.read(key: "user");
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        _user = User(
          user_id: userMap['user_id'],
          name: userMap['name'],
          email: userMap['email'],
          phone_number: userMap['phone'],
          uid: userMap['uid'] ?? '',
        );
        notifyListeners();
        _isLoggedIn = true;

        return _user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Clear the user from secure storage
  Future<void> clearUser() async {
    try {
      await _storage.delete(key: "user");
      _user = null;
      _isLoggedIn = false;
      _cachedGifticons = null;
      _gifticonCacheTime = null;

      // notifyListeners를 안전하게 호출
      // 이미 dispose된 위젯에서 호출될 수 있으므로 try-catch로 감싸기
      try {
        notifyListeners();
      } catch (e) {
      }
    } catch (e) {
      // 오류가 발생해도 상태는 업데이트
      _user = null;
      _isLoggedIn = false;
      try {
        notifyListeners();
      } catch (notifyError) {
      }
    }
  }
}

// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:my_app/model/user.dart';

// class UserProvider with ChangeNotifier {
//   late User _user;

//   User get user => _user;

//   void setUser(User user) {
//     _user = user;
//     notifyListeners();
//   }

//   Future<User?> getUser() async {
//     final storage = FlutterSecureStorage();

//     // Read the JSON string from storage
//     final userJson = await storage.read(key: "user");

//     if (userJson != null) {
//       // Decode the JSON string into a map
//       final userMap = jsonDecode(userJson);

//       // Create a user object from the map
//       return User(
//         user_id: userMap['user_id'],
//         name: userMap['name'],
//         email: userMap['email'],
//         phone: userMap['phone'],
//       );
//     } else {
//       print("No user data found in storage");
//       return null;
//     }
//   }

// }
