import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../models/invoice_model.dart';
import '../services/firestore_service.dart';

class FactoryProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<Client> _clients = [];
  List<Client> _suppliers = [];
  List<Invoice> _invoices = [];

  List<Client> get clients => _clients;
  List<Client> get suppliers => _suppliers;
  List<Invoice> get invoices => _invoices;

  FactoryProvider() {
    // بدء الاستماع للبيانات تلقائياً فور تشغيل التطبيق
    _initStreams();
  }

  void _initStreams() {
    // مراقبة العملاء بـ Real-time
    _service.getClientsAndSuppliers('client').listen((data) {
      _clients = data;
      notifyListeners();
    });

    // مراقبة الموردين بـ Real-time
    _service.getClientsAndSuppliers('supplier').listen((data) {
      _suppliers = data;
      notifyListeners();
    });

    // مراقبة كل فواتير المصنع بـ Real-time
    _service.getAllInvoices().listen((data) {
      _invoices = data;
      notifyListeners();
    });
  }

  // إضافة عميل أو مورد جديد
  Future<void> addNewClient(Client client) async {
    try {
      await _service.saveClient(client);
    } catch (e) {
      print("خطأ في إضافة العميل في الـ Provider: $e");
      rethrow;
    }
  }

  // إضافة فاتورة جديدة وتحديث الحساب تلقائياً
  Future<void> addNewInvoice(Invoice invoice) async {
    try {
      await _service.saveInvoice(invoice);
    } catch (e) {
      print("خطأ في إضافة الفاتورة في الـ Provider: $e");
      rethrow;
    }
  }

  // حساب إجمالي الديون المستحقة للمصنع (الفلوس اللي بره)
  double get totalClientDebts {
    return _clients.fold(0, (sum, client) => sum + client.currentBalance);
  }

  // حساب إجمالي الديون للموردين (الفلوس اللي علينا)
  double get totalSupplierDebts {
    return _suppliers.fold(0, (sum, supplier) => sum + supplier.currentBalance);
  }
}
