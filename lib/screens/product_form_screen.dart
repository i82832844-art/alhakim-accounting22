import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_repository.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final String? initialBarcode;
  const ProductFormScreen({super.key, this.product, this.initialBarcode});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _barcode = TextEditingController();
  final _category = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _purchase = TextEditingController(text: '0');
  final _sale = TextEditingController(text: '0');
  final _quantity = TextEditingController(text: '0');
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _name.text = p.name;
      _barcode.text = p.barcode ?? '';
      _category.text = p.category ?? '';
      _brand.text = p.brand ?? '';
      _model.text = p.model ?? '';
      _purchase.text = p.purchasePrice.toString();
      _sale.text = p.salePrice.toString();
      _quantity.text = p.quantity.toString();
      _imagePath = p.imagePath;
    } else if (widget.initialBarcode != null) {
      _barcode.text = widget.initialBarcode!;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _barcode, _category, _brand, _model, _purchase, _sale, _quantity]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file != null) setState(() => _imagePath = file.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final product = Product(
      id: widget.product?.id,
      name: _name.text.trim(),
      barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
      category: _category.text.trim().isEmpty ? null : _category.text.trim(),
      purchasePrice: double.tryParse(_purchase.text.replaceAll(',', '.')) ?? 0,
      salePrice: double.tryParse(_sale.text.replaceAll(',', '.')) ?? 0,
      quantity: int.tryParse(_quantity.text) ?? 0,
      imagePath: _imagePath,
      brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
      model: _model.text.trim().isEmpty ? null : _model.text.trim(),
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      final repo = context.read<ProductRepository>();
      if (widget.product == null) {
        await repo.insert(product);
      } else {
        await repo.update(product);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر حفظ المنتج: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(TextEditingController c, String label, {TextInputType? type, String? Function(String?)? validator}) {
    return TextFormField(controller: c, keyboardType: type, validator: validator, decoration: InputDecoration(labelText: label));
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.product != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'تعديل المنتج' : 'إضافة منتج')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 170,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                child: _imagePath == null
                    ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, size: 42), SizedBox(height: 8), Text('تصوير المنتج')])
                    : ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.file(File(_imagePath!), fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 18),
            _field(_name, 'اسم المنتج *', validator: (v) => (v == null || v.trim().isEmpty) ? 'اسم المنتج مطلوب' : null),
            const SizedBox(height: 12),
            _field(_barcode, 'الباركود'),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _field(_brand, 'الماركة')), const SizedBox(width: 10), Expanded(child: _field(_model, 'الموديل'))]),
            const SizedBox(height: 12),
            _field(_category, 'التصنيف'),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _field(_purchase, 'سعر الشراء', type: const TextInputType.numberWithOptions(decimal: true))), const SizedBox(width: 10), Expanded(child: _field(_sale, 'سعر البيع', type: const TextInputType.numberWithOptions(decimal: true)))]),
            const SizedBox(height: 12),
            _field(_quantity, 'الكمية', type: TextInputType.number),
            const SizedBox(height: 22),
            FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save_outlined), label: Text(_saving ? 'جارٍ الحفظ...' : 'حفظ المنتج'), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54))),
          ],
        ),
      ),
    );
  }
}
