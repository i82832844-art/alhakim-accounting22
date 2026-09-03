import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/product_repository.dart';
import '../services/sales_repository.dart';
import 'scan_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final List<CartItem> _cart = [];
  bool _saving = false;

  double get _total => _cart.fold(0, (sum, item) => sum + item.total);

  void _add(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    setState(() {
      if (index == -1) {
        if (product.quantity > 0) _cart.add(CartItem(product: product, quantity: 1));
      } else if (_cart[index].quantity < product.quantity) {
        _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity + 1);
      }
    });
  }

  void _changeQuantity(int index, int delta) {
    final item = _cart[index];
    final next = item.quantity + delta;
    if (next <= 0) {
      setState(() => _cart.removeAt(index));
      return;
    }
    if (next > item.product.quantity) return;
    setState(() => _cart[index] = item.copyWith(quantity: next));
  }

  Future<void> _scan() async {
    final product = await Navigator.push<Product?>(context, MaterialPageRoute(builder: (_) => const ScanScreen(returnProduct: true)));
    if (product != null) _add(product);
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await context.read<SalesRepository>().createSale(List.unmodifiable(_cart));
      if (!mounted) return;
      setState(() => _cart.clear());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الفاتورة وتحديث المخزون')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر إتمام البيع: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المبيعات')),
      floatingActionButton: FloatingActionButton.extended(onPressed: _scan, icon: const Icon(Icons.qr_code_scanner), label: const Text('مسح منتج')),
      body: Column(children: [
        Expanded(
          child: _cart.isEmpty
              ? const Center(child: Text('الفاتورة فارغة\nابدأ بمسح باركود المنتج', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, height: 1.5)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cart.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final item = _cart[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.product.name),
                        subtitle: Text('${item.product.salePrice.toStringAsFixed(2)} × ${item.quantity}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(onPressed: () => _changeQuantity(index, -1), icon: const Icon(Icons.remove_circle_outline)),
                          Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(onPressed: () => _changeQuantity(index, 1), icon: const Icon(Icons.add_circle_outline)),
                        ]),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0x15000000)))),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), Text(_total.toStringAsFixed(2), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800))]),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _cart.isEmpty || _saving ? null : _checkout, icon: const Icon(Icons.point_of_sale_outlined), label: Text(_saving ? 'جارٍ الحفظ...' : 'إتمام البيع'))),
            ]),
          ),
        ),
      ]),
    );
  }
}
