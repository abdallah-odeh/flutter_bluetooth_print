import 'package:blue_print_pos/receipt/receipt_base_view.dart';

import 'collection_style.dart';
import 'receipt.dart';

class ReceiptImage extends BaseReceiptView {
  ReceiptImage(
    this.data, {
    this.alignment = ReceiptAlignment.center,
    this.width = 120,
  });

  final String data;
  final int width;
  final ReceiptAlignment alignment;

  @override
  String get html => '''
    <div class="$_alignmentStyleHTML">
      <img src ="data:image/png;base64,$data" width="$width"/>
    </div>
    ''';

  String get _alignmentStyleHTML {
    if (alignment == ReceiptAlignment.left) {
      return CollectionStyle.textLeft;
    } else if (alignment == ReceiptAlignment.right) {
      return CollectionStyle.textRight;
    }
    return CollectionStyle.textCenter;
  }
}

class ReceiptNetworkImage extends ReceiptImage {
  ReceiptNetworkImage(
    final String data, {
    final int width = 120,
    final ReceiptAlignment alignment = ReceiptAlignment.center,
  }) : super(data, alignment: alignment, width: width);

  @override
  String get html => '''
    <div class="$_alignmentStyleHTML">
      <img src ="$data" width="$width"/>
    </div>
    ''';
}
