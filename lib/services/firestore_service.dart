import 'dart:async';
import '../models/client_model.dart';
import '../models/invoice_model.dart';

class FirestoreService {
  // قاعدة بيانات وهمية في الذاكرة المؤقتة لاختبار التصميم والعمليات
  static final List<Client> _clients = [];
  static final List<Invoice> _invoices = [];

  final _clientsController = StreamController<List<Client>>.broadcast();
  final _invoicesController = StreamController<List<Invoice>>.broadcast();

  // حفظ عميل جديد
  Future<void> saveClient(Client client) async {
    _clients.add(client);
    _clientsController.add(_clients);
  }

  // جلب العملاء
  Stream<List<Client>> getClientsAndSuppliers(String type) async* {
    yield _clients.where((c) => c.type == type).toList();
    yield* _clientsController.stream.map((list) => list.where((c) => c.type == type).toList());
  }

  // حفظ فاتورة وتحديث الحسابات
  Future<void> saveInvoice(Invoice invoice) async {
    _invoices.add(invoice);
    
    final index = _clients.indexWhere((c) => c.id == invoice.clientId);
    if (index != -1) {
      final old = _clients[index];
      _clients[index] = Client(
        id: old.id,
        name: old.name,
        phone: old.phone,
        address: old.address,
        type: old.type,
        initialBalance: old.initialBalance,
        currentBalance: old.currentBalance + invoice.remainingAmount,
      );
    }
    
    _invoicesController.add(_invoices);
    _clientsController.add(_clients);
  }

  // جلب فواتير عميل
  Stream<List<Invoice>> getClientInvoices(String clientId) async* {
    yield _invoices.where((i) => i.clientId == clientId).toList();
    yield* _invoicesController.stream.map((list) => list.where((i) => i.clientId == clientId).toList());
  }

  // جلب كل الفواتير للدفتر
  Stream<List<Invoice>> getAllInvoices() async* {
    yield _invoices.toList();
    yield* _invoicesController.stream;
  }
}
