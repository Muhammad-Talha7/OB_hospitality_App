class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<String> savedAddresses;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.savedAddresses = const [],
  });

  static const mockUser = User(
    id: 'user_01',
    name: 'Alexandre Laurent',
    email: 'alexandre.laurent@example.com',
    phone: '+1 (613) 555-0142',
    savedAddresses: [
      '104 Bank St, Apt 4B, Ottawa, ON',
      '240 Sparks St, Ottawa, ON',
    ],
  );
}
