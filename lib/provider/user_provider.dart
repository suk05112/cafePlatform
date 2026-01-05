import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cafeplatform/model/user.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _user; // Nullable for better initialization handling

  User? get user => _user;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // Constructor: Initialize UserProvider and load user from storage
  UserProvider() {
    _loadUserFromStorage();
  }

  /// Set the user and save it to storage
  Future<void> setUser(User user) async {
    _user = user;
    await _saveUserToStorage(user);
    notifyListeners();
  }

  /// Fetch the user from secure storage (public method)
  Future<User?> fetchUser() async {
    return await _loadUserFromStorage();
  }

  /// Save the user to secure storage (private method)
  Future<void> _saveUserToStorage(User user) async {
    print("${user.name}, ${user.email}, ${user.phone_number}");
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
      print("User saved to secure storage.");
    } catch (e) {
      print("Failed to save user to storage: $e");
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
        print("User loaded from secure storage.");
        print("${_user?.name}, ${_user?.email}, ${_user?.phone_number}");
        _isLoggedIn = true;

        return _user;
      } else {
        print("No user data found in secure storage.");
        return null;
      }
    } catch (e) {
      print("Failed to load user from storage: $e");
      return null;
    }
  }

  /// Clear the user from secure storage
  Future<void> clearUser() async {
    try {
      await _storage.delete(key: "user");
      _user = null;
      _isLoggedIn = false;

      notifyListeners();
      print("User data cleared from storage.");
    } catch (e) {
      print("Failed to clear user data: $e");
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
