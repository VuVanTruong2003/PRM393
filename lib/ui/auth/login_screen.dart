import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_ui.dart';
import '../widgets/gradient_header.dart';
import '../../state/app_config.dart';
import '../../state/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    final auth = context.watch<AuthController>();

    final useFirebase = config.useFirebase;

    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            height: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Text(
                  'Quản Lý Chi Tiêu',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Quản lý tài chính cá nhân thông minh',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      decoration: AppUI.cardDecoration(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: false, label: Text('Demo')),
                              ButtonSegment(value: true, label: Text('Firebase')),
                            ],
                            selected: {useFirebase},
                            onSelectionChanged: (v) => config.setUseFirebase(v.first),
                          ),
                          const SizedBox(height: 16),
                          if (!useFirebase) ...[
                            const Text(
                              'Demo mode: dữ liệu lưu cục bộ và không cần tài khoản.',
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => auth.continueAsGuest(),
                              child: const Text('Tiếp tục với tư cách khách'),
                            ),
                          ] else ...[
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(labelText: 'Email'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              decoration: const InputDecoration(labelText: 'Mật khẩu'),
                            ),
                            const SizedBox(height: 12),
                            if (auth.lastError != null) ...[
                              Text(
                                auth.lastError.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            FilledButton(
                              onPressed: auth.isFirebaseInitializing
                                  ? null
                                  : () {
                                      final email = _emailController.text;
                                      final password = _passwordController.text;
                                      if (_isRegister) {
                                        auth.registerWithEmail(
                                          email: email,
                                          password: password,
                                        );
                                      } else {
                                        auth.signInWithEmail(
                                          email: email,
                                          password: password,
                                        );
                                      }
                                    },
                              child: Text(_isRegister ? 'Tạo tài khoản' : 'Đăng nhập'),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => setState(
                                    () => _isRegister = !_isRegister,
                                  ),
                                  child: Text(_isRegister
                                      ? 'Đã có tài khoản? Đăng nhập'
                                      : 'Chưa có tài khoản? Đăng ký'),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => auth.sendPasswordResetEmail(
                                    email: _emailController.text,
                                  ),
                                  child: const Text('Quên mật khẩu?'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

