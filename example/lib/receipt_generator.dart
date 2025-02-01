import 'dart:convert';
import 'dart:ui' as ui;

import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/receipt/receipt.dart';
import 'package:blue_print_pos_example/receipt_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:intl/intl.dart';

mixin ReceiptGenerator {
  Future<Uint8List> generateReceipt() async {
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
      items: <ReceiptItem>[
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

    receiptText.addRow(<RowItem>[
      RowItem(text: info.taxNo, flex: 2),
      RowItem(text: 'الرقم الضريبي')
    ]);
    receiptText.addRow(<RowItem>[
      RowItem(text: info.billNo, flex: 2),
      RowItem(text: 'رقم الفاتورة'),
    ]);
    receiptText.addRow(<RowItem>[
      RowItem(
          text: DateFormat('yyyy-MM-dd').format(info.billDateTime), flex: 2),
      RowItem(text: 'تاريخ الفاتورة'),
    ]);
    receiptText.addRow(<RowItem>[
      RowItem(text: info.customerName, flex: 2),
      RowItem(text: 'اسم العميل'),
    ]);
    receiptText.addRow(<RowItem>[
      RowItem(text: info.paymentType, flex: 2),
      RowItem(text: 'طريقة الدفع'),
    ]);
    receiptText.addRow(<RowItem>[
      RowItem(text: info.representativeName, flex: 2),
      RowItem(text: 'اسم المندوب'),
    ]);
    receiptText.addRow(<RowItem>[
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
      for (final ReceiptItem item in info.items)
        <String>[
          item.total.toStringAsFixed(3),
          item.tax.toStringAsFixed(3),
          item.discount.toStringAsFixed(3),
          item.price.toStringAsFixed(3),
          item.quantity.toStringAsFixed(3),
          item.description,
        ],
      for (final ReceiptItem item in info.items)
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

    receiptText.addRow(<RowItem>[
      RowItem(text: info.items.length.toString(), flex: 2),
      RowItem(text: 'عدد الأصناف'),
    ]);
    receiptText.addRow(<RowItem>[
      RowItem(
          text: info.items
              .map((ReceiptItem e) => e.quantity)
              .reduce((num a, num b) => a + b)
              .toString(),
          flex: 2),
      RowItem(text: 'عدد الكميات'),
    ]);
    receiptText.addRow(<RowItem>[
      RowItem(
          text: info.items
              .map((ReceiptItem e) => e.discount)
              .reduce((num a, num b) => a + b)
              .toString(),
          flex: 2),
      RowItem(text: 'قيمة الخصم'),
    ]);
    receiptText.addRow(<RowItem>[
      RowItem(
          text: info.items
              .map((ReceiptItem e) => e.price * e.quantity)
              .reduce((num a, num b) => a + b)
              .toString(),
          flex: 2),
      RowItem(text: 'المجموع'),
    ]);
    receiptText.addRow(<RowItem>[
      RowItem(
          text: info.items
              .map((ReceiptItem e) => e.tax)
              .reduce((num a, num b) => a + b)
              .toString(),
          flex: 2),
      RowItem(text: 'الضريبة'),
    ]);
    receiptText.addRow(<RowItem>[
      RowItem(
          text: info.items
              .map((ReceiptItem e) => e.total)
              .reduce((num a, num b) => a + b)
              .toString(),
          flex: 2),
      RowItem(text: 'الإجمالي'),
    ]);
    //
    // final String base64a = await receiptText
    //     .imageProviderToBase64(const AssetImage('assets/logo.jpg'));
    // final base64 = await receiptText.imageProviderToBase64(FileImage(File(
    //     '/data/user/0/com.ayeee.blue_print_pos_example/files/rabbit_black.jpg')));

    // receiptText.addImage(base64a);
    // receiptText.addImage(base64);
    receiptText
        .addNetworkImage('https://tinypng.com/images/social/developer-api.jpg');

    // print('CONTENT: ${receiptText.content}');

    final String content = receiptText.content;
    final Uint8List data = await BluePrintPos.contentToImage(content: content);
    return data;
  }
}
