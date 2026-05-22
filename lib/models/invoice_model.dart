import 'package:uuid/uuid.dart';

class InvoiceItem {
  final String name;
  final int quantity;
  final double price;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}

class Invoice {
  final String id;
  final String clientId; // ربط مباشر بـ ID العميل
  final String clientName; 
  final DateTime date;
  final List<InvoiceItem> items;
  final double discount;
  final double paidAmount;
  final String createdBy;

  Invoice({
    String? id,
    required this.clientId,
    required this.clientName,
    required this.date,
    required this.items,
    this.discount = 0.0,
    required this.paidAmount,
    required this.createdBy,
  }) : this.id = id ?? const Uuid().v4();

  double get subTotal => items.fold(0, (sum, item) => sum + item.total);
  double get grandTotal => subTotal - discount;
  double get remainingAmount => grandTotal - paidAmount; // المتبقي من الفاتورة

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'discount': discount,
      'paidAmount': paidAmount,
      'grandTotal': grandTotal,
      'remainingAmount': remainingAmount,
      'createdBy': createdBy,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      date: DateTime.parse(map['date']),
      items: (map['items'] as List)
          .map((item) => InvoiceItem.fromMap(item))
          .toList(),
      discount: (map['discount'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      createdBy: map['createdBy'] ?? '',
    );
  }
}
