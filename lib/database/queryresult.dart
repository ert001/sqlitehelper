import 'package:sqlite_ffi/sqlite_ffi.dart';
import 'package:sqlitehelper/database/database.dart';

class QueryResult {
  final Statement _statment;
  final _result = <RowResult>[];

  QueryResult({required Statement statment, required Database database})
    : _statment = statment {
    for (final r in statment) {
      _result.add(r);
    }
  }

  dynamic cellValue(int row, int column) {
    if (row < 0 || row >= _result.length) {
      return null;
    }

    return _result[row][column];
  }

  int get length => _result.length;

  bool get readOnly => true;

  List<Column> get columns => _statment.columns;
}

/// Select rowid and all columns
/// Hide rowid column
class TableDataResult extends QueryResult {
  final DBTable table;

  TableDataResult({required this.table, required super.database})
    : super(statment: database.query("SELECT ROWID, * FROM [${table.name}]")!);

  @override
  bool get readOnly => false;

  @override
  List<Column> get columns => _statment.columns.skip(1).toList();

  @override
  cellValue(int row, int column) {
    return super.cellValue(row, column + 1);
  }
}
