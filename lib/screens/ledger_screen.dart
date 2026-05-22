import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/factory_provider.dart';
import '../models/invoice_model.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FactoryProvider>(context);
    final invoices = provider.invoices;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // لون خلفية هادئ ومريح للعين
      appBar: AppBar(
        title: const Text('سجل العمليات والدفتر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A1A24),
        elevation: 0,
      ),
      body: invoices.isEmpty
          ? const Center(child: Text('لا توجد عمليات مسجلة حتى الآن', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return _buildModernInvoiceCard(invoice);
              },
            ),
    );
  }

  Widget _buildModernInvoiceCard(Invoice invoice) {
    final bool isFullyPaid = invoice.remainingAmount <= 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الهيدر: اسم العميل والتاريخ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    invoice.clientName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2D3142)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFullyPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFullyPaid ? 'خالص' : 'آجل',
                    style: TextStyle(
                      color: isFullyPaid ? Colors.green[700] : Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('yyyy-MM-dd • hh:mm a').format(invoice.date),
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFEEEEEE), thickness: 1.5),
            ),
            
            // تفاصيل المبالغ بتصميم عصري
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountColumn('الإجمالي', invoice.grandTotal, Colors.black87),
                _buildAmountColumn('المدفوع (تنزيل)', invoice.paidAmount, Colors.green[600]!),
                _buildAmountColumn('المتبقي (عليه)', invoice.remainingAmount, Colors.red[600]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountColumn(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(0)} ج',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
