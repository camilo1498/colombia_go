> **BrainSync Context Pumper** 🧠
> Dynamically loaded for active file: `lib/main.dart` (Domain: **Frontend (React/UI)**)

### 🔴 Frontend (React/UI) Gotchas
- **⚠️ GOTCHA: Fixed null crash in Inicio — prevents null/undefined runtime crashes**: -         }catch (e,s){
+         } catch (e,s){
-         }
+           return 'Inicio cancelado';
-         final String? idToken = account.authentication.idToken;
+         }
-         final credential = GoogleAuthProvider.credential(idToken: idToken);
+ 
-         result = await _auth.signInWithCredential(credential);
+         final String? idToken = account.authentication.idToken;
-       }
+         final credential = GoogleAuthProvider.credential(idToken: idToken);
-       final user = result.user!;
+         result = await _auth.signInWithCredential(credential);
- 
+       }
-       if (result.additionalUserInfo?.isNewUser ?? false) {
+       final user = result.user!;
-         final partes = (user.displayName ?? '').split(' ');
+ 
-         final nombre = partes.isNotEmpty ? partes.first : '';
+       if (result.additionalUserInfo?.isNewUser ?? false) {
-         final apellido = partes.length > 1 ? partes.skip(1).join(' ') : '';
+         final partes = (user.displayName ?? '').split(' ');
- 
+         final nombre = partes.isNotEmpty ? partes.first : '';
-         await _firestore.collection('USUARIO').doc(user.uid).set({
+         final apellido = partes.length > 1 ? partes.skip(1).join(' ') : '';
-           'ID_USUARIO': user.uid,
+ 
-           'NOMBRE': nombre,
+         await _firestore.collection('USUARIO').doc(user.uid).set({
-           'APELLIDO': apellido,
+           'ID_USUARIO': user.uid,
-           'CORREO': user.email ?? '',
+           'NOMBRE': nombre,
-           'TELEFONO': '',
+           'APELLIDO': apellido,
-           'CIUDAD': '',
+           'CORREO': user.email ?? '',
-           'INTERESES': [],
+           'TELEFONO': '',
-           'FOTO_URL': user.photoURL ?? '',
+           'CIUDAD': '',
-           'fechaCreacion': FieldValue.serverTimestamp(),
+           'INTERESES': [],
-         });
+           'FOTO_URL': user.photoURL ?? '',
-       } else {
+           'fechaCrea
… [diff truncated]

📌 IDE AST Context: Modified symbols likely include [AuthService]
- **⚠️ GOTCHA: Fixed null crash in String — prevents null/undefined runtime crashes**: -         }
+         }catch (e,s){
- 
+           print(e);
-         final String? idToken = account.authentication.idToken;
+           print(s);
-         final credential = GoogleAuthProvider.credential(idToken: idToken);
+         }
-         result = await _auth.signInWithCredential(credential);
+ 
-       }
+         final String? idToken = account.authentication.idToken;
-       final user = result.user!;
+         final credential = GoogleAuthProvider.credential(idToken: idToken);
- 
+         result = await _auth.signInWithCredential(credential);
-       if (result.additionalUserInfo?.isNewUser ?? false) {
+       }
-         final partes = (user.displayName ?? '').split(' ');
+       final user = result.user!;
-         final nombre = partes.isNotEmpty ? partes.first : '';
+ 
-         final apellido = partes.length > 1 ? partes.skip(1).join(' ') : '';
+       if (result.additionalUserInfo?.isNewUser ?? false) {
- 
+         final partes = (user.displayName ?? '').split(' ');
-         await _firestore.collection('USUARIO').doc(user.uid).set({
+         final nombre = partes.isNotEmpty ? partes.first : '';
-           'ID_USUARIO': user.uid,
+         final apellido = partes.length > 1 ? partes.skip(1).join(' ') : '';
-           'NOMBRE': nombre,
+ 
-           'APELLIDO': apellido,
+         await _firestore.collection('USUARIO').doc(user.uid).set({
-           'CORREO': user.email ?? '',
+           'ID_USUARIO': user.uid,
-           'TELEFONO': '',
+           'NOMBRE': nombre,
-           'CIUDAD': '',
+           'APELLIDO': apellido,
-           'INTERESES': [],
+           'CORREO': user.email ?? '',
-           'FOTO_URL': user.photoURL ?? '',
+           'TELEFONO': '',
-           'fechaCreacion': FieldValue.serverTimestamp(),
+           'CIUDAD': '',
-         });
+           'INTERESES': [],
-       } else {
+           'FOTO_URL': user.photoURL ?? '',
-         await _firestore.collection(
… [diff truncated]

📌 IDE AST Context: Modified symbols likely include [AuthService]

### 📐 Frontend (React/UI) Conventions & Fixes
- **[what-changed] Added API key auth authentication — leverages inheritance to reduce code dupl...**: - import 'package:firebase_core/firebase_core.dart';
+ import 'package:flutter/foundation.dart' show kIsWeb;
- import 'package:provider/provider.dart';
+ import 'package:firebase_core/firebase_core.dart';
- import 'screens/app_state.dart';
+ import 'package:provider/provider.dart';
- import 'screens/login_screen.dart';
+ import 'screens/app_state.dart';
- 
+ import 'screens/login_screen.dart';
- void main() async {
+ 
-   WidgetsFlutterBinding.ensureInitialized();
+ void main() async {
-   try {
+   WidgetsFlutterBinding.ensureInitialized();
-     await Firebase.initializeApp(
+   try {
-       options: const FirebaseOptions(
+     if (kIsWeb) {
-         apiKey: "[REDACTED]",
+       // Web necesita opciones explícitas
-         authDomain: "colombia-go-2.firebaseapp.com",
+       await Firebase.initializeApp(
-         projectId: "colombia-go-2",
+         options: const FirebaseOptions(
-         storageBucket: "colombia-go-2.firebasestorage.app",
+           apiKey: "[REDACTED]",
-         messagingSenderId: "1073933859036",
+           authDomain: "colombia-go-2.firebaseapp.com",
-         appId: "1:1073933859036:web:6afe3f69356033f9d6dc19",
+           projectId: "colombia-go-2",
-       ),
+           storageBucket: "colombia-go-2.firebasestorage.app",
-     );
+           messagingSenderId: "1073933859036",
-   } catch (e) {
+           appId: "1:1073933859036:web:6afe3f69356033f9d6dc19",
-     print('Firebase error: $e');
+         ),
-   }
+       );
- 
+     } else {
-   final appState = AppState();
+       // Android/iOS usa google-services.json / GoogleService-Info.plist automáticamente
-   await appState.cargarPreferencias();
+       await Firebase.initializeApp();
- 
+     }
-   runApp(
+   } catch (e) {
-     ChangeNotifierProvider.value(
+     print('Firebase error: $e');
-       value: appState,
+   }
-       child: const ColombiaGoApp(
… [diff truncated]

📌 IDE AST Context: Modified symbols likely include [main, ColombiaGoApp, _ColombiaGoAppState]
- **[what-changed] 🟢 Edited lib/screens/auth_service.dart (9 changes, 1min)**: Active editing session on lib/screens/auth_service.dart.
9 content changes over 1 minutes.
- **[what-changed] 🟢 Edited lib/screens/auth_service.dart (7 changes, 8min)**: Active editing session on lib/screens/auth_service.dart.
7 content changes over 8 minutes.
- **[problem-fix] Fixed null crash in Usar — prevents null/undefined runtime crashes**: -         await _firestore.collection('USUARIO').doc(user.uid).update({
+         // Usar set+merge en lugar de update para evitar error si el doc no existe
-           'FOTO_URL': user.photoURL ?? '',
+         await _firestore.collection('USUARIO').doc(user.uid).set({
-         });
+           'FOTO_URL': user.photoURL ?? '',
-       }
+         }, SetOptions(merge: true));
- 
+       }
-       return null;
+ 
-     } on FirebaseAuthException catch (e) {
+       return null;
-       if (e.code == 'popup-closed-by-user') return 'Inicio cancelado';
+     } on FirebaseAuthException catch (e) {
-       if (e.code == 'account-exists-with-different-credential') {
+       if (e.code == 'popup-closed-by-user') return 'Inicio cancelado';
-         return 'Ya existe una cuenta con ese correo usando otro método';
+       if (e.code == 'account-exists-with-different-credential') {
-       }
+         return 'Ya existe una cuenta con ese correo usando otro método';
-       return 'Error: ${e.message}';
+       }
-     } catch (e) {
+       return 'Error: ${e.message}';
-       return 'Error inesperado: $e';
+     } catch (e) {
-     }
+       return 'Error inesperado: $e';
-   }
+     }
- 
+   }
-   // ── REGISTRAR USUARIO ──────────────────────────────────────────────────────
+ 
-   Future<String?> registrarUsuario({
+   // ── REGISTRAR USUARIO ──────────────────────────────────────────────────────
-     required String nombres,
+   Future<String?> registrarUsuario({
-     required String apellidos,
+     required String nombres,
-     required String correo,
+     required String apellidos,
-     required String contrasena,
+     required String correo,
-   }) async {
+     required String contrasena,
-     try {
+   }) async {
-       UserCredential result = await _auth.createUserWithEmailAndPassword(
+     try {
-         email: correo,
+       UserCredential result = await _auth.createUserWithEmailAndPassword(
-       
… [diff truncated]

📌 IDE AST Context: Modified symbols likely include [AuthService]
- **[what-changed] 🟢 Edited lib/screens/auth_service.dart (18 changes, 19min)**: Active editing session on lib/screens/auth_service.dart.
18 content changes over 19 minutes.
- **[convention] Fixed null crash in GoogleSignInException — prevents null/undefined runtime c... — confirmed 4x**: -         } on GoogleSignInException catch (e,s) {
+         } on GoogleSignInException catch (_) {
-           print(e);
+           return 'Inicio cancelado';
-           print(s);
+         }
-           return 'Inicio cancelado';
+ 
-         } catch (e,s){
+         final String? idToken = account.authentication.idToken;
-           print(e);
+         final credential = GoogleAuthProvider.credential(idToken: idToken);
-           print(s);
+         result = await _auth.signInWithCredential(credential);
-           return 'Inicio cancelado';
+       }
- 
+       final user = result.user!;
-         }
+ 
- 
+       if (result.additionalUserInfo?.isNewUser ?? false) {
-         final String? idToken = account.authentication.idToken;
+         final partes = (user.displayName ?? '').split(' ');
-         final credential = GoogleAuthProvider.credential(idToken: idToken);
+         final nombre = partes.isNotEmpty ? partes.first : '';
-         result = await _auth.signInWithCredential(credential);
+         final apellido = partes.length > 1 ? partes.skip(1).join(' ') : '';
-       }
+ 
-       final user = result.user!;
+         await _firestore.collection('USUARIO').doc(user.uid).set({
- 
+           'ID_USUARIO': user.uid,
-       if (result.additionalUserInfo?.isNewUser ?? false) {
+           'NOMBRE': nombre,
-         final partes = (user.displayName ?? '').split(' ');
+           'APELLIDO': apellido,
-         final nombre = partes.isNotEmpty ? partes.first : '';
+           'CORREO': user.email ?? '',
-         final apellido = partes.length > 1 ? partes.skip(1).join(' ') : '';
+           'TELEFONO': '',
- 
+           'CIUDAD': '',
-         await _firestore.collection('USUARIO').doc(user.uid).set({
+           'INTERESES': [],
-           'ID_USUARIO': user.uid,
+           'FOTO_URL': user.photoURL ?? '',
-           'NOMBRE': nombre,
+           'fechaCreacion': FieldValue.serverTimestamp(),
-     
… [diff truncated]

📌 IDE AST Context: Modified symbols likely include [AuthService]
- **[convention] Fixed null crash in UserCredential — prevents null/undefined runtime crashes — confirmed 4x**: -       final GoogleAuthProvider googleProvider = GoogleAuthProvider();
+       UserCredential result;
-       googleProvider.addScope('email');
+ 
-       googleProvider.addScope('profile');
+       if (kIsWeb) {
-       googleProvider.setCustomParameters({'prompt': 'select_account'});
+         // ── WEB: usa popup de Firebase directamente ──
- 
+         final GoogleAuthProvider googleProvider = GoogleAuthProvider();
-       final UserCredential result = await _auth.signInWithPopup(googleProvider);
+         googleProvider.addScope('email');
-       final user = result.user!;
+         googleProvider.addScope('profile');
- 
+         googleProvider.setCustomParameters({'prompt': 'select_account'});
-       if (result.additionalUserInfo?.isNewUser ?? false) {
+         result = await _auth.signInWithPopup(googleProvider);
-         final partes = (user.displayName ?? '').split(' ');
+       } else {
-         final nombre = partes.isNotEmpty ? partes.first : '';
+         // ── MOBILE (Android / iOS): usa google_sign_in ──
-         final apellido = partes.length > 1 ? partes.skip(1).join(' ') : '';
+         final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
- 
+         final GoogleSignInAccount? account = await googleSignIn.signIn();
-         await _firestore.collection('USUARIO').doc(user.uid).set({
+         if (account == null) return 'Inicio cancelado';
-           'ID_USUARIO': user.uid,
+ 
-           'NOMBRE': nombre,
+         final GoogleSignInAuthentication googleAuth =
-           'APELLIDO': apellido,
+             await account.authentication;
-           'CORREO': user.email ?? '',
+         final credential = GoogleAuthProvider.credential(
-           'TELEFONO': '',
+           accessToken: googleAuth.accessToken,
-           'CIUDAD': '',
+           idToken: googleAuth.idToken,
-           'INTERESES': [],
+         );
-           'FOTO_URL': user.photoURL ?? '',
+         
… [diff truncated]

📌 IDE AST Context: Modified symbols likely include [AuthService]
- **[convention] what-changed in gastronomia.dart — confirmed 3x**: -                                                 Colors.white.withOpacity(0.25),
+                                                 Colors.white.withValues(alpha: .25),

📌 IDE AST Context: Modified symbols likely include [CategoriaRestaurante, CategoriaExtension, Restaurante, GastronomiaScreen, _GastronomiaScreenState]
- **[what-changed] Updated schema Colors — leverages inheritance to reduce code duplication**: -                                           color: Colors.white.withValues(alpha: .2),
+                                           color: Colors.white
-                                           borderRadius:
+                                               .withValues(alpha: .2),
-                                               BorderRadius.circular(8)),
+                                           borderRadius:
-                                       child: IconButton(
+                                               BorderRadius.circular(8)),
-                                           icon: const Icon(Icons.menu,
+                                       child: IconButton(
-                                               color: Colors.black87, size: 28),
+                                           icon: const Icon(Icons.menu,
-                                           onPressed: () => Scaffold.of(context)
+                                               color: Colors.black87, size: 28),
-                                               .openEndDrawer())),
+                                           onPressed: () => Scaffold.of(context)
-                                 ]))),
+                                               .openEndDrawer())),
-                   ]);
+                                 ]))),
-                 },
+                   ]);
-               )),
+                 },
-     );
+               )),
-   }
+     );
- 
+   }
-   Widget _buildMap(bool dark) => Container(
+ 
-       decoration: BoxDecoration(
+   Widget _buildMap(bool dark) => Container(
-           borderRadius: BorderRadius.circular(15),
+       decoration: BoxDecoration(
-           boxShadow: const [
+           borderRadius: BorderRadius.circular(15),
-             BoxShadow(
+           boxShadow: const [
-                 color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
+             BoxShadow(
-           ]),
+                 c
… [diff truncated]

📌 IDE AST Context: Modified symbols likely include [CategoriaRestaurante, CategoriaExtension, Restaurante, GastronomiaScreen, _GastronomiaScreenState]
- **[discovery] discovery in app_drawer.dart**: File updated (external): lib/screens/app_drawer.dart

Content summary (218 lines):
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
/// [pantallaActual] indica qué pantall
