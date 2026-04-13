import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../utils/app_localization.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  static const _setupCompletedKey = 'app_setup_completed';
  static const _initialCapitalKey = 'finance_initial_capital';
  static const _languageKey = 'app_language';

  final _capitalController = TextEditingController();
  String _selectedLanguage = 'en';
  bool _saving = false;

  @override
  void dispose() {
    _capitalController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    final initialCapital = double.tryParse(_capitalController.text) ?? 0;
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _selectedLanguage);
    await ref.read(languageProvider.notifier).setLanguage(_selectedLanguage);
    await prefs.setDouble(_initialCapitalKey, initialCapital);
    await prefs.setBool(_setupCompletedKey, true);
    if (mounted) {
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(ref, 'welcome_corporate_ladies'),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(tr(ref, 'setup_business_profile')),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLanguage,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'language'),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 'en', child: Text(tr(ref, 'english'))),
                        DropdownMenuItem(value: 'fr', child: Text(tr(ref, 'french'))),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedLanguage = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _capitalController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: tr(ref, 'initial_capital'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _completeSetup,
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(tr(ref, 'start_app')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
