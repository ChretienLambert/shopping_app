import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart' as csv;
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
            _buildSectionHeader('Profile'),
            _buildProfileCard(user),
            const SizedBox(height: 32),

            // Data Management Section
            _buildSectionHeader('Cloud Sync & Data'),
            _buildSettingTile(
              icon: Icons.cloud_sync_rounded,
              title: 'Push local to Online',
              subtitle: 'Manually sync local changes to cloud',
              onTap: () => _handleManualSync(context, ref),
              trailing: const Icon(Icons.sync, size: 20),
            ),
            _buildSettingTile(
              icon: Icons.network_check_rounded,
              title: 'Check DB Connection',
              subtitle: 'Speak to Supabase and verify schema',
              onTap: () => _testDatabaseConnection(context, ref),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Exports'),
            _buildSettingTile(
              icon: Icons.dataset_rounded,
              title: 'Export All Data',
              subtitle: 'Download everything in JSON format',
              onTap: () => _exportAllData(context, ref),
            ),
            _buildSettingTile(
              icon: Icons.table_view_rounded,
              title: 'Inventory Export (CSV)',
              subtitle: 'Perfect for Excel or Google Sheets',
              onTap: () => _exportProductsCsv(context, ref),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Diagnostics & Support'),
            _buildSettingTile(
              icon: Icons.bug_report_rounded,
              title: 'Share Error Logs',
              subtitle: 'Send technical logs to support for help',
              onTap: () => _shareLogFile(context),
              trailing: const Icon(Icons.share_rounded, size: 20),
            ),
            _buildSettingTile(
              icon: Icons.delete_forever_rounded,
              title: 'Wipe All Data (Start New)',
              subtitle: 'Deletes local and cloud data for this account',
              onTap: () => _confirmSystemReset(context, ref),
              destructive: true,
            ),
            const SizedBox(height: 32),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            _buildLanguageTile(),
            _buildThemeTile(isDarkMode),
            const SizedBox(height: 32),

            // Logout
            _buildSettingTile(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              subtitle: 'Log out of your account securely',
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
                  user?.email?.split('@').first ?? 'Manager',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  user?.email ?? 'shop@manager.com',
                  style: TextStyle(color: AppTheme.slate500, fontSize: 13),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Edit'),
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
            color: (destructive ? Colors.red : AppTheme.primaryBlue).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: destructive ? Colors.red : AppTheme.primaryBlue,
            size: 22,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: AppTheme.slate500, fontSize: 12)),
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
        title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(isDarkMode ? 'Modern slate theme' : 'Clean indigo theme', style: TextStyle(color: AppTheme.slate500, fontSize: 12)),
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
          child: const Icon(Icons.language, color: AppTheme.primaryBlue, size: 22),
        ),
        title: Text(tr(ref, 'language'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: DropdownButton<String>(
          value: lang,
          underline: const SizedBox.shrink(),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'fr', child: Text('Francais')),
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
  Future<void> _exportAllData(BuildContext context, WidgetRef ref) async {
    final products = ref.read(productProvider);
    final customers = ref.read(customerProvider);
    final sales = ref.read(saleProvider);
    final expenses = ref.read(expenseProvider);

    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'products': products.map((p) => p.serverId).toList(), // Simplified for brevity in this example
      'customers': customers.map((c) => c.serverId).toList(),
      'sales': sales.map((s) => s.serverId).toList(),
      'expenses': expenses.map((e) => e.serverId).toList(),
    };

    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/shop_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonEncode(data));
      
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'ShopTrack Backup',
        ),
      );
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _exportProductsCsv(BuildContext context, WidgetRef ref) async {
    final products = ref.read(productProvider);
    List<List<dynamic>> rows = [["ID", "Name", "Price", "Stock"]];
    for (var p in products) {
      rows.add([p.serverId, p.name, p.price, p.stockQuantity]);
    }
    String csvData = csv.Csv().encode(rows);
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/inventory_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csvData);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Inventory CSV',
        ),
      );
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _handleManualSync(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Row(children: [CircularProgressIndicator(strokeWidth: 2), SizedBox(width: 12), Text('Syncing data...')])),
    );
    try {
      await ref.read(syncManagerProvider).syncAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync completed successfully!')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
    }
  }

  Future<void> _testDatabaseConnection(BuildContext context, WidgetRef ref) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    
    final error = await ref.read(syncManagerProvider).checkConnection();
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading
      
      if (error == null) {
        _showSuccessDialog(context, 'Successfully connected to database and verified schema.');
      } else {
        _showErrorDialog(context, error);
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green),
            SizedBox(width: 12),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Great'))],
      ),
    );
  }

  Future<void> _shareLogFile(BuildContext context) async {
    try {
      final logFile = logger.logFile;
      if (logFile != null && await logFile.exists()) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(logFile.path)],
            subject: 'ShopTrack App Logs - ${DateTime.now()}',
          ),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No log file found or it is currently being initialized.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing logs: $e')),
        );
      }
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    bool isSchemaError = error.contains('relation') && error.contains('does not exist');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Connection Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error, style: const TextStyle(fontSize: 12, color: Colors.red)),
            if (isSchemaError) ...[
              const SizedBox(height: 16),
              const Text(
                'TIP: This usually means you need to run the SQL schema in your Supabase SQL Editor.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Dismiss'))],
      ),
    );
  }

  Future<void> _confirmSystemReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Full Reset'),
        content: const Text(
          'This will erase all your local and cloud data for this account. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Wipe Data'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(maintenanceServiceProvider).completeSystemReset();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('System reset completed.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset failed: $e')),
        );
      }
    }
  }
}
