import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Servicio para envío de correos electrónicos
class EmailService {
  // Singleton
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // ============================================================
  // CONFIGURACIÓN SMTP
  // TODO: Mover estas credenciales a variables de entorno o configuración segura
  // ============================================================
  
  // Para Gmail:
  // 1. Habilitar verificación en 2 pasos en tu cuenta Google
  // 2. Crear una "Contraseña de aplicación" en: https://myaccount.google.com/apppasswords
  // 3. Usar esa contraseña aquí
  
  static const String _smtpHost = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _senderEmail = 'chinomarcos87@gmail.com'; // CAMBIAR
  static const String _senderPassword = 'kgxrkzexmqoigrbk';  // CAMBIAR
  static const String _senderName = 'Hospital System';

  /// Enviar código de verificación por email
  Future<bool> sendVerificationCode({
    required String recipientEmail,
    required String verificationCode,
    required String recipientName,
  }) async {
    try {
      // Validar configuración
      if (_senderEmail == 'tu-correo@gmail.com' || 
          _senderPassword == 'tu-contraseña-de-aplicacion') {
        print('⚠️ ADVERTENCIA: Credenciales SMTP no configuradas');
        print('📧 Código de verificación para $recipientEmail: $verificationCode');
        print('⚠️ Por favor configura las credenciales en email_service.dart');
        // En desarrollo, retornamos true para que funcione el flujo
        return true;
      }

      // Configurar servidor SMTP
      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _senderEmail,
        password: _senderPassword,
        ssl: false,
        allowInsecure: true,
      );

      // Crear mensaje
      final message = Message()
        ..from = Address(_senderEmail, _senderName)
        ..recipients.add(recipientEmail)
        ..subject = 'Código de Verificación - Hospital System'
        ..html = _buildEmailHtml(
          recipientName: recipientName,
          verificationCode: verificationCode,
        );

      // Enviar correo
      final sendReport = await send(message, smtpServer);
      
      print('✅ Correo enviado exitosamente a: $recipientEmail');
      print('📧 Reporte: ${sendReport.toString()}');
      
      return true;
    } catch (e) {
      print('❌ Error al enviar correo: $e');
      // En desarrollo, mostrar el código en consola como fallback
      print('📧 Código de verificación para $recipientEmail: $verificationCode');
      return false;
    }
  }

  /// Construir HTML del correo
  String _buildEmailHtml({
    required String recipientName,
    required String verificationCode,
  }) {
    return '''
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Código de Verificación</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 30px;
            text-align: center;
            color: #ffffff;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
            font-weight: 600;
        }
        .content {
            padding: 40px 30px;
            text-align: center;
        }
        .greeting {
            font-size: 18px;
            color: #333333;
            margin-bottom: 20px;
        }
        .message {
            font-size: 16px;
            color: #666666;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .code-container {
            background-color: #f8f9fa;
            border: 2px dashed #667eea;
            border-radius: 8px;
            padding: 20px;
            margin: 30px 0;
        }
        .code {
            font-size: 36px;
            font-weight: bold;
            color: #667eea;
            letter-spacing: 8px;
            font-family: 'Courier New', monospace;
        }
        .expiry {
            font-size: 14px;
            color: #999999;
            margin-top: 15px;
        }
        .warning {
            background-color: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 20px 0;
            text-align: left;
        }
        .warning p {
            margin: 0;
            color: #856404;
            font-size: 14px;
        }
        .footer {
            background-color: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #999999;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏥 Hospital System</h1>
        </div>
        <div class="content">
            <p class="greeting">Hola, <strong>$recipientName</strong></p>
            <p class="message">
                Has solicitado recuperar tu contraseña. Usa el siguiente código de verificación para continuar:
            </p>
            <div class="code-container">
                <div class="code">$verificationCode</div>
                <p class="expiry">⏱️ Este código expira en 5 minutos</p>
            </div>
            <div class="warning">
                <p><strong>⚠️ Importante:</strong> Si no solicitaste este código, ignora este mensaje. Tu cuenta permanece segura.</p>
            </div>
        </div>
        <div class="footer">
            <p>Este es un correo automático, por favor no responder.</p>
            <p>&copy; 2025 Hospital System. Todos los derechos reservados.</p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  /// Enviar correo de notificación genérico
  Future<bool> sendNotification({
    required String recipientEmail,
    required String subject,
    required String htmlBody,
  }) async {
    try {
      if (_senderEmail == 'tu-correo@gmail.com' || 
          _senderPassword == 'tu-contraseña-de-aplicacion') {
        print('⚠️ ADVERTENCIA: Credenciales SMTP no configuradas');
        return false;
      }

      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _senderEmail,
        password: _senderPassword,
        ssl: false,
        allowInsecure: true,
      );

      final message = Message()
        ..from = Address(_senderEmail, _senderName)
        ..recipients.add(recipientEmail)
        ..subject = subject
        ..html = htmlBody;

      await send(message, smtpServer);
      print('✅ Notificación enviada a: $recipientEmail');
      
      return true;
    } catch (e) {
      print('❌ Error al enviar notificación: $e');
      return false;
    }
  }
}
