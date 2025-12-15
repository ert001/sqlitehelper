import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:sqlitehelper/database/database.dart';

/// The column of the reulst
class QueryColumn {
  /// The colummn name
  final String name;

  /// The index of the column in the Row
  final int index;

  /// Data type of the column
  final ColumnType type;

  /// The database table for this column
  final DBTable? table;

  const QueryColumn({
    required this.name,
    required this.index,
    required this.type,
    this.table,
  });

  // String value(Row row) {
  //   final result = row[index];
  //   return result is String ? result : "";
  // }
}

class QueryResult {
  final sqlite.ResultSet result;

  final columns = <QueryColumn>[];

  QueryResult({required this.result, required Database database}) {
    int index = 0;
    final tableNames = result.tableNames;
    for (final name in result.columnNames) {
      final tn = tableNames == null ? null : tableNames[index];
      final table = database.getTable(tn);
      final type = table?.getColumn(name)?.type ?? ColumnType.none;

      columns.add(
        QueryColumn(name: name, index: index++, type: type, table: table),
      );
    }
  }

  dynamic cellValue(int row, int column) {
    if (row < 0 ||
        row >= result.length ||
        column < 0 ||
        column >= columns.length) {
      return null;
    }

    return result[row][column];
  }

  int get length => result.length;
}
