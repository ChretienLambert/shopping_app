import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/maintenance_service.dart';

final maintenanceServiceProvider = Provider<MaintenanceService>((ref) => MaintenanceService());
