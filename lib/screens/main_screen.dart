import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_screen.dart';
import 'products_screen.dart';
import 'customers_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/sync_provider.dart';
import 'sales_screen.dart';
import 'expenses_screen.dart';
import 'finance_screen.dart';
import 'settings_screen.dart';
import '../widgets/sidebar.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'auth/login_screen.dart';
import '../services/logging_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:io';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  void _initConnectivity() async {
    await _performConnectionCheck();
  }

  Future<void> _performConnectionCheck() async {
    try {
      final result = await Connectivity().checkConnectivity();
      bool online = result != ConnectivityResult.none;
      
      // Verification step: if connectivity_plus says offline, double check with a real host
      if (!online) {
        try {
          final lookup = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 2));
          online = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
        } catch (_) {
          online = false;
        }
      }
      
      if (mounted) {
        setState(() => _isOnline = online);
        logger.info('Connection status verified: ${online ? "Online" : "Offline"}');
      }
    } catch (e) {
      if (mounted) setState(() => _isOnline = true);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductsScreen(),
    const CustomersScreen(),
    const SalesScreen(),
    const ExpensesScreen(),
    const FinanceScreen(),
  ];

  final List<String> _screenTitles = [
    'Dashboard',
    'Products',
    'Customers',
    'Sales',
    'Expenses',
    'Finance',
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isGuest = ref.watch(guestModeProvider);
    
    return authState.when(
      data: (state) {
        if (state.session == null && !isGuest) {
          return const LoginScreen();
        }
        // Initialize sync manager once authenticated
        final syncManager = ref.watch(syncManagerProvider);
        
        return FutureBuilder<bool>(
          future: _checkIfInitialSyncNeeded(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            
            final needsSync = snapshot.data ?? false;
            
            if (needsSync) {
              return _buildSyncOverlay(context, syncManager);
            }
            
            return _buildMainLayout(context);
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Auth Error: $error'),
        ),
      ),
    );
  }

  Widget _buildMainLayout(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Row(
        children: [
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
                // Modern Header Component
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _screenTitles[_selectedIndex],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Connectivity Indicator
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                      size: 14,
                                      color: _isOnline ? Colors.green : Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isOnline ? 'Online' : 'Offline Mode',
                                      style: TextStyle(
                                        color: _isOnline ? Colors.green : Colors.amber,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                onPressed: () => _performConnectionCheck(),
                                tooltip: 'Ping Connection',
                                visualDensity: VisualDensity.compact,
                                color: AppTheme.slate400,
                              ),
                            ],
                          ),
                          Text(
                            'Manage your business data',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Export Button
                      Container(
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
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Settings',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: ClipRRect(
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkIfInitialSyncNeeded() async {
    // We check if we have any customers or products. 
    // If local DB is empty but we are logged in, we likely need an initial sync.
    try {
      final products = ref.read(productProvider);
      final customers = ref.read(customerProvider);
      
      // If both are empty, we might be on a new device.
      return products.isEmpty && customers.isEmpty;
    } catch (e) {
      return false;
    }
  }

  Widget _buildSyncOverlay(BuildContext context, dynamic syncManager) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_download, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'Setting up your shop...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Fetching your data from the cloud',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 40),
            FutureBuilder(
              future: syncManager.triggerInitialSync(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // Use microtask to avoid build phase setState
                  Future.microtask(() {
                    if (mounted) setState(() {});
                  });
                  return const Text('Complete!', style: TextStyle(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)),
                      TextButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
