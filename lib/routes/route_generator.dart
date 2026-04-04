import 'package:flutter/material.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/home/categories_screen.dart';
import '../presentation/screens/cart/cart_screen.dart';
import '../presentation/screens/cart/checkout_screen.dart';
import '../presentation/screens/orders/my_orders_screen.dart';
import '../presentation/screens/orders/order_detail_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/profile/edit_profile_screen.dart';
import '../presentation/screens/profile/change_password_screen.dart';
import '../presentation/screens/profile/addresses_screen.dart';
import '../presentation/screens/notifications/notifications_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      case AppRoutes.cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case AppRoutes.checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case AppRoutes.myOrders:
        return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
      case AppRoutes.orderDetail:
        return MaterialPageRoute(builder: (_) => const OrderDetailScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case AppRoutes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case AppRoutes.addresses:
        return MaterialPageRoute(builder: (_) => const AddressesScreen());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
