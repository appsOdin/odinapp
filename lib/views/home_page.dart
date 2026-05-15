import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../theme/app_theme.dart';
import '../controllers/login_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _nombreUsuario = '';
  final LoginController _loginController = LoginController();
  @override
  void initState() {
    super.initState();
    _obtenerNombreUsuario();
  }

  Future<void> _obtenerNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('api_token');
    if (token != null) {
      Map<String, dynamic> payload = JwtDecoder.decode(token);
      setState(() {
        _nombreUsuario = payload['name'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.home, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text(
                    _nombreUsuario,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.article_outlined),
              title: Text('Artículos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/articles');
              },
            ),
            ListTile(
              leading: Icon(Icons.lock_reset),
              title: Text('Cambiar contraseña'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/update-password');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Salir'),
              onTap: () async {
                await _loginController.logout(context);
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: Text(
          _nombreUsuario.isEmpty ? '¡Hola!' : '¡Hola, $_nombreUsuario!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
