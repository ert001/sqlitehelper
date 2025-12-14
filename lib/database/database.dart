import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart' as sq;

// Classes, types, functions to represents sqlite database entities.

enum ColumnType { text, integer, real, blob, none }

ColumnType stringToType(String type) {
  return switch (type) {
    'TEXT' => ColumnType.text,
    'INTEGER' => ColumnType.integer,
    'REAL' => ColumnType.real,
    'BLOB' => ColumnType.blob,
    _ => ColumnType.none,
  };
}

class DBColumn {
  final String name;
  final ColumnType type;

  final bool notNull;
  final int pkIndex;

  const DBColumn({
    required this.name,
    required this.type,
    required this.notNull,
    required this.pkIndex,
  });
}

class DBTable {
  final String name;
  final String createStmt;
  final columns = <DBColumn>[];

  DBTable._({required this.name, required this.createStmt});

  static DBTable create(sq.Database db, Row schemaRow) {
    final table = DBTable._(name: schemaRow[1], createStmt: schemaRow[3]);

    //name,type,notnull,dflt_value,pk
    final sql = 'PRAGMA TABLE_INFO(${table.name})';
    for (final row in db.select(sql)) {
      final nnull = row['notnull'] > 0;
      final pkIndex = row['pk'];
      final column = DBColumn(
        name: row['name'],
        type: stringToType(row['type']),
        notNull: nnull,
        pkIndex: pkIndex,
      );
      table.columns.add(column);
    }

    return table;
  }
}

///
/// Implement SQLite database model
class Database {
  final sq.Database db;
  final tables = <DBTable>[];

  Database._({required this.db}) {
    loadDBInfo();
  }

  void loadDBInfo() {
    final sql = 'select [type], name, tbl_name, sql from sqlite_schema';

    for (final row in db.select(sql)) {
      switch (row[0]) {
        case 'table':
          final table = DBTable.create(db, row);
          tables.add(table);
        case 'index':
          ;
        case 'view':
          ;
        case 'trigger':
          ;
      }
    }
  }

  ResultSet query(String stmt, [List<Object?> parameters = const []]) {
    return db.select(stmt, parameters);
  }

  static Map<String, Database> databases = {};

  ///
  ///Open the database and put it into databases map.
  ///
  static Database? open(String dbName) {
    var db = databases[dbName];
    if (db == null) {
      try {
        final dbint = sq.sqlite3.open(dbName);
        db = Database._(db: dbint);
        databases[dbName] = db;
      } catch (e) {
        // ok
      }
    }
    return db;
  }
}
