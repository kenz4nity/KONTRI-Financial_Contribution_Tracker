// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_record.dart';

// ***********************
// IsarCollectionGenerator
// ***********************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPaymentRecordCollection on Isar {
  IsarCollection<PaymentRecord> get paymentRecords => this.collection();
}

const PaymentRecordSchema = CollectionSchema(
  name: r'PaymentRecord',
  id: -157825587411876126,
  properties: {
    r'amount': PropertySchema(id: 0, name: r'amount', type: IsarType.double),
    r'folderId': PropertySchema(id: 1, name: r'folderId', type: IsarType.long),
    r'note': PropertySchema(id: 2, name: r'note', type: IsarType.string),
    r'paidAt': PropertySchema(id: 3, name: r'paidAt', type: IsarType.dateTime),
    r'participantId': PropertySchema(
      id: 4,
      name: r'participantId',
      type: IsarType.long,
    ),
    r'proofFileName': PropertySchema(
      id: 5,
      name: r'proofFileName',
      type: IsarType.string,
    ),
  },

  estimateSize: _paymentRecordEstimateSize,
  serialize: _paymentRecordSerialize,
  deserialize: _paymentRecordDeserialize,
  deserializeProp: _paymentRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'participantId': IndexSchema(
      id: -6135301321018090996,
      name: r'participantId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'participantId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'folderId': IndexSchema(
      id: 6340065978996931043,
      name: r'folderId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'folderId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _paymentRecordGetId,
  getLinks: _paymentRecordGetLinks,
  attach: _paymentRecordAttach,
  version: '3.3.2',
);

int _paymentRecordEstimateSize(
  PaymentRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.proofFileName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _paymentRecordSerialize(
  PaymentRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeLong(offsets[1], object.folderId);
  writer.writeString(offsets[2], object.note);
  writer.writeDateTime(offsets[3], object.paidAt);
  writer.writeLong(offsets[4], object.participantId);
  writer.writeString(offsets[5], object.proofFileName);
}

PaymentRecord _paymentRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaymentRecord();
  object.amount = reader.readDouble(offsets[0]);
  object.folderId = reader.readLong(offsets[1]);
  object.id = id;
  object.note = reader.readStringOrNull(offsets[2]);
  object.paidAt = reader.readDateTime(offsets[3]);
  object.participantId = reader.readLong(offsets[4]);
  object.proofFileName = reader.readStringOrNull(offsets[5]);
  return object;
}

P _paymentRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _paymentRecordGetId(PaymentRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _paymentRecordGetLinks(PaymentRecord object) {
  return [];
}

void _paymentRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  PaymentRecord object,
) {
  object.id = id;
}

extension PaymentRecordQueryWhereSort
    on QueryBuilder<PaymentRecord, PaymentRecord, QWhere> {
  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhere> anyParticipantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'participantId'),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhere> anyFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'folderId'),
      );
    });
  }
}

extension PaymentRecordQueryWhere
    on QueryBuilder<PaymentRecord, PaymentRecord, QWhereClause> {
  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause>
  participantIdEqualTo(int participantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'participantId',
          value: [participantId],
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause>
  participantIdNotEqualTo(int participantId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'participantId',
                lower: [],
                upper: [participantId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'participantId',
                lower: [participantId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'participantId',
                lower: [participantId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'participantId',
                lower: [],
                upper: [participantId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause>
  participantIdGreaterThan(int participantId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'participantId',
          lower: [participantId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause>
  participantIdLessThan(int participantId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'participantId',
          lower: [],
          upper: [participantId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause>
  participantIdBetween(
    int lowerParticipantId,
    int upperParticipantId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'participantId',
          lower: [lowerParticipantId],
          includeLower: includeLower,
          upper: [upperParticipantId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause> folderIdEqualTo(
    int folderId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'folderId', value: [folderId]),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause>
  folderIdNotEqualTo(int folderId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [],
                upper: [folderId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [folderId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [folderId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [],
                upper: [folderId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause>
  folderIdGreaterThan(int folderId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'folderId',
          lower: [folderId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause>
  folderIdLessThan(int folderId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'folderId',
          lower: [],
          upper: [folderId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterWhereClause> folderIdBetween(
    int lowerFolderId,
    int upperFolderId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'folderId',
          lower: [lowerFolderId],
          includeLower: includeLower,
          upper: [upperFolderId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PaymentRecordQueryFilter
    on QueryBuilder<PaymentRecord, PaymentRecord, QFilterCondition> {
  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  amountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  folderIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'folderId', value: value),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  folderIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'folderId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  folderIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'folderId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  folderIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'folderId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  noteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  noteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  paidAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paidAt', value: value),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  paidAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'paidAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  paidAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'paidAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  paidAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'paidAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  participantIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'participantId', value: value),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  participantIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'participantId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  participantIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'participantId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  participantIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'participantId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'proofFileName'),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'proofFileName'),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'proofFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'proofFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'proofFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'proofFileName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'proofFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'proofFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'proofFileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'proofFileName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'proofFileName', value: ''),
      );
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterFilterCondition>
  proofFileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'proofFileName', value: ''),
      );
    });
  }
}

extension PaymentRecordQueryObject
    on QueryBuilder<PaymentRecord, PaymentRecord, QFilterCondition> {}

extension PaymentRecordQueryLinks
    on QueryBuilder<PaymentRecord, PaymentRecord, QFilterCondition> {}

extension PaymentRecordQuerySortBy
    on QueryBuilder<PaymentRecord, PaymentRecord, QSortBy> {
  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> sortByFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy>
  sortByFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.desc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> sortByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> sortByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy>
  sortByParticipantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantId', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy>
  sortByParticipantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantId', Sort.desc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy>
  sortByProofFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofFileName', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy>
  sortByProofFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofFileName', Sort.desc);
    });
  }
}

extension PaymentRecordQuerySortThenBy
    on QueryBuilder<PaymentRecord, PaymentRecord, QSortThenBy> {
  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> thenByFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy>
  thenByFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.desc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> thenByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy> thenByPaidAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy>
  thenByParticipantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantId', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy>
  thenByParticipantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantId', Sort.desc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy>
  thenByProofFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofFileName', Sort.asc);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QAfterSortBy>
  thenByProofFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofFileName', Sort.desc);
    });
  }
}

extension PaymentRecordQueryWhereDistinct
    on QueryBuilder<PaymentRecord, PaymentRecord, QDistinct> {
  QueryBuilder<PaymentRecord, PaymentRecord, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QDistinct> distinctByFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'folderId');
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QDistinct> distinctByPaidAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidAt');
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QDistinct>
  distinctByParticipantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'participantId');
    });
  }

  QueryBuilder<PaymentRecord, PaymentRecord, QDistinct>
  distinctByProofFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'proofFileName',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension PaymentRecordQueryProperty
    on QueryBuilder<PaymentRecord, PaymentRecord, QQueryProperty> {
  QueryBuilder<PaymentRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PaymentRecord, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<PaymentRecord, int, QQueryOperations> folderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'folderId');
    });
  }

  QueryBuilder<PaymentRecord, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<PaymentRecord, DateTime, QQueryOperations> paidAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidAt');
    });
  }

  QueryBuilder<PaymentRecord, int, QQueryOperations> participantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'participantId');
    });
  }

  QueryBuilder<PaymentRecord, String?, QQueryOperations>
  proofFileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proofFileName');
    });
  }
}
