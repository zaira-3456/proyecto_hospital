import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // 🎨 PERSONALIZA ESTOS COLORES
  final Color backgroundColor1 = const Color(0xFF000000); // Negro
  final Color backgroundColor2 = const Color(0xFF000000); // Negro
  final Color cardColor = const Color(0xFF371E86); // Morado oscuro
  final Color buttonColor = const Color(0xFF0386D9); // Azul
  final Color accentColor = const Color(0xFF4A90C8); // Azul

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      print('Usuario: ${_userController.text}');
      print('Contraseña: ${_passwordController.text}');
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: const Text('Funcionalidad de recuperación de contraseña'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    
    // Determinar si es móvil o tablet/desktop
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    // Tamaños responsivos
    final double logoSize = isMobile ? 100 : (isTablet ? 130 : 150);
    final double cardPadding = isMobile ? 20 : 30;
    final double cardMaxWidth = isMobile ? screenWidth * 0.9 : (isTablet ? 500 : 400);
    final double labelFontSize = isMobile ? 13 : 14;
    final double buttonFontSize = isMobile ? 15 : 16;
    final double spacing = isMobile ? 15 : 20;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor1,
              backgroundColor2,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: isMobile ? 20 : 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🖼️ Logo responsivo
                  Container(
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset(
                      'assets/techBridge_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.local_hospital,
                          size: logoSize * 0.7,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: isMobile ? 30 : 40),
                  
                  // 🎨 Card de login responsivo
                  Container(
                    constraints: BoxConstraints(maxWidth: cardMaxWidth),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            SizedBox(height: spacing),
                            
                            // Campo Usuario
                            Text(
                              'Usuario:',
                              style: TextStyle(
                                fontSize: labelFontSize,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _userController,
                              enabled: !_isLoading,
                              style: TextStyle(
                                fontSize: labelFontSize,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: accentColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 15,
                                  vertical: isMobile ? 12 : 14,
                                ),
                                isDense: isMobile,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su usuario';
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: spacing),
                            
                            // Campo Contraseña
                            Text(
                              'Contraseña:',
                              style: TextStyle(
                                fontSize: labelFontSize,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              enabled: !_isLoading,
                              style: TextStyle(
                                fontSize: labelFontSize,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: accentColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 15,
                                  vertical: isMobile ? 12 : 14,
                                ),
                                isDense: isMobile,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                    size: isMobile ? 20 : 24,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su contraseña';
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: isMobile ? 12 : 15),
                            
                            // ¿Olvidaste tu contraseña?
                            GestureDetector(
                              onTap: _isLoading ? null : _handleForgotPassword,
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 13,
                                  color: accentColor,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: spacing),
                            
                            // Botón Iniciar
                            SizedBox(
                              height: isMobile ? 45 : 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  disabledBackgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  elevation: 3,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Iniciar',
                                        style: TextStyle(
                                          fontSize: buttonFontSize,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            
                            SizedBox(height: isMobile ? 15 : 20),
                            
                            // Enlace de Registro
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '¿No tienes cuenta? ',
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _isLoading ? null : () {
                                    print('Ir a registro');
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                                  },
                                  child: Text(
                                    'Regístrate',
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Espacio adicional al final para evitar que el teclado tape el contenido
                  SizedBox(height: isMobile ? 20 : 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}