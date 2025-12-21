import 'package:sqlite_ffi/sqlite_ffi.dart';

// Classes, types, functions to represents sqlite database entities.
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

ColumnType _stringToType(String? type) {
  return switch (type) {
    'TEXT' => ColumnType.text,
    'INTEGER' => ColumnType.integer,
    'REAL' => ColumnType.double,
    'BLOB' => ColumnType.blob,
    _ => ColumnType.none,
  };
}

class DBTable {
  final String name;
  final String createStmt;
  final columns = <DBColumn>[];

  DBTable._({required this.name, required this.createStmt});

  DBColumn? getColumn(String name) {
    for (final c in columns) {
      if (c.name == name) return c;
    }

    return null;
  }

  static DBTable create(Sqlite3Database db, RowResult schemaRow) {
    final table = DBTable._(
      name: schemaRow[1]!.stringValue,
      createStmt: schemaRow[3]!.stringValue,
    );

    //name,type,notnull,dflt_value,pk
    final sql = 'PRAGMA TABLE_INFO(${table.name})';
    final stmt = db.select(sql);
    if (stmt != null) {
      for (final row in stmt) {
        final nnull = row['notnull']?.value > 0;
        final pkIndex = row['pk']?.value;
        final column = DBColumn(
          name: row['name']?.stringValue ?? '',
          type: _stringToType(row['type']?.stringValue),
          notNull: nnull,
          pkIndex: pkIndex,
        );
        table.columns.add(column);
      }
    }

    return table;
  }
}

///
/// Implement SQLite database model
class Database {
  final Sqlite3Database db;
  final tables = <DBTable>[];

  Database._({required this.db}) {
    loadDBInfo();
  }

  DBTable? getTable(String? tableName) {
    for (final t in tables) {
      if (t.name == tableName) return t;
    }
    return null;
  }

  void loadDBInfo() {
    final sql = 'select [type], name, tbl_name, sql from sqlite_schema';
    final stmt = db.select(sql);
    if (stmt == null) {
      return;
    }
    for (final row in stmt) {
      switch (row[0]?.stringValue) {
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

  /// Run statment and return result
  Statement? query(String stmt) {
    return db.select(stmt);
  }

  static Map<String, Database> databases = {};

  ///
  ///Open the database and put it into databases map.
  ///
  static Database? open(String dbName) {
    var db = databases[dbName];
    if (db == null) {
      try {
        final dbint = Sqlite3Database.open(dbName, false);
        if (dbint != null) {
          db = Database._(db: dbint);
          databases[dbName] = db;
        }
      } catch (e) {
        db = null;
      }
    }
    return db;
  }
}
