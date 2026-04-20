import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/services/sync_record_resolver.dart';

void main() {
  test('finds records by stable server id', () {
    final record = SyncRecordResolver.findExistingRecord(
      [
        {
          'id': 'local-1',
          'serverId': 'server-1',
        },
      ],
      serverId: 'server-1',
    );

    expect(record, isNotNull);
    expect(record?['id'], 'local-1');
  });

  test('uses remote server id as local id for unseen remote records', () {
    final localId = SyncRecordResolver.stableLocalId(
      existingJson: null,
      remoteServerId: 'server-42',
    );

    expect(localId, 'server-42');
  });
}
