import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:master_detail_flow/master_detail_flow.dart';
import 'package:provider/provider.dart';
import 'package:sqlitehelper/database/queryresult.dart';
import 'package:sqlitehelper/views/queryresult.dart';
import 'database/database.dart';
import 'package:sqlitehelper/maindrawer.dart';
import 'mainappbar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqlite_ffi/sqlite_ffi.dart' as sq;
import 'l10n/app_localizations.dart';

void openDBFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);
    Database.open(file.path);
  } else {
    // User canceled the picker
  }
}

Future<void> createNewWindow() async {
  // Create a new window
  final controller = await WindowController.create(
    WindowConfiguration(
      hiddenAtLaunch: true,
      arguments: 'YOUR_WINDOW_ARGUMENTS_HERE',
    ),
  );

  // // Show the window (if hidden at launch)
  // await controller.show();
}

Future<void> main(List<String> args) async {
  String? dbName;

  if (args.isNotEmpty) dbName = args[0];

  WidgetsFlutterBinding.ensureInitialized();
  final windowController = await WindowController.fromCurrentEngine();
  final winArgs = windowController.arguments;

  if (winArgs.isEmpty) {
    runApp(MyApp(dbName: dbName));
  } else {
    windowController.show();
    runApp(MyApp(dbName: null));
  }
}

class MyApp extends StatelessWidget {
  final Database? database;

  MyApp({super.key, required String? dbName})
    : database = dbName == null ? null : Database.open(dbName);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const title = "SQLite DB Viewer";

    final table = database?.getTable("Org");

    return MaterialApp(
      title: title,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en'), Locale('ru')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: table == null
          ? MDPage()
          : ViewResultTest(
              database: database!,
              resultModel: QueryResultModel(
                result: TableDataResult(table: table!, database: database!),
              ),
            ),
    );
  }
}

class ViewResultTest extends StatelessWidget {
  final Database database;
  final QueryResultModel resultModel;

  const ViewResultTest({
    super.key,
    required this.database,
    required this.resultModel,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => resultModel,
      child: Scaffold(
        body: QueryResultView(
          onEditCell: (cell) {
            final value = 'test';
            final refCell = sq.Cell(
              value: value,
              column: cell.value.column,
              type: cell.value.type,
            );

            final newCell = Cell(location: cell.location, value: refCell);
            resultModel.changeCell(newCell);
          },
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailsPageScaffold(body: const Text("Test"));
  }
}

class MDPage extends StatelessWidget {
  const MDPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MDScaffold(
      title: const Text('Simple flow'),
      items: [
        DrawerHeader(child: Center(child: Text('A flow'))),

        ListTile(title: Text("Open DB"), onTap: () => openDBFile()),
        ListTile(title: Text("New windows"), onTap: () => createNewWindow()),

        MDItem(
          title: const Text('Master item 1'),
          pageBuilder: (_) => const HomePage(),
          panelPadding: const EdgeInsets.all(0),
        ),
        MDItem(
          title: const Text('Master item 2'),
          pageBuilder: (_) => const HomePage(),
        ),
        // This padding aligns the divider with the edges of the tiles
        const MDPadding(child: Divider()),
        MDItem(
          title: const Text('Master item 3'),
          pageBuilder: (_) => const HomePage(),
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: MainAppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(loc.title),
      ),
      drawer: MainDrawer(
        onOpenDB: () => openDBFile(),
        onNewWindow: () => createNewWindow(),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('Test', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
