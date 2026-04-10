import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'login_screen.dart';
import 'auth_service.dart';
import 'responsive_helper.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  final _authService = AuthService();
  bool _cargando = false;
  bool _verContrasena = false;
  bool _verConfirmarContrasena = false;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_nombresController.text.isEmpty ||
        _apellidosController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _contrasenaController.text.isEmpty ||
        _confirmarContrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa todos los campos')));
      return;
    }
    if (_contrasenaController.text.trim() !=
        _confirmarContrasenaController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Las contraseñas no coinciden'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    setState(() => _cargando = true);
    final error = await _authService.registrarUsuario(
      nombres: _nombresController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      correo: _correoController.text.trim(),
      contrasena: _contrasenaController.text.trim(),
    );
    setState(() => _cargando = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      // Mostrar diálogo de verificación en lugar de navegar directamente
      _mostrarDialogoVerificacion();
    }
  }

  void _mostrarDialogoVerificacion() {
    final appState = context.read<AppState>();
    final dark = appState.modoOscuro;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.mark_email_read,
                color: Color.fromARGB(255, 12, 78, 165), size: 28),
            const SizedBox(width: 10),
            Text(
              'Verifica tu correo',
              style: TextStyle(
                color: dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Te enviamos un correo de verificación a:\n\n${_correoController.text.trim()}\n\nRevisa tu bandeja de entrada (y la carpeta de spam) y haz clic en el enlace para activar tu cuenta.',
          style: TextStyle(
            color: dark ? Colors.white70 : Colors.black87,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // cierra diálogo
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (c) => const LoginScreen()));
            },
            child: const Text(
              'Ir a Iniciar Sesión',
              style: TextStyle(
                color: Color.fromARGB(255, 12, 78, 165),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dark = appState.modoOscuro;
    final r = R(context);
    final linkColor = dark ? Colors.yellow[200]! : Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
              dark
                  ? 'assets/images/fondo_noche.png'
                  : 'assets/images/fondo.jpeg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity),
          if (dark)
            Container(
                color: Colors.black.withOpacity(0.6),
                width: double.infinity,
                height: double.infinity),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: r.hPad, vertical: r.h * 0.02),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: r.maxW),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: r.h * 0.03),
                      Image.asset('assets/images/logo.png',
                          height: r.h * 0.15,
                          width: r.isTablet ? 250 : r.w * 0.6,
                          fit: BoxFit.contain),
                      SizedBox(height: r.h * 0.025),
                      Text(
                        appState.t('crear_cuenta'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: r.fs(r.w * (r.isTablet ? 0.045 : 0.07)),
                            fontWeight: FontWeight.w500,
                            color: dark ? Colors.white : Colors.black,
                            letterSpacing: 1.5),
                      ),
                      SizedBox(height: r.h * 0.025),
                      _buildField(_nombresController, 'NOMBRES/APODO', r, dark),
                      SizedBox(height: r.h * 0.02),
                      _buildField(_apellidosController, appState.t('APELLIDOS'),
                          r, dark),
                      SizedBox(height: r.h * 0.02),
                      _buildField(
                          _correoController, appState.t('CORREO'), r, dark,
                          email: true),
                      SizedBox(height: r.h * 0.02),
                      _buildFieldPassword(
                        _contrasenaController,
                        appState.t('CONTRASEÑA'),
                        r,
                        dark,
                        verTexto: _verContrasena,
                        onToggle: () =>
                            setState(() => _verContrasena = !_verContrasena),
                      ),
                      SizedBox(height: r.h * 0.02),
                      _buildFieldPassword(
                        _confirmarContrasenaController,
                        'CONFIRMAR CONTRASEÑA',
                        r,
                        dark,
                        verTexto: _verConfirmarContrasena,
                        onToggle: () => setState(() =>
                            _verConfirmarContrasena = !_verConfirmarContrasena),
                      ),
                      SizedBox(height: r.h * 0.03),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cargando ? null : _registrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 12, 78, 165),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: r.h * 0.02),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            elevation: 4,
                          ),
                          child: _cargando
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(appState.t('registrarse'),
                                  style: TextStyle(
                                      fontSize: r.fs(
                                          r.w * (r.isTablet ? 0.025 : 0.04)),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5)),
                        ),
                      ),
                      SizedBox(height: r.h * 0.04),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(appState.t('ya_tienes_cuenta'),
                            style: TextStyle(
                                fontFamily: 'LobsterTwo',
                                fontSize:
                                    r.fs(r.w * (r.isTablet ? 0.04 : 0.06)),
                                fontStyle: FontStyle.italic,
                                color: linkColor)),
                      ),
                      SizedBox(height: r.h * 0.02),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const LoginScreen())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.40),
                            foregroundColor: linkColor,
                            padding:
                                EdgeInsets.symmetric(vertical: r.h * 0.015),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            elevation: 2,
                          ),
                          child: Text(appState.t('Iniciar sesión'),
                              style: TextStyle(
                                  fontFamily: 'LobsterTwo',
                                  fontSize:
                                      r.fs(r.w * (r.isTablet ? 0.035 : 0.055)),
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                  color: linkColor)),
                        ),
                      ),
                      SizedBox(height: r.h * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller, String hint, R r, bool dark,
      {bool email = false}) {
    return Container(
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.left,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        style: TextStyle(
            color: dark ? Colors.white : Colors.black,
            fontSize: r.fs(r.w * (r.isTablet ? 0.022 : 0.035))),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(vertical: r.h * 0.016, horizontal: 24),
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: r.fs(r.w * (r.isTablet ? 0.022 : 0.035)),
              fontWeight: FontWeight.w500,
              color: dark ? Colors.white70 : Colors.black),
        ),
      ),
    );
  }

  Widget _buildFieldPassword(
    TextEditingController controller,
    String hint,
    R r,
    bool dark, {
    required bool verTexto,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !verTexto,
        textAlign: TextAlign.left,
        style: TextStyle(
            color: dark ? Colors.white : Colors.black,
            fontSize: r.fs(r.w * (r.isTablet ? 0.022 : 0.035))),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(vertical: r.h * 0.016, horizontal: 24),
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: r.fs(r.w * (r.isTablet ? 0.022 : 0.035)),
              fontWeight: FontWeight.w500,
              color: dark ? Colors.white70 : Colors.black),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                verTexto ? Icons.visibility : Icons.visibility_off,
                color: dark ? Colors.white60 : Colors.black54,
                size: 22,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ),
    );
  }
}
