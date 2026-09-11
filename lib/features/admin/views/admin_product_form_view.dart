import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/cloudinary_service.dart';
import '../controllers/admin_product_controller.dart';

class AdminProductFormView extends StatefulWidget {
  const AdminProductFormView({super.key});

  @override
  State<AdminProductFormView> createState() => _AdminProductFormViewState();
}

class _AdminProductFormViewState extends State<AdminProductFormView> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _conditionCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'Tenda';
  final _categories = [
    'Tenda',
    'Sleeping Bag',
    'Kompor',
    'Backpack',
    'Matras',
    'Lainnya',
  ];
  final _pickedImages = <File>[].obs;
  final _existingImages = <String>[].obs;

  ProductModel? _existingProduct;
  bool get isEditing => _existingProduct != null;

  @override
  void initState() {
    super.initState();
    _existingProduct = Get.arguments as ProductModel?;
    if (_existingProduct != null) {
      _nameCtrl.text = _existingProduct!.name;
      _descCtrl.text = _existingProduct!.description;
      _priceCtrl.text = _existingProduct!.pricePerDay.toString();
      _stockCtrl.text = _existingProduct!.stock.toString();
      _selectedCategory = _existingProduct!.category;
      _existingImages.value = _existingProduct!.images;
      _weightCtrl.text = _existingProduct!.specs['weight'] ?? '';
      _capacityCtrl.text = _existingProduct!.specs['capacity'] ?? '';
      _colorCtrl.text = _existingProduct!.specs['color'] ?? '';
      _conditionCtrl.text = _existingProduct!.specs['condition'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _weightCtrl.dispose();
    _capacityCtrl.dispose();
    _colorCtrl.dispose();
    _conditionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    _pickedImages.addAll(picked.map((f) => File(f.path)));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<AdminProductController>();
    final cloudinary = Get.find<CloudinaryService>();

    List<String> allImages = List.from(_existingImages);

    if (_pickedImages.isNotEmpty) {
      final urls = await cloudinary.uploadMultipleImages(
        _pickedImages,
        folder: 'products',
      );
      allImages = [...allImages, ...urls];
    }

    final specs = <String, dynamic>{};
    if (_weightCtrl.text.isNotEmpty) specs['weight'] = _weightCtrl.text;
    if (_capacityCtrl.text.isNotEmpty) specs['capacity'] = _capacityCtrl.text;
    if (_colorCtrl.text.isNotEmpty) specs['color'] = _colorCtrl.text;
    if (_conditionCtrl.text.isNotEmpty) specs['condition'] = _conditionCtrl.text;

    await controller.saveProduct(
      id: _existingProduct?.id ?? '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      pricePerDay: int.parse(_priceCtrl.text),
      category: _selectedCategory,
      stock: int.parse(_stockCtrl.text),
      specs: specs,
      images: allImages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images
              Text('Foto Produk',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...List.generate(_existingImages.length, (i) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _existingImages[i],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _existingImages.removeAt(i),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Ionicons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      ...List.generate(_pickedImages.length, (i) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _pickedImages[i],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _pickedImages.removeAt(i),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Ionicons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.border, width: 2),
                          ),
                          child: const Icon(Ionicons.camera_outline,
                              color: AppColors.textHint, size: 28),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Nama Produk',
                controller: _nameCtrl,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Deskripsi',
                controller: _descCtrl,
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Category
              Text('Kategori',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Harga/Hari (Rp)',
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (int.tryParse(v) == null) return 'Harus angka';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Stok',
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (int.tryParse(v) == null) return 'Harus angka';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text('Spesifikasi',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Berat',
                hint: 'cth: 2.5 kg',
                controller: _weightCtrl,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Kapasitas',
                hint: 'cth: 4 orang',
                controller: _capacityCtrl,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Warna',
                controller: _colorCtrl,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Kondisi',
                hint: 'cth: Baru, Bagus, Bekas',
                controller: _conditionCtrl,
              ),
              const SizedBox(height: 32),

              Obx(() => CustomButton(
                    label: isEditing ? 'Simpan Perubahan' : 'Tambah Produk',
                    isLoading: Get.find<AdminProductController>().isSaving.value,
                    onPressed: _save,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
