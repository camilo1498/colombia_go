import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'login_screen.dart';
import 'mi_perfil.dart';
import 'configuracion.dart';
import 'gastronomia.dart';
import 'turismo.dart';
import 'cultura.dart';
import 'bares_y_discotecas.dart';
import 'inicio_sesion.dart';

/// Widget reutilizable del menú hamburguesa para todas las pantallas.
/// [pantallaActual] indica qué pantalla está activa para no navegar a sí misma.
class AppDrawer extends StatelessWidget {
  final String pantallaActual;

  const AppDrawer({super.key, required this.pantallaActual});

  static const String inicio = 'inicio';
  static const String gastronomia = 'gastronomia';
  static const String turismo = 'turismo';
  static const String cultura = 'cultura';
  static const String bares = 'bares';
  static const String despuesBares = 'despues_bares';
  static const String despuesCultura = 'despues_cultura';
  static const String despuesGastro = 'despues_gastronomia';
  static const String despuesTurismo = 'despues_turismo';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dark = appState.modoOscuro;

    return Drawer(
      child: Container(
        color: dark ? const Color(0xFF1e1e2e) : Colors.white,
        child: ListView(padding: EdgeInsets.zero, children: [
          // ── HEADER ──────────────────────────────────────────────────────
          DrawerHeader(
            decoration:
                const BoxDecoration(color: Color.fromARGB(246, 255, 187, 2)),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset('assets/images/logo.png',
                  height: 80,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.menu, size: 80, color: Colors.white)),
              const SizedBox(height: 20),
              const Text('Colombia GO',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ]),
          ),

          // ── NAVEGACIÓN ───────────────────────────────────────────────────
          _tile(
              Icons.home, appState.t('inicio'), dark, pantallaActual == inicio,
              () {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (c) => const PantallaPrincipalScreen()),
                (r) => false);
          }),
          _tile(Icons.restaurant, appState.t('gastronomia'), dark,
              pantallaActual == gastronomia || pantallaActual == despuesGastro,
              () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const GastronomiaScreen()));
          }),
          _tile(Icons.beach_access, appState.t('turismo'), dark,
              pantallaActual == turismo || pantallaActual == despuesTurismo,
              () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const TurismoScreen()));
          }),
          _tile(Icons.museum, appState.t('cultura'), dark,
              pantallaActual == cultura || pantallaActual == despuesCultura,
              () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const CulturaScreen()));
          }),
          _tile(Icons.nightlife, appState.t('bares_drawer'), dark,
              pantallaActual == bares || pantallaActual == despuesBares, () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => const BaresYDiscotecasScreen()));
          }),

          const Divider(),

          _tile(Icons.person, appState.t('mi_perfil'), dark, false, () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const MiPerfilScreen()));
          }),
          _tile(Icons.settings, appState.t('configuracion'), dark, false, () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const ConfiguracionScreen()));
          }),

          const Divider(),

          // ── CERRAR SESIÓN ────────────────────────────────────────────────
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            leading: Icon(Icons.logout,
                color: dark ? Colors.white70 : Colors.black87, size: 24),
            title: Text(appState.t('cerrar_sesion'),
                style: TextStyle(color: dark ? Colors.white : Colors.black87)),
            onTap: () => _mostrarDialogoCerrarSesion(context, appState),
          ),
        ]),
      ),
    );
  }

  Widget _tile(IconData icon, String title, bool dark, bool esActual,
      VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      leading: Icon(icon,
          color: esActual
              ? const Color.fromARGB(246, 255, 187, 2)
              : (dark ? Colors.white70 : Colors.black87)),
      title: Text(title,
          style: TextStyle(
              color: esActual
                  ? const Color.fromARGB(246, 255, 187, 2)
                  : (dark ? Colors.white : Colors.black87),
              fontWeight: esActual ? FontWeight.bold : FontWeight.normal)),
      onTap: esActual ? null : onTap,
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context, AppState appState) {
    final dark = appState.modoOscuro;
    final bgColor = dark ? Colors.grey[900]! : Colors.white;
    final textColor = dark ? Colors.white : Colors.black87;
    final subColor = dark ? Colors.grey[400]! : Colors.black54;

    // Guardamos el navigator ANTES de cerrar el drawer
    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Cerramos el drawer
    Navigator.pop(context);

    // Mostramos el diálogo usando el navigator raíz
    navigator.push(
      DialogRoute(
        context: navigator.context,
        builder: (ctx) => AlertDialog(
          backgroundColor: bgColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            const Icon(Icons.logout, color: Colors.red, size: 26),
            const SizedBox(width: 10),
            Text(appState.t('cerrar_sesion'),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ]),
          content: Text(
            appState.t('cerrar_sesion_confirm'),
            style: TextStyle(fontSize: 14, color: subColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(appState.t('cancelar'),
                  style: TextStyle(
                      color: dark ? Colors.grey[400] : Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                // Cerramos el diálogo
                Navigator.pop(ctx);
                // Cerramos sesión
                await FirebaseAuth.instance.signOut();
                // Mostramos snackbar y navegamos al login
                scaffoldMessenger.showSnackBar(SnackBar(
                    content: Text(appState.t('sesion_cerrada')),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2)));
                navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (c) => const LoginScreen()),
                    (r) => false);
              },
              child: Text(appState.t('cerrar_sesion'),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
