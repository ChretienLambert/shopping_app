import 'package:isar/isar.dart';
import '../models/weekly_checkup.dart';
import '../services/isar_service.dart';

class WeeklyCheckupRepository {
  Future<Isar> get _isar async => await IsarService.instance.isar;

  Future<List<WeeklyCheckup>> getAll() async {
    final isar = await _isar;
    return await isar.weeklyCheckups.where().sortByCheckupDateDesc().findAll();
  }

  Future<WeeklyCheckup?> getById(int id) async {
    final isar = await _isar;
    return await isar.weeklyCheckups.where().idEqualTo(id).findFirst();
  }

  Future<void> save(WeeklyCheckup checkup) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.weeklyCheckups.put(checkup);
    });
  }

  Future<void> softDelete(WeeklyCheckup checkup) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      checkup.deletedAt = DateTime.now();
      await isar.weeklyCheckups.put(checkup);
    });
  }

  Future<void> delete(WeeklyCheckup checkup) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.weeklyCheckups.delete(checkup.id);
    });
  }

  // Get checkups for a specific week
  Future<List<WeeklyCheckup>> getByWeek(DateTime weekStartDate) async {
    final isar = await _isar;
    return await isar.weeklyCheckups
        .where()
        .weekStartDateEqualTo(weekStartDate)
        .findAll();
  }

  // Get the most recent checkup
  Future<WeeklyCheckup?> getLatest() async {
    final isar = await _isar;
    return await isar.weeklyCheckups.where().sortByCheckupDateDesc().findFirst();
  }
}
