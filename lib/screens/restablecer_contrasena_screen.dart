import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'login_screen.dart';
import 'auth_service.dart';
import 'responsive_helper.dart';

class RestablecerContrasenaScreen extends StatefulWidget {
  const RestablecerContrasenaScreen({super.key});

  @override
  State<RestablecerContrasenaScreen> createState() =>
      _RestablecerContrasenaScreenState();
}

class _RestablecerContrasenaScreenState
    extends State<RestablecerContrasenaScreen> {
  final _correoController = TextEditingController();
  final _authService = AuthService();
  bool _cargando = false;
  bool _correoEnviado = false;

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _enviarCorreo() async {
    if (_correoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escribe tu correo electrónico')));
      return;
    }
    setState(() => _cargando = true);
    final error =
        await _authService.restablecerContrasena(_correoController.text.trim());
    if (!mounted) return;
    setState(() => _cargando = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
    } else {
      setState(() => _correoEnviado = true);
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: r.h * 0.03),

                      // Logo
                      Image.asset('assets/images/logo.png',
                          width: r.isTablet ? 280 : r.w * 0.75,
                          height: r.h * 0.2,
                          fit: BoxFit.contain),

                      SizedBox(height: r.h * 0.01),

                      // Slogan
                      Text(
                        appState.t('slogan'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'LobsterTwo',
                            fontSize: r.fs(r.isTablet ? 28 : 35),
                            color: dark ? Colors.white : Colors.black,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                            height: 1.1),
                      ),

                      SizedBox(height: r.h * 0.02),

                      // Título
                      Text(
                        appState.t('restablecer_titulo'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'LobsterTwo',
                            fontSize: r.fs(r.w * (r.isTablet ? 0.04 : 0.065)),
                            fontStyle: FontStyle.italic,
                            color: dark ? Colors.yellow[200] : Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: const [
                              Shadow(
                                  offset: Offset(-1.5, -1.5),
                                  color: Colors.black),
                              Shadow(
                                  offset: Offset(1.5, -1.5),
                                  color: Colors.black),
                              Shadow(
                                  offset: Offset(1.5, 1.5),
                                  color: Colors.black),
                              Shadow(
                                  offset: Offset(-1.5, 1.5),
                                  color: Colors.black),
                            ]),
                      ),

                      SizedBox(height: r.h * 0.03),

                      // ── Estado: correo enviado ──
                      if (_correoEnviado) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: r.w * 0.05, vertical: r.h * 0.03),
                          decoration: BoxDecoration(
                            color: dark
                                ? Colors.green.withOpacity(0.25)
                                : Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.green.shade400, width: 1.5),
                          ),
                          child: Column(children: [
                            Icon(Icons.mark_email_read_outlined,
                                size: r.isTablet ? 60 : r.w * 0.14,
                                color: Colors.green.shade400),
                            SizedBox(height: r.h * 0.015),
                            Text('¡Correo enviado!',
                                style: TextStyle(
                                    fontFamily: 'LobsterTwo',
                                    fontSize: r
                                        .fs(r.w * (r.isTablet ? 0.035 : 0.055)),
                                    color: dark
                                        ? Colors.green.shade300
                                        : Colors.green.shade700,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: r.h * 0.01),
                            Text(
                                'Revisa tu bandeja de entrada y sigue el enlace para restablecer tu contraseña.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: r
                                        .fs(r.w * (r.isTablet ? 0.024 : 0.038)),
                                    color:
                                        dark ? Colors.white70 : Colors.black87,
                                    height: 1.4)),
                            SizedBox(height: r.h * 0.015),
                            Text('¿No llegó? Revisa tu carpeta de spam.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize:
                                        r.fs(r.w * (r.isTablet ? 0.02 : 0.033)),
                                    color:
                                        dark ? Colors.white54 : Colors.black54,
                                    fontStyle: FontStyle.italic)),
                          ]),
                        ),
                        SizedBox(height: r.h * 0.04),
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _correoEnviado = false;
                            _correoController.clear();
                          }),
                          icon: Icon(Icons.refresh, color: linkColor),
                          label: Text('Intentar con otro correo',
                              style: TextStyle(
                                  color: linkColor,
                                  fontSize:
                                      r.fs(r.w * (r.isTablet ? 0.025 : 0.04)),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],

                      // ── Estado: formulario ──
                      if (!_correoEnviado) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: r.w * 0.04, vertical: r.h * 0.012),
                          decoration: BoxDecoration(
                            color: dark
                                ? Colors.white.withOpacity(0.15)
                                : Colors.white.withOpacity(0.70),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Text(appState.t('escribe_correo'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize:
                                      r.fs(r.w * (r.isTablet ? 0.024 : 0.038)),
                                  color: dark ? Colors.white : Colors.black87,
                                  height: 1.3)),
                        ),

                        SizedBox(height: r.h * 0.03),

                        // ── Campo correo con ícono mejorado y texto centrado ──
                        TextField(
                          controller: _correoController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_cargando,
                          style: TextStyle(
                              color: dark ? Colors.white : Colors.black87,
                              fontSize:
                                  r.fs(r.w * (r.isTablet ? 0.025 : 0.04))),
                          decoration: InputDecoration(
                            hintText: appState.t('correo_electronico'),
                            hintStyle: TextStyle(
                                color: dark ? Colors.white70 : Colors.black87,
                                fontSize:
                                    r.fs(r.w * (r.isTablet ? 0.025 : 0.04))),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: dark
                                ? Colors.white.withOpacity(0.15)
                                : Colors.white.withOpacity(0.70),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 13),
                            // ícono mejorado
                            prefixIcon: const Icon(
                              Icons.email_rounded,
                              size: 22,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            // espejo invisible para centrar el hint
                            suffixIcon: const SizedBox(width: 44),
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                          ),
                        ),

                        SizedBox(height: r.h * 0.04),

                        // ── BOTÓN CONTINUAR ──
                        _cargando
                            ? SizedBox(
                                width: r.w * 0.06,
                                height: r.w * 0.06,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: linkColor))
                            : TextButton(
                                onPressed: _enviarCorreo,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: r.h * 0.015),
                                ),
                                child: Text('Continuar',
                                    style: TextStyle(
                                        fontFamily: 'LobsterTwo',
                                        fontSize: r.fs(
                                            r.w * (r.isTablet ? 0.05 : 0.075)),
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w400,
                                        color: linkColor)),
                              ),
                      ],

                      SizedBox(height: r.h * 0.04),

                      // ── BOTÓN INICIAR SESIÓN ──
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
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text('Iniciar sesión',
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
}
