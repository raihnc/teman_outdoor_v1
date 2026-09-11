import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  final _formKey = GlobalKey<FormState>();
  final _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, screen) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screen.pagePadding + (screen.isLargePhone ? 8 : 0),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Ionicons.leaf,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Selamat Datang! 👋',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Masuk ke akun Anda untuk mulai menyewa alat camping.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 40),
                        CustomTextField(
                          label: 'Email',
                          hint: 'Masukkan email Anda',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefix: const Icon(Ionicons.mail_outline, size: 20),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Email wajib diisi';
                            if (!GetUtils.isEmail(v))
                              return 'Email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Password',
                          hint: 'Masukkan password',
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          prefix: const Icon(
                            Ionicons.lock_closed_outline,
                            size: 20,
                          ),
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                            icon: Icon(
                              _obscurePass
                                  ? Ionicons.eye_outline
                                  : Ionicons.eye_off_outline,
                              size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Password wajib diisi';
                            if (v.length < 6) return 'Minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),
                        Obx(
                          () => CustomButton(
                            label: 'Masuk',
                            isLoading: _authController.isLoading.value,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _authController.signInWithEmail(
                                  _emailCtrl.text.trim(),
                                  _passCtrl.text,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: TextButton(
                            onPressed: () => Get.toNamed(AppRoutes.register),
                            child: RichText(
                              text: TextSpan(
                                text: 'Belum punya akun? ',
                                style: Theme.of(context).textTheme.bodySmall,
                                children: const [
                                  TextSpan(
                                    text: 'Daftar',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
