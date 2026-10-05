import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoggedIn = false;
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._authRepository) {
    _init();
  }

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _isLoggedIn = await _authRepository.isLoggedIn();
    _currentUser = await _authRepository.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authRepository.login(email, password);
      _isLoggedIn = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(String name, String email, String phone, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authRepository.signup(name, email, phone, password);
      _isLoggedIn = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authRepository.logout();
    _isLoggedIn = false;
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  // Quick testing toggle for development
  void toggleMockAuth() {
    if (_isLoggedIn) {
      logout();
    } else {
      login('guest@obhospitality.com', 'password123');
    }
  }
}
