import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_session.dart';
import '../services/sync_manager.dart';
import 'auth_provider.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  final syncManager = SyncManager(ref.watch(appConfigProvider));
  
  ref.listen<AsyncValue<AppSession?>>(appSessionProvider, (previous, next) {
    final previousSession = previous?.value;
    final nextSession = next.value;

    if (nextSession != null &&
        nextSession.isOnline &&
        previousSession?.serverUserId != nextSession.serverUserId) {
      syncManager.triggerInitialSync();
    }
  });

  ref.onDispose(() => syncManager.dispose());
  return syncManager;
});
