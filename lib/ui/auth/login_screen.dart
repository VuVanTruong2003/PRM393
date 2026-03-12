import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_ui.dart';
import '../../state/auth_controller.dart';
import '../widgets/gradient_header.dart';

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
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            height: 220,
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 34,
                        color: Color(0xFF2F80ED),
                      ),
                    ),
                  ),
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
                          const Text(
                            'Đăng nhập bằng Firebase',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dữ liệu sẽ đồng bộ realtime theo từng tài khoản.',
                            style: TextStyle(color: Theme.of(context).hintColor),
                          ),
                          const SizedBox(height: 16),
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

