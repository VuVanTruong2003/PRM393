import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_ui.dart';
import '../../firebase_bootstrap.dart';
import '../../state/app_config.dart';
import '../../state/auth_controller.dart';
import '../../state/notification_settings_controller.dart';
import '../../state/profile_controller.dart';
import '../widgets/section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    final auth = context.watch<AuthController>();
    final profileCtrl = context.watch<ProfileController>();
    final notif = context.watch<NotificationSettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tài khoản',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppUI.pastelBlue,
                    child: const Icon(Icons.person_outline),
                  ),
                  title: Text(
                    auth.isSignedIn
                        ? profileCtrl.displayNameOrFallback()
                        : 'Chưa đăng nhập',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text('Firebase account'),
                  trailing: FilledButton.tonal(
                    onPressed: auth.isSignedIn ? () => auth.signOut() : null,
                    child: const Text('Đăng xuất'),
                  ),
                  onTap: () => context.push('/profile'),
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cloud_done_outlined),
                  title: const Text('Đồng bộ dữ liệu realtime'),
                  subtitle: Text(
                    FirebaseBootstrap.isConfigured
                        ? 'Mỗi user dữ liệu riêng trên Firestore.'
                        : 'Firebase chưa cấu hình hoàn chỉnh.',
                  ),
                ),
                if (!FirebaseBootstrap.isConfigured) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Để bật Firebase: thay REPLACE_ME trong lib/firebase_options.dart bằng thông số thật (hoặc dùng FlutterFire CLI).',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cài đặt ứng dụng',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Ngôn ngữ'),
                  subtitle: const Text('Tiếng Việt'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.currency_exchange_outlined),
                  title: const Text('Đơn vị tiền tệ'),
                  subtitle: Text(_currencyLabel(profileCtrl.profile.currencyCode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Quản lý ví'),
                  subtitle: const Text('Tạo và chỉnh sửa các ví tiền'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/accounts'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Quản lý danh mục'),
                  subtitle: const Text('Tùy chỉnh danh mục thu/chi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/categories'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.savings_outlined),
                  title: const Text('Ngân sách'),
                  subtitle: const Text('Thiết lập ngân sách theo tháng'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/budgets'),
                ),
                const Divider(height: 16),
                RadioGroup<ThemeMode>(
                  groupValue: config.themeMode,
                  onChanged: (v) {
                    if (v == null) return;
                    config.setThemeMode(v);
                  },
                  child: const Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        title: Text('Giao diện theo hệ thống'),
                        value: ThemeMode.system,
                      ),
                      RadioListTile<ThemeMode>(
                        title: Text('Sáng'),
                        value: ThemeMode.light,
                      ),
                      RadioListTile<ThemeMode>(
                        title: Text('Tối'),
                        value: ThemeMode.dark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông báo',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Chào buổi sáng'),
                  subtitle: Text('Hàng ngày lúc ${_fmtTime(context, notif.morningTime)}'),
                  value: notif.morningEnabled,
                  onChanged: (v) => notif.setMorningEnabled(v),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.alarm_outlined),
                  title: const Text('Giờ chào buổi sáng'),
                  subtitle: Text(_fmtTime(context, notif.morningTime)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickTime(
                    context,
                    initial: notif.morningTime,
                    onPicked: (t) => notif.setMorningTime(t),
                  ),
                ),
                const Divider(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Nhắc ghi chi tiêu'),
                  subtitle: Text('Hàng ngày lúc ${_fmtTime(context, notif.expenseTime)}'),
                  value: notif.expenseEnabled,
                  onChanged: (v) => notif.setExpenseEnabled(v),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time_outlined),
                  title: const Text('Giờ nhắc'),
                  subtitle: Text(_fmtTime(context, notif.expenseTime)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickTime(
                    context,
                    initial: notif.expenseTime,
                    onPicked: (t) => notif.setExpenseTime(t),
                  ),
                ),
                const Divider(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Cảnh báo ngân sách'),
                  subtitle: Text('Cảnh báo khi chi tiêu ≥ ${notif.budgetThreshold}% ngân sách'),
                  value: notif.budgetEnabled,
                  onChanged: (v) => notif.setBudgetEnabled(v),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.tune_outlined),
                  title: const Text('Ngưỡng cảnh báo'),
                  subtitle: Text('${notif.budgetThreshold}% ngân sách'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickThreshold(
                    context,
                    initial: notif.budgetThreshold,
                    onPicked: (v) => notif.setBudgetThreshold(v),
                  ),
                ),
                const Divider(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tóm tắt tuần (Chủ nhật)'),
                  subtitle: const Text('Tự động tổng kết chi tiêu tuần'),
                  value: notif.weeklyEnabled,
                  onChanged: (v) => notif.setWeeklyEnabled(v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _currencyLabel(String code) {
  return switch (code) {
    'USD' => 'US Dollar (\$)',
    'EUR' => 'Euro (€)',
    _ => 'Việt Nam Đồng (₫)',
  };
}

String _fmtTime(BuildContext context, TimeOfDay t) =>
    MaterialLocalizations.of(context).formatTimeOfDay(t);

Future<void> _pickTime(
  BuildContext context, {
  required TimeOfDay initial,
  required ValueChanged<TimeOfDay> onPicked,
}) async {
  final picked = await showTimePicker(context: context, initialTime: initial);
  if (picked == null) return;
  onPicked(picked);
}

Future<void> _pickThreshold(
  BuildContext context, {
  required int initial,
  required ValueChanged<int> onPicked,
}) async {
  var value = initial;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Ngưỡng cảnh báo'),
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$value%'),
            Slider(
              value: value.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '$value%',
              onChanged: (v) => setState(() => value = v.round()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Huỷ'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPicked(value);
          },
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
}

