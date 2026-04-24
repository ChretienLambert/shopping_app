import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/sync_provider.dart';
import '../services/logging_service.dart';
import '../utils/app_localization.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';
import 'dashboard_screen.dart';
import 'products_screen.dart';
import 'customers_screen.dart';
import 'sales_screen.dart';
import 'expenses_screen.dart';
import 'finance_screen.dart';
import 'settings_screen.dart';
import 'auth/login_screen.dart';
import 'dart:async';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isOnline = true;
  bool _initialSyncChecked = false;
  bool _needsInitialSync = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _performConnectionCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When workstation is focused/resumed, trigger a background sync to get remote changes
    if (state == AppLifecycleState.resumed) {
      ref.read(syncManagerProvider).syncAll();
    }
  }

  Future<void> _performConnectionCheck() async {
    final syncManager = ref.read(syncManagerProvider);
    final online = await syncManager.checkConnection() == null;
    if (mounted) {
      setState(() {
        _isOnline = online;
      });
      if (online && !_initialSyncChecked) {
        _initialSyncChecked = true;
        _decideInitialSync();
      }
    }
  }

  Future<void> _decideInitialSync() async {
    final syncManager = ref.read(syncManagerProvider);
    
    // We check if sync is needed (e.g., if we have no customers yet)
    // To keep it simple, we only show the overlay if we are online and 
    // it's the first time we enter the main screen in this session.
    if (_isOnline) {
      setState(() => _needsInitialSync = true);
      try {
        await syncManager.triggerInitialSync();
      } catch (e) {
        debugPrint('Initial sync failed: $e');
      } finally {
        if (mounted) {
          setState(() => _needsInitialSync = false);
        }
      }
    }
  }

  Widget _buildSyncOverlay(BuildContext context, dynamic syncManager) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(tr(ref, 'syncing_data'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(tr(ref, 'please_wait_initial_sync')),
          ],
        ),
      ),
    );
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductsScreen(),
    const CustomersScreen(),
    const SalesScreen(),
    const ExpensesScreen(),
    const FinanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appSession = ref.watch(appSessionProvider);

    return appSession.when(
      data: (session) {
        if (session == null) {
          return const LoginScreen();
        }

        if (_needsInitialSync && session.isOnline) {
          return _buildSyncOverlay(context, ref.watch(syncManagerProvider));
        }

        return _buildMainLayout(context);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        // Fallback to local session if available even on auth error
        final cachedSession = ref.read(authServiceProvider).currentAppSession;
        if (cachedSession != null) {
          logger.warning('Auth error detected, but using cached session: $error');
          return _buildMainLayout(context);
        }

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    tr(ref, 'connection_error'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString().contains('SocketException') || error.toString().contains('host lookup')
                        ? tr(ref, 'offline_auth_error')
                        : error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(appSessionProvider),
                    child: Text(tr(ref, 'retry')),
                  ),
                  TextButton(
                    onPressed: () => ref.read(authServiceProvider).signInAsGuest(),
                    child: Text(tr(ref, 'continue_offline')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainLayout(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    final screenTitles = [
      tr(ref, 'dashboard'),
      tr(ref, 'catalogs'),
      tr(ref, 'customers'),
      tr(ref, 'sales'),
      tr(ref, 'expenses'),
      tr(ref, 'finance'),
    ];

    final navItems = [
      (icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: tr(ref, 'dashboard')),
      (icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, label: tr(ref, 'catalogs')),
      (icon: Icons.people_outline, selectedIcon: Icons.people, label: tr(ref, 'customers')),
      (icon: Icons.shopping_cart_outlined, selectedIcon: Icons.shopping_cart, label: tr(ref, 'sales')),
      (icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long, label: tr(ref, 'expenses')),
      (icon: Icons.account_balance_outlined, selectedIcon: Icons.account_balance, label: tr(ref, 'finance')),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final navigator = Navigator.of(context);
          final shouldExit = await _showExitConfirmationDialog(context);
          if (shouldExit && mounted) {
            navigator.pop();
          }
        }
      },
      child: Scaffold(
        key: GlobalKey<ScaffoldState>(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottomNavigationBar: isMobile
            ? NavigationBar(
                height: 64, // Slightly shorter for mobile
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                labelBehavior: screenWidth < 380 ? NavigationDestinationLabelBehavior.alwaysHide : NavigationDestinationLabelBehavior.alwaysShow,
                destinations: navItems
                    .map((item) => NavigationDestination(
                          icon: Icon(item.icon, size: 22),
                          selectedIcon: Icon(item.selectedIcon, size: 22),
                          label: item.label,
                        ))
                    .toList(),
              )
            : null,
        body: Row(
          children: [
            if (!isMobile)
              Sidebar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  if (index == 6) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    return;
                  }
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                isDarkMode: isDarkMode,
                onThemeToggle: (value) {
                  ref.read(themeProvider.notifier).setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              ),
            Expanded(
              child: Column(
                children: [
                  Builder(builder: (context) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 24,
                        vertical: isMobile ? 10 : 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        screenTitles[_selectedIndex],
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: isMobile ? (screenWidth < 350 ? 16 : 18) : 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildConnectionBadge(isMobile),
                                  ],
                                ),
                                if (!isMobile)
                                  Text(
                                    tr(ref, 'manage_business_data'),
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isMobile) 
                            IconButton(
                              icon: const Icon(Icons.settings_outlined, size: 22),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                            )
                          else ...[
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              onPressed: () => _performConnectionCheck(),
                              tooltip: tr(ref, 'ping_connection'),
                              color: AppTheme.slate400,
                            ),
                            const SizedBox(width: 8),
                            _buildSettingsButton(context),
                          ],
                        ],
                      ),
                    );
                  }),
                  Expanded(
                    child: _screens[_selectedIndex],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionBadge(bool isMobile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallMobile = screenWidth < 350;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 4 : 8, vertical: 4),
      decoration: BoxDecoration(
        color: (_isOnline ? Colors.green : Colors.amber).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_isOnline ? Colors.green : Colors.amber).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOnline ? Icons.cloud_done : Icons.cloud_off,
            size: isSmallMobile ? 10 : 12,
            color: _isOnline ? Colors.green : Colors.amber,
          ),
          if (!isMobile) ...[
            const SizedBox(width: 4),
            Text(
              _isOnline ? tr(ref, 'online') : tr(ref, 'offline_mode'),
              style: TextStyle(
                color: _isOnline ? Colors.green : Colors.amber,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  tr(ref, 'settings'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'exit_app')),
        content: Text(tr(ref, 'are_you_sure_exit')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr(ref, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(tr(ref, 'exit')),
          ),
        ],
      ),
    ) ?? false;
  }
}
