class SyncRecordResolver {
  static Map<dynamic, dynamic>? findExistingRecord(
    Iterable<dynamic> records, {
    String? localId,
    String? serverId,
  }) {
    for (final record in records) {
      if (record is! Map) continue;
      if (localId != null && record['id'] == localId) {
        return record;
      }
      if (serverId != null && record['serverId'] == serverId) {
        return record;
      }
    }
    return null;
  }

  static String stableLocalId({
    required Map<dynamic, dynamic>? existingJson,
    required String remoteServerId,
  }) {
    final existingId = existingJson?['id'] as String?;
    return existingId == null || existingId.isEmpty ? remoteServerId : existingId;
  }
}
