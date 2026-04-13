import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_localization.dart';

class Sidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    final user = ref.watch(currentUserProvider);
    
    return Container(
      width: isSmallScreen ? 80 : 256,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1)),
            ),
            child: isSmallScreen
                ? Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppTheme.logoGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
                  )
                : Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppTheme.logoGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Corporate Ladies',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Business Suite',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: tr(ref, 'dashboard'),
                  index: 0,
                  isSelected: selectedIndex == 0,
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2,
                  label: tr(ref, 'catalogs'),
                  index: 1,
                  isSelected: selectedIndex == 1,
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people_outline,
                  selectedIcon: Icons.people,
                  label: tr(ref, 'customers'),
                  index: 2,
                  isSelected: selectedIndex == 2,
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.shopping_cart_outlined,
                  selectedIcon: Icons.shopping_cart,
                  label: tr(ref, 'sales'),
                  index: 3,
                  isSelected: selectedIndex == 3,
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long,
                  label: tr(ref, 'expenses'),
                  index: 4,
                  isSelected: selectedIndex == 4,
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.account_balance_outlined,
                  selectedIcon: Icons.account_balance,
                  label: tr(ref, 'finance'),
                  index: 5,
                  isSelected: selectedIndex == 5,
                  isSmallScreen: isSmallScreen,
                ),
              ],
            ),
          ),
          
          // Theme Toggle
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1)),
            ),
            child: isSmallScreen
                ? IconButton(
                    icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () => onThemeToggle(!isDarkMode),
                    color: Theme.of(context).colorScheme.onSurface,
                  )
                : Row(
                    children: [
                      Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        tr(ref, 'dark_mode'),
                        style: TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      Switch(
                        value: isDarkMode,
                        onChanged: onThemeToggle,
                        activeThumbColor: AppTheme.primaryBlue,
                      ),
                    ],
                  ),
          ),
          
          // User Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue,
                  radius: 18,
                  child: Text(
                    user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (!isSmallScreen) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user?.email?.split('@')[0] ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.language, size: 18),
                    onPressed: () async {
                      final currentLang = ref.read(languageProvider);
                      final newLang = currentLang == 'en' ? 'fr' : 'en';
                      await ref.read(languageProvider.notifier).setLanguage(newLang);
                    },
                    tooltip: tr(ref, 'language'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 18),
                    onPressed: () => ref.read(authServiceProvider).signOut(),
                    tooltip: tr(ref, 'logout'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required bool isSelected,
    required bool isSmallScreen,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? null : Colors.transparent,
        gradient: isSelected ? AppTheme.primaryGradient : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onDestinationSelected(index),
          hoverColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 0 : 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: isSmallScreen ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 20,
                ),
                if (!isSmallScreen) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
