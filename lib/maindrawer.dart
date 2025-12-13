import 'package:flutter/material.dart';
import 'package:sqlitehelper/l10n/app_localizations.dart';

class DrawerMenu extends StatelessWidget {
  final void Function() onOpenDB;
  final void Function() onNewWindow;

  const DrawerMenu({
    super.key,
    required this.onOpenDB,
    required this.onNewWindow,
  });

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(child: Text(loc.title)),
        ListTile(title: Text(loc.openDB), onTap: () => onOpenDB()),
        ListTile(title: Text("New windows"), onTap: () => onNewWindow()),
      ],
    );
  }
}

class MainDrawer extends Drawer {
  // final void Function() onOpenDB;
  // final void Function() onNewWindow;

  MainDrawer({
    super.key,
    required void Function() onOpenDB,
    required Function() onNewWindow,
  }) : super(
         child: DrawerMenu(onOpenDB: onOpenDB, onNewWindow: onNewWindow),
       );
}
