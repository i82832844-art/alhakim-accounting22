import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/product_repository.dart';
import 'product_form_screen.dart';

class ScanScreen extends StatefulWidget {
  final bool returnProduct;
  const ScanScreen({super.key, this.returnProduct = false});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _locked = false;

  Future<void> _handleBarcode(String code) async {
    if (_locked) return;
    setState(() => _locked = true);
    final product = await context.read<ProductRepository>().findByBarcode(code);
    if (!mounted) return;
    if (product != null) {
      if (widget.returnProduct) {
        Navigator.pop(context, product);
        return;
      }
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('الباركود: ${product.barcode ?? '-'}'),
          Text('الكمية: ${product.quantity}'),
          const SizedBox(height: 4),
          Text('سعر البيع: ${product.salePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('تم')),
        ]))),
      );
    } else {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormScreen(initialBarcode: code)));
    }
    if (mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسح الباركود')),
      body: Stack(children: [
        MobileScanner(onDetect: (capture) {
          final code = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
          if (code != null && code.isNotEmpty) _handleBarcode(code);
        }),
        Center(child: Container(width: 280, height: 170, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(20)))),
        const Positioned(bottom: 40, left: 0, right: 0, child: Center(child: Text('وجّه الكاميرا نحو الباركود', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)))),
      ]),
    );
  }
}
