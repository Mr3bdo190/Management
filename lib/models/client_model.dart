import 'package:uuid/uuid.dart';

class Client {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String type; // 'client' (عميل) أو 'supplier' (مورد)
  final double initialBalance; // الرصيد الافتتاحي أول ما فتحنا له حساب
  final double currentBalance; // الحساب الحالي الصافي (له أو عليه)

  Client({
    String? id,
    required this.name,
    required this.phone,
    this.address = '',
    required this.type,
    this.initialBalance = 0.0,
    double? currentBalance,
  })  : this.id = id ?? const Uuid().v4(),
        this.currentBalance = currentBalance ?? initialBalance;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'type': type,
      'initialBalance': initialBalance,
      'currentBalance': currentBalance,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      type: map['type'] ?? 'client',
      initialBalance: (map['initialBalance'] ?? 0).toDouble(),
      currentBalance: (map['currentBalance'] ?? 0).toDouble(),
    );
  }
}
