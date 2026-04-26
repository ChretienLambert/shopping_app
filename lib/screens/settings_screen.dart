import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/product_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/maintenance_provider.dart';
import '../providers/language_provider.dart';
import '../services/logging_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(ref, 'settings')),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Profile Section
            _buildSectionHeader(tr(ref, 'profile')),
            _buildProfileCard(user),
            const SizedBox(height: 32),

            // Data Management Section
            _buildSectionHeader(tr(ref, 'cloud_sync_data')),
            _buildSyncControls(),
            const SizedBox(height: 16),
            _buildSettingTile(
              icon: Icons.network_check_rounded,
              title: tr(ref, 'check_db_connection'),
              subtitle: tr(ref, 'check_db_subtitle'),
              onTap: () => _testDatabaseConnection(context, ref),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader(tr(ref, 'exports')),
            _buildSettingTile(
              icon: Icons.dataset_rounded,
              title: tr(ref, 'export_all_data'),
              subtitle: tr(ref, 'export_all_subtitle'),
              onTap: () => _exportAllData(context, ref),
            ),
            const SizedBox(height: 32),

            // App Settings Section
            _buildSectionHeader(tr(ref, 'app_settings')),
            _buildLanguageTile(),
            _buildThemeTile(isDarkMode),
            const SizedBox(height: 32),

            _buildSectionHeader(tr(ref, 'maintenance')),
            _buildSettingTile(
              icon: Icons.save_alt_rounded,
              title: tr(ref, 'save_logs_local'),
              subtitle: tr(ref, 'save_logs_subtitle'),
              onTap: () => _saveLogsToLocal(context),
              trailing: const Icon(Icons.download_rounded, size: 20),
            ),
            _buildSettingTile(
              icon: Icons.bug_report_rounded,
              title: tr(ref, 'share_error_logs'),
              subtitle: tr(ref, 'share_logs_subtitle'),
              onTap: () => _shareLogFile(context),
              trailing: const Icon(Icons.share_rounded, size: 20),
            ),
            _buildSettingTile(
              icon: Icons.delete_forever_rounded,
              title: tr(ref, 'wipe_all_data'),
              subtitle: tr(ref, 'wipe_data_subtitle'),
              onTap: () => _confirmSystemReset(context, ref),
              destructive: true,
            ),
            const SizedBox(height: 32),

            // Logout
            _buildSettingTile(
              icon: Icons.logout_rounded,
              title: tr(ref, 'sign_out'),
              subtitle: tr(ref, 'sign_out_subtitle'),
              onTap: () => ref.read(authServiceProvider).signOut(),
              destructive: true,
            ),
            const SizedBox(height: 48),
            
            Center(
              child: Text(
                'ShopTrack v1.0.0',
                style: TextStyle(
                  color: AppTheme.slate400,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color ?? AppTheme.slate500,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            child: Icon(Icons.person_rounded, color: AppTheme.primaryBlue, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.email?.split('@').first ?? tr(ref, 'manager'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.email ?? 'shop@manager.com',
                  style: TextStyle(color: AppTheme.slate500, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(tr(ref, 'edit')),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool destructive = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 350;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: isSmall ? 8 : 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (destructive ? Colors.red : AppTheme.primaryBlue).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: destructive ? Colors.red : AppTheme.primaryBlue,
            size: isSmall ? 18 : 22,
          ),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isSmall ? 13 : 15)),
        subtitle: Text(subtitle, style: TextStyle(color: AppTheme.slate500, fontSize: isSmall ? 10 : 12)),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: AppTheme.slate300, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeTile(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: Colors.amber,
            size: 22,
          ),
        ),
        title: Text(tr(ref, 'dark_mode'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(isDarkMode ? tr(ref, 'dark_mode_subtitle') : tr(ref, 'light_mode_subtitle'), style: TextStyle(color: AppTheme.slate500, fontSize: 12)),
        value: isDarkMode,
        activeThumbColor: AppTheme.primaryBlue,
        onChanged: (value) {
          ref.read(themeProvider.notifier).setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
        },
      ),
    );
  }

  Widget _buildLanguageTile() {
    final lang = ref.watch(languageProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.language, color: AppTheme.primaryBlue, size: 22),
        ),
        title: Text(tr(ref, 'language'), 
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: DropdownButton<String>(
          value: lang,
          underline: const SizedBox.shrink(),
          isDense: true,
          items: [
            DropdownMenuItem(value: 'en', child: Text(tr(ref, 'english'))),
            DropdownMenuItem(value: 'fr', child: Text(tr(ref, 'french'))),
          ],
          onChanged: (value) {
            if (value != null) {
              ref.read(languageProvider.notifier).setLanguage(value);
            }
          },
        ),
      ),
    );
  }

  // Implementation of actions (Export, Reset, etc.) copied and adapted from ExportScreen
  Widget _buildSyncControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSyncButton(
                  label: 'Push Data',
                  icon: Icons.cloud_upload_outlined,
                  color: Colors.blue,
                  onTap: () => _handlePush(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSyncButton(
                  label: 'Pull Data',
                  icon: Icons.cloud_download_outlined,
                  color: Colors.green,
                  onTap: () => _handlePull(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sync local changes or download cloud updates manually.',
            style: TextStyle(color: AppTheme.slate500, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePush(BuildContext context, WidgetRef ref) async {
    _showSyncFeedback(context, 'Pushing data...');
    try {
      await ref.read(syncManagerProvider).pushAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Push completed successfully.')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Push failed: $e')));
    }
  }

  Future<void> _handlePull(BuildContext context, WidgetRef ref) async {
    _showSyncFeedback(context, 'Pulling data...');
    try {
      await ref.read(syncManagerProvider).pullAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pull completed successfully.')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pull failed: $e')));
    }
  }

  void _showSyncFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  Future<void> _exportAllData(BuildContext context, WidgetRef ref) async {
    final products = ref.read(productProvider);
    final customers = ref.read(customerProvider);
    final sales = ref.read(saleProvider);
    final expenses = ref.read(expenseProvider);

    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'products': products.map((p) => p.toJson()).toList(),
      'customers': customers.map((c) => c.toJson()).toList(),
      'sales': sales.map((s) => s.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
    };

    try {
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return;

      final file = File('$selectedDirectory/shop_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonEncode(data));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported to: ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${tr(ref, 'error')}: $e')));
    }
  }

  Future<void> _testDatabaseConnection(BuildContext context, WidgetRef ref) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    
    final error = await ref.read(syncManagerProvider).checkConnection();
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading
      
      if (error == null) {
        _showSuccessDialog(context, tr(ref, 'db_connect_success'));
      } else {
        _showErrorDialog(context, error);
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green),
            SizedBox(width: 12),
            Text(tr(ref, 'success')),
          ],
        ),
        content: Text(tr(ref, 'db_connect_success')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(ref, 'great')))],
      ),
    );
  }

  Future<void> _shareLogFile(BuildContext context) async {
    try {
      final logFile = logger.logFile;
      if (logFile != null && await logFile.exists()) {
        await Share.shareXFiles(
          [XFile(logFile.path)],
          subject: 'ShopTrack App Logs - ${DateTime.now()}',
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr(ref, 'no_log_file'))),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr(ref, 'error_sharing_logs')}: $e')),
        );
      }
    }
  }

  Future<void> _saveLogsToLocal(BuildContext context) async {
    try {
      final logFile = logger.logFile;
      if (logFile == null || !await logFile.exists()) {
         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(ref, 'no_log_file'))));
         return;
      }

      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return;

      final destination = File('$selectedDirectory/app_logs_${DateTime.now().millisecondsSinceEpoch}.txt');
      await logFile.copy(destination.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logs saved to: ${destination.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save logs: $e')),
        );
      }
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    bool isSchemaError = error.contains('relation') && error.contains('does not exist');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text(tr(ref, 'connection_failed')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error, style: const TextStyle(fontSize: 12, color: Colors.red)),
            if (isSchemaError) ...[
              const SizedBox(height: 16),
              Text(
                tr(ref, 'db_schema_tip'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(ref, 'dismiss')))],
      ),
    );
  }

  Future<void> _confirmSystemReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'confirm_full_reset')),
        content: const Text('Are you sure you want to wipe all local data? This will not affect your cloud database, but you will need to pull data again to see it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr(ref, 'cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(tr(ref, 'wipe_data')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(maintenanceServiceProvider).resetLocalDatabase();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Local data wiped successfully.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr(ref, 'reset_failed')}: $e')),
        );
      }
    }
  }
}
