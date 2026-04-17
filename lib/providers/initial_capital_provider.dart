import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialCapitalNotifier extends StateNotifier<double> {
  static const _initialCapitalKey = 'finance_initial_capital';

  InitialCapitalNotifier() : super(0.0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_initialCapitalKey) ?? 0.0;
  }

  Future<void> updateCapital(double value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_initialCapitalKey, value);
  }
}

final initialCapitalProvider = StateNotifierProvider<InitialCapitalNotifier, double>(
  (ref) => InitialCapitalNotifier(),
);
