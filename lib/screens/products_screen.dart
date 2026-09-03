import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_repository.dart';
import 'product_form_screen.dart';
import 'scan_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _search = TextEditingController();
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); _search.addListener(_load); }
  @override
  void dispose() { _search.removeListener(_load); _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await context.read<ProductRepository>().all(query: _search.text);
    if (mounted) setState(() { _products = data; _loading = false; });
  }

  Future<void> _delete(Product p) async {
    final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('حذف المنتج؟'), content: Text('سيتم حذف ${p.name} نهائيًا.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف'))]));
    if (yes == true) { await context.read<ProductRepository>().delete(p.id!); _load(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المنتجات'), actions: [IconButton(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen())); _load(); }, icon: const Icon(Icons.qr_code_scanner))]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen())); _load(); }, icon: const Icon(Icons.add), label: const Text('إضافة منتج')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: TextField(controller: _search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث بالاسم أو الباركود أو الموديل...'))),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _products.isEmpty ? const Center(child: Text('لا توجد منتجات')) : RefreshIndicator(onRefresh: _load, child: ListView.separated(padding: const EdgeInsets.all(16), itemCount: _products.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) {
          final p = _products[i];
          return Dismissible(key: ValueKey(p.id), direction: DismissDirection.endToStart, confirmDismiss: (_) async { await _delete(p); return false; }, background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24), decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.delete_outline, color: Colors.red)), child: Card(child: ListTile(onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormScreen(product: p))); _load(); }, leading: p.imagePath != null ? CircleAvatar(backgroundImage: FileImage(File(p.imagePath!))) : const CircleAvatar(child: Icon(Icons.inventory_2_outlined)), title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text('${p.barcode ?? 'بدون باركود'} • كمية ${p.quantity}'), trailing: Text(p.salePrice.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))));
        })) ),
      ]),
    );
  }
}
