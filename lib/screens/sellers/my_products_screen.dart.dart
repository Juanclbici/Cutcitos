import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../services/product/product_service.dart';
import '../../services/category/category_service.dart';
import '../../services/cloudinary/cloudinary_service.dart';
import '../../widgets/product_image.dart';
import '../../widgets/user_cover.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  late Future<List<Product>> _productsFuture = Future.value([]);
  late int _vendedorId;
  bool _loading = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _selectedImage = 'default_product.png';
  String _selectedStatus = 'disponible';
  int? _categoriaSeleccionada;
  List<Category> _categorias = [];

  Product? _editingProduct;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    _vendedorId = prefs.getInt('user_id') ?? 0;
    _categorias = await CategoryService.getAllCategories();
    _refrescarProductos();
  }

  Future<void> _refrescarProductos() async {
    setState(() {
      _productsFuture = ProductService.getMyProducts();
    });
  }

  void _mostrarFormulario({Product? producto}) {
    _editingProduct = producto;
    if (producto != null) {
      _nameController.text = producto.name;
      _priceController.text = producto.price.toString();
      _descripcionController.text = producto.description ?? '';
      _selectedImage = producto.image;
      _selectedStatus = producto.status.toLowerCase();
      _categoriaSeleccionada = producto.categoryId;
    } else {
      _nameController.clear();
      _priceController.clear();
      _descripcionController.clear();
      _selectedImage = 'default_product.png';
      _selectedStatus = 'disponible';
      _categoriaSeleccionada = _categorias.isNotEmpty ? _categorias.first.id : null;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(producto == null ? 'Nuevo Producto' : 'Editar Producto'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_editingProduct != null) ...[
                  ProductImage(
                    imagePath: _selectedImage,
                    width: 100,
                    height: 100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _categoriaSeleccionada,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: _categorias.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'disponible', child: Text('Disponible')),
                    DropdownMenuItem(value: 'agotado', child: Text('Agotado')),
                    DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                  ],
                  onChanged: (val) => _selectedStatus = val!,
                  decoration: const InputDecoration(labelText: 'Estado'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: _guardarProducto, child: const Text('Guardar')),
        ],
      ),
    );
  }

  Future<void> _subirImagenDesdeGaleria() async {
    final url = await CloudinaryService.subirImagenFirmada(folder: 'productos');
    if (url != null) {
      print('✅ Imagen subida: $url');
      setState(() {
        _selectedImage = url;
      });
    } else {
      print('❌ No se subió imagen');
    }
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (!_selectedImage.startsWith('http') && _selectedImage != 'default_product.png') {
        final url = await CloudinaryService.subirImagenFirmada(folder: 'productos');
        if (url == null) {
          _mostrarMensaje('❌ No se pudo subir la imagen');
          setState(() => _loading = false);
          return;
        }
        _selectedImage = url;
      }

      final data = {
        'nombre': _nameController.text.trim(),
        'precio': double.tryParse(_priceController.text) ?? 0.0,
        'imagen': _selectedImage,
        'estado_producto': _selectedStatus,
        'descripcion': _descripcionController.text.trim(),
        'cantidad_disponible': 10,
        'categoria_id': _categoriaSeleccionada ?? 1,
      };

      Navigator.pop(context);

      if (_editingProduct == null) {
        await ProductService.createProduct(data);
        _mostrarMensaje('✅ Producto creado');
      } else {
        await ProductService.updateProduct(_editingProduct!.id, data);
        _mostrarMensaje('✅ Producto actualizado');
      }

      _refrescarProductos();
    } catch (e) {
      _mostrarMensaje('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _eliminarProducto(int productId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('¿Seguro que deseas eliminar este producto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _loading = true);
      try {
        await ProductService.deleteProduct(productId);
        _mostrarMensaje('Producto eliminado');
        _refrescarProductos();
      } catch (e) {
        _mostrarMensaje('Error al eliminar: $e');
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _cambiarImagenProducto(Product producto) async {
    final nuevaUrl = await CloudinaryService.subirImagenFirmada(folder: 'productos');
    if (nuevaUrl != null) {
      try {
        await ProductService.updateProduct(producto.id, {
          'imagen': nuevaUrl,
        });
        _mostrarMensaje('✅ Imagen actualizada');
        _refrescarProductos();
      } catch (e) {
        _mostrarMensaje('❌ Error al actualizar imagen: $e');
      }
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const SizedBox(
                height: 200,
                width: double.infinity,
                child: UserCover(),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final productos = snapshot.data ?? [];

                if (productos.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No tienes productos aún.'),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final p = productos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Stack(
                          children: [
                            ProductImage(
                              imagePath: p.image,
                              width: 60,
                              height: 60,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _cambiarImagenProducto(p),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.edit, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(p.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\$${p.price.toStringAsFixed(2)}'),
                            Text(p.status, style: TextStyle(color: _getStatusColor(p.status))),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit), onPressed: () => _mostrarFormulario(producto: p)),
                            IconButton(icon: const Icon(Icons.delete), onPressed: () => _eliminarProducto(p.id)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'disponible':
        return Colors.green;
      case 'agotado':
        return Colors.red;
      case 'inactivo':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}

