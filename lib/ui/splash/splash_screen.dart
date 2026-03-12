import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_ui.dart';
import '../../state/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1600), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final auth = context.read<AuthController>();
    context.go(auth.isSignedIn ? '/dashboard' : '/login');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppUI.headerGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 24,
                        offset: Offset(0, 12),
                        color: Color(0x22000000),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 56,
                    color: Color(0xFF2F80ED),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Quản Lý Chi Tiêu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quản lý tài chính cá nhân thông minh',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 56),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(
                      Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

