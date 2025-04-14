import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth/login_screen.dart';
import 'screens/sellers/sellers_list.dart';
import 'services/api_service.dart';

Future<void> main() async {
  // Carga las variables de entorno ANTES de iniciar la app
  await dotenv.load(fileName: ".env");
  await ApiService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cutcitos App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const SellersList(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}