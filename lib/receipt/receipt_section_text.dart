import 'dart:convert';
import 'dart:io';

import 'package:blue_print_pos/receipt/collection_style.dart';
import 'package:blue_print_pos/receipt/receipt_image.dart';
import 'package:blue_print_pos/receipt/receipt_row.dart';
import 'package:blue_print_pos/receipt/receipt_table_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'receipt_alignment.dart';
import 'receipt_line.dart';
import 'receipt_text.dart';
import 'receipt_text_left_right.dart';
import 'receipt_text_size_type.dart';
import 'receipt_text_style.dart';
import 'receipt_text_style_type.dart';

class ReceiptSectionText {
  ReceiptSectionText();

  String _data = '';

  /// Build a page from html, [CollectionStyle.all] is defined CSS inside html
  /// [_data] will collect all generated tag from model [ReceiptText],
  /// [ReceiptTextLeftRight] and [ReceiptLine]
  String get content {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RECEIPT</title>
</head>

${CollectionStyle.all}

<body>
  <div class="receipt">
    <div class="container">
      <!-- testing part -->
      
      $_data
      
    </div>
  </div>
</body>
</html>
    ''';
  }

  /// Handler tag of text (p or b) and put inside body html
  /// This will generate single line text left, center or right
  /// [text] value of text will print
  /// [alignment] to set alignment of text
  /// [style] define normal or bold
  /// [size] to set size of text small, medium, large or extra large
  void addText(
    String text, {
    ReceiptAlignment alignment = ReceiptAlignment.center,
    ReceiptTextStyleType style = ReceiptTextStyleType.normal,
    ReceiptTextSizeType size = ReceiptTextSizeType.medium,
  }) {
    final ReceiptText receiptText = ReceiptText(
      text,
      textStyle: ReceiptTextStyle(
        type: style,
        size: size,
      ),
      alignment: alignment,
    );
    _data += receiptText.html;
  }

  /// Handler tag of text (span or b) and put inside body html
  /// This will generate left right text with two value input from parameter
  /// [leftText] and [rightText]
  void addLeftRightText(
    String leftText,
    String rightText, {
    ReceiptTextStyleType leftStyle = ReceiptTextStyleType.normal,
    ReceiptTextStyleType rightStyle = ReceiptTextStyleType.normal,
    ReceiptTextSizeType leftSize = ReceiptTextSizeType.medium,
    ReceiptTextSizeType rightSize = ReceiptTextSizeType.medium,
  }) {
    final ReceiptTextLeftRight leftRightText = ReceiptTextLeftRight(
      leftText,
      rightText,
      leftTextStyle: ReceiptTextStyle(
        type: leftStyle,
        useSpan: true,
        size: leftSize,
      ),
      rightTextStyle: ReceiptTextStyle(
        type: leftStyle,
        useSpan: true,
        size: rightSize,
      ),
    );
    _data += leftRightText.html;
  }

  /// Add new line as empty or dashed line.
  /// [count] is how much line
  /// if [useDashed] true line will print as dashed line
  void addSpacer({int count = 1, bool useDashed = false}) {
    final ReceiptLine line = ReceiptLine(count: count, useDashed: useDashed);
    _data += line.html;
  }

  void addHtml(final String html) {
    _data += html;
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

  void addImage(
    String base64, {
    int width = 120,
    ReceiptAlignment alignment = ReceiptAlignment.center,
  }) {
    final ReceiptImage image = ReceiptImage(
      base64,
      width: width,
      alignment: alignment,
    );
    _data += image.html;
  }

  void addNetworkImage(
    String url, {
    int width = 120,
    ReceiptAlignment alignment = ReceiptAlignment.center,
  }) {
    final ReceiptNetworkImage image = ReceiptNetworkImage(
      url,
      width: width,
      alignment: alignment,
    );
    _data += image.html;
  }

  void addTable({
    required final List<String> headers,
    required final List<List<String>> rows,
  }) {
    final ReceiptTableView table = ReceiptTableView(<ReceiptText>[
      for (final String cell in headers)
        ReceiptText(cell,
            textStyle: const ReceiptTextStyle(
                size: ReceiptTextSizeType.small,
                type: ReceiptTextStyleType.bold)),
    ], <List<ReceiptText>>[
      for (final List<String> row in rows) ...[
        <ReceiptText>[
          for (final String cell in row)
            ReceiptText(cell,
                textStyle:
                    const ReceiptTextStyle(size: ReceiptTextSizeType.small)),
        ]
      ]
    ]);
    _data += table.html;
  }

  void addRow(final List<RowItem> items) {
    if (items.isEmpty) return;
    if (items.length == 1) {
      final first = items.first;
      addText(first.text, style: first.type, size: first.size);
      return;
    }
    final left = items.first;
    final right = items.last;
    return addLeftRightText(
      left.text,
      right.text,
      leftStyle: left.type,
      rightStyle: right.type,
      leftSize: left.size,
      rightSize: right.size,
    );

    final ReceiptRow row = ReceiptRow([
      for (final RowItem item in items)
        RowCell(
            flex: item.flex,
            text: ReceiptText(
              item.text,
              textStyle: ReceiptTextStyle(
                type: item.type,
                size: item.size,
              ),
              alignment: item.alignment,
            )),
    ]);
    _data += row.html;
  }
}

class RowItem {
  RowItem({
    this.flex = 1,
    required this.text,
    this.type = ReceiptTextStyleType.normal,
    this.size = ReceiptTextSizeType.small,
    this.alignment = ReceiptAlignment.right,
  });

  final int flex;
  final String text;

  /// [type] to define weight of text
  /// [ReceiptTextStyleType.normal] for normal weight
  /// [ReceiptTextStyleType.bold] for more weight than normal type
  final ReceiptTextStyleType type;

  /// [size] define size of text,
  final ReceiptTextSizeType size;

  final ReceiptAlignment alignment;
}
