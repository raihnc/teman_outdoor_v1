import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  final _formKey = GlobalKey<FormState>();
  final _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
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
      appBar: AppBar(
        title: const Text('Daftar'),
        surfaceTintColor: Colors.transparent,
      ),
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
                        const SizedBox(height: 24),
                        Text(
                          'Buat Akun Baru',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Isi data diri Anda untuk mulai menyewa.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          label: 'Nama Lengkap',
                          hint: 'Masukkan nama lengkap',
                          controller: _nameCtrl,
                          prefix: const Icon(Ionicons.person_outline, size: 20),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Nama wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Nomor Telepon',
                          hint: 'Masukkan nomor telepon',
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          prefix: const Icon(Ionicons.call_outline, size: 20),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'No. telepon wajib diisi';
                            }
                            if (v.trim().length < 9) {
                              return 'No. telepon tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Email',
                          hint: 'Masukkan email',
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
                          hint: 'Minimal 6 karakter',
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
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Konfirmasi Password',
                          hint: 'Ulangi password',
                          controller: _confirmPassCtrl,
                          obscureText: _obscureConfirm,
                          prefix: const Icon(
                            Ionicons.lock_closed_outline,
                            size: 20,
                          ),
                          suffix: IconButton(
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            icon: Icon(
                              _obscureConfirm
                                  ? Ionicons.eye_outline
                                  : Ionicons.eye_off_outline,
                              size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (v != _passCtrl.text)
                              return 'Password tidak cocok';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        Obx(
                          () => CustomButton(
                            label: 'Daftar',
                            isLoading: _authController.isLoading.value,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _authController.signUpWithEmail(
                                  _emailCtrl.text.trim(),
                                  _passCtrl.text,
                                  _nameCtrl.text.trim(),
                                  _phoneCtrl.text.trim(),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            child: RichText(
                              text: TextSpan(
                                text: 'Sudah punya akun? ',
                                style: Theme.of(context).textTheme.bodySmall,
                                children: const [
                                  TextSpan(
                                    text: 'Masuk',
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
