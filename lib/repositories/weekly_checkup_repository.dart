import '../models/weekly_checkup.dart';
import '../services/hive_service.dart';

class WeeklyCheckupRepository {
  final _hive = HiveService.instance;

  Future<List<WeeklyCheckup>> getAll() async {
    final box = _hive.getBox('weekly_checkups');
    final checkups = box.values
        .map((c) => WeeklyCheckup.fromJson(c))
        .toList();
    checkups.sort((a, b) => b.checkupDate.compareTo(a.checkupDate));
    return checkups;
  }

  Future<WeeklyCheckup?> getById(String id) async {
    final box = _hive.getBox('weekly_checkups');
    final data = box.get(id);
    return data != null ? WeeklyCheckup.fromJson(data) : null;
  }

  Future<void> save(WeeklyCheckup checkup) async {
    final box = _hive.getBox('weekly_checkups');
    checkup.updatedAt = DateTime.now();
    await box.put(checkup.id, checkup.toJson());
  }

  Future<void> softDelete(WeeklyCheckup checkup) async {
    final box = _hive.getBox('weekly_checkups');
    checkup.deletedAt = DateTime.now();
    checkup.updatedAt = DateTime.now();
    await box.put(checkup.id, checkup.toJson());
  }

  Future<void> delete(WeeklyCheckup checkup) async {
    final box = _hive.getBox('weekly_checkups');
    await box.delete(checkup.id);
  }

  Future<List<WeeklyCheckup>> getByWeek(DateTime weekStartDate) async {
    final all = await getAll();
    return all.where((c) => 
      c.weekStartDate.year == weekStartDate.year && 
      c.weekStartDate.month == weekStartDate.month && 
      c.weekStartDate.day == weekStartDate.day
    ).toList();
  }

  Future<WeeklyCheckup?> getLatest() async {
    final all = await getAll();
    return all.isNotEmpty ? all.first : null;
  }
}
