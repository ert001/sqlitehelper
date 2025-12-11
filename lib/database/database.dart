import 'dart:io';
import 'dart:async';
import 'package:sqlite3/sqlite3.dart' as sq;

class Table {
  final String name;

  const Table({required this.name});
}

///
/// Implement SQLite database model
class Database {
  final sq.Database db;
  final tables = <Table>[];

  Database._({required this.db});

  static Map<String, Database> databases = {};

  ///
  ///Open the database and put it into databases map.
  ///
  static Database open(String dbName) {
    var db = databases[dbName];
    if (db == null) {
      final dbint = sq.sqlite3.open(dbName);
      db = Database._(db: dbint);
      databases[dbName] = db;
    }
    return db;
  }
}
