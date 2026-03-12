import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/auth_controller.dart';
import '../../state/profile_controller.dart';
import '../widgets/gradient_header.dart';
import '../widgets/section_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _displayNameController;
  bool _initialSynced = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profileCtrl = context.watch<ProfileController>();
    final profile = profileCtrl.profile;

    if (!profileCtrl.loading && !_initialSynced) {
      _initialSynced = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _displayNameController.text = profile.displayName;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileCtrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                GradientHeader(
                  height: 160,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAvatar(profileCtrl, auth),
                      const SizedBox(height: 12),
                      Text(
                        profileCtrl.displayNameOrFallback(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (auth.user?.email != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            auth.user!.email!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin hiển thị',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên hiển thị',
                            hintText: 'Nhập tên của bạn',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: auth.user?.email ?? '',
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tuỳ chọn',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _currencyValue(profile.currencyCode),
                          decoration: const InputDecoration(
                            labelText: 'Đơn vị tiền tệ',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.currency_exchange_outlined),
                          ),
                          items: _currencyOptions
                              .map((e) => DropdownMenuItem(
                                    value: e.code,
                                    child: Text(e.label),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              profileCtrl.saveProfile(
                                  profile.copyWith(currencyCode: v));
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _timezoneValue(profile.timezone),
                          decoration: const InputDecoration(
                            labelText: 'Múi giờ',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.schedule),
                          ),
                          items: _timezoneOptions
                              .map((e) => DropdownMenuItem(
                                    value: e.code,
                                    child: Text(e.label),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              profileCtrl.saveProfile(
                                  profile.copyWith(timezone: v));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (profileCtrl.error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      profileCtrl.error.toString(),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: FilledButton.icon(
                    onPressed: profileCtrl.saving ? null : () => _save(profileCtrl),
                    icon: profileCtrl.saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(profileCtrl.saving ? 'Đang lưu...' : 'Lưu thay đổi'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAvatar(ProfileController profileCtrl, AuthController auth) {
    final url = profileCtrl.profile.avatarUrl;
    final name = profileCtrl.displayNameOrFallback();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 44,
      backgroundColor: Colors.white,
      backgroundImage: url != null && url.isNotEmpty
          ? NetworkImage(url)
          : null,
      child: url == null || url.isEmpty
          ? Text(
              initial,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2F80ED),
              ),
            )
          : null,
    );
  }

  static const List<({String code, String label})> _currencyOptions = [
    (code: 'VND', label: 'Việt Nam Đồng (₫)'),
    (code: 'USD', label: 'US Dollar (\$)'),
    (code: 'EUR', label: 'Euro (€)'),
  ];

  static const List<({String code, String label})> _timezoneOptions = [
    (code: 'Asia/Ho_Chi_Minh', label: 'Việt Nam (GMT+7)'),
    (code: 'UTC', label: 'UTC'),
    (code: 'Asia/Bangkok', label: 'Bangkok (GMT+7)'),
    (code: 'Asia/Tokyo', label: 'Tokyo (GMT+9)'),
  ];

  String _currencyValue(String code) {
    return _currencyOptions.any((e) => e.code == code)
        ? code
        : _currencyOptions.first.code;
  }

  String _timezoneValue(String tz) {
    return _timezoneOptions.any((e) => e.code == tz)
        ? tz
        : _timezoneOptions.first.code;
  }

  void _save(ProfileController ctrl) {
    final next = ctrl.profile.copyWith(
      displayName: _displayNameController.text.trim(),
    );
    ctrl.saveProfile(next);
  }
}
