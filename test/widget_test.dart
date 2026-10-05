import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/main.dart';
import 'package:customer_app/services/restaurant_repository.dart';
import 'package:customer_app/services/order_repository.dart';
import 'package:customer_app/services/auth_repository.dart';
import 'package:customer_app/providers/restaurant_provider.dart';
import 'package:customer_app/providers/order_provider.dart';
import 'package:customer_app/providers/auth_provider.dart';
import 'package:customer_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final authRepository = MockAuthRepository();
    final restaurantRepository = MockRestaurantRepository();
    final orderRepository = MockOrderRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
          ChangeNotifierProvider(create: (_) => RestaurantProvider(restaurantRepository)),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OrderProvider(orderRepository)),
        ],
        child: const CustomerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('OB Hospitality'), findsOneWidget);
    expect(find.text('Kitchens'), findsOneWidget);
  });
}
