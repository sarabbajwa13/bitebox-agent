import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../config/app_strings.dart';
import '../../config/app_theme.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';

/// Add / edit a product (admin).
class ProductEditScreen extends StatefulWidget {
  /// null = naya product; warna edit.
  final Product? product;
  const ProductEditScreen({super.key, this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _image;
  late final TextEditingController _category;
  late bool _isVeg;
  late bool _isAvailable;
  late List<_VariantCtrl> _variants;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _desc = TextEditingController(text: p?.description ?? '');
    _image = TextEditingController(text: p?.imageUrl ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _isVeg = p?.isVeg ?? true;
    _isAvailable = p?.isAvailable ?? true;
    _variants = (p?.variants ?? [])
        .map((v) => _VariantCtrl(name: v.name, price: v.price, id: v.id))
        .toList();
    if (_variants.isEmpty) _variants.add(_VariantCtrl());
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _image.dispose();
    _category.dispose();
    for (final v in _variants) {
      v.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final variants = <ProductVariant>[];
    for (final v in _variants) {
      final name = v.name.text.trim();
      final price = double.tryParse(v.price.text.trim());
      if (name.isNotEmpty && price != null) {
        variants.add(ProductVariant(
          id: v.id ?? 'v_${DateTime.now().microsecondsSinceEpoch}_${variants.length}',
          name: name,
          price: price,
        ));
      }
    }
    if (variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.variantRequired)),
      );
      return;
    }

    final product = Product(
      id: widget.product?.id ?? '',
      storeId: AppConfig.storeId,
      name: _name.text.trim(),
      description: _desc.text.trim(),
      imageUrl: _image.text.trim(),
      category: _category.text.trim().isEmpty
          ? 'Snacks'
          : _category.text.trim(),
      isVeg: _isVeg,
      isAvailable: _isAvailable,
      variants: variants,
    );

    setState(() => _saving = true);
    final provider = context.read<ProductsProvider>();
    if (_isEdit) {
      await provider.update(product);
    } else {
      await provider.add(product);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.productSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? AppStrings.editProduct : AppStrings.addProduct),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _ImagePreview(controller: _image),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _image,
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: AppStrings.productImageUrl,
                hintText: AppStrings.productImageHint,
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: AppStrings.productName,
                prefixIcon: Icon(Icons.fastfood_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.nameRequired2
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _desc,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: AppStrings.productDesc,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _category,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: AppStrings.productCategory,
                hintText: 'Pakoda, Rolls, Chaat…',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isVeg,
              activeThumbColor: AppColors.veg,
              onChanged: (v) => setState(() => _isVeg = v),
              title: const Text(AppStrings.isVegLabel),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isAvailable,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _isAvailable = v),
              title: const Text(AppStrings.isAvailableLabel),
            ),
            const Divider(height: AppSpacing.xl),
            const Text(
              AppStrings.variants,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (int i = 0; i < _variants.length; i++)
              _VariantRow(
                ctrl: _variants[i],
                onRemove: _variants.length > 1
                    ? () => setState(() => _variants.removeAt(i).dispose())
                    : null,
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    setState(() => _variants.add(_VariantCtrl())),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(AppStrings.addVariant),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(AppStrings.saveProduct),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final TextEditingController controller;
  const _ImagePreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final url = controller.text.trim();
    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3ECE4),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined,
                      size: 36, color: AppColors.textSecondary),
                  SizedBox(height: 6),
                  Text('Image preview',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Text(
                  'Image not loading — check URL / CORS',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  final _VariantCtrl ctrl;
  final VoidCallback? onRemove;
  const _VariantRow({required this.ctrl, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: ctrl.name,
              decoration: const InputDecoration(
                labelText: AppStrings.variantName,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: ctrl.price,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: AppStrings.priceLabel,
                prefixText: '${AppConfig.currencySymbol} ',
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: onRemove == null ? AppColors.border : AppColors.danger,
          ),
        ],
      ),
    );
  }
}

class _VariantCtrl {
  final String? id;
  final TextEditingController name;
  final TextEditingController price;
  _VariantCtrl({String? name, double? price, this.id})
      : name = TextEditingController(text: name ?? ''),
        price = TextEditingController(
          text: price != null ? price.toStringAsFixed(0) : '',
        );

  void dispose() {
    name.dispose();
    price.dispose();
  }
}
