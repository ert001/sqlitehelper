import 'package:flutter/material.dart';
import 'package:sqlitehelper/l10n/app_localizations.dart';

class DrawerMenu extends StatelessWidget {
  final void Function() onOpenDB;

  const DrawerMenu({super.key, required this.onOpenDB});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(child: Text(loc.title)),
        ListTile(title: Text(loc.openDB), onTap: () => onOpenDB()),
      ],
    );
  }
}

class MainDrawer extends Drawer {
  final void Function() onOpenDB;

  MainDrawer({super.key, required this.onOpenDB})
    : super(child: DrawerMenu(onOpenDB: onOpenDB));
}
