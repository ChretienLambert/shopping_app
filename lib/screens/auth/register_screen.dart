import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_localization.dart';
import '../finance_screen.dart';
import '../../providers/weekly_checkup_provider.dart';
import '../../models/weekly_checkup.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address (e.g. name@company.com)');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    if (password != _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUp(email, password, name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(ref, 'registration_success'))),
        );
        // Navigate to finance screen and show weekly checkup dialog
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FinanceScreen()),
        );
        // Show weekly checkup dialog after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showWeeklyCheckupDialog();
          }
        });
      }
    } catch (e) {
      String message = e.toString();
      if (message.contains('email_address_invalid')) {
        message = 'The email address provided is invalid. Please check for typos.';
      } else if (message.contains('user_already_exists')) {
        message = 'An account with this email already exists.';
      } else if (message.contains('over_email_send_rate_limit')) {
        message = 'Signup rate limit exceeded. Please use Guest Mode (Bypass) for quick development access.';
      }
      setState(() {
        _errorMessage = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showWeeklyCheckupDialog() async {
    final notesController = TextEditingController();
    final payoutController = TextEditingController(text: '0');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Weekly Checkup'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome! Complete your first weekly checkup', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildResumeRow('Stock Purchased', '0 XAF'),
                        _buildResumeRow('Sales Revenue', '0 XAF'),
                        _buildResumeRow('Business Expenses', '0 XAF'),
                        _buildResumeRow('Personal Payouts', '0 XAF'),
                        const SizedBox(height: 4),
                        _buildResumeRow('Recovered from Sales', '0 XAF', isHighlight: true),
                        _buildResumeRow('Remaining to Recover', '0 XAF'),
                        _buildResumeRow('Realized Profit', '0 XAF', isHighlight: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Profit Distribution', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: payoutController,
                    decoration: const InputDecoration(
                      labelText: 'Profit Payout (take as salary)',
                      border: OutlineInputBorder(),
                      suffixText: 'XAF',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final payout = double.tryParse(payoutController.text) ?? 0;
                
                if (payout > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No profit available to distribute yet')),
                  );
                  return;
                }

                // Create weekly checkup record
                final now = DateTime.now();
                final weekStart = WeeklyCheckup.getWeekStartDate(now);
                final weekEnd = WeeklyCheckup.getWeekEndDate(now);
                
                final checkup = WeeklyCheckup()
                  ..weekStartDate = weekStart
                  ..weekEndDate = weekEnd
                  ..totalStockPurchased = 0
                  ..totalSalesRevenue = 0
                  ..totalBusinessExpenses = 0
                  ..totalPersonalPayouts = 0
                  ..capitalRecovered = 0
                  ..capitalRemaining = 0
                  ..realizedProfit = 0
                  ..profitPayoutTaken = payout
                  ..profitReinjected = 0 // No reinject option anymore
                  ..notes = notesController.text;

                await ref.read(weeklyCheckupProvider.notifier).addCheckup(checkup);

                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
              child: const Text('Complete Checkup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.slate500, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
              color: isHighlight ? (value.startsWith('-') ? Colors.red : Colors.green) : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.auto_graph_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineLarge,
                  ),
                  Text(
                    'Join the Corporate Ladies Business Suite',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),
                  
                  // Register Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.destructive.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.destructive.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppTheme.destructive, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock_reset_rounded, size: 20),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 32),
                        
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : const Text('Register Now'),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                tr(ref, 'sign_in'),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
        ],
      ),
    );
  }
}
