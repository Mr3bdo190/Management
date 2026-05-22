import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';
import '../models/invoice_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreService() {
    // تفعيل الكاش المحلي للعمل أوفلاين ومزامنة الداتا تلقائياً فور الاتصال
    _db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // === عمليات العملاء والموردين ===

  // إضافة أو تعديل عميل/مورد
  Future<void> saveClient(Client client) async {
    await _db.collection('clients').doc(client.id).set(client.toMap());
  }

  // جلب قائمة العملاء أو الموردين حسب النوع (Real-time)
  Stream<List<Client>> getClientsAndSuppliers(String type) {
    return _db
        .collection('clients')
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Client.fromMap(doc.data())).toList());
  }

  // === عمليات الفواتير والعمليات المركبة ===

  // حفظ فاتورة وتحديث مديونية العميل في نفس الوقت
  Future<void> saveInvoice(Invoice invoice) async {
    final batch = _db.batch();

    // 1. مرجع الفاتورة الجديدة
    final invoiceRef = _db.collection('invoices').doc(invoice.id);
    batch.set(invoiceRef, invoice.toMap());

    // 2. مرجع حساب العميل لتحديث رصيده الحالي بالباقي من الفاتورة
    final clientRef = _db.collection('clients').doc(invoice.clientId);
    
    batch.update(clientRef, {
      'currentBalance': FieldValue.increment(invoice.remainingAmount),
    });

    // تنفيذ العمليتين معاً لحماية البيانات من التضارب
    await batch.commit();
  }

  // جلب فواتير عميل محدد لكشف الحساب
  Stream<List<Invoice>> getClientInvoices(String clientId) {
    return _db
        .collection('invoices')
        .where('clientId', isEqualTo: clientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Invoice.fromMap(doc.data())).toList());
  }

  // جلب كل فواتير المصنع للدفتر العام
  Stream<List<Invoice>> getAllInvoices() {
    return _db
        .collection('invoices')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Invoice.fromMap(doc.data())).toList());
  }
}
