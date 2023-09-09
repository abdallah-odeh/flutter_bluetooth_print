import 'package:blue_print_pos/receipt/receipt_base_view.dart';

class ReceiptDivider extends BaseReceiptView {
  ReceiptDivider({this.count = 1});

  /// [count] to decide how much line without are used, empty or dashed line
  final int count;

  /// Get the tag of html, empty line use <br> and dashed line use <hr>
  /// For loop will generate how much line will printed
  @override
  String get html {
    String concatHtml = '';
    for (int i = 0; i < count; i++) {
      concatHtml += _emptyLine;
    }
    return concatHtml;
  }

  /// <br>
  String get _emptyLine => '''
    <hr border-top: 3px solid #bbb>
    ''';
}
