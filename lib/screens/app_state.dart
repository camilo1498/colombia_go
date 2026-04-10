import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  String _idioma = 'Español';
  bool _modoOscuro = false;
  bool _siguiendoSistema = true;

  // Notificaciones
  bool _notifPush = true;
  bool _notifEmail = false;
  bool _notifPromociones = true;

  // Preferencias
  String _tamanoFuente = 'Mediano';
  String _unidadDistancia = 'Kilómetros';

  // Getters
  String get idioma => _idioma;
  bool get modoOscuro => _modoOscuro;
  bool get siguiendoSistema => _siguiendoSistema;
  bool get esIngles => _idioma == 'English';
  bool get notifPush => _notifPush;
  bool get notifEmail => _notifEmail;
  bool get notifPromociones => _notifPromociones;
  String get tamanoFuente => _tamanoFuente;
  String get unidadDistancia => _unidadDistancia;

  // Factor de escala según tamaño de fuente
  double get fontScale {
    switch (_tamanoFuente) {
      case 'Pequeño':
        return 0.85;
      case 'Grande':
        return 1.2;
      default:
        return 1.0;
    }
  }

  // Cargar preferencias al iniciar
  Future<void> cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    _idioma = prefs.getString('idioma') ?? 'Español';
    _modoOscuro = prefs.getBool('modoOscuro') ?? false;
    _siguiendoSistema = prefs.getBool('siguiendoSistema') ?? true;
    _notifPush = prefs.getBool('notifPush') ?? true;
    _notifEmail = prefs.getBool('notifEmail') ?? false;
    _notifPromociones = prefs.getBool('notifPromociones') ?? true;
    _tamanoFuente = prefs.getString('tamanoFuente') ?? 'Mediano';
    _unidadDistancia = prefs.getString('unidadDistancia') ?? 'Kilómetros';
    notifyListeners();
  }

  void setIdioma(String nuevoIdioma) async {
    _idioma = nuevoIdioma;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idioma', nuevoIdioma);
  }

  void actualizarDesistema(Brightness brightness) {
    if (_siguiendoSistema) {
      _modoOscuro = brightness == Brightness.dark;
      notifyListeners();
    }
  }

  void setModoOscuro(bool valor) async {
    _siguiendoSistema = false;
    _modoOscuro = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modoOscuro', valor);
    await prefs.setBool('siguiendoSistema', false);
  }

  void seguirSistema(Brightness brightness) async {
    _siguiendoSistema = true;
    _modoOscuro = brightness == Brightness.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('siguiendoSistema', true);
  }

  void setNotifPush(bool valor) async {
    _notifPush = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifPush', valor);
  }

  void setNotifEmail(bool valor) async {
    _notifEmail = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifEmail', valor);
  }

  void setNotifPromociones(bool valor) async {
    _notifPromociones = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifPromociones', valor);
  }

  void setTamanoFuente(String valor) async {
    _tamanoFuente = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tamanoFuente', valor);
  }

  void setUnidadDistancia(String valor) async {
    _unidadDistancia = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unidadDistancia', valor);
  }

  static const Map<String, Map<String, String>> traducciones = {
    'Español': {
      // Login
      'slogan': 'TU PARCERO EN LA\nVUELTA TURISTICA',
      'correo': 'CORREO ELECTRONICO',
      'contrasena': 'CONTRASEÑA',
      'iniciar_sesion': 'INICIAR SESION',
      'iniciar_google': 'INICIAR SESION CON GOOGLE',
      'registrate': 'Registrate Aqui',
      'restablecer': 'Restablecer Contraseña',
      // Registro
      'crear_cuenta': 'CREAR CUENTA',
      'nombres': 'NOMBRES',
      'apellidos': 'APELLIDOS',
      'usuario': 'NOMBRE DE USUARIO/APODO',
      'registrarse': 'REGISTRARSE',
      'ya_tienes_cuenta': '¿Ya tienes cuenta?',
      'iniciar_sesion2': 'Iniciar sesion',
      // Restablecer
      'restablecer_titulo': 'Restablecer Contraseña',
      'escribe_correo':
          'Escribe tu correo\nelectrónico para poder\nrecibir tu código de\nverificación',
      'correo_electronico': 'Correo Electrónico',
      'codigo_verificacion': 'Ingrese el código de verificación',
      'continuar': 'CONTINUAR',
      // Inicio
      'gastronomia': 'Gastronomía',
      'turismo': 'Turismo',
      'cultura': 'Cultura',
      'bares': 'Bares y\ndiscotecas',
      'destino_recomendado': 'Destino Recomendado',
      // Drawer
      'inicio': 'Inicio',
      'bares_drawer': 'Bares y Discotecas',
      'mi_perfil': 'Mi Perfil',
      'configuracion': 'Configuración',
      // Mapas
      'explorar': 'EXPLORAR MÁS LUGARES',
      'volver_mapa': 'VOLVER AL MAPA',
      // Mi Perfil
      'perfil_titulo': 'Mi Perfil',
      'nombre_completo': 'Nombre Completo',
      'correo_perfil': 'Correo Electrónico',
      'telefono': 'Teléfono',
      'ciudad': 'Ciudad',
      'intereses': 'Intereses Turísticos',
      'toca_seleccionar': 'Toca para seleccionar/deseleccionar',
      'lugares_visitados': 'Lugares Visitados',
      'perfil_actualizado': 'Perfil actualizado',
      'galeria': 'Galería',
      'camara': 'Cámara',
      'eliminar_foto': 'Eliminar foto',
      // Lugares visitados
      'agregar_lugar': 'Agregar Lugar',
      'nombre_lugar': 'Nombre del Lugar',
      'departamento': 'Departamento',
      'agregar': 'Agregar',
      'sin_lugares': 'Aún no has agregado lugares visitados',
      // Configuracion
      'config_titulo': 'Configuración',
      'notificaciones': 'Notificaciones',
      'notif_push': 'Notificaciones Push',
      'notif_push_desc': 'Recibe alertas en tu dispositivo',
      'notif_email': 'Notificaciones por Email',
      'notif_email_desc': 'Recibe correos con novedades',
      'promociones': 'Promociones',
      'promociones_desc': 'Ofertas y descuentos especiales',
      'preferencias': 'Preferencias',
      'idioma': 'Idioma',
      'modo_oscuro': 'Modo Oscuro',
      'modo_oscuro_desc': 'Apariencia del tema',
      'tamano_fuente': 'Tamaño de Fuente',
      'unidad_distancia': 'Unidad de Distancia',
      'privacidad': 'Privacidad y Seguridad',
      'cambiar_pass': 'Cambiar Contraseña',
      'cambiar_pass_desc': 'Actualiza tu contraseña',
      'config_privacidad': 'Privacidad',
      'config_privacidad_desc': 'Controla quién ve tu información',
      'informacion': 'Información',
      'terminos': 'Términos y Condiciones',
      'terminos_desc': 'Lee nuestros términos',
      'politica': 'Política de Privacidad',
      'politica_desc': 'Cómo manejamos tus datos',
      'acerca': 'Acerca de',
      'version': 'Versión 1.0.0',
      'cerrar_sesion': 'Cerrar Sesión',
      'eliminar_cuenta': 'Eliminar cuenta',
      'funcion_desarrollo': 'Función en desarrollo',
      'config_actualizada': 'Configuración actualizada',
      'seleccionar_idioma': 'Seleccionar Idioma',
      'cancelar': 'Cancelar',
      'cerrar': 'Cerrar',
      'eliminar': 'Eliminar',
      'cerrar_sesion_confirm': '¿Estás seguro que deseas cerrar sesión?',
      'eliminar_cuenta_confirm':
          '¿Estás seguro que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
      'sesion_cerrada': 'Sesión cerrada',
      'error_imagen': 'Error al seleccionar imagen',
      // Botones Gastronomía
      'cat_cafes': 'Cafes y repostería',
      'cat_mercados': 'Mercados Gastronómicos',
      'cat_restaurantes_tipicos': 'Restaurantes típicos',
      'cat_restaurantes_inter': 'Rest. Internacionales',
      // Botones Turismo
      'cat_parques_naturales': 'Parques Naturales',
      'cat_monumentos': 'Monumentos',
      'cat_museos': 'Museos',
      'cat_playas': 'Playas y ríos',
      // Botones Cultura
      'cat_museos_cultura': 'Museos',
      'cat_teatros': 'Teatros y Cines',
      'cat_monumentos_hist': 'Monumentos históricos',
      'cat_parques_cult': 'Parques culturales',
      // Botones Bares
      'cat_bares': 'Bares',
      'cat_discotecas': 'Discotecas',
      'cat_karaokes': 'Karaokes',
      'cat_eventos': 'Eventos nocturnos',
    },
    'English': {
      // Login
      'slogan': 'YOUR BUDDY ON THE\nTOURIST TRIP',
      'correo': 'EMAIL ADDRESS',
      'contrasena': 'PASSWORD',
      'iniciar_sesion': 'SIGN IN',
      'iniciar_google': 'SIGN IN WITH GOOGLE',
      'registrate': 'Register Here',
      'restablecer': 'Reset Password',
      // Registro
      'crear_cuenta': 'CREATE ACCOUNT',
      'nombres': 'FIRST NAME',
      'apellidos': 'LAST NAME',
      'usuario': 'USERNAME/NICKNAME',
      'registrarse': 'REGISTER',
      'ya_tienes_cuenta': 'Already have an account?',
      'iniciar_sesion2': 'Sign in',
      // Restablecer
      'restablecer_titulo': 'Reset Password',
      'escribe_correo':
          'Enter your email\naddress to receive\nyour verification\ncode',
      'correo_electronico': 'Email Address',
      'codigo_verificacion': 'Enter the verification code',
      'continuar': 'CONTINUE',
      // Inicio
      'gastronomia': 'Gastronomy',
      'turismo': 'Tourism',
      'cultura': 'Culture',
      'bares': 'Bars &\nNightclubs',
      'destino_recomendado': 'Recommended Destination',
      // Drawer
      'inicio': 'Home',
      'bares_drawer': 'Bars & Nightclubs',
      'mi_perfil': 'My Profile',
      'configuracion': 'Settings',
      // Mapas
      'explorar': 'EXPLORE MORE PLACES',
      'volver_mapa': 'BACK TO MAP',
      // Mi Perfil
      'perfil_titulo': 'My Profile',
      'nombre_completo': 'Full Name',
      'correo_perfil': 'Email Address',
      'telefono': 'Phone',
      'ciudad': 'City',
      'intereses': 'Tourist Interests',
      'toca_seleccionar': 'Tap to select/deselect',
      'lugares_visitados': 'Visited Places',
      'perfil_actualizado': 'Profile updated',
      'galeria': 'Gallery',
      'camara': 'Camera',
      'eliminar_foto': 'Remove photo',
      // Lugares visitados
      'agregar_lugar': 'Add Place',
      'nombre_lugar': 'Place Name',
      'departamento': 'Department / State',
      'agregar': 'Add',
      'sin_lugares': 'No visited places added yet',
      // Configuracion
      'config_titulo': 'Settings',
      'notificaciones': 'Notifications',
      'notif_push': 'Push Notifications',
      'notif_push_desc': 'Receive alerts on your device',
      'notif_email': 'Email Notifications',
      'notif_email_desc': 'Receive emails with news',
      'promociones': 'Promotions',
      'promociones_desc': 'Special offers and discounts',
      'preferencias': 'Preferences',
      'idioma': 'Language',
      'modo_oscuro': 'Dark Mode',
      'modo_oscuro_desc': 'Theme appearance',
      'tamano_fuente': 'Font Size',
      'unidad_distancia': 'Distance Unit',
      'privacidad': 'Privacy and Security',
      'cambiar_pass': 'Change Password',
      'cambiar_pass_desc': 'Update your password',
      'config_privacidad': 'Privacy',
      'config_privacidad_desc': 'Control who sees your information',
      'informacion': 'Information',
      'terminos': 'Terms and Conditions',
      'terminos_desc': 'Read our terms',
      'politica': 'Privacy Policy',
      'politica_desc': 'How we handle your data',
      'acerca': 'About',
      'version': 'Version 1.0.0',
      'cerrar_sesion': 'Sign Out',
      'eliminar_cuenta': 'Delete account',
      'funcion_desarrollo': 'Feature under development',
      'config_actualizada': 'Settings updated',
      'seleccionar_idioma': 'Select Language',
      'cancelar': 'Cancel',
      'cerrar': 'Close',
      'eliminar': 'Delete',
      'cerrar_sesion_confirm': 'Are you sure you want to sign out?',
      'eliminar_cuenta_confirm':
          'Are you sure you want to delete your account? This action cannot be undone.',
      'sesion_cerrada': 'Signed out',
      'error_imagen': 'Error selecting image',
      // Botones Gastronomía
      'cat_cafes': 'Cafes & Bakeries',
      'cat_mercados': 'Gastronomic Markets',
      'cat_restaurantes_tipicos': 'Typical Restaurants',
      'cat_restaurantes_inter': 'Intl. Restaurants',
      // Botones Turismo
      'cat_parques_naturales': 'Natural Parks',
      'cat_monumentos': 'Monuments',
      'cat_museos': 'Museums',
      'cat_playas': 'Beaches & Rivers',
      // Botones Cultura
      'cat_museos_cultura': 'Museums',
      'cat_teatros': 'Theaters & Cinemas',
      'cat_monumentos_hist': 'Historic Monuments',
      'cat_parques_cult': 'Cultural Parks',
      // Botones Bares
      'cat_bares': 'Bars',
      'cat_discotecas': 'Nightclubs',
      'cat_karaokes': 'Karaokes',
      'cat_eventos': 'Night Events',
    },
  };

  String t(String key) {
    return traducciones[_idioma]?[key] ?? key;
  }
}
