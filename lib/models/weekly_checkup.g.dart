// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_checkup.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWeeklyCheckupCollection on Isar {
  IsarCollection<WeeklyCheckup> get weeklyCheckups => this.collection();
}

const WeeklyCheckupSchema = CollectionSchema(
  name: r'WeeklyCheckup',
  id: 252243642174233898,
  properties: {
    r'capitalRecovered': PropertySchema(
      id: 0,
      name: r'capitalRecovered',
      type: IsarType.double,
    ),
    r'capitalRemaining': PropertySchema(
      id: 1,
      name: r'capitalRemaining',
      type: IsarType.double,
    ),
    r'checkupDate': PropertySchema(
      id: 2,
      name: r'checkupDate',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 4,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'isDirty': PropertySchema(
      id: 5,
      name: r'isDirty',
      type: IsarType.bool,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 6,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 7,
      name: r'notes',
      type: IsarType.string,
    ),
    r'operationId': PropertySchema(
      id: 8,
      name: r'operationId',
      type: IsarType.string,
    ),
    r'profitPayoutTaken': PropertySchema(
      id: 9,
      name: r'profitPayoutTaken',
      type: IsarType.double,
    ),
    r'profitReinjected': PropertySchema(
      id: 10,
      name: r'profitReinjected',
      type: IsarType.double,
    ),
    r'realizedProfit': PropertySchema(
      id: 11,
      name: r'realizedProfit',
      type: IsarType.double,
    ),
    r'serverId': PropertySchema(
      id: 12,
      name: r'serverId',
      type: IsarType.string,
    ),
    r'totalBusinessExpenses': PropertySchema(
      id: 13,
      name: r'totalBusinessExpenses',
      type: IsarType.double,
    ),
    r'totalPersonalPayouts': PropertySchema(
      id: 14,
      name: r'totalPersonalPayouts',
      type: IsarType.double,
    ),
    r'totalSalesRevenue': PropertySchema(
      id: 15,
      name: r'totalSalesRevenue',
      type: IsarType.double,
    ),
    r'totalStockPurchased': PropertySchema(
      id: 16,
      name: r'totalStockPurchased',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 17,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 18,
      name: r'userId',
      type: IsarType.long,
    ),
    r'weekEndDate': PropertySchema(
      id: 19,
      name: r'weekEndDate',
      type: IsarType.dateTime,
    ),
    r'weekStartDate': PropertySchema(
      id: 20,
      name: r'weekStartDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _weeklyCheckupEstimateSize,
  serialize: _weeklyCheckupSerialize,
  deserialize: _weeklyCheckupDeserialize,
  deserializeProp: _weeklyCheckupDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'serverId': IndexSchema(
      id: -7950187970872907662,
      name: r'serverId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'serverId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isDirty': IndexSchema(
      id: 5701622868881901852,
      name: r'isDirty',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isDirty',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'weekStartDate': IndexSchema(
      id: 7906057668223877157,
      name: r'weekStartDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'weekStartDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'weekEndDate': IndexSchema(
      id: -7470339102593665499,
      name: r'weekEndDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'weekEndDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'checkupDate': IndexSchema(
      id: 8756237890637660017,
      name: r'checkupDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'checkupDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'totalStockPurchased': IndexSchema(
      id: -3775466315432775831,
      name: r'totalStockPurchased',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'totalStockPurchased',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'totalSalesRevenue': IndexSchema(
      id: 5233171534187857883,
      name: r'totalSalesRevenue',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'totalSalesRevenue',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'totalBusinessExpenses': IndexSchema(
      id: 2957063829127510257,
      name: r'totalBusinessExpenses',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'totalBusinessExpenses',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'totalPersonalPayouts': IndexSchema(
      id: 6388270703010784950,
      name: r'totalPersonalPayouts',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'totalPersonalPayouts',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'capitalRecovered': IndexSchema(
      id: -429275500683478866,
      name: r'capitalRecovered',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'capitalRecovered',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'capitalRemaining': IndexSchema(
      id: -5642385277119511188,
      name: r'capitalRemaining',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'capitalRemaining',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'realizedProfit': IndexSchema(
      id: 5316915793447238503,
      name: r'realizedProfit',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'realizedProfit',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'profitPayoutTaken': IndexSchema(
      id: 1877747303740772625,
      name: r'profitPayoutTaken',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'profitPayoutTaken',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'profitReinjected': IndexSchema(
      id: 3913074462502759466,
      name: r'profitReinjected',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'profitReinjected',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'deletedAt': IndexSchema(
      id: -8969437169173379604,
      name: r'deletedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'deletedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _weeklyCheckupGetId,
  getLinks: _weeklyCheckupGetLinks,
  attach: _weeklyCheckupAttach,
  version: '3.1.0+1',
);

int _weeklyCheckupEstimateSize(
  WeeklyCheckup object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.operationId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.serverId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _weeklyCheckupSerialize(
  WeeklyCheckup object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.capitalRecovered);
  writer.writeDouble(offsets[1], object.capitalRemaining);
  writer.writeDateTime(offsets[2], object.checkupDate);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDateTime(offsets[4], object.deletedAt);
  writer.writeBool(offsets[5], object.isDirty);
  writer.writeDateTime(offsets[6], object.lastSyncedAt);
  writer.writeString(offsets[7], object.notes);
  writer.writeString(offsets[8], object.operationId);
  writer.writeDouble(offsets[9], object.profitPayoutTaken);
  writer.writeDouble(offsets[10], object.profitReinjected);
  writer.writeDouble(offsets[11], object.realizedProfit);
  writer.writeString(offsets[12], object.serverId);
  writer.writeDouble(offsets[13], object.totalBusinessExpenses);
  writer.writeDouble(offsets[14], object.totalPersonalPayouts);
  writer.writeDouble(offsets[15], object.totalSalesRevenue);
  writer.writeDouble(offsets[16], object.totalStockPurchased);
  writer.writeDateTime(offsets[17], object.updatedAt);
  writer.writeLong(offsets[18], object.userId);
  writer.writeDateTime(offsets[19], object.weekEndDate);
  writer.writeDateTime(offsets[20], object.weekStartDate);
}

WeeklyCheckup _weeklyCheckupDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WeeklyCheckup();
  object.capitalRecovered = reader.readDouble(offsets[0]);
  object.capitalRemaining = reader.readDouble(offsets[1]);
  object.checkupDate = reader.readDateTime(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.isDirty = reader.readBool(offsets[5]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[6]);
  object.notes = reader.readStringOrNull(offsets[7]);
  object.operationId = reader.readStringOrNull(offsets[8]);
  object.profitPayoutTaken = reader.readDouble(offsets[9]);
  object.profitReinjected = reader.readDouble(offsets[10]);
  object.realizedProfit = reader.readDouble(offsets[11]);
  object.serverId = reader.readStringOrNull(offsets[12]);
  object.totalBusinessExpenses = reader.readDouble(offsets[13]);
  object.totalPersonalPayouts = reader.readDouble(offsets[14]);
  object.totalSalesRevenue = reader.readDouble(offsets[15]);
  object.totalStockPurchased = reader.readDouble(offsets[16]);
  object.updatedAt = reader.readDateTime(offsets[17]);
  object.userId = reader.readLongOrNull(offsets[18]);
  object.weekEndDate = reader.readDateTime(offsets[19]);
  object.weekStartDate = reader.readDateTime(offsets[20]);
  return object;
}

P _weeklyCheckupDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    case 15:
      return (reader.readDouble(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readDateTime(offset)) as P;
    case 18:
      return (reader.readLongOrNull(offset)) as P;
    case 19:
      return (reader.readDateTime(offset)) as P;
    case 20:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _weeklyCheckupGetId(WeeklyCheckup object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _weeklyCheckupGetLinks(WeeklyCheckup object) {
  return [];
}

void _weeklyCheckupAttach(
    IsarCollection<dynamic> col, Id id, WeeklyCheckup object) {
  object.id = id;
}

extension WeeklyCheckupByIndex on IsarCollection<WeeklyCheckup> {
  Future<WeeklyCheckup?> getByServerId(String? serverId) {
    return getByIndex(r'serverId', [serverId]);
  }

  WeeklyCheckup? getByServerIdSync(String? serverId) {
    return getByIndexSync(r'serverId', [serverId]);
  }

  Future<bool> deleteByServerId(String? serverId) {
    return deleteByIndex(r'serverId', [serverId]);
  }

  bool deleteByServerIdSync(String? serverId) {
    return deleteByIndexSync(r'serverId', [serverId]);
  }

  Future<List<WeeklyCheckup?>> getAllByServerId(List<String?> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'serverId', values);
  }

  List<WeeklyCheckup?> getAllByServerIdSync(List<String?> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'serverId', values);
  }

  Future<int> deleteAllByServerId(List<String?> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'serverId', values);
  }

  int deleteAllByServerIdSync(List<String?> serverIdValues) {
    final values = serverIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'serverId', values);
  }

  Future<Id> putByServerId(WeeklyCheckup object) {
    return putByIndex(r'serverId', object);
  }

  Id putByServerIdSync(WeeklyCheckup object, {bool saveLinks = true}) {
    return putByIndexSync(r'serverId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServerId(List<WeeklyCheckup> objects) {
    return putAllByIndex(r'serverId', objects);
  }

  List<Id> putAllByServerIdSync(List<WeeklyCheckup> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'serverId', objects, saveLinks: saveLinks);
  }
}

extension WeeklyCheckupQueryWhereSort
    on QueryBuilder<WeeklyCheckup, WeeklyCheckup, QWhere> {
  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere> anyUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'userId'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere> anyIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isDirty'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere> anyWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'weekStartDate'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere> anyWeekEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'weekEndDate'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere> anyCheckupDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'checkupDate'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere>
      anyTotalStockPurchased() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'totalStockPurchased'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere>
      anyTotalSalesRevenue() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'totalSalesRevenue'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere>
      anyTotalBusinessExpenses() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'totalBusinessExpenses'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere>
      anyTotalPersonalPayouts() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'totalPersonalPayouts'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere>
      anyCapitalRecovered() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'capitalRecovered'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere>
      anyCapitalRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'capitalRemaining'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere> anyRealizedProfit() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'realizedProfit'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere>
      anyProfitPayoutTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profitPayoutTaken'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere>
      anyProfitReinjected() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profitReinjected'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhere> anyDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'deletedAt'),
      );
    });
  }
}

extension WeeklyCheckupQueryWhere
    on QueryBuilder<WeeklyCheckup, WeeklyCheckup, QWhereClause> {
  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause> userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [null],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'userId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause> userIdEqualTo(
      int? userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      userIdNotEqualTo(int? userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      userIdGreaterThan(
    int? userId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'userId',
        lower: [userId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause> userIdLessThan(
    int? userId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'userId',
        lower: [],
        upper: [userId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause> userIdBetween(
    int? lowerUserId,
    int? upperUserId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'userId',
        lower: [lowerUserId],
        includeLower: includeLower,
        upper: [upperUserId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [null],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'serverId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause> serverIdEqualTo(
      String? serverId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'serverId',
        value: [serverId],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      serverIdNotEqualTo(String? serverId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [],
              upper: [serverId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [serverId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [serverId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'serverId',
              lower: [],
              upper: [serverId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause> isDirtyEqualTo(
      bool isDirty) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isDirty',
        value: [isDirty],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      isDirtyNotEqualTo(bool isDirty) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isDirty',
              lower: [],
              upper: [isDirty],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isDirty',
              lower: [isDirty],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isDirty',
              lower: [isDirty],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isDirty',
              lower: [],
              upper: [isDirty],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      weekStartDateEqualTo(DateTime weekStartDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'weekStartDate',
        value: [weekStartDate],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      weekStartDateNotEqualTo(DateTime weekStartDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [],
              upper: [weekStartDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [weekStartDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [weekStartDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [],
              upper: [weekStartDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      weekStartDateGreaterThan(
    DateTime weekStartDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStartDate',
        lower: [weekStartDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      weekStartDateLessThan(
    DateTime weekStartDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStartDate',
        lower: [],
        upper: [weekStartDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      weekStartDateBetween(
    DateTime lowerWeekStartDate,
    DateTime upperWeekStartDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekStartDate',
        lower: [lowerWeekStartDate],
        includeLower: includeLower,
        upper: [upperWeekStartDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      weekEndDateEqualTo(DateTime weekEndDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'weekEndDate',
        value: [weekEndDate],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      weekEndDateNotEqualTo(DateTime weekEndDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekEndDate',
              lower: [],
              upper: [weekEndDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekEndDate',
              lower: [weekEndDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekEndDate',
              lower: [weekEndDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekEndDate',
              lower: [],
              upper: [weekEndDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      weekEndDateGreaterThan(
    DateTime weekEndDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekEndDate',
        lower: [weekEndDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      weekEndDateLessThan(
    DateTime weekEndDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekEndDate',
        lower: [],
        upper: [weekEndDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      weekEndDateBetween(
    DateTime lowerWeekEndDate,
    DateTime upperWeekEndDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'weekEndDate',
        lower: [lowerWeekEndDate],
        includeLower: includeLower,
        upper: [upperWeekEndDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      checkupDateEqualTo(DateTime checkupDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'checkupDate',
        value: [checkupDate],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      checkupDateNotEqualTo(DateTime checkupDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'checkupDate',
              lower: [],
              upper: [checkupDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'checkupDate',
              lower: [checkupDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'checkupDate',
              lower: [checkupDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'checkupDate',
              lower: [],
              upper: [checkupDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      checkupDateGreaterThan(
    DateTime checkupDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'checkupDate',
        lower: [checkupDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      checkupDateLessThan(
    DateTime checkupDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'checkupDate',
        lower: [],
        upper: [checkupDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      checkupDateBetween(
    DateTime lowerCheckupDate,
    DateTime upperCheckupDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'checkupDate',
        lower: [lowerCheckupDate],
        includeLower: includeLower,
        upper: [upperCheckupDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalStockPurchasedEqualTo(double totalStockPurchased) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'totalStockPurchased',
        value: [totalStockPurchased],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalStockPurchasedNotEqualTo(double totalStockPurchased) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalStockPurchased',
              lower: [],
              upper: [totalStockPurchased],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalStockPurchased',
              lower: [totalStockPurchased],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalStockPurchased',
              lower: [totalStockPurchased],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalStockPurchased',
              lower: [],
              upper: [totalStockPurchased],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalStockPurchasedGreaterThan(
    double totalStockPurchased, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalStockPurchased',
        lower: [totalStockPurchased],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalStockPurchasedLessThan(
    double totalStockPurchased, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalStockPurchased',
        lower: [],
        upper: [totalStockPurchased],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalStockPurchasedBetween(
    double lowerTotalStockPurchased,
    double upperTotalStockPurchased, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalStockPurchased',
        lower: [lowerTotalStockPurchased],
        includeLower: includeLower,
        upper: [upperTotalStockPurchased],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalSalesRevenueEqualTo(double totalSalesRevenue) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'totalSalesRevenue',
        value: [totalSalesRevenue],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalSalesRevenueNotEqualTo(double totalSalesRevenue) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalSalesRevenue',
              lower: [],
              upper: [totalSalesRevenue],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalSalesRevenue',
              lower: [totalSalesRevenue],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalSalesRevenue',
              lower: [totalSalesRevenue],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalSalesRevenue',
              lower: [],
              upper: [totalSalesRevenue],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalSalesRevenueGreaterThan(
    double totalSalesRevenue, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalSalesRevenue',
        lower: [totalSalesRevenue],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalSalesRevenueLessThan(
    double totalSalesRevenue, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalSalesRevenue',
        lower: [],
        upper: [totalSalesRevenue],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalSalesRevenueBetween(
    double lowerTotalSalesRevenue,
    double upperTotalSalesRevenue, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalSalesRevenue',
        lower: [lowerTotalSalesRevenue],
        includeLower: includeLower,
        upper: [upperTotalSalesRevenue],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalBusinessExpensesEqualTo(double totalBusinessExpenses) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'totalBusinessExpenses',
        value: [totalBusinessExpenses],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalBusinessExpensesNotEqualTo(double totalBusinessExpenses) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalBusinessExpenses',
              lower: [],
              upper: [totalBusinessExpenses],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalBusinessExpenses',
              lower: [totalBusinessExpenses],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalBusinessExpenses',
              lower: [totalBusinessExpenses],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalBusinessExpenses',
              lower: [],
              upper: [totalBusinessExpenses],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalBusinessExpensesGreaterThan(
    double totalBusinessExpenses, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalBusinessExpenses',
        lower: [totalBusinessExpenses],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalBusinessExpensesLessThan(
    double totalBusinessExpenses, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalBusinessExpenses',
        lower: [],
        upper: [totalBusinessExpenses],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalBusinessExpensesBetween(
    double lowerTotalBusinessExpenses,
    double upperTotalBusinessExpenses, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalBusinessExpenses',
        lower: [lowerTotalBusinessExpenses],
        includeLower: includeLower,
        upper: [upperTotalBusinessExpenses],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalPersonalPayoutsEqualTo(double totalPersonalPayouts) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'totalPersonalPayouts',
        value: [totalPersonalPayouts],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalPersonalPayoutsNotEqualTo(double totalPersonalPayouts) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalPersonalPayouts',
              lower: [],
              upper: [totalPersonalPayouts],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalPersonalPayouts',
              lower: [totalPersonalPayouts],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalPersonalPayouts',
              lower: [totalPersonalPayouts],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'totalPersonalPayouts',
              lower: [],
              upper: [totalPersonalPayouts],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalPersonalPayoutsGreaterThan(
    double totalPersonalPayouts, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalPersonalPayouts',
        lower: [totalPersonalPayouts],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalPersonalPayoutsLessThan(
    double totalPersonalPayouts, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalPersonalPayouts',
        lower: [],
        upper: [totalPersonalPayouts],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      totalPersonalPayoutsBetween(
    double lowerTotalPersonalPayouts,
    double upperTotalPersonalPayouts, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'totalPersonalPayouts',
        lower: [lowerTotalPersonalPayouts],
        includeLower: includeLower,
        upper: [upperTotalPersonalPayouts],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      capitalRecoveredEqualTo(double capitalRecovered) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'capitalRecovered',
        value: [capitalRecovered],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      capitalRecoveredNotEqualTo(double capitalRecovered) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capitalRecovered',
              lower: [],
              upper: [capitalRecovered],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capitalRecovered',
              lower: [capitalRecovered],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capitalRecovered',
              lower: [capitalRecovered],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capitalRecovered',
              lower: [],
              upper: [capitalRecovered],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      capitalRecoveredGreaterThan(
    double capitalRecovered, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capitalRecovered',
        lower: [capitalRecovered],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      capitalRecoveredLessThan(
    double capitalRecovered, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capitalRecovered',
        lower: [],
        upper: [capitalRecovered],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      capitalRecoveredBetween(
    double lowerCapitalRecovered,
    double upperCapitalRecovered, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capitalRecovered',
        lower: [lowerCapitalRecovered],
        includeLower: includeLower,
        upper: [upperCapitalRecovered],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      capitalRemainingEqualTo(double capitalRemaining) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'capitalRemaining',
        value: [capitalRemaining],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      capitalRemainingNotEqualTo(double capitalRemaining) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capitalRemaining',
              lower: [],
              upper: [capitalRemaining],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capitalRemaining',
              lower: [capitalRemaining],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capitalRemaining',
              lower: [capitalRemaining],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capitalRemaining',
              lower: [],
              upper: [capitalRemaining],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      capitalRemainingGreaterThan(
    double capitalRemaining, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capitalRemaining',
        lower: [capitalRemaining],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      capitalRemainingLessThan(
    double capitalRemaining, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capitalRemaining',
        lower: [],
        upper: [capitalRemaining],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      capitalRemainingBetween(
    double lowerCapitalRemaining,
    double upperCapitalRemaining, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capitalRemaining',
        lower: [lowerCapitalRemaining],
        includeLower: includeLower,
        upper: [upperCapitalRemaining],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      realizedProfitEqualTo(double realizedProfit) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'realizedProfit',
        value: [realizedProfit],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      realizedProfitNotEqualTo(double realizedProfit) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'realizedProfit',
              lower: [],
              upper: [realizedProfit],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'realizedProfit',
              lower: [realizedProfit],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'realizedProfit',
              lower: [realizedProfit],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'realizedProfit',
              lower: [],
              upper: [realizedProfit],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      realizedProfitGreaterThan(
    double realizedProfit, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'realizedProfit',
        lower: [realizedProfit],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      realizedProfitLessThan(
    double realizedProfit, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'realizedProfit',
        lower: [],
        upper: [realizedProfit],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      realizedProfitBetween(
    double lowerRealizedProfit,
    double upperRealizedProfit, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'realizedProfit',
        lower: [lowerRealizedProfit],
        includeLower: includeLower,
        upper: [upperRealizedProfit],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      profitPayoutTakenEqualTo(double profitPayoutTaken) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profitPayoutTaken',
        value: [profitPayoutTaken],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      profitPayoutTakenNotEqualTo(double profitPayoutTaken) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profitPayoutTaken',
              lower: [],
              upper: [profitPayoutTaken],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profitPayoutTaken',
              lower: [profitPayoutTaken],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profitPayoutTaken',
              lower: [profitPayoutTaken],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profitPayoutTaken',
              lower: [],
              upper: [profitPayoutTaken],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      profitPayoutTakenGreaterThan(
    double profitPayoutTaken, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profitPayoutTaken',
        lower: [profitPayoutTaken],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      profitPayoutTakenLessThan(
    double profitPayoutTaken, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profitPayoutTaken',
        lower: [],
        upper: [profitPayoutTaken],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      profitPayoutTakenBetween(
    double lowerProfitPayoutTaken,
    double upperProfitPayoutTaken, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profitPayoutTaken',
        lower: [lowerProfitPayoutTaken],
        includeLower: includeLower,
        upper: [upperProfitPayoutTaken],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      profitReinjectedEqualTo(double profitReinjected) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'profitReinjected',
        value: [profitReinjected],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      profitReinjectedNotEqualTo(double profitReinjected) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profitReinjected',
              lower: [],
              upper: [profitReinjected],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profitReinjected',
              lower: [profitReinjected],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profitReinjected',
              lower: [profitReinjected],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'profitReinjected',
              lower: [],
              upper: [profitReinjected],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      profitReinjectedGreaterThan(
    double profitReinjected, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profitReinjected',
        lower: [profitReinjected],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      profitReinjectedLessThan(
    double profitReinjected, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profitReinjected',
        lower: [],
        upper: [profitReinjected],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      profitReinjectedBetween(
    double lowerProfitReinjected,
    double upperProfitReinjected, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'profitReinjected',
        lower: [lowerProfitReinjected],
        includeLower: includeLower,
        upper: [upperProfitReinjected],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      updatedAtEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updatedAt',
        value: [updatedAt],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      updatedAtNotEqualTo(DateTime updatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [updatedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updatedAt',
              lower: [],
              upper: [updatedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      updatedAtGreaterThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [updatedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      updatedAtLessThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [],
        upper: [updatedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updatedAt',
        lower: [lowerUpdatedAt],
        includeLower: includeLower,
        upper: [upperUpdatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'deletedAt',
        value: [null],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'deletedAt',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      deletedAtEqualTo(DateTime? deletedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'deletedAt',
        value: [deletedAt],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      deletedAtNotEqualTo(DateTime? deletedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deletedAt',
              lower: [],
              upper: [deletedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deletedAt',
              lower: [deletedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deletedAt',
              lower: [deletedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deletedAt',
              lower: [],
              upper: [deletedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      deletedAtGreaterThan(
    DateTime? deletedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'deletedAt',
        lower: [deletedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      deletedAtLessThan(
    DateTime? deletedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'deletedAt',
        lower: [],
        upper: [deletedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterWhereClause>
      deletedAtBetween(
    DateTime? lowerDeletedAt,
    DateTime? upperDeletedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'deletedAt',
        lower: [lowerDeletedAt],
        includeLower: includeLower,
        upper: [upperDeletedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WeeklyCheckupQueryFilter
    on QueryBuilder<WeeklyCheckup, WeeklyCheckup, QFilterCondition> {
  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      capitalRecoveredEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capitalRecovered',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      capitalRecoveredGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'capitalRecovered',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      capitalRecoveredLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'capitalRecovered',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      capitalRecoveredBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'capitalRecovered',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      capitalRemainingEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capitalRemaining',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      capitalRemainingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'capitalRemaining',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      capitalRemainingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'capitalRemaining',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      capitalRemainingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'capitalRemaining',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      checkupDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checkupDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      checkupDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checkupDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      checkupDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checkupDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      checkupDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checkupDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deletedAt',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      deletedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      deletedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deletedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      isDirtyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDirty',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      lastSyncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      lastSyncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      lastSyncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'operationId',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'operationId',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationId',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      operationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationId',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      profitPayoutTakenEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profitPayoutTaken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      profitPayoutTakenGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'profitPayoutTaken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      profitPayoutTakenLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'profitPayoutTaken',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      profitPayoutTakenBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'profitPayoutTaken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      profitReinjectedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'profitReinjected',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      profitReinjectedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'profitReinjected',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      profitReinjectedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'profitReinjected',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      profitReinjectedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'profitReinjected',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      realizedProfitEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'realizedProfit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      realizedProfitGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'realizedProfit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      realizedProfitLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'realizedProfit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      realizedProfitBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'realizedProfit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serverId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serverId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverId',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalBusinessExpensesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalBusinessExpenses',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalBusinessExpensesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalBusinessExpenses',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalBusinessExpensesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalBusinessExpenses',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalBusinessExpensesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalBusinessExpenses',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalPersonalPayoutsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPersonalPayouts',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalPersonalPayoutsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPersonalPayouts',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalPersonalPayoutsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPersonalPayouts',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalPersonalPayoutsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPersonalPayouts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalSalesRevenueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSalesRevenue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalSalesRevenueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSalesRevenue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalSalesRevenueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSalesRevenue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalSalesRevenueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSalesRevenue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalStockPurchasedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalStockPurchased',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalStockPurchasedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalStockPurchased',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalStockPurchasedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalStockPurchased',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      totalStockPurchasedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalStockPurchased',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      userIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      userIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      userIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      userIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      weekEndDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      weekEndDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      weekEndDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      weekEndDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekEndDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      weekStartDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      weekStartDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      weekStartDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterFilterCondition>
      weekStartDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekStartDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WeeklyCheckupQueryObject
    on QueryBuilder<WeeklyCheckup, WeeklyCheckup, QFilterCondition> {}

extension WeeklyCheckupQueryLinks
    on QueryBuilder<WeeklyCheckup, WeeklyCheckup, QFilterCondition> {}

extension WeeklyCheckupQuerySortBy
    on QueryBuilder<WeeklyCheckup, WeeklyCheckup, QSortBy> {
  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByCapitalRecovered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capitalRecovered', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByCapitalRecoveredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capitalRecovered', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByCapitalRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capitalRemaining', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByCapitalRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capitalRemaining', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByCheckupDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkupDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByCheckupDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkupDate', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDirty', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDirty', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByOperationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationId', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByOperationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationId', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByProfitPayoutTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitPayoutTaken', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByProfitPayoutTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitPayoutTaken', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByProfitReinjected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitReinjected', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByProfitReinjectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitReinjected', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByRealizedProfit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedProfit', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByRealizedProfitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedProfit', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByTotalBusinessExpenses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBusinessExpenses', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByTotalBusinessExpensesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBusinessExpenses', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByTotalPersonalPayouts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPersonalPayouts', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByTotalPersonalPayoutsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPersonalPayouts', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByTotalSalesRevenue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSalesRevenue', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByTotalSalesRevenueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSalesRevenue', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByTotalStockPurchased() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStockPurchased', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByTotalStockPurchasedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStockPurchased', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> sortByWeekEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEndDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByWeekEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEndDate', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      sortByWeekStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.desc);
    });
  }
}

extension WeeklyCheckupQuerySortThenBy
    on QueryBuilder<WeeklyCheckup, WeeklyCheckup, QSortThenBy> {
  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByCapitalRecovered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capitalRecovered', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByCapitalRecoveredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capitalRecovered', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByCapitalRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capitalRemaining', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByCapitalRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capitalRemaining', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByCheckupDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkupDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByCheckupDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkupDate', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDirty', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDirty', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByOperationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationId', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByOperationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationId', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByProfitPayoutTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitPayoutTaken', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByProfitPayoutTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitPayoutTaken', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByProfitReinjected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitReinjected', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByProfitReinjectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profitReinjected', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByRealizedProfit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedProfit', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByRealizedProfitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realizedProfit', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByTotalBusinessExpenses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBusinessExpenses', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByTotalBusinessExpensesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBusinessExpenses', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByTotalPersonalPayouts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPersonalPayouts', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByTotalPersonalPayoutsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPersonalPayouts', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByTotalSalesRevenue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSalesRevenue', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByTotalSalesRevenueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSalesRevenue', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByTotalStockPurchased() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStockPurchased', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByTotalStockPurchasedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStockPurchased', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy> thenByWeekEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEndDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByWeekEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekEndDate', Sort.desc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QAfterSortBy>
      thenByWeekStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.desc);
    });
  }
}

extension WeeklyCheckupQueryWhereDistinct
    on QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct> {
  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByCapitalRecovered() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capitalRecovered');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByCapitalRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capitalRemaining');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByCheckupDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkupDate');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct> distinctByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDirty');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct> distinctByOperationId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByProfitPayoutTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profitPayoutTaken');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByProfitReinjected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profitReinjected');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByRealizedProfit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'realizedProfit');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct> distinctByServerId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByTotalBusinessExpenses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBusinessExpenses');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByTotalPersonalPayouts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPersonalPayouts');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByTotalSalesRevenue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSalesRevenue');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByTotalStockPurchased() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalStockPurchased');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct> distinctByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByWeekEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekEndDate');
    });
  }

  QueryBuilder<WeeklyCheckup, WeeklyCheckup, QDistinct>
      distinctByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekStartDate');
    });
  }
}

extension WeeklyCheckupQueryProperty
    on QueryBuilder<WeeklyCheckup, WeeklyCheckup, QQueryProperty> {
  QueryBuilder<WeeklyCheckup, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WeeklyCheckup, double, QQueryOperations>
      capitalRecoveredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capitalRecovered');
    });
  }

  QueryBuilder<WeeklyCheckup, double, QQueryOperations>
      capitalRemainingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capitalRemaining');
    });
  }

  QueryBuilder<WeeklyCheckup, DateTime, QQueryOperations>
      checkupDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkupDate');
    });
  }

  QueryBuilder<WeeklyCheckup, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WeeklyCheckup, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<WeeklyCheckup, bool, QQueryOperations> isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDirty');
    });
  }

  QueryBuilder<WeeklyCheckup, DateTime?, QQueryOperations>
      lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<WeeklyCheckup, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<WeeklyCheckup, String?, QQueryOperations> operationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationId');
    });
  }

  QueryBuilder<WeeklyCheckup, double, QQueryOperations>
      profitPayoutTakenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profitPayoutTaken');
    });
  }

  QueryBuilder<WeeklyCheckup, double, QQueryOperations>
      profitReinjectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profitReinjected');
    });
  }

  QueryBuilder<WeeklyCheckup, double, QQueryOperations>
      realizedProfitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'realizedProfit');
    });
  }

  QueryBuilder<WeeklyCheckup, String?, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<WeeklyCheckup, double, QQueryOperations>
      totalBusinessExpensesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBusinessExpenses');
    });
  }

  QueryBuilder<WeeklyCheckup, double, QQueryOperations>
      totalPersonalPayoutsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPersonalPayouts');
    });
  }

  QueryBuilder<WeeklyCheckup, double, QQueryOperations>
      totalSalesRevenueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSalesRevenue');
    });
  }

  QueryBuilder<WeeklyCheckup, double, QQueryOperations>
      totalStockPurchasedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalStockPurchased');
    });
  }

  QueryBuilder<WeeklyCheckup, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<WeeklyCheckup, int?, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<WeeklyCheckup, DateTime, QQueryOperations>
      weekEndDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekEndDate');
    });
  }

  QueryBuilder<WeeklyCheckup, DateTime, QQueryOperations>
      weekStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekStartDate');
    });
  }
}
