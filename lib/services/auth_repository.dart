import 'dart:async';
import '../models/user.dart';

abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
  Future<User> login(String email, String password);
  Future<User> signup(String name, String email, String phone, String password);
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  bool _isLoggedIn = false; // Starts false to allow testing the checkout login gate!
  User? _currentUser;

  @override
  Future<bool> isLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _isLoggedIn;
  }

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _isLoggedIn ? (_currentUser ?? User.mockUser) : null;
  }

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoggedIn = true;
    _currentUser = User(
      id: 'user_mock',
      name: email.split('@').first.capitalize(),
      email: email,
      phone: '+1 (613) 555-0142',
      savedAddresses: [
        '104 Bank St, Apt 4B, Ottawa, ON',
        '240 Sparks St, Ottawa, ON',
      ],
    );
    return _currentUser!;
  }

  @override
  Future<User> signup(String name, String email, String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _isLoggedIn = true;
    _currentUser = User(
      id: 'user_mock',
      name: name,
      email: email,
      phone: phone,
      savedAddresses: [
        '104 Bank St, Apt 4B, Ottawa, ON',
      ],
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _isLoggedIn = false;
    _currentUser = null;
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
