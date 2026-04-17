import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../services/sync_manager.dart';
import 'auth_provider.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  final syncManager = SyncManager();
  
  // Real-time sync disabled as per request
  // Listen to auth state to trigger sync on login
  ref.listen<AsyncValue<supabase.AuthState>>(authStateProvider, (previous, next) {
    if (next.value?.session != null && previous?.value?.session == null) {
      // Manual trigger of initial sync when logging in
      syncManager.triggerInitialSync();
    }
  });

  ref.onDispose(() => syncManager.dispose());
  return syncManager;
});
