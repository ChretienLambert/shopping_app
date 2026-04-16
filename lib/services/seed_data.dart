// Seed data helper — disabled when Isar is not present in this project.
// The project currently uses Drift (`DriftService`). If you intend to seed
// data into a local Isar instance, add `lib/services/isar_service.dart` and
// re-enable this file. For now the seeder is a no-op to avoid analyzer errors.

class SeedDataService {
  static Future<void> seedDummyData() async {
    // No-op seeder. Add IsarService and implement seeding if needed.
    return;
  }
}
