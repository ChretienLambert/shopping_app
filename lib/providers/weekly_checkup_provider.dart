import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weekly_checkup.dart';
import '../repositories/weekly_checkup_repository.dart';

class WeeklyCheckupNotifier extends StateNotifier<List<WeeklyCheckup>> {
  final _repository = WeeklyCheckupRepository();

  WeeklyCheckupNotifier() : super([]) {
    loadCheckups();
  }

  Future<void> loadCheckups() async {
    final checkups = await _repository.getAll();
    state = checkups..sort((a, b) => b.checkupDate.compareTo(a.checkupDate));
  }

  Future<void> addCheckup(WeeklyCheckup checkup) async {
    await _repository.save(checkup);
    await loadCheckups();
  }

  Future<void> updateCheckup(WeeklyCheckup checkup) async {
    await _repository.save(checkup);
    await loadCheckups();
  }

  Future<void> deleteCheckup(WeeklyCheckup checkup) async {
    await _repository.softDelete(checkup);
    await loadCheckups();
  }

  Future<WeeklyCheckup?> getCheckupById(int id) async {
    final checkups = await _repository.getAll();
    try {
      return checkups.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get the most recent checkup
  Future<WeeklyCheckup?> getLatestCheckup() async {
    final checkups = await _repository.getAll();
    if (checkups.isEmpty) return null;
    return checkups.reduce((a, b) => a.checkupDate.isAfter(b.checkupDate) ? a : b);
  }

  // Check if a checkup is due (more than 7 days since last checkup)
  Future<bool> isCheckupDue() async {
    final latest = await getLatestCheckup();
    if (latest == null) return true; // No checkups yet, so one is due
    
    final daysSinceLastCheckup = DateTime.now().difference(latest.checkupDate).inDays;
    return daysSinceLastCheckup >= 7;
  }

  // Get checkups for a specific date range
  Future<List<WeeklyCheckup>> getCheckupsInRange(DateTime startDate, DateTime endDate) async {
    final checkups = await _repository.getAll();
    return checkups.where((c) {
      return c.checkupDate.isAfter(startDate) && c.checkupDate.isBefore(endDate);
    }).toList();
  }
}

final weeklyCheckupProvider = StateNotifierProvider<WeeklyCheckupNotifier, List<WeeklyCheckup>>((ref) {
  return WeeklyCheckupNotifier();
});
