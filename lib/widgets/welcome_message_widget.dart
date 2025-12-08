import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget que muestra mensaje de bienvenida con el nombre del usuario
class WelcomeMessageWidget extends StatefulWidget {
  final String prefix; // ej: "Bienvenido de nuevo," o "Bienvenido,"
  final TextStyle? style;

  const WelcomeMessageWidget({
    super.key,
    this.prefix = 'Bienvenido,',
    this.style,
  });

  @override
  State<WelcomeMessageWidget> createState() => _WelcomeMessageWidgetState();
}

class _WelcomeMessageWidgetState extends State<WelcomeMessageWidget> {
  String _fullMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('current_username');

      if (username != null && username.isNotEmpty) {
        // Buscar en 'users'
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (userDoc.docs.isNotEmpty) {
          if (mounted) {
            setState(() {
              final name = userDoc.docs.first.data()['name'] ?? 'Usuario';
              _fullMessage = '${widget.prefix} $name';
              _isLoading = false;
            });
          }
          return;
        }

        // Buscar en 'usuarios' (legacy)
        userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (userDoc.docs.isNotEmpty && mounted) {
          final data = userDoc.docs.first.data();
          final name = (data['name'] ?? data['nombre'] ?? 'Usuario') as String;
          setState(() {
            _fullMessage = '${widget.prefix} $name';
            _isLoading = false;
          });
          return;
        }
      }

      // Si no se encontró
      if (mounted) {
        setState(() {
          _fullMessage = '${widget.prefix} Usuario';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando nombre: $e');
      if (mounted) {
        setState(() {
          _fullMessage = '${widget.prefix} Usuario';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Text(
        '${widget.prefix} ...',
        style: widget.style,
      );
    }

    return Text(
      _fullMessage,
      style: widget.style,
    );
  }
}
