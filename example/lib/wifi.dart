import 'dart:typed_data';

import 'package:blue_print_pos_example/receipt_generator.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart'
    as esc_pos_utils_plus;
import 'package:flutter/material.dart';

class WifiPrinting extends StatefulWidget {
  const WifiPrinting({Key? key}) : super(key: key);

  @override
  State<WifiPrinting> createState() => _WifiPrintingState();
}

class _WifiPrintingState extends State<WifiPrinting> with ReceiptGenerator {
  final TextEditingController ipController =
      TextEditingController(text: '192.168.1.26');
  final TextEditingController portController =
      TextEditingController(text: '9100');
  bool _isLoading = false;
  bool _isGenerating = false;
  Image? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth printing')),
      body: SafeArea(child: Builder(
        builder: (BuildContext context) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }
          if (_isGenerating) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                if (image != null) image!,
                TextField(
                  controller: ipController,
                  decoration: const InputDecoration(
                    labelText: 'IP',
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: portController,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: onConnect,
                  child: const Text('Connect'),
                ),
              ],
            ),
          );
        },
      )),
    );
  }

  Future<List<int>> testTicket() async {
    final profile = await esc_pos_utils_plus.CapabilityProfile.load();
    final generator = esc_pos_utils_plus.Generator(
        esc_pos_utils_plus.PaperSize.mm80, profile);
    // return [];
    List<int> bytes = [];

    bytes += await generateReceipt();

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  Future<void> onConnect() async {
    final Uint8List receipt = await generateReceipt();
    final List<int> ticket = await testTicket();

    setState(() => _isLoading = true);

    final String ip = ipController.text;
    final int port = int.tryParse(portController.text) ?? 9100;

    final service = FlutterThermalPrinterNetwork(
      ip,
      port: port,
    );

    await service.connect();
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [...receipt];
    if (context.mounted) {
      // bytes = await FlutterThermalPrinter.instance
      //     .screenShotWidget(
      //   context,
      //   generator: generator,
      //   // customWidth: 575,
      //   customWidth: PaperSize.mm80.width,
      //   // widget: receiptWidget("Network"),
      //   widget: const ReceiptUI(),
      // );
      bytes += generator.feed(1);
      bytes += generator.cut();
      await service.printTicket(bytes);
    }
    await service.disconnect();

    // final NetworkPrinter printer = NetworkPrinter(paper, profile);
    // final PosPrintResult connect = await printer.connect(ip, port: port);
    //
    // // final PrinterNetworkManager printer = PrinterNetworkManager(ip, port: port);
    // // final PrinterNetworkManager printer = PrinterNetworkManager('192.168.1.26');
    // // final PosPrintResult connect = await printer.connect();
    // print('POS CONNECT RESULT: ${connect.value} | ${connect.msg}');
    // if (connect == PosPrintResult.success) {
    //   printer.image(await getReceiptAsImage());
    //   printer.feed(2);
    //   printer.cut();
    //   // final PosPrintResult printing = await printer.(ticket);
    //
    //   printer.disconnect();
    // }

    // const PaperSize paper = PaperSize.mm80;
    // final CapabilityProfile profile = await CapabilityProfile.load();
    // final NetworkPrinter printer = NetworkPrinter(paper, profile);
    //
    // final String ip = ipController.text;
    // final int port = int.tryParse(portController.text) ?? 9100;
    //
    // final PosPrintResult res = await printer.connect(ip, port: port);
    //
    // print('connect result: ${res.value} | ${res.msg}');

    setState(() => _isLoading = false);

    // switch (connect) {
    //   case PosPrintResult.success:
    //     _onGenerateReceipt();
    //     break;
    //   case PosPrintResult.timeout:
    //   case PosPrintResult.ticketEmpty:
    //     break;
    //   case PosPrintResult.printInProgress:
    //     break;
    //   case PosPrintResult.scanInProgress:
    //     break;
    // }
  }

  Future<void> _onGenerateReceipt() async {
    setState(() => _isGenerating = true);

    final Uint8List receipt = await generateReceipt();
    setState(() {
      _isGenerating = false;
      image = Image.memory(receipt);
    });
  }
}
