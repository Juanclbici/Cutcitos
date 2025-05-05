import 'package:flutter/material.dart';
import '../../services/message/message_service.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_drawer.dart';
import '../../models/User.dart';
import '../../widgets/user_image.dart';
import '../sellers/seller_chat.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _inbox = [];
  bool _isLoading = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadInbox();
  }

  Future<void> _loadInbox() async {
    try {
      final inboxData = await MessageService.getInbox();
      final usuarios = await MessageService.getAllUsers();

      final enrichedInbox = inboxData.map((item) {
        final user = usuarios.firstWhere(
              (u) => u.id == item['usuario_id'].toString(),
          orElse: () => User(
            id: item['usuario_id'].toString(),
            nombre: 'Desconocido',
            email: '',
            rol: 'usuario',
            telefono: '',
            codigoUDG: '',
            estadoCuenta: '',
            fotoPerfil: 'assets/images/default/default_profile.jpg',
            fechaRegistro: DateTime.now(),
          ),
        );

        return {
          ...item,
          'nombre': user.nombre,
          'foto': user.fotoPerfil,
        };
      }).toList();

      setState(() {
        _inbox = enrichedInbox;
        _isLoading = false;
      });
    } catch (e) {
      print("Error cargando inbox: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bandeja de Entrada"),
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: true,
      ),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inbox.isEmpty
          ? const Center(child: Text("No tienes conversaciones aún"))
          : ListView.builder(
        itemCount: _inbox.length,
        itemBuilder: (context, index) {
          final item = _inbox[index];
          final usuarioId = item['usuario_id'];
          final mensaje = item['ultimo_mensaje'] ?? '';
          final fecha = item['fecha'] ?? '';
          final noLeido = item['no_leido'] ?? false;
          final nombre = item['nombre'] ?? 'Usuario';
          final foto = item['foto'] ?? 'assets/images/default/default_profile.jpg';

          return ListTile(
            leading: UserImage(
              imagePath: foto,
              width: 50,
              height: 50,
              borderRadius: BorderRadius.circular(25),
            ),
            title: Text(
              nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              mensaje,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fecha.toString().split('T').first,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                if (noLeido)
                  const Icon(Icons.mark_chat_unread, color: Colors.redAccent, size: 18),
              ],
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellerChatScreen(
                    sellerName: nombre,
                    sellerImage: foto,
                    usuarioId: usuarioId,
                  ),
                ),
              );

              if (result == true) {
                _loadInbox();
              }
            },
          );
        },
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 1),
    );
  }
}
