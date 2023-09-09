class ReceiptInfo {
  final String merchantName;
  final String merchantAddress;
  final String merchantPhone;
  final String receiptType;
  final String? receiptTypeFooter;
  final DateTime printDateTime;
  final DateTime billDateTime;
  final String taxNo;
  final String billNo;
  final String customerName;
  final String paymentType;
  final String representativeName;
  final String representativeNumber;
  final List<ReceiptItem> items;

  ReceiptInfo({
    required this.merchantName,
    required this.merchantAddress,
    required this.merchantPhone,
    required this.receiptType,
    required this.receiptTypeFooter,
    required this.printDateTime,
    required this.billDateTime,
    required this.taxNo,
    required this.billNo,
    required this.customerName,
    required this.paymentType,
    required this.representativeName,
    required this.representativeNumber,
    required this.items,
  });
}

class ReceiptItem {
  final String description;
  final num quantity;
  final num price;
  final num discount;
  final num tax;

  ReceiptItem({
    required this.description,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.tax,
  });

  num get total {
    return quantity * price - discount + tax;
  }
}
