import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _googleSignInInitialized = false;

  // ── INICIAR SESIÓN EMAIL/PASSWORD ──────────────────────────────────────────
  Future<String?> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      // Bloquear si no ha verificado el correo
      if (!result.user!.emailVerified) {
        await _auth.signOut();
        return 'Debes verificar tu correo antes de iniciar sesión. Revisa tu bandeja de entrada.';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'Usuario no encontrado';
      if (e.code == 'wrong-password') return 'Contraseña incorrecta';
      if (e.code == 'invalid-credential')
        return 'Correo o contraseña incorrectos';
      if (e.code == 'invalid-email')
        return 'El correo no tiene un formato válido';
      if (e.code == 'user-disabled') return 'Esta cuenta ha sido deshabilitada';
      return 'Error: ${e.message}';
    }
  }

  // ── INICIAR SESIÓN CON GOOGLE ──────────────────────────────────────────────
  Future<String?> iniciarSesionConGoogle() async {
    try {
      UserCredential result;

      if (kIsWeb) {
        // ── WEB: usa popup de Firebase directamente ──
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        result = await _auth.signInWithPopup(googleProvider);
      } else {
        // ── MOBILE (Android / iOS): usa google_sign_in v7 ──
        final googleSignIn = GoogleSignIn.instance;
        if (!_googleSignInInitialized) {
          await googleSignIn.initialize();
          _googleSignInInitialized = true;
        }

        final GoogleSignInAccount account;
        try {
          account = await googleSignIn.authenticate(
            scopeHint: ['email', 'profile'],
          );
        } on GoogleSignInException catch (_) {
          return 'Inicio cancelado';
        }

        final String? idToken = account.authentication.idToken;
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        result = await _auth.signInWithCredential(credential);
      }
      final user = result.user!;

      if (result.additionalUserInfo?.isNewUser ?? false) {
        final partes = (user.displayName ?? '').split(' ');
        final nombre = partes.isNotEmpty ? partes.first : '';
        final apellido = partes.length > 1 ? partes.skip(1).join(' ') : '';

        await _firestore.collection('USUARIO').doc(user.uid).set({
          'ID_USUARIO': user.uid,
          'NOMBRE': nombre,
          'APELLIDO': apellido,
          'CORREO': user.email ?? '',
          'TELEFONO': '',
          'CIUDAD': '',
          'INTERESES': [],
          'FOTO_URL': user.photoURL ?? '',
          'fechaCreacion': FieldValue.serverTimestamp(),
        });
      } else {
        // Usar set+merge en lugar de update para evitar error si el doc no existe
        await _firestore.collection('USUARIO').doc(user.uid).set({
          'FOTO_URL': user.photoURL ?? '',
        }, SetOptions(merge: true));
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user') return 'Inicio cancelado';
      if (e.code == 'account-exists-with-different-credential') {
        return 'Ya existe una cuenta con ese correo usando otro método';
      }
      return 'Error: ${e.message}';
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  // ── REGISTRAR USUARIO ──────────────────────────────────────────────────────
  Future<String?> registrarUsuario({
    required String nombres,
    required String apellidos,
    required String correo,
    required String contrasena,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      // Enviar correo de verificación
      await result.user!.sendEmailVerification();

      // Guardar datos en Firestore (cuenta creada pero pendiente de verificación)
      await _firestore.collection('USUARIO').doc(result.user!.uid).set({
        'ID_USUARIO': result.user!.uid,
        'NOMBRE': nombres,
        'APELLIDO': apellidos,
        'CORREO': correo,
        'TELEFONO': '',
        'CIUDAD': '',
        'INTERESES': [],
        'FOTO_URL': '',
        'verificado': false,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      // Cerrar sesión inmediatamente — debe verificar primero
      await _auth.signOut();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use')
        return 'El correo ya está registrado';
      if (e.code == 'weak-password')
        return 'La contraseña es muy débil (mínimo 6 caracteres)';
      if (e.code == 'invalid-email')
        return 'El correo no tiene un formato válido';
      return 'Error: ${e.message}';
    }
  }

  // ── CERRAR SESIÓN ──────────────────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // ── RESTABLECER CONTRASEÑA ─────────────────────────────────────────────────
  Future<String?> restablecerContrasena(String correo) async {
    try {
      await _auth.sendPasswordResetEmail(email: correo);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found')
        return 'No existe una cuenta con ese correo';
      if (e.code == 'invalid-email')
        return 'El correo no tiene un formato válido';
      return 'Error: ${e.message}';
    }
  }

  // ── ELIMINAR CUENTA ────────────────────────────────────────────────────────
  Future<String?> eliminarCuenta({String? contrasena}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 'No hay usuario autenticado';

      final esGoogle =
          currentUser.providerData.any((p) => p.providerId == 'google.com');

      // Reautenticar según el proveedor
      if (esGoogle) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        await currentUser.reauthenticateWithPopup(googleProvider);
      } else {
        if (contrasena == null || contrasena.isEmpty) {
          return 'Debes ingresar tu contraseña para confirmar';
        }
        final credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: contrasena,
        );
        await currentUser.reauthenticateWithCredential(credential);
      }

      final uid = currentUser.uid;

      // Eliminar documento de Firestore
      await _firestore.collection('USUARIO').doc(uid).delete();

      // Eliminar cuenta de Firebase Auth
      await currentUser.delete();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Contraseña incorrecta';
      }
      if (e.code == 'popup-closed-by-user') return 'Operación cancelada';
      if (e.code == 'requires-recent-login') {
        return 'Sesión expirada. Cierra sesión y vuelve a entrar.';
      }
      return 'Error: ${e.message}';
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  // ── USUARIO ACTUAL ─────────────────────────────────────────────────────────
  User? get usuarioActual => _auth.currentUser;
}
