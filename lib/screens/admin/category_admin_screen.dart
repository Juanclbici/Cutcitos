import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/category/category_service.dart';

class CategoryAdminScreen extends StatefulWidget {
  const CategoryAdminScreen({super.key});

  @override
  State<CategoryAdminScreen> createState() => _CategoryAdminScreenState();
}

class _CategoryAdminScreenState extends State<CategoryAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _imagenController = TextEditingController();

  bool _isLoading = false;
  List<Category> _categorias = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categorias = await CategoryService.getAllCategories();
      setState(() => _categorias = categorias);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar categorías: $e')),
      );
    }
  }

  Future<void> _crearCategoria() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await CategoryService.createCategory(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        imagen: _imagenController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Categoría creada exitosamente')),
      );

      _formKey.currentState!.reset();
      await _loadCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Categorías'),
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FORMULARIO
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre de la categoría'),
                    validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Nombre requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imagenController,
                    decoration: const InputDecoration(labelText: 'URL de la imagen (opcional)'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _crearCategoria,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Crear Categoría'),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                ],
              ),
            ),

            // LISTA DE CATEGORÍAS
            const Text(
              'Categorías existentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _categorias.isEmpty
                  ? const Center(child: Text('No hay categorías registradas.'))
                  : ListView.builder(
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final cat = _categorias[index];
                  return ListTile(
                    // Sin imagen
                    title: Text(cat.name),
                    subtitle: Text(cat.description ?? ''),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
