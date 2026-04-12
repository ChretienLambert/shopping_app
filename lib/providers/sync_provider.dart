import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_manager.dart';
import 'auth_provider.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  final syncManager = SyncManager();
  
  // Listen to auth state to trigger sync on login
  ref.listen(authStateProvider, (previous, next) {
    if (next.value?.session != null && previous?.value?.session == null) {
      syncManager.syncAll();
    }
  });

  ref.onDispose(() => syncManager.dispose());
  return syncManager;
});
