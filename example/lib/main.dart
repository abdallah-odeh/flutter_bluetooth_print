import 'package:blue_print_pos_example/bluetooth.dart';
import 'package:blue_print_pos_example/wifi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late final PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter thermal printing')),
      body: const DefaultTabController(
        length: 2,
        child: TabBarView(children: [
          BluetoothPrinting(),
          WifiPrinting(),
        ]),
      ),
    );
  }
}
