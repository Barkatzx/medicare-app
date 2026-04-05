import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicare_app/data/repositories/auth_repository.dart';
import 'package:medicare_app/data/repositories/cart_repository.dart';
import 'package:medicare_app/data/repositories/cart_repository_impl.dart';
import 'package:medicare_app/data/repositories/notification_repository.dart';
import 'package:medicare_app/data/repositories/notification_repository_impl.dart';
import 'package:medicare_app/data/repositories/product_repository.dart';
import 'package:medicare_app/presentation/providers/cart_provider.dart';
import 'package:medicare_app/presentation/providers/notification_provider.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/datasources/local/shared_prefs_helper.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/verify_auth_usecase.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final sharedPrefsHelper = SharedPrefsHelper(prefs);
  final client = http.Client();

  final AuthRepository authRepository = AuthRepositoryImpl(
    client: client,
    sharedPreferencesHelper: sharedPrefsHelper,
  );

  final ProductRepository productRepository = ProductRepositoryImpl(
    client: client,
    prefsHelper: sharedPrefsHelper,
  );

  final CartRepository cartRepository = CartRepositoryImpl(
    client: client,
    prefsHelper: sharedPrefsHelper,
  );

  final NotificationRepository notificationRepository =
      NotificationRepositoryImpl(
        client: client,
        prefsHelper: sharedPrefsHelper,
      );

  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final verifyAuthUseCase = VerifyAuthUseCase(authRepository);

  final authProvider = AuthProvider(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    verifyAuthUseCase: verifyAuthUseCase,
  );

  final productProvider = ProductProvider(productRepository: productRepository);

  final cartProvider = CartProvider(cartRepository: cartRepository);

  final notificationProvider = NotificationProvider(
    notificationRepository: notificationRepository,
  );

  await authProvider.initialize();

  runApp(
    MyApp(
      authProvider: authProvider,
      productProvider: productProvider,
      cartProvider: cartProvider,
      notificationProvider: notificationProvider,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final ProductProvider productProvider;
  final CartProvider cartProvider;
  final NotificationProvider notificationProvider;

  const MyApp({
    Key? key,
    required this.authProvider,
    required this.productProvider,
    required this.cartProvider,
    required this.notificationProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: productProvider),
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
      ],
      child: MaterialApp(
        title: 'MediCare App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          scaffoldBackgroundColor: CustomTheme.backgroundColor,
          fontFamily: CustomTheme.primaryFontFamily,
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: -0.5,
              height: 1.2,
            ),
            displayMedium: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              letterSpacing: -0.3,
              height: 1.3,
            ),
            displaySmall: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              height: 1.4,
            ),
            headlineMedium: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              height: 1.4,
            ),
            bodyLarge: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1F2937),
              height: 1.5,
            ),
            bodyMedium: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
            bodySmall: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
              height: 1.5,
            ),
            labelLarge: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1F2937),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontFamily: 'Lufga',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              height: 1.4,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontFamily: 'Lufga',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        initialRoute: authProvider.isLoggedIn && authProvider.isCustomer
            ? AppRoutes.home
            : AppRoutes.login,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
