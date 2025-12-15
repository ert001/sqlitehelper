import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqlitehelper/database/queryresult.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class CellValue {
  final dynamic value;

  CellValue({required this.value});

  String? stringValue() {
    if (value == null) return value;
    if (value is String) return value;
    return value.toString();
  }
}

class CellLocation {
  final int column;
  final int row;

  CellLocation({required this.column, required this.row});

  bool equals(TableVicinity vicinity) {
    return column == vicinity.column && row == vicinity.row;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellLocation && column == other.column && row == other.row;

  @override
  int get hashCode => Object.hash(column, row);
}

class Cell {
  final CellValue value;
  final CellLocation location;

  Cell({required this.value, required this.location});
}

class _SetCellValueIntent extends Intent {
  const _SetCellValueIntent();
}

class _CopyToClipboardIntent extends Intent {
  const _CopyToClipboardIntent();
}

class QueryResultModel extends ChangeNotifier {
  QueryResult _result;

  final _changedCells = <CellLocation, CellValue>{};

  QueryResultModel({required QueryResult result}) : _result = result;

  void setResult(QueryResult result) {
    _result = result;
    _changedCells.clear();

    notifyListeners();
  }

  void changeCell(Cell newCell) {
    _changedCells[newCell.location] = newCell.value;

    notifyListeners();
  }

  CellValue value(int column, int row) {
    final loc = CellLocation(column: column, row: row);
    final chValue = _changedCells[loc];

    return chValue ?? CellValue(value: _result.cellValue(row, column));
  }

  List<QueryColumn> get columns => _result.columns;
}

class QueryResultViewTheme {
  final Color dividerColor;
  final Color headerColor;
  final Color selectedCellBack;
  final Color cellBack;
  final Color nullValue;

  QueryResultViewTheme(ThemeData src)
    : dividerColor = src.colorScheme.secondaryContainer,
      cellBack = src.colorScheme.surface,
      selectedCellBack = src.colorScheme.secondaryContainer,
      nullValue = src.colorScheme.primaryContainer.withAlpha(110),
      headerColor = src.colorScheme.primaryContainer.withAlpha(180);
}

class QueryResultView extends StatefulWidget {
  final void Function(Cell cell)? onCellClick;
  final void Function(Cell cell)? onEditCell;
  final void Function(Cell cell)? onCopyToClipboard;
  final QueryResultViewTheme? theme;

  const QueryResultView({
    super.key,
    this.onCellClick,
    this.onEditCell,
    this.onCopyToClipboard,
    this.theme,
  });

  @override
  State<StatefulWidget> createState() {
    return _QueryResultState();
  }
}

class _QueryResultState extends State<QueryResultView> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  Cell? selectedCell;

  final _shortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.f2): _SetCellValueIntent(),
    SingleActivator(
      LogicalKeyboardKey.keyC,
      meta: Platform.isMacOS,
      control: !Platform.isMacOS,
    ): _CopyToClipboardIntent(),
  };

  late final Map<Type, Action<Intent>> _actions;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _actions = <Type, Action<Intent>>{
      _SetCellValueIntent: CallbackAction(onInvoke: (intent) => _onEditCell()),
      _CopyToClipboardIntent: CallbackAction(
        onInvoke: (intent) => _copyToClipboard(),
      ),
    };
  }

  void _copyToClipboard() {
    final value = selectedCell?.value.stringValue();

    if (value != null) {
      Clipboard.setData(ClipboardData(text: value));
      widget.onCopyToClipboard?.call(selectedCell!);
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();

    super.dispose();
  }

  TableSpan _columnSpan(int index, QueryResultViewTheme theme) {
    return TableSpan(
      extent: FixedTableSpanExtent(220),
      foregroundDecoration: index == selectedCell?.location.column
          ? TableSpanDecoration(
              border: TableSpanBorder(
                leading: BorderSide(width: 1, color: theme.dividerColor),
                trailing: BorderSide(width: 1, color: theme.dividerColor),
              ),
            )
          : null,
    );
  }

  void _onCellClick(int row, int column, QueryResultModel model) {
    final cell = Cell(
      location: CellLocation(column: column, row: row),
      value: model.value(column, row),
    );
    widget.onCellClick?.call(cell);

    _focusNode.requestFocus();

    setState(() {
      selectedCell = cell;
    });
  }

  TableSpan _rowSpan(int index, QueryResultViewTheme theme) {
    return TableSpan(
      extent: const FixedTableSpanExtent(30),
      foregroundDecoration: index == selectedCell?.location.row
          ? TableSpanDecoration(
              border: TableSpanBorder(
                leading: BorderSide(width: 1, color: theme.dividerColor),
                trailing: BorderSide(width: 1, color: theme.dividerColor),
              ),
            )
          : null,
    );
  }

  TableViewCell _cell(
    BuildContext context,
    TableVicinity vicinity,
    QueryResultModel model,
    QueryResultViewTheme theme,
  ) {
    if (vicinity.row == 0) {
      return TableViewCell(
        child: Container(
          color: theme.headerColor,
          child: Center(child: Text(model.columns[vicinity.column].name)),
        ),
      );
    }

    CellValue value = model.value(vicinity.column, vicinity.row);
    final strValue = value.stringValue();
    final isNull = strValue == null;

    return TableViewCell(
      child: GestureDetector(
        onTap: () => _onCellClick(vicinity.row, vicinity.column, model),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 4),
          color: selectedCell?.location.equals(vicinity) ?? false
              ? theme.selectedCellBack
              : isNull
              ? theme.nullValue
              : theme.cellBack,
          child: isNull
              ? null
              : Text(strValue, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  void _onEditCell() {
    if (selectedCell != null) {
      widget.onEditCell?.call(
        Cell(value: selectedCell!.value, location: selectedCell!.location),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<QueryResultModel>();

    final theme = widget.theme ?? QueryResultViewTheme(Theme.of(context));

    return Padding(
      padding: EdgeInsetsGeometry.all(8),
      child: Scrollbar(
        controller: _verticalController,
        child: Scrollbar(
          controller: _horizontalController,
          child: FocusableActionDetector(
            focusNode: _focusNode,
            actions: _actions,
            shortcuts: _shortcuts,
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
              rowCount: model._result.length,
              pinnedRowCount: 1,
              columnCount: model.columns.length,
              columnBuilder: (index) => _columnSpan(index, theme),
              rowBuilder: (index) => _rowSpan(index, theme),
              cellBuilder: (context, vicinity) =>
                  _cell(context, vicinity, model, theme),
            ),
          ),
        ),
      ),
    );
  }
}
