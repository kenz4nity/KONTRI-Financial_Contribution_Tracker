// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contri_folder.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetContriFolderCollection on Isar {
  IsarCollection<ContriFolder> get contriFolders => this.collection();
}

const ContriFolderSchema = CollectionSchema(
  name: r'ContriFolder',
  id: -2033848803915041083,
  properties: {
    r'budget': PropertySchema(id: 0, name: r'budget', type: IsarType.double),
    r'deadline': PropertySchema(
      id: 1,
      name: r'deadline',
      type: IsarType.dateTime,
    ),
    r'startDate': PropertySchema(
      id: 2,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(id: 3, name: r'title', type: IsarType.string),
  },

  estimateSize: _contriFolderEstimateSize,
  serialize: _contriFolderSerialize,
  deserialize: _contriFolderDeserialize,
  deserializeProp: _contriFolderDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _contriFolderGetId,
  getLinks: _contriFolderGetLinks,
  attach: _contriFolderAttach,
  version: '3.3.2',
);

int _contriFolderEstimateSize(
  ContriFolder object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _contriFolderSerialize(
  ContriFolder object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.budget);
  writer.writeDateTime(offsets[1], object.deadline);
  writer.writeDateTime(offsets[2], object.startDate);
  writer.writeString(offsets[3], object.title);
}

ContriFolder _contriFolderDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ContriFolder();
  object.budget = reader.readDouble(offsets[0]);
  object.deadline = reader.readDateTime(offsets[1]);
  object.id = id;
  object.startDate = reader.readDateTimeOrNull(offsets[2]);
  object.title = reader.readString(offsets[3]);
  return object;
}

P _contriFolderDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _contriFolderGetId(ContriFolder object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _contriFolderGetLinks(ContriFolder object) {
  return [];
}

void _contriFolderAttach(
  IsarCollection<dynamic> col,
  Id id,
  ContriFolder object,
) {
  object.id = id;
}

extension ContriFolderQueryWhereSort
    on QueryBuilder<ContriFolder, ContriFolder, QWhere> {
  QueryBuilder<ContriFolder, ContriFolder, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ContriFolderQueryWhere
    on QueryBuilder<ContriFolder, ContriFolder, QWhereClause> {
  QueryBuilder<ContriFolder, ContriFolder, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ContriFolder, ContriFolder, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterWhereClause> idBetween(
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
}

extension ContriFolderQueryFilter
    on QueryBuilder<ContriFolder, ContriFolder, QFilterCondition> {
  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> budgetEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'budget',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  budgetGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'budget',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  budgetLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'budget',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> budgetBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'budget',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  deadlineEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deadline', value: value),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  deadlineGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deadline',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  deadlineLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deadline',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  deadlineBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deadline',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'startDate'),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'startDate'),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  startDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startDate', value: value),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  startDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  startDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  startDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension ContriFolderQueryObject
    on QueryBuilder<ContriFolder, ContriFolder, QFilterCondition> {}

extension ContriFolderQueryLinks
    on QueryBuilder<ContriFolder, ContriFolder, QFilterCondition> {}

extension ContriFolderQuerySortBy
    on QueryBuilder<ContriFolder, ContriFolder, QSortBy> {
  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> sortByBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.asc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> sortByBudgetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.desc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> sortByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.asc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> sortByDeadlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.desc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension ContriFolderQuerySortThenBy
    on QueryBuilder<ContriFolder, ContriFolder, QSortThenBy> {
  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> thenByBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.asc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> thenByBudgetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'budget', Sort.desc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> thenByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.asc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> thenByDeadlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.desc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension ContriFolderQueryWhereDistinct
    on QueryBuilder<ContriFolder, ContriFolder, QDistinct> {
  QueryBuilder<ContriFolder, ContriFolder, QDistinct> distinctByBudget() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'budget');
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QDistinct> distinctByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deadline');
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<ContriFolder, ContriFolder, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension ContriFolderQueryProperty
    on QueryBuilder<ContriFolder, ContriFolder, QQueryProperty> {
  QueryBuilder<ContriFolder, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ContriFolder, double, QQueryOperations> budgetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'budget');
    });
  }

  QueryBuilder<ContriFolder, DateTime, QQueryOperations> deadlineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deadline');
    });
  }

  QueryBuilder<ContriFolder, DateTime?, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<ContriFolder, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
