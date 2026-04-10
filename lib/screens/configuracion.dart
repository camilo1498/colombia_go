import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_state.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  static const _golden = Color.fromARGB(246, 255, 187, 2);
  static const _goldenBorder = OutlineInputBorder(
    borderSide: BorderSide(color: _golden, width: 2),
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dark = appState.modoOscuro;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
              dark
                  ? 'assets/images/fondo_noche.png'
                  : 'assets/images/fondo.jpeg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (c, e, s) =>
                  Container(color: const Color(0xFF87CEEB))),
          if (dark)
            Container(
                color: Colors.black.withOpacity(0.6),
                width: double.infinity,
                height: double.infinity),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8)),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black87, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        appState.t('config_titulo'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'LobsterTwo',
                          fontSize: 28,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                                offset: Offset(-1.5, -1.5),
                                color: Colors.black),
                            Shadow(
                                offset: Offset(1.5, -1.5), color: Colors.black),
                            Shadow(
                                offset: Offset(1.5, 1.5), color: Colors.black),
                            Shadow(
                                offset: Offset(-1.5, 1.5), color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ]),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── NOTIFICACIONES ──
                          _buildSectionTitle(appState.t('notificaciones')),
                          const SizedBox(height: 10),
                          _buildCard(
                              dark,
                              Column(children: [
                                _buildSwitch(
                                    Icons.notifications_active_outlined,
                                    appState.t('notif_push'),
                                    appState.t('notif_push_desc'),
                                    appState.notifPush,
                                    dark, (v) {
                                  appState.setNotifPush(v);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              appState.t('config_actualizada')),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: Colors.green));
                                }),
                                const Divider(height: 1),
                                _buildSwitch(
                                    Icons.email_outlined,
                                    appState.t('notif_email'),
                                    appState.t('notif_email_desc'),
                                    appState.notifEmail,
                                    dark, (v) {
                                  appState.setNotifEmail(v);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              appState.t('config_actualizada')),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: Colors.green));
                                }),
                                const Divider(height: 1),
                                _buildSwitch(
                                    Icons.local_offer_outlined,
                                    appState.t('promociones'),
                                    appState.t('promociones_desc'),
                                    appState.notifPromociones,
                                    dark, (v) {
                                  appState.setNotifPromociones(v);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              appState.t('config_actualizada')),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: Colors.green));
                                }),
                              ])),

                          const SizedBox(height: 25),

                          // ── PREFERENCIAS ──
                          _buildSectionTitle(appState.t('preferencias')),
                          const SizedBox(height: 10),
                          _buildCard(
                              dark,
                              Column(children: [
                                _buildOption(
                                    Icons.language_outlined,
                                    appState.t('idioma'),
                                    appState.idioma,
                                    dark,
                                    () => _showIdiomaDialog(context, appState)),
                                const Divider(height: 1),
                                _buildSwitch(
                                    Icons.dark_mode_outlined,
                                    appState.t('modo_oscuro'),
                                    appState.t('modo_oscuro_desc'),
                                    appState.modoOscuro,
                                    dark, (v) {
                                  appState.setModoOscuro(v);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              appState.t('config_actualizada')),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: Colors.green));
                                }),
                                const Divider(height: 1),
                                _buildOption(
                                    Icons.text_fields_outlined,
                                    appState.t('tamano_fuente'),
                                    appState.tamanoFuente,
                                    dark,
                                    () => _showTamanoDialog(context, appState)),
                                const Divider(height: 1),
                                _buildOption(
                                    Icons.straighten_outlined,
                                    appState.t('unidad_distancia'),
                                    appState.unidadDistancia,
                                    dark,
                                    () => _showUnidadDialog(context, appState)),
                              ])),

                          const SizedBox(height: 25),

                          // ── PRIVACIDAD ──
                          _buildSectionTitle(appState.t('privacidad')),
                          const SizedBox(height: 10),
                          _buildCard(
                              dark,
                              Column(children: [
                                _buildOption(
                                    Icons.lock_outline,
                                    appState.t('cambiar_pass'),
                                    appState.t('cambiar_pass_desc'),
                                    dark,
                                    () => _showCambiarPasswordDialog(
                                        context, appState)),
                                const Divider(height: 1),
                                _buildOption(
                                    Icons.security_outlined,
                                    appState.t('config_privacidad'),
                                    appState.t('config_privacidad_desc'),
                                    dark,
                                    () => _showPrivacidadDialog(
                                        context, appState)),
                              ])),

                          const SizedBox(height: 25),

                          // ── INFORMACIÓN ──
                          _buildSectionTitle(appState.t('informacion')),
                          const SizedBox(height: 10),
                          _buildCard(
                              dark,
                              Column(children: [
                                _buildOption(
                                    Icons.description_outlined,
                                    appState.t('terminos'),
                                    appState.t('terminos_desc'),
                                    dark,
                                    () =>
                                        _showTerminosDialog(context, appState)),
                                const Divider(height: 1),
                                _buildOption(
                                    Icons.privacy_tip_outlined,
                                    appState.t('politica'),
                                    appState.t('politica_desc'),
                                    dark,
                                    () =>
                                        _showPoliticaDialog(context, appState)),
                                const Divider(height: 1),
                                _buildOption(
                                    Icons.info_outline,
                                    appState.t('acerca'),
                                    appState.t('version'),
                                    dark,
                                    () => _showAcercaDialog(context, appState)),
                              ])),

                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  elevation: 4),
                              onPressed: () =>
                                  _showLogoutDialog(context, appState),
                              icon:
                                  const Icon(Icons.logout, color: Colors.white),
                              label: Text(appState.t('cerrar_sesion'),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Center(
                              child: TextButton(
                            onPressed: () =>
                                _showDeleteDialog(context, appState),
                            child: Text(appState.t('eliminar_cuenta'),
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline)),
                          )),
                          const SizedBox(height: 30),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                      offset: Offset(1, 1), color: Colors.black, blurRadius: 2)
                ])),
      );

  Widget _buildCard(bool dark, Widget child) => Container(
        decoration: BoxDecoration(
          color: dark
              ? Colors.grey[900]!.withOpacity(0.85)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: child,
      );

  Widget _buildSwitch(IconData icon, String title, String subtitle, bool value,
          bool dark, ValueChanged<bool> onChanged) =>
      ListTile(
        leading: Icon(icon, color: dark ? Colors.grey[400] : Colors.grey[700]),
        title: Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: dark ? Colors.white : Colors.black87)),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontSize: 13,
                color: dark ? Colors.grey[400] : Colors.grey[600])),
        trailing:
            Switch(value: value, onChanged: onChanged, activeColor: _golden),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      );

  Widget _buildOption(IconData icon, String title, String subtitle, bool dark,
          VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, color: dark ? Colors.grey[400] : Colors.grey[700]),
        title: Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: dark ? Colors.white : Colors.black87)),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontSize: 13,
                color: dark ? Colors.grey[400] : Colors.grey[600])),
        trailing: Icon(Icons.chevron_right,
            color: dark ? Colors.grey[600] : Colors.grey[400]),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      );

  // ─── CAMBIAR CONTRASEÑA ───────────────────────────────────────────────────
  void _showCambiarPasswordDialog(BuildContext context, AppState appState) {
    final user = FirebaseAuth.instance.currentUser;
    final dark = appState.modoOscuro;
    final bgColor = dark ? Colors.grey[900]! : Colors.white;
    final textColor = dark ? Colors.white : Colors.black87;
    final subTextColor = dark ? Colors.grey[400]! : Colors.black54;

    final esGoogle =
        user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
    if (esGoogle) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: bgColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Image.asset('assets/images/google_logo.png', width: 28, height: 28),
            const SizedBox(width: 8),
            Text(appState.t('cambiar_pass'),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: dark
                    ? Colors.blue.withOpacity(0.15)
                    : const Color(0xFFF1F8FF),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: const Color(0xFF4285F4).withOpacity(0.3)),
              ),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFF4285F4), size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    appState.esIngles
                        ? 'Your account is linked to Google. Passwords are managed by Google, not by Colombia GO.'
                        : 'Tu cuenta está vinculada a Google. Las contraseñas son administradas por Google, no por Colombia GO.',
                    style: TextStyle(fontSize: 13, color: textColor),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Text(
              appState.esIngles
                  ? 'To change your password, visit your Google account settings.'
                  : 'Para cambiar tu contraseña, visita la configuración de tu cuenta de Google.',
              style: TextStyle(fontSize: 13, color: subTextColor),
              textAlign: TextAlign.center,
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(appState.t('cerrar'),
                  style: TextStyle(color: subTextColor)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon:
                  const Icon(Icons.open_in_new, color: Colors.white, size: 16),
              label: Text(
                appState.esIngles ? 'Go to Google' : 'Ir a Google',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final uri = Uri.parse('https://myaccount.google.com/security');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      );
      return;
    }

    final actualCtrl = TextEditingController();
    final nuevaCtrl = TextEditingController();
    final confirmarCtrl = TextEditingController();
    bool verActual = false;
    bool verNueva = false;
    bool verConfirmar = false;
    bool cargando = false;
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: bgColor,
          title: Row(children: [
            const Icon(Icons.lock_outline, color: _golden),
            const SizedBox(width: 8),
            Text(appState.t('cambiar_pass'),
                style: TextStyle(fontSize: 18, color: textColor)),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: actualCtrl,
                obscureText: !verActual,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: appState.esIngles
                      ? 'Current password'
                      : 'Contraseña actual',
                  labelStyle: TextStyle(color: subTextColor),
                  border: const OutlineInputBorder(),
                  focusedBorder: _goldenBorder,
                  prefixIcon: Icon(Icons.lock, color: subTextColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                        verActual ? Icons.visibility_off : Icons.visibility,
                        color: subTextColor),
                    onPressed: () =>
                        setStateDialog(() => verActual = !verActual),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nuevaCtrl,
                obscureText: !verNueva,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText:
                      appState.esIngles ? 'New password' : 'Nueva contraseña',
                  labelStyle: TextStyle(color: subTextColor),
                  border: const OutlineInputBorder(),
                  focusedBorder: _goldenBorder,
                  prefixIcon: Icon(Icons.lock_open, color: subTextColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                        verNueva ? Icons.visibility_off : Icons.visibility,
                        color: subTextColor),
                    onPressed: () => setStateDialog(() => verNueva = !verNueva),
                  ),
                  helperText: appState.esIngles
                      ? 'Minimum 6 characters'
                      : 'Mínimo 6 caracteres',
                  helperStyle: TextStyle(color: subTextColor),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmarCtrl,
                obscureText: !verConfirmar,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: appState.esIngles
                      ? 'Confirm new password'
                      : 'Confirmar nueva contraseña',
                  labelStyle: TextStyle(color: subTextColor),
                  border: const OutlineInputBorder(),
                  focusedBorder: _goldenBorder,
                  prefixIcon: Icon(Icons.lock_open, color: subTextColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                        verConfirmar ? Icons.visibility_off : Icons.visibility,
                        color: subTextColor),
                    onPressed: () =>
                        setStateDialog(() => verConfirmar = !verConfirmar),
                  ),
                ),
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                        child: Text(errorMsg!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13))),
                  ]),
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(
              onPressed: cargando ? null : () => Navigator.pop(ctx),
              child: Text(appState.t('cancelar'),
                  style:
                      TextStyle(color: dark ? Colors.grey[400] : Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _golden),
              onPressed: cargando
                  ? null
                  : () async {
                      final actual = actualCtrl.text.trim();
                      final nueva = nuevaCtrl.text.trim();
                      final confirmar = confirmarCtrl.text.trim();

                      if (actual.isEmpty ||
                          nueva.isEmpty ||
                          confirmar.isEmpty) {
                        setStateDialog(() => errorMsg = appState.esIngles
                            ? 'Please fill in all fields.'
                            : 'Por favor completa todos los campos.');
                        return;
                      }
                      if (nueva.length < 6) {
                        setStateDialog(() => errorMsg = appState.esIngles
                            ? 'New password must be at least 6 characters.'
                            : 'La nueva contraseña debe tener al menos 6 caracteres.');
                        return;
                      }
                      if (nueva != confirmar) {
                        setStateDialog(() => errorMsg = appState.esIngles
                            ? 'Passwords do not match.'
                            : 'Las contraseñas no coinciden.');
                        return;
                      }
                      if (nueva == actual) {
                        setStateDialog(() => errorMsg = appState.esIngles
                            ? 'New password must be different from the current one.'
                            : 'La nueva contraseña debe ser diferente a la actual.');
                        return;
                      }

                      setStateDialog(() {
                        cargando = true;
                        errorMsg = null;
                      });

                      try {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser == null) throw Exception('No user');
                        final credential = EmailAuthProvider.credential(
                            email: currentUser.email!, password: actual);
                        await currentUser
                            .reauthenticateWithCredential(credential);
                        await FirebaseAuth.instance.currentUser!.reload();
                        final freshUser = FirebaseAuth.instance.currentUser!;
                        await freshUser.updatePassword(nueva);

                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(appState.esIngles
                                  ? 'Password updated successfully!'
                                  : '¡Contraseña actualizada correctamente!'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3)));
                        }
                      } on FirebaseAuthException catch (e) {
                        String msg;
                        switch (e.code) {
                          case 'wrong-password':
                          case 'invalid-credential':
                            msg = appState.esIngles
                                ? 'Current password is incorrect.'
                                : 'La contraseña actual es incorrecta.';
                            break;
                          case 'too-many-requests':
                            msg = appState.esIngles
                                ? 'Too many attempts. Try again later.'
                                : 'Demasiados intentos. Intenta más tarde.';
                            break;
                          case 'requires-recent-login':
                            msg = appState.esIngles
                                ? 'Session expired. Please log out and log in again.'
                                : 'Sesión expirada. Por favor cierra sesión y vuelve a entrar.';
                            break;
                          case 'weak-password':
                            msg = appState.esIngles
                                ? 'Password is too weak. Use at least 6 characters.'
                                : 'Contraseña muy débil. Usa al menos 6 caracteres.';
                            break;
                          case 'network-request-failed':
                            msg = appState.esIngles
                                ? 'Network error. Check your connection.'
                                : 'Error de red. Verifica tu conexión.';
                            break;
                          default:
                            msg = appState.esIngles
                                ? 'Error: ${e.message}'
                                : 'Error: ${e.message}';
                        }
                        setStateDialog(() {
                          cargando = false;
                          errorMsg = msg;
                        });
                      } catch (e) {
                        setStateDialog(() {
                          cargando = false;
                          errorMsg = appState.esIngles
                              ? 'Unexpected error. Try again.'
                              : 'Error inesperado. Intenta de nuevo.';
                        });
                      }
                    },
              child: cargando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(appState.esIngles ? 'Update' : 'Actualizar',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PRIVACIDAD ───────────────────────────────────────────────────────────
  void _showPrivacidadDialog(BuildContext context, AppState appState) {
    final dark = appState.modoOscuro;
    final bgColor = dark ? Colors.grey[900]! : Colors.white;
    final textColor = dark ? Colors.white : Colors.black87;
    final subTextColor = dark ? Colors.grey[400]! : Colors.black54;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.security_outlined, color: _golden),
          const SizedBox(width: 8),
          Text(appState.t('config_privacidad'),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _privacidadItem(
              Icons.visibility_outlined,
              appState.esIngles
                  ? 'Profile visibility'
                  : 'Visibilidad del perfil',
              appState.esIngles
                  ? 'Only you can see your personal information.'
                  : 'Solo tú puedes ver tu información personal.',
              textColor,
              subTextColor),
          const SizedBox(height: 12),
          _privacidadItem(
              Icons.location_off_outlined,
              appState.esIngles ? 'Location' : 'Ubicación',
              appState.esIngles
                  ? 'Your location is only used to show nearby places.'
                  : 'Tu ubicación solo se usa para mostrarte lugares cercanos.',
              textColor,
              subTextColor),
          const SizedBox(height: 12),
          _privacidadItem(
              Icons.lock_outline,
              appState.esIngles ? 'Data protection' : 'Protección de datos',
              appState.esIngles
                  ? 'Your data is stored securely and is never shared with third parties.'
                  : 'Tus datos se almacenan de forma segura y nunca se comparten con terceros.',
              textColor,
              subTextColor),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appState.t('cerrar'),
                style: const TextStyle(color: _golden)),
          ),
        ],
      ),
    );
  }

  Widget _privacidadItem(IconData icon, String title, String desc,
          Color textColor, Color subColor) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: _golden, size: 22),
        const SizedBox(width: 10),
        Flexible(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
          const SizedBox(height: 2),
          Text(desc, style: TextStyle(fontSize: 12, color: subColor)),
        ])),
      ]);

  // ─── TÉRMINOS Y CONDICIONES ───────────────────────────────────────────────
  void _showTerminosDialog(BuildContext context, AppState appState) {
    final dark = appState.modoOscuro;
    final bgColor = dark ? Colors.grey[900]! : Colors.white;
    final textColor = dark ? Colors.white : Colors.black87;
    final subTextColor = dark ? Colors.grey[400]! : Colors.black54;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.description_outlined, color: _golden),
          const SizedBox(width: 8),
          Text(appState.t('terminos'),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ]),
        content: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                appState.esIngles
                    ? '1. Acceptance of Terms'
                    : '1. Aceptación de Términos',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(
                appState.esIngles
                    ? 'By using Colombia GO, you agree to these terms and conditions.'
                    : 'Al usar Colombia GO, aceptas estos términos y condiciones.',
                style: TextStyle(fontSize: 13, color: subTextColor)),
            const SizedBox(height: 12),
            Text(
                appState.esIngles
                    ? '2. Use of the App'
                    : '2. Uso de la Aplicación',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(
                appState.esIngles
                    ? 'Colombia GO is a tourism guide app for Colombia. Content is for informational purposes only.'
                    : 'Colombia GO es una guía turística de Colombia. El contenido es solo de carácter informativo.',
                style: TextStyle(fontSize: 13, color: subTextColor)),
            const SizedBox(height: 12),
            Text(appState.esIngles ? '3. User Account' : '3. Cuenta de Usuario',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(
                appState.esIngles
                    ? 'You are responsible for maintaining the confidentiality of your account credentials.'
                    : 'Eres responsable de mantener la confidencialidad de tus credenciales de acceso.',
                style: TextStyle(fontSize: 13, color: subTextColor)),
            const SizedBox(height: 12),
            Text(appState.esIngles ? '4. Modifications' : '4. Modificaciones',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(
                appState.esIngles
                    ? 'We reserve the right to modify these terms at any time.'
                    : 'Nos reservamos el derecho de modificar estos términos en cualquier momento.',
                style: TextStyle(fontSize: 13, color: subTextColor)),
            const SizedBox(height: 8),
            Text('© 2025 Colombia GO',
                style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                    fontStyle: FontStyle.italic)),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appState.t('cerrar'),
                style: const TextStyle(color: _golden)),
          ),
        ],
      ),
    );
  }

  // ─── POLÍTICA DE PRIVACIDAD ───────────────────────────────────────────────
  void _showPoliticaDialog(BuildContext context, AppState appState) {
    final dark = appState.modoOscuro;
    final bgColor = dark ? Colors.grey[900]! : Colors.white;
    final textColor = dark ? Colors.white : Colors.black87;
    final subTextColor = dark ? Colors.grey[400]! : Colors.black54;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.privacy_tip_outlined, color: _golden),
          const SizedBox(width: 8),
          Text(appState.t('politica'),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ]),
        content: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                appState.esIngles
                    ? '1. Information We Collect'
                    : '1. Información que Recopilamos',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(
                appState.esIngles
                    ? 'We collect name, email, and usage data to improve your experience.'
                    : 'Recopilamos nombre, correo y datos de uso para mejorar tu experiencia.',
                style: TextStyle(fontSize: 13, color: subTextColor)),
            const SizedBox(height: 12),
            Text(
                appState.esIngles
                    ? '2. How We Use Your Data'
                    : '2. Cómo Usamos tus Datos',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(
                appState.esIngles
                    ? 'Your data is used to personalize your experience and improve our services.'
                    : 'Tus datos se usan para personalizar tu experiencia y mejorar nuestros servicios.',
                style: TextStyle(fontSize: 13, color: subTextColor)),
            const SizedBox(height: 12),
            Text(appState.esIngles ? '3. Data Sharing' : '3. Compartir Datos',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(
                appState.esIngles
                    ? 'We do not sell or share your personal data with third parties.'
                    : 'No vendemos ni compartimos tus datos personales con terceros.',
                style: TextStyle(fontSize: 13, color: subTextColor)),
            const SizedBox(height: 12),
            Text(appState.esIngles ? '4. Security' : '4. Seguridad',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(
                appState.esIngles
                    ? 'We use Firebase to store your data securely with industry-standard encryption.'
                    : 'Usamos Firebase para almacenar tus datos de forma segura con cifrado estándar.',
                style: TextStyle(fontSize: 13, color: subTextColor)),
            const SizedBox(height: 8),
            Text('© 2025 Colombia GO',
                style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                    fontStyle: FontStyle.italic)),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appState.t('cerrar'),
                style: const TextStyle(color: _golden)),
          ),
        ],
      ),
    );
  }

  // ─── ACERCA DE ────────────────────────────────────────────────────────────
  void _showAcercaDialog(BuildContext context, AppState appState) {
    final dark = appState.modoOscuro;
    final bgColor = dark ? Colors.grey[900]! : Colors.white;
    final textColor = dark ? Colors.white : Colors.black87;
    final subTextColor = dark ? Colors.grey[400]! : Colors.black54;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/images/logo.png',
              height: 80,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.travel_explore, size: 80, color: _golden)),
          const SizedBox(height: 12),
          Text('Colombia GO!',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'LobsterTwo',
                  color: textColor)),
          const SizedBox(height: 4),
          Text(appState.t('version'),
              style: TextStyle(fontSize: 14, color: subTextColor)),
          const SizedBox(height: 12),
          Text(
            appState.esIngles
                ? 'Your buddy on the tourist trip. Discover gastronomy, tourism, culture and nightlife.'
                : 'Tu parcero en la vuelta turistica. Descubre gastronomía, turismo, cultura y vida nocturna.',
            style: TextStyle(fontSize: 13, color: subTextColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text('© 2025 Colombia GO',
              style: TextStyle(
                  fontSize: 12,
                  color: subTextColor,
                  fontStyle: FontStyle.italic)),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appState.t('cerrar'),
                style: const TextStyle(color: _golden)),
          ),
        ],
      ),
    );
  }

  // ─── ELIMINAR CUENTA ─────────────────────────────────────────────────────
  void _showDeleteDialog(BuildContext context, AppState appState) {
    final user = FirebaseAuth.instance.currentUser;
    final dark = appState.modoOscuro;
    final bgColor = dark ? Colors.grey[900]! : Colors.white;
    final textColor = dark ? Colors.white : Colors.black87;
    final subTextColor = dark ? Colors.grey[400]! : Colors.black54;
    final authService = AuthService();

    final esGoogle =
        user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
    final passCtrl = TextEditingController();
    bool verPass = false;
    bool cargando = false;
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: bgColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(appState.t('eliminar_cuenta'),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      dark ? Colors.red.withOpacity(0.15) : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade400, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          appState.esIngles
                              ? 'This action is irreversible. Your account and all your data will be permanently deleted.'
                              : 'Esta acción es irreversible. Tu cuenta y todos tus datos serán eliminados permanentemente.',
                          style: TextStyle(
                              fontSize: 13,
                              color: dark
                                  ? Colors.red.shade300
                                  : Colors.red.shade700),
                        ),
                      ),
                    ]),
              ),
              const SizedBox(height: 16),
              if (!esGoogle) ...[
                Text(
                  appState.esIngles
                      ? 'Enter your password to confirm:'
                      : 'Ingresa tu contraseña para confirmar:',
                  style: TextStyle(fontSize: 13, color: subTextColor),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passCtrl,
                  obscureText: !verPass,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: appState.esIngles ? 'Password' : 'Contraseña',
                    labelStyle: TextStyle(color: subTextColor),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock, color: subTextColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                          verPass ? Icons.visibility_off : Icons.visibility,
                          color: subTextColor),
                      onPressed: () => setStateDialog(() => verPass = !verPass),
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  appState.esIngles
                      ? 'You will be asked to confirm with your Google account.'
                      : 'Se te pedirá confirmar con tu cuenta de Google.',
                  style: TextStyle(fontSize: 13, color: subTextColor),
                  textAlign: TextAlign.center,
                ),
              ],
              if (errorMsg != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                        child: Text(errorMsg!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13))),
                  ]),
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(
              onPressed: cargando ? null : () => Navigator.pop(ctx),
              child: Text(appState.t('cancelar'),
                  style:
                      TextStyle(color: dark ? Colors.grey[400] : Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: cargando
                  ? null
                  : () async {
                      if (!esGoogle && passCtrl.text.trim().isEmpty) {
                        setStateDialog(() => errorMsg = appState.esIngles
                            ? 'Please enter your password.'
                            : 'Por favor ingresa tu contraseña.');
                        return;
                      }
                      setStateDialog(() {
                        cargando = true;
                        errorMsg = null;
                      });
                      final error = await authService.eliminarCuenta(
                        contrasena: esGoogle ? null : passCtrl.text.trim(),
                      );
                      if (!ctx.mounted) return;
                      if (error != null) {
                        setStateDialog(() {
                          cargando = false;
                          errorMsg = error;
                        });
                      } else {
                        Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(appState.esIngles
                                  ? 'Account deleted successfully.'
                                  : 'Cuenta eliminada correctamente.'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3)));
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const LoginScreen()),
                              (r) => false);
                        }
                      }
                    },
              child: cargando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      appState.esIngles ? 'Delete account' : 'Eliminar cuenta',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showIdiomaDialog(BuildContext context, AppState appState) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(appState.t('seleccionar_idioma')),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                RadioListTile<String>(
                    title: const Text('Español'),
                    value: 'Español',
                    groupValue: appState.idioma,
                    activeColor: _golden,
                    onChanged: (v) {
                      appState.setIdioma(v!);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Idioma cambiado a Español'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2)));
                    }),
                RadioListTile<String>(
                    title: const Text('English'),
                    value: 'English',
                    groupValue: appState.idioma,
                    activeColor: _golden,
                    onChanged: (v) {
                      appState.setIdioma(v!);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Language changed to English'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2)));
                    }),
              ]),
            ));
  }

  void _showTamanoDialog(BuildContext context, AppState appState) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(appState.t('tamano_fuente')),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: ['Pequeño', 'Mediano', 'Grande']
                      .map((t) => RadioListTile<String>(
                          title: Text(t),
                          value: t,
                          groupValue: appState.tamanoFuente,
                          activeColor: _golden,
                          onChanged: (v) {
                            appState.setTamanoFuente(v!);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(appState.t('config_actualizada')),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2)));
                          }))
                      .toList()),
            ));
  }

  void _showUnidadDialog(BuildContext context, AppState appState) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(appState.t('unidad_distancia')),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: ['Kilómetros', 'Millas']
                      .map((u) => RadioListTile<String>(
                          title: Text(u),
                          value: u,
                          groupValue: appState.unidadDistancia,
                          activeColor: _golden,
                          onChanged: (v) {
                            appState.setUnidadDistancia(v!);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(appState.t('config_actualizada')),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2)));
                          }))
                      .toList()),
            ));
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(appState.t('cerrar_sesion')),
              content: Text(appState.t('cerrar_sesion_confirm')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(appState.t('cancelar'))),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(appState.t('sesion_cerrada')),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2)));
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const LoginScreen()),
                          (r) => false);
                    }
                  },
                  child: Text(appState.t('cerrar_sesion'),
                      style: const TextStyle(color: Colors.red)),
                ),
              ],
            ));
  }
}
