import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../services/restaurant_repository.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantRepository _repository;

  List<Restaurant> _restaurants = [];
  Restaurant? _selectedRestaurant;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCuisine = 'All';

  RestaurantProvider(this._repository) {
    loadRestaurants();
  }

  List<Restaurant> get restaurants => _restaurants;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCuisine => _selectedCuisine;

  final List<String> availableCuisines = [
    'All',
    'Grill & Kebab',
    'Seafood & Poke',
    'Italian',
    'Desserts',
  ];

  Future<void> loadRestaurants() async {
    _isLoading = true;
    notifyListeners();
    _restaurants = await _repository.getRestaurants(
      query: _searchQuery,
      cuisine: _selectedCuisine,
    );
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadRestaurants();
  }

  void setCuisine(String cuisine) {
    _selectedCuisine = cuisine;
    loadRestaurants();
  }

  Future<void> selectRestaurant(String id) async {
    _isLoading = true;
    notifyListeners();
    _selectedRestaurant = await _repository.getRestaurantById(id);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReviewToSelectedRestaurant(Review review) async {
    if (_selectedRestaurant == null) return;
    await _repository.submitReview(_selectedRestaurant!.id, review);
    await selectRestaurant(_selectedRestaurant!.id);
    loadRestaurants();
  }
}
