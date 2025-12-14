import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqlitehelper/database/queryresult.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class QueryResultModel extends ChangeNotifier {
  QueryResult result;

  QueryResultModel({required this.result});

  void setResult(QueryResult result) {
    this.result = result;
    notifyListeners();
  }

  List<QueryColumn> get columns => result.columns;
}

class _ThemeData {
  final Color dividerColor;
  final Color headerColor;
  final Color selectedCellBack;
  final Color cellBack;

  _ThemeData(ThemeData src)
    : dividerColor = src.colorScheme.secondaryContainer,
      cellBack = src.colorScheme.surface,
      selectedCellBack = src.colorScheme.secondaryContainer,
      headerColor = src.colorScheme.primaryContainer.withAlpha(180);
}

class QueryResultView extends StatefulWidget {
  const QueryResultView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _QueryResultState();
  }
}

class _CellLocation {
  final int column;
  final int row;

  _CellLocation({required this.column, required this.row});

  bool equals(TableVicinity vicinity) {
    return column == vicinity.column && row == vicinity.row;
  }
}

class _QueryResultState extends State<QueryResultView> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  _CellLocation? selectedCell;

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  TableSpan _columnSpan(int index, _ThemeData theme) {
    return TableSpan(
      extent: FixedTableSpanExtent(220),
      foregroundDecoration: index == selectedCell?.column
          ? TableSpanDecoration(
              border: TableSpanBorder(
                leading: BorderSide(width: 1, color: theme.dividerColor),
                trailing: BorderSide(width: 1, color: theme.dividerColor),
              ),
            )
          : null,
    );
  }

  TableSpan _rowSpan(int index, _ThemeData theme) {
    return TableSpan(
      extent: const FixedTableSpanExtent(30),
      foregroundDecoration: index == selectedCell?.row
          ? TableSpanDecoration(
              border: TableSpanBorder(
                leading: BorderSide(width: 1, color: theme.dividerColor),
                trailing: BorderSide(width: 1, color: theme.dividerColor),
              ),
            )
          : null,
      // backgroundDecoration: index % 2 != 0
      //     ? null
      //     : SpanDecoration(color: Colors.amber.shade100),
    );
  }

  TableViewCell _cell(
    BuildContext context,
    TableVicinity vicinity,
    QueryResultModel model,
    _ThemeData theme,
  ) {
    if (vicinity.row == 0) {
      return TableViewCell(
        child: Container(
          color: theme.headerColor,
          child: Center(child: Text(model.columns[vicinity.column].name)),
        ),
      );
    }

    return TableViewCell(
      child: GestureDetector(
        onTap: () => setState(() {
          selectedCell = _CellLocation(
            column: vicinity.column,
            row: vicinity.row,
          );
        }),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 4),
          color: selectedCell?.equals(vicinity) ?? false
              ? theme.selectedCellBack
              : theme.cellBack,
          child: Text(
            model.result.cellValue(vicinity.row, vicinity.column),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<QueryResultModel>();

    final theme = _ThemeData(Theme.of(context));

    return Padding(
      padding: EdgeInsetsGeometry.all(8),
      child: Scrollbar(
        controller: _verticalController,
        child: Scrollbar(
          controller: _horizontalController,
          child: TableView.builder(
            verticalDetails: ScrollableDetails(
              direction: AxisDirection.down,
              controller: _verticalController,
              physics: const AlwaysScrollableScrollPhysics(),
            ),
            horizontalDetails: ScrollableDetails(
              direction: AxisDirection.right,
              controller: _horizontalController,
              physics: const AlwaysScrollableScrollPhysics(),
            ),
            rowCount: model.result.length,
            pinnedRowCount: 1,
            columnCount: model.columns.length,
            columnBuilder: (index) => _columnSpan(index, theme),
            rowBuilder: (index) => _rowSpan(index, theme),
            cellBuilder: (context, vicinity) =>
                _cell(context, vicinity, model, theme),
          ),
        ),
      ),
    );
  }
}
