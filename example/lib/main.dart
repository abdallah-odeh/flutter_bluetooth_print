import 'dart:convert';
import 'dart:io';

import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/models.dart';
import 'package:blue_print_pos/receipt/receipt.dart';
import 'package:blue_print_pos_example/receipt_info.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BluePrintPos _bluePrintPos = BluePrintPos.instance;
  List<BlueDevice> _blueDevices = <BlueDevice>[];
  BlueDevice? _selectedDevice;
  bool _isLoading = false;
  int _loadingAtIndex = -1;

  Image? image;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Blue Print Pos'),
        ),
        body: SafeArea(
          child: _isLoading && _blueDevices.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              : _blueDevices.isNotEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: List<Widget>.generate(_blueDevices.length,
                                (int index) {
                              return Row(
                                children: <Widget>[
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _blueDevices[index].address ==
                                              (_selectedDevice?.address ?? '')
                                          ? _onDisconnectDevice
                                          : () => _onSelectDevice(index),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _blueDevices[index].name,
                                              style: TextStyle(
                                                color:
                                                    _selectedDevice?.address ==
                                                            _blueDevices[index]
                                                                .address
                                                        ? Colors.blue
                                                        : Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              _blueDevices[index].address,
                                              style: TextStyle(
                                                color:
                                                    _selectedDevice?.address ==
                                                            _blueDevices[index]
                                                                .address
                                                        ? Colors.blueGrey
                                                        : Colors.grey,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_loadingAtIndex == index && _isLoading)
                                    Container(
                                      height: 24.0,
                                      width: 24.0,
                                      margin: const EdgeInsets.only(right: 8.0),
                                      child: const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.blue,
                                        ),
                                      ),
                                    ),
                                  if (!_isLoading &&
                                      _blueDevices[index].address ==
                                          (_selectedDevice?.address ?? ''))
                                    TextButton(
                                      onPressed: _onPrintReceipt,
                                      child: Container(
                                        color: _selectedDevice == null
                                            ? Colors.grey
                                            : Colors.blue,
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Text(
                                          'Test Print',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.pressed)) {
                                              return Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.5);
                                            }
                                            return Theme.of(context)
                                                .primaryColor;
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    )
                  : image ??
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Scan bluetooth device',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.blue),
                            ),
                            Text(
                              'Press button scan',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isLoading ? null : _onScanPressed,
          // onPressed: _isLoading ? null : _onPrintReceipt,
          child: const Icon(Icons.search),
          backgroundColor: _isLoading ? Colors.grey : Colors.blue,
        ),
      ),
    );
  }

  Future<void> _onScanPressed() async {
    setState(() => _isLoading = true);
    _bluePrintPos.scan().then((List<BlueDevice> devices) {
      print('FOUND DEVICES: ${devices.length}');
      if (devices.isNotEmpty) {
        setState(() {
          _blueDevices = devices;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  void _onDisconnectDevice() {
    _bluePrintPos.disconnect().then((ConnectionStatus status) {
      if (status == ConnectionStatus.disconnect) {
        setState(() {
          _selectedDevice = null;
        });
      }
    });
  }

  void _onSelectDevice(int index) {
    setState(() {
      _isLoading = true;
      _loadingAtIndex = index;
    });
    final BlueDevice blueDevice = _blueDevices[index];
    _bluePrintPos.connect(blueDevice).then((ConnectionStatus status) {
      if (status == ConnectionStatus.connected) {
        setState(() => _selectedDevice = blueDevice);
      } else if (status == ConnectionStatus.timeout) {
        _onDisconnectDevice();
      } else {
        print('$runtimeType - something wrong');
      }
      setState(() => _isLoading = false);
    });
  }

  Future<String> imageProviderToBase64(final ImageProvider provider) async {
    switch (provider.runtimeType) {
      case AssetImage:
        final ByteData bytes =
            await rootBundle.load((provider as AssetImage).assetName);
        return base64.encode(Uint8List.view(bytes.buffer));
      case FileImage:
        final File imageFile = (provider as FileImage).file;
        final List<int> imageBytes = imageFile.readAsBytesSync();
        return base64Encode(imageBytes);
      case NetworkImage:
        throw Exception(
            'You can\'t use addImage to your receipt with network images, instead use addNetworkImage');
    }
    return '';
  }

  Future<void> _onPrintReceipt() async {
    final ReceiptInfo info = ReceiptInfo(
      merchantName: 'الشركة الأولى للتوزيع',
      merchantAddress: 'عمان - ابو نصير',
      merchantPhone: '0776633122',
      receiptType: 'مبيعات',
      receiptTypeFooter: 'نسخة العميل',
      printDateTime: DateTime.now(),
      billDateTime: DateTime.now(),
      taxNo: '178141097',
      billNo: '31001946',
      customerName: 'عميل جديد / Center',
      paymentType: 'مبيعات نقدي',
      representativeName: 'SSC NEW',
      representativeNumber: '0775233116',
      items: [
        ReceiptItem(
          description: 'Item 1',
          quantity: 3,
          price: 2.25,
          discount: 0,
          tax: 0,
        ),
        ReceiptItem(
          description: 'Item 2',
          quantity: 5,
          price: 2.25,
          discount: 0,
          tax: 0,
        ),
        ReceiptItem(
          description: 'Item 3',
          quantity: 5,
          price: 2.25,
          discount: 0,
          tax: 0,
        ),
        ReceiptItem(
          description: 'Item 4',
          quantity: 5,
          price: 2.25,
          discount: 0,
          tax: 0,
        ),
      ],
    );

    /// Example for Print Text
    final ReceiptSectionText receiptText = ReceiptSectionText();

    receiptText.addSpacer();
    receiptText.addText(
      info.merchantName,
      size: ReceiptTextSizeType.medium,
      style: ReceiptTextStyleType.bold,
    );
    receiptText.addText(
      info.merchantAddress,
      size: ReceiptTextSizeType.small,
    );
    receiptText.addText(
      info.merchantPhone,
      size: ReceiptTextSizeType.small,
    );
    receiptText.addSpacer();
    receiptText.addText(info.receiptType);
    if (info.receiptTypeFooter?.isNotEmpty ?? false) {
      receiptText.addText(
        info.receiptTypeFooter!,
        size: ReceiptTextSizeType.small,
      );
    }
    receiptText.addText(
      DateFormat('yyyy-MM-dd HH:mm').format(info.printDateTime),
      size: ReceiptTextSizeType.small,
      alignment: ReceiptAlignment.left,
    );

    receiptText.addRow(
        [RowItem(text: info.taxNo, flex: 2), RowItem(text: 'الرقم الضريبي')]);
    receiptText.addRow([
      RowItem(text: info.billNo, flex: 2),
      RowItem(text: 'رقم الفاتورة'),
    ]);
    receiptText.addRow([
      RowItem(
          text: DateFormat('yyyy-MM-dd').format(info.billDateTime), flex: 2),
      RowItem(text: 'تاريخ الفاتورة'),
    ]);
    receiptText.addRow([
      RowItem(text: info.customerName, flex: 2),
      RowItem(text: 'اسم العميل'),
    ]);
    receiptText.addRow([
      RowItem(text: info.paymentType, flex: 2),
      RowItem(text: 'طريقة الدفع'),
    ]);
    receiptText.addRow([
      RowItem(text: info.representativeName, flex: 2),
      RowItem(text: 'اسم المندوب'),
    ]);
    receiptText.addRow([
      RowItem(text: info.representativeNumber, flex: 2),
      RowItem(text: 'رقم هاتف المندوب'),
    ]);
    receiptText.addSpacer(count: 2);
    receiptText.addText('تفاصيل الأصناف', size: ReceiptTextSizeType.small);
    receiptText.addTable(headers: <String>[
      'الإجمالي',
      'الضريبة',
      'الخصم',
      'السعر',
      'الكمية',
      'الصنف'
    ], rows: <List<String>>[
      for (final item in info.items)
        <String>[
          item.total.toStringAsFixed(3),
          item.tax.toStringAsFixed(3),
          item.discount.toStringAsFixed(3),
          item.price.toStringAsFixed(3),
          item.quantity.toStringAsFixed(3),
          item.description,
        ],
      for (final item in info.items)
        <String>[
          item.total.toStringAsFixed(3),
          item.tax.toStringAsFixed(3),
          item.discount.toStringAsFixed(3),
          item.price.toStringAsFixed(3),
          item.quantity.toStringAsFixed(3),
          item.description,
        ],
    ]);
    //BYTES LENGTH: 70945

    receiptText.addSpacer();

    // await _bluePrintPos.printReceiptText(receiptText,
    //     feedCount: 1, paperSize: PaperSize.mm80);
    // return;

    receiptText.addRow([
      RowItem(text: info.items.length.toString(), flex: 2),
      RowItem(text: 'عدد الأصناف'),
    ]);
    receiptText.addRow([
      RowItem(
          text: info.items
              .map((e) => e.quantity)
              .reduce((a, b) => a + b)
              .toString(),
          flex: 2),
      RowItem(text: 'عدد الكميات'),
    ]);
    receiptText.addRow([
      RowItem(
          text: info.items
              .map((e) => e.discount)
              .reduce((a, b) => a + b)
              .toString(),
          flex: 2),
      RowItem(text: 'قيمة الخصم'),
    ]);
    receiptText.addRow([
      RowItem(
          text: info.items
              .map((e) => e.price * e.quantity)
              .reduce((a, b) => a + b)
              .toString(),
          flex: 2),
      RowItem(text: 'المجموع'),
    ]);
    receiptText.addRow([
      RowItem(
          text: info.items.map((e) => e.tax).reduce((a, b) => a + b).toString(),
          flex: 2),
      RowItem(text: 'الضريبة'),
    ]);
    receiptText.addRow([
      RowItem(
          text:
              info.items.map((e) => e.total).reduce((a, b) => a + b).toString(),
          flex: 2),
      RowItem(text: 'الإجمالي'),
    ]);

    final base64a = await receiptText
        .imageProviderToBase64(const AssetImage('assets/logo.jpg'));
    // final base64 = await receiptText.imageProviderToBase64(FileImage(File(
    //     '/data/user/0/com.ayeee.blue_print_pos_example/files/rabbit_black.jpg')));

    receiptText.addImage(base64a);
    // receiptText.addImage(base64);
    receiptText
        .addNetworkImage('https://tinypng.com/images/social/developer-api.jpg');

    // print('CONTENT: ${receiptText.content}');

    final content = receiptText.content;
    final data = await BluePrintPos.contentToImage(content: content);
    setState(() => image = Image.memory(data));

    print('ASSET BASE64 -> $base64a');
    // print('FILE BASE64 -> $base64b');

    // return;

    for (var i = 0; i < 100; i++)
      await _bluePrintPos.printBarcode(
        Barcode.code128('2100004'.split('').map((e) => int.parse(e)).toList()),
        feedCount: 0,
      );

    return;
    //
    // // /// Example for print QR
    // // await _bluePrintPos.printQR('www.google.com', size: 250);
    //
    // // /// Text after QR
    // // final ReceiptSectionText receiptSecondText = ReceiptSectionText();
    // // receiptSecondText.addText('Powered by ayeee',
    // //     size: ReceiptTextSizeType.small);
    // // receiptSecondText.addSpacer();
    // // await _bluePrintPos.printReceiptText(receiptSecondText, feedCount: 1);
  }
}
