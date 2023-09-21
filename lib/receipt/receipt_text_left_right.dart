import 'package:blue_print_pos/receipt/collection_style.dart';
import 'package:blue_print_pos/receipt/receipt_base_view.dart';

import 'receipt_text_style.dart';
import 'receipt_text_style_type.dart';

class ReceiptTextLeftRight extends BaseReceiptView {
  ReceiptTextLeftRight(
    this.leftText,
    this.rightText, {
    this.leftTextStyle = const ReceiptTextStyle(
      type: ReceiptTextStyleType.normal,
      useSpan: true,
    ),
    this.rightTextStyle = const ReceiptTextStyle(
      type: ReceiptTextStyleType.normal,
      useSpan: true,
    ),
  });

  final String leftText;
  final String rightText;
  final ReceiptTextStyle leftTextStyle;
  final ReceiptTextStyle rightTextStyle;

  // @override
  // String get html => '''
  //   <p class="full-width inline-block">
  //     <${leftTextStyle.textStyleHTML} class="left ${leftTextStyle.textSizeHtml}">$leftText</${leftTextStyle.textStyleHTML}>
  //     <${rightTextStyle.textStyleHTML} class="right ${rightTextStyle.textSizeHtml}">$rightText</${rightTextStyle.textStyleHTML}>
  //   </p>
  // ''';

  @override
  String get html {
    return '''
<div class="clearfix"> 
  <div style="width: 66%; float:left" class="${leftTextStyle.textSizeHtml} ${CollectionStyle.textRight}">
    $leftText
  </div>
  <div style="width: 33%; float:right" class="${rightTextStyle.textSizeHtml} ${CollectionStyle.textRight}">
     $rightText
  </div>
  <br>
</div>
  ''';
  }
}
