import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_state.dart';
import 'registro_screen.dart';
import 'restablecer_contrasena_screen.dart';
import 'inicio_sesion.dart';
import 'auth_service.dart';
import 'responsive_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _authService = AuthService();
  bool _cargando = false;
  bool _verContrasena = false;

  // ── Links de redes sociales ───────────────────────────────────────────────
  static const String _urlInstagram =
      'https://www.instagram.com/colombiago2026/';
  static const String _urlX = 'https://x.com/colombia_g61606';

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el enlace')));
      }
    }
  }

  Future<void> _iniciarSesion() async {
    if (_correoController.text.isEmpty || _contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa todos los campos')));
      return;
    }
    setState(() => _cargando = true);
    final error = await _authService.iniciarSesion(
      correo: _correoController.text.trim(),
      contrasena: _contrasenaController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _cargando = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (c) => const PantallaPrincipalScreen()));
    }
  }

  Future<void> _iniciarSesionGoogle() async {
    setState(() => _cargando = true);
    final error = await _authService.iniciarSesionConGoogle();
    if (!mounted) return;
    setState(() => _cargando = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (c) => const PantallaPrincipalScreen()));
    }
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
                      // Logo
                      Image.asset('assets/images/logo.png',
                          height: r.h * 0.18,
                          width: r.isDesktop ? 400 : r.w * 0.75,
                          fit: BoxFit.contain),

                      SizedBox(height: r.sp(r.h * 0.02)),

                      // Slogan
                      Text(
                        appState.t('slogan'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'LobsterTwo',
                          fontSize: r.fs(r.w * (r.isTablet ? 0.06 : 0.09)),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          color: dark ? Colors.white : Colors.black,
                          height: 1.2,
                        ),
                      ),

                      SizedBox(height: r.sp(r.h * 0.03)),

                      // Campo correo
                      TextField(
                        controller: _correoController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_cargando,
                        style: TextStyle(
                            color: dark ? Colors.white : Colors.black,
                            fontSize: r.fs(r.w * (r.isTablet ? 0.025 : 0.04))),
                        decoration: InputDecoration(
                          hintText: appState.t('correo'),
                          hintStyle: TextStyle(
                              fontSize:
                                  r.fs(r.w * (r.isTablet ? 0.022 : 0.035)),
                              fontWeight: FontWeight.w300,
                              color: dark ? Colors.white70 : Colors.black,
                              letterSpacing: 0.1),
                          filled: true,
                          fillColor: dark
                              ? Colors.white.withOpacity(0.15)
                              : Colors.white.withOpacity(0.70),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.5))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  const BorderSide(color: Colors.white)),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: r.h * 0.018, horizontal: r.w * 0.04),
                        ),
                      ),

                      SizedBox(height: r.h * 0.015),

                      // Campo contraseña
                      TextField(
                        controller: _contrasenaController,
                        obscureText: !_verContrasena,
                        enabled: !_cargando,
                        style: TextStyle(
                            color: dark ? Colors.white : Colors.black,
                            fontSize: r.fs(r.w * (r.isTablet ? 0.025 : 0.04))),
                        decoration: InputDecoration(
                          hintText: appState.t('contrasena'),
                          hintStyle: TextStyle(
                              fontSize:
                                  r.fs(r.w * (r.isTablet ? 0.022 : 0.035)),
                              fontWeight: FontWeight.w300,
                              color: dark ? Colors.white70 : Colors.black,
                              letterSpacing: 1.2),
                          filled: true,
                          fillColor: dark
                              ? Colors.white.withOpacity(0.15)
                              : Colors.white.withOpacity(0.70),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.5))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  const BorderSide(color: Colors.white)),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: r.h * 0.018, horizontal: r.w * 0.04),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _verContrasena
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: dark ? Colors.white60 : Colors.black54,
                              size: 22,
                            ),
                            onPressed: () => setState(
                                () => _verContrasena = !_verContrasena),
                          ),
                        ),
                      ),

                      SizedBox(height: r.sp(r.h * 0.025)),

                      // Botón Email
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cargando ? null : _iniciarSesion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 12, 78, 165),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: r.h * 0.02),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 4,
                          ),
                          child: _cargando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text(appState.t('iniciar_sesion'),
                                  style: TextStyle(
                                      fontSize: r.fs(
                                          r.w * (r.isTablet ? 0.025 : 0.04)),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.5)),
                        ),
                      ),

                      SizedBox(height: r.h * 0.015),

                      // Botón Google
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cargando ? null : _iniciarSesionGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dark
                                ? Colors.white.withOpacity(0.15)
                                : Colors.white.withOpacity(0.85),
                            foregroundColor: dark ? Colors.white : Colors.black,
                            padding:
                                EdgeInsets.symmetric(vertical: r.h * 0.015),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 2,
                          ),
                          child: _cargando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                      Text(appState.t('iniciar_google'),
                                          style: TextStyle(
                                              fontSize: r.fs(r.w *
                                                  (r.isTablet ? 0.022 : 0.035)),
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 1)),
                                      SizedBox(height: r.h * 0.005),
                                      Image.asset(
                                          'assets/images/google_logo.png',
                                          height: r.isTablet ? 30 : r.w * 0.07,
                                          width: r.isTablet ? 30 : r.w * 0.07),
                                    ]),
                        ),
                      ),

                      SizedBox(height: r.sp(r.h * 0.01)),

                      // Links
                      TextButton(
                        onPressed: _cargando
                            ? null
                            : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => const RegistroScreen())),
                        child: Text(appState.t('registrate'),
                            style: TextStyle(
                                fontFamily: 'LobsterTwo',
                                fontSize:
                                    r.fs(r.w * (r.isTablet ? 0.045 : 0.07)),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                                color: linkColor)),
                      ),
                      TextButton(
                        onPressed: _cargando
                            ? null
                            : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) =>
                                        const RestablecerContrasenaScreen())),
                        child: Text(appState.t('restablecer'),
                            style: TextStyle(
                                fontFamily: 'LobsterTwo',
                                fontSize:
                                    r.fs(r.w * (r.isTablet ? 0.045 : 0.07)),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                                color: linkColor)),
                      ),

                      SizedBox(height: r.sp(r.h * 0.01)),

                      // ── Redes sociales ────────────────────────────────────
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Instagram
                            GestureDetector(
                              onTap: () => _abrirUrl(_urlInstagram),
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: r.w * 0.02),
                                  child: Image.asset(
                                      'assets/images/logo_insta.png',
                                      height: r.isTablet ? 60 : r.w * 0.14,
                                      width: r.isTablet ? 60 : r.w * 0.14)),
                            ),
                            // X (Twitter)
                            GestureDetector(
                              onTap: () => _abrirUrl(_urlX),
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: r.w * 0.02),
                                  child: Image.asset(
                                      'assets/images/logo_x_elon.png',
                                      height: r.isTablet ? 40 : r.w * 0.09,
                                      width: r.isTablet ? 40 : r.w * 0.09)),
                            ),
                          ]),

                      SizedBox(height: r.h * 0.02),
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
}
