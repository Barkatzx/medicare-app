import 'package:flutter/material.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:provider/provider.dart';
import '../../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(CustomTheme.spacingXXL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: CustomTheme.spacingXXL * 2),
                Text(
                  'Welcome Back!',
                  style: CustomTextStyle.heading1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: CustomTheme.spacingSM),
                Text(
                  'Login to your account',
                  style: CustomTextStyle.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: CustomTheme.spacingXXL * 2),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 11) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: CustomTheme.spacingLG), // Removed const
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: CustomTheme.textTertiary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: CustomTheme.spacingSM), // Removed const
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: CustomTextStyle.bodySmall.copyWith(
                        color: CustomTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: CustomTheme.spacingXXL), // Removed const
                // Error Message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.errorMessage != null) {
                      return Container(
                        padding: EdgeInsets.all(CustomTheme.spacingMD),
                        margin: EdgeInsets.only(bottom: CustomTheme.spacingLG),
                        decoration: BoxDecoration(
                          color: CustomTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            CustomTheme.radiusMD,
                          ),
                          border: Border.all(
                            color: CustomTheme.errorColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: CustomTheme.errorColor,
                              size: 20,
                            ),
                            SizedBox(width: CustomTheme.spacingMD),
                            Expanded(
                              child: Text(
                                authProvider.errorMessage!,
                                style: TextStyle(color: CustomTheme.errorColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Login',
                      isLoading: authProvider.isLoading,
                      onPressed: _handleLogin,
                    );
                  },
                ),
                SizedBox(height: CustomTheme.spacingLG), // Removed const
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: CustomTextStyle.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: Text(
                        'Create Account',
                        style: CustomTextStyle.bodySmall.copyWith(
                          color: CustomTheme.primaryColor,
                          fontWeight: CustomTheme.fontWeightBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(CustomTheme.spacingXL),
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: CustomTheme.spacingMD),
                  const Text('Logging in...'),
                ],
              ),
            ),
          ),
        ),
      );

      String phoneInput = _phoneController.text.trim();
      bool success = await authProvider.login(
        phoneNumber: phoneInput,
        password: _passwordController.text,
      );

      Navigator.pop(context);

      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else if (authProvider.pendingApprovalMessage != null && mounted) {
        _showPendingApprovalDialog(
          context,
          authProvider.pendingApprovalMessage!,
        );
      } else if (authProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: CustomTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
            ),
          ),
        );
      }
    }
  }

  void _showPendingApprovalDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
        ),
        child: Padding(
          padding: EdgeInsets.all(CustomTheme.spacingXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(CustomTheme.spacingLG),
                decoration: BoxDecoration(
                  color: CustomTheme.warningColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pending_actions,
                  size: 50,
                  color: CustomTheme.warningColor,
                ),
              ),
              SizedBox(height: CustomTheme.spacingXL),
              Text(
                'Account Pending Approval',
                style: CustomTextStyle.heading2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: CustomTheme.spacingMD),
              Text(
                message,
                style: CustomTextStyle.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: CustomTheme.spacingXXL),
              CustomButton(
                text: 'OK',
                onPressed: () {
                  Navigator.pop(context);
                  _phoneController.clear();
                  _passwordController.clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
