import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/factory_provider.dart';
import 'ledger_screen.dart';
import 'add_invoice_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FactoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(
              title: 'إجمالي أموالنا بالخارج (العملاء)',
              amount: provider.totalClientDebts,
              color: Colors.green,
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              title: 'إجمالي الديون علينا (الموردين)',
              amount: provider.totalSupplierDebts,
              color: Colors.redAccent,
              icon: Icons.trending_down,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    context,
                    title: 'إنشاء فاتورة',
                    icon: Icons.add_shopping_cart,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddInvoiceScreen()));
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'دفتر الحسابات',
                    icon: Icons.menu_book,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LedgerScreen()));
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'العملاء والموردين',
                    icon: Icons.people_alt,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً: شاشة إدارة العملاء')));
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'المصاريف',
                    icon: Icons.account_balance_wallet,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً: شاشة المصاريف')));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required double amount, required Color color, required IconData icon}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 30, child: Icon(icon, color: color, size: 30)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text('${amount.toStringAsFixed(2)} ج.م', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.indigo),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
