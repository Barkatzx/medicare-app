import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medicare_app/data/repositories/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/datasources/local/shared_prefs_helper.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/verify_auth_usecase.dart';
import 'presentation/providers/auth_provider.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final sharedPrefsHelper = SharedPrefsHelper(prefs);

  // Initialize HTTP Client
  final client = http.Client();

  // Initialize Repository
  // In main.dart, update this line:
  final AuthRepository authRepository = AuthRepositoryImpl(
    client: client,
    sharedPreferencesHelper: sharedPrefsHelper, // Changed from prefsHelper
  );

  // Initialize Use Cases
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final verifyAuthUseCase = VerifyAuthUseCase(authRepository);

  // Initialize Auth Provider
  final authProvider = AuthProvider(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    verifyAuthUseCase: verifyAuthUseCase,
  );

  // Initialize auth state
  await authProvider.initialize();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({Key? key, required this.authProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: authProvider)],
      child: MaterialApp(
        title: 'MediCare App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: authProvider.isLoggedIn && authProvider.isCustomer
            ? AppRoutes.home
            : AppRoutes.login,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
