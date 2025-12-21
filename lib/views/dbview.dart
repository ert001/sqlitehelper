import 'package:flutter/material.dart';
import 'package:sqlite_ffi/sqlite_ffi.dart' as sq;
import 'package:sqlitehelper/database/database.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class DbNode {}

class TableNode extends DbNode {
  final DBTable table;

  TableNode({required this.table});
}

class ColumnNode extends DbNode {
  final DBColumn column;

  ColumnNode({required this.column});
}

class IndexNode extends DbNode {}

/// View database structure
class DatabaseViewModel extends ChangeNotifier {
  final Database database;

  DatabaseViewModel({required this.database});

  List<TreeViewNode<DbNode>> get dbTree {
    final ret = <TreeViewNode<DbNode>>[];

    for (final table in database.tables) {
      final tnode = TableNode(table: table);

      final columns = <TreeViewNode<DbNode>>[];

      for (final column in table.columns) {
        final cnode = TreeViewNode<DbNode>(ColumnNode(column: column));
        columns.add(cnode);
      }

      final node = TreeViewNode<DbNode>(tnode, children: columns);
      ret.add(node);
    }
    return ret;
  }
}

class DatabaseView extends StatefulWidget {
  const DatabaseView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DatabaseViewState();
  }
}

class _DatabaseViewState extends State<DatabaseView> {
  @override
  Widget build(BuildContext context) {
    // final TreeView tv = TreeView(tree: tree)
    return Text("test");
  }
}
