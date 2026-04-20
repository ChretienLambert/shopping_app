import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/maintenance_service.dart';
import 'auth_provider.dart';

final maintenanceServiceProvider = Provider<MaintenanceService>((ref) {
  return MaintenanceService(ref.watch(appConfigProvider));
});
