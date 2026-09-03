import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/product_repository.dart';
import '../services/sales_repository.dart';
import 'products_screen.dart';
import 'scan_screen.dart';
import 'product_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _count = 0;
  double _inventory = 0;
  int _low = 0;
  double _salesToday = 0;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final repo = context.read<ProductRepository>();
    final sales = context.read<SalesRepository>();
    final start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final values = await Future.wait([repo.count(), repo.inventoryValue(), repo.lowStock(), sales.salesTotal(from: start)]);
    if (mounted) setState(() { _count = values[0] as int; _inventory = values[1] as double; _low = (values[2] as List).length; _salesToday = values[3] as double; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الحكيم للمحاسبة'), centerTitle: false, actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF176BFF), Color(0xFF6C4DFF)]), borderRadius: BorderRadius.circular(28)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('لوحة التحكم', style: TextStyle(color: Colors.white70)), const SizedBox(height: 8), Text('${_inventory.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)), const Text('قيمة المخزون بسعر الشراء', style: TextStyle(color: Colors.white70))]),
        const SizedBox(height: 18),
        Row(children: [Expanded(child: _stat('المنتجات', '$_count', Icons.inventory_2_outlined)), const SizedBox(width: 12), Expanded(child: _stat('ناقص المخزون', '$_low', Icons.warning_amber_rounded))]),
        const SizedBox(height: 12),
        _stat('مبيعات اليوم', _salesToday.toStringAsFixed(2), Icons.point_of_sale_outlined),
        const SizedBox(height: 18),
        const Text('عمليات سريعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          _quick('مسح باركود', Icons.qr_code_scanner, () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()));
            await _load();
          }),
          const SizedBox(width: 12),
          _quick('إضافة منتج', Icons.add_box_outlined, () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen()));
            await _load();
          }),
        ]),
        const SizedBox(height: 12),
        _quickWide('إدارة المنتجات والجرد', Icons.inventory_outlined, () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen())); _load(); }),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('الحكيم للمحاسبة — الإصدار 0.2.1', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('قاعدة بيانات محلية، إدارة المنتجات، باركود، مبيعات وفواتير، خصم تلقائي من المخزون، ومؤشرات مبيعات اليوم. المرحلة التالية: المشتريات والمصروفات والتقارير والنسخ الاحتياطي والتعرف الذكي بالصورة.'),
            ]))),
      ])),
    );
  }

  Widget _stat(String title, String value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [Icon(icon, size: 30), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 3), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))])]));
  Widget _quick(String title, IconData icon, VoidCallback onTap) => Expanded(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Icon(icon, size: 32), const SizedBox(height: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.w600))]))));
  Widget _quickWide(String title, IconData icon, VoidCallback onTap) => InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: Card(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), child: Row(children: [Icon(icon, size: 30), const SizedBox(width: 14), Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)), const Spacer(), const Icon(Icons.chevron_left)])));
}
