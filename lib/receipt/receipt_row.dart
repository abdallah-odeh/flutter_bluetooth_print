import 'package:blue_print_pos/receipt/receipt_base_view.dart';
import 'package:blue_print_pos/receipt/receipt_text.dart';

class ReceiptRow extends BaseReceiptView {
  ReceiptRow(this.cells);

  final List<RowCell> cells;

  @override
  String get html {
    String divs = '';
    var totalFlexes = cells.map((e) => e.flex).reduce((a, b) => a + b);
    for (final RowCell cell in cells) {
      /*
      <div style="width: 66%; float:left" class="text-right text-small">
       <p>178141097</p>
    </div>

    <div style="width: 33%; float:right" class="text-right text-small">
       <p>الرقم الضريبي</p>
    </div>


    <br>
       */
      // var div = cell.text.html.replaceAll('<div', '<div')

      divs =
          '$divs<div style="flex-basis: ${((cell.flex / totalFlexes) * 100).toInt()}%">${cell.text.html}</div>';
    }

    return '''
<div class="flex-container">
  $divs
</div>
    ''';
  }
}

class RowCell {
  RowCell({this.flex = 1, required this.text});

  final int flex;
  final ReceiptText text;
}
