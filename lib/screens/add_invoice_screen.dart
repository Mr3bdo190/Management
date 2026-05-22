import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/factory_provider.dart';
import '../models/invoice_model.dart';
import '../models/client_model.dart';

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  
  List<InvoiceItem> _items = [];
  bool _isLoading = false;

  void _addNewItem() {
    // محاكاة سريعة لإضافة صنف، في التطبيق الفعلي سيتم فتح ديالوج لأخذ بيانات الصنف
    setState(() {
      _items.add(InvoiceItem(name: 'خامة/منتج جديد', quantity: 1, price: 1000));
    });
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate() || _items.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<FactoryProvider>(context, listen: false);
      
      // إنشاء العميل في الخلفية (أو البحث عنه لو موجود، للتبسيط سننشئه)
      final tempClient = Client(
        name: _clientNameController.text.trim(),
        phone: '',
        type: 'client',
      );
      await provider.addNewClient(tempClient);

      final newInvoice = Invoice(
        clientId: tempClient.id,
        clientName: tempClient.name,
        date: DateTime.now(),
        items: _items,
        paidAmount: double.tryParse(_paidAmountController.text) ?? 0.0,
        createdBy: 'مدير النظام',
      );

      await provider.addNewInvoice(newInvoice);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الفاتورة بنجاح وتحديث الحسابات!', style: TextStyle(fontFamily: 'Cairo'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = _items.fold(0, (sum, item) => sum + item.total);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('فاتورة جديدة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildModernTextField(
              controller: _clientNameController,
              label: 'اسم العميل',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            
            // قسم الأصناف
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الأصناف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _addNewItem,
                  icon: const Icon(Icons.add_circle_outline, color: Colors.indigo),
                  label: const Text('إضافة صنف', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            ..._items.map((item) => Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: ListTile(
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${item.quantity} × ${item.price} ج'),
                trailing: Text('${item.total} ج', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
              ),
            )).toList(),
            
            const SizedBox(height: 20),
            _buildModernTextField(
              controller: _paidAmountController,
              label: 'المبلغ المدفوع الآن',
              icon: Icons.payments_outlined,
              isNumber: true,
            ),
            
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إجمالي الفاتورة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('$total ج.م', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.indigo)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ الفاتورة وتحديث الدفتر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({required TextEditingController controller, required String label, required IconData icon, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) => val!.isEmpty ? 'هذا الحقل مطلوب' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
      ),
    );
  }
}
