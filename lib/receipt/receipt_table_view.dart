import 'package:blue_print_pos/receipt/receipt_base_view.dart';
import 'package:blue_print_pos/receipt/receipt_text.dart';

class ReceiptTableView extends BaseReceiptView {
  ReceiptTableView(this.headers, this.rows);

  final List<ReceiptText> headers;
  final List<List<ReceiptText>> rows;

  @override
  String get html {
    String th = '';
    String tr = '';
    for (final ReceiptText header in headers) {
      th = '$th<th>${header.html}</th>';
    }
    for (final List<ReceiptText> row in rows) {
      tr = '$tr<tr>';
      for (final ReceiptText cell in row) {
        tr = '$tr<td>${cell.html}</td>';
      }
      tr = '$tr</tr>';
    }

    return '''
<table>
  <tr>
    $th
  </tr>
  $tr
</table>    
    ''';
  }
}
