import 'package:sqlite3/sqlite3.dart';

/// The column of the reulst
class QueryColumn {
  /// The colummn name
  final String name;

  /// The index of the column in the Row
  final int index;

  const QueryColumn({required this.name, required this.index});

  String value(Row row) {
    final result = row[index];
    return result is String ? result : "";
  }
}

class QueryResult {
  final ResultSet result;

  final columns = <QueryColumn>[];

  QueryResult({required this.result}) {
    int index = 0;
    for (final name in result.columnNames) {
      columns.add(QueryColumn(name: name, index: index++));
    }
  }

  String cellValue(int row, int column) {
    if (row < 0 ||
        row >= result.length ||
        column < 0 ||
        column >= columns.length) {
      return "";
    }

    return columns[column].value(result[row]);
  }

  int get length => result.length;
}
