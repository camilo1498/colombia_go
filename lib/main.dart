import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/app_state.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      // Web necesita opciones explícitas
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDKrUtLpDg_rC6U93_Q4CjAbXGw6GA-uAk",
          authDomain: "colombia-go-2.firebaseapp.com",
          projectId: "colombia-go-2",
          storageBucket: "colombia-go-2.firebasestorage.app",
          messagingSenderId: "1073933859036",
          appId: "1:1073933859036:web:6afe3f69356033f9d6dc19",
        ),
      );
    } else {
      // Android/iOS usa google-services.json / GoogleService-Info.plist automáticamente
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Firebase error: $e');
  }

  final appState = AppState();
  await appState.cargarPreferencias();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const ColombiaGoApp(),
    ),
  );
}

class ColombiaGoApp extends StatefulWidget {
  const ColombiaGoApp({super.key});

  @override
  State<ColombiaGoApp> createState() => _ColombiaGoAppState();
}

class _ColombiaGoAppState extends State<ColombiaGoApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      context.read<AppState>().actualizarDesistema(brightness);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    context.read<AppState>().actualizarDesistema(brightness);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(appState.fontScale),
      ),
      child: MaterialApp(
        title: 'Colombia GO!',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
