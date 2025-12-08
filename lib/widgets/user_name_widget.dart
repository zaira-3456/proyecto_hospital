import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget reutilizable que muestra el nombre del usuario logueado
/// Usar en el header de cualquier SideMenu/Drawer
class UserNameWidget extends StatefulWidget {
  final TextStyle? style;
  final String loadingText;
  final String defaultText;

  const UserNameWidget({
    super.key,
    this.style,
    this.loadingText = 'Cargando...',
    this.defaultText = 'Usuario',
  });

  @override
  State<UserNameWidget> createState() => _UserNameWidgetState();
}

class _UserNameWidgetState extends State<UserNameWidget> {
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userName = widget.loadingText;
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      // Obtener username desde SharedPreferences (guardado en login)
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('current_username');
      
      if (username != null && username.isNotEmpty) {
        // Buscar en colección 'users'
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (userDoc.docs.isNotEmpty && mounted) {
          setState(() {
            _userName = userDoc.docs.first.data()['name'] ?? widget.defaultText;
            _isLoading = false;
          });
          return;
        }

        // Si no se encuentra en 'users', buscar en 'usuarios' (legacy)
        final legacyDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (legacyDoc.docs.isNotEmpty && mounted) {
          final data = legacyDoc.docs.first.data();
          setState(() {
            _userName = (data['name'] ?? data['nombre'] ?? widget.defaultText) as String;
            _isLoading = false;
          });
          return;
        }
      }

      // Si no hay username o no se encontró
      if (mounted) {
        setState(() {
          _userName = widget.defaultText;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando nombre de usuario: $e');
      if (mounted) {
        setState(() {
          _userName = widget.defaultText;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _userName,
      style: widget.style,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
