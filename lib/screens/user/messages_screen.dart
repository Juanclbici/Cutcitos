import 'package:flutter/material.dart';
import '../../models/SellerData.dart';
import 'info_profile.dart';
import '../sellers/sellers_list.dart';
import '../sellers/seller_chat.dart';

// First class - MessagesScreen
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final SellerData _sellerData = SellerData();
  List<Seller> _sellers = [];
  bool _isLoading = true;
  int _selectedIndex = 1; // Set to 1 for Messages tab

  @override
  void initState() {
    super.initState();
    _loadSellers();
  }

  Future<void> _loadSellers() async {
    try {
      final sellers = await _sellerData.getSellers();
      setState(() {
        _sellers = sellers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensajes"),
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _sellers.length,
        itemBuilder: (context, index) {
          final seller = _sellers[index];
          // Mock last message
          final lastMessage = "Hola, ¿cómo estás?";
          final lastMessageTime = "12:30 PM";

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(seller.profileImage),
              radius: 25,
            ),
            title: Text(
              seller.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              lastMessageTime,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            onTap: () {
              // Navigate to chat detail screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellerChatScreen(
                sellerName: seller.name,
                sellerImage: seller.profileImage,
                ),
              ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) { // Home tab
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SellersList())
            );
          } else if (index == 3) { // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InfoProfile(),
              ),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
