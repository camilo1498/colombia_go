import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_state.dart';
import 'responsive_helper.dart';
import 'favoritos_service.dart';

// ─── Mapa interés → icono ──────────────────────────────────────────────────
const Map<String, IconData> _interesIconos = {
  'Gastronomía': Icons.restaurant_rounded,
  'Cultura': Icons.museum_rounded,
  'Naturaleza': Icons.park_rounded,
  'Aventura': Icons.terrain_rounded,
  'Vida Nocturna': Icons.nightlife_rounded,
  'Historia': Icons.account_balance_rounded,
};

class MiPerfilScreen extends StatefulWidget {
  const MiPerfilScreen({super.key});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  final String? imagenPorDefecto = 'assets/images/foto_perfil.png';
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  bool _isEditing = false;
  bool _cargando = true;
  Uint8List? _imagenSeleccionada;
  String? _fotoUrl;
  String? _fotoBase64;
  final ImagePicker _picker = ImagePicker();

  static const String _prefKey = 'intereses_turisticos';

  Map<String, bool> interesesTuristicos = {
    'Gastronomía': false,
    'Cultura': false,
    'Naturaleza': false,
    'Aventura': false,
    'Vida Nocturna': false,
    'Historia': false,
  };

  List<Map<String, String>> _lugaresVisitados = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarInteresesLocales() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    if (stored != null) {
      final map = Map<String, bool>.from(jsonDecode(stored));
      if (mounted)
        setState(() => interesesTuristicos = {...interesesTuristicos, ...map});
    }
  }

  Future<void> _guardarInteresesLocales() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(interesesTuristicos));
  }

  Future<void> _cargarDatosUsuario() async {
    await _cargarInteresesLocales();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _cargando = false);
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('USUARIO')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nombreController.text =
              '${data['NOMBRE'] ?? ''} ${data['APELLIDO'] ?? ''}'.trim();
          _emailController.text = data['CORREO'] ?? user.email ?? '';
          _telefonoController.text = data['TELEFONO'] ?? '';
          _ciudadController.text = data['CIUDAD'] ?? '';
          _fotoBase64 = data['FOTO_BASE64'];
          _fotoUrl = (_fotoBase64 == null || _fotoBase64!.isEmpty)
              ? user.photoURL
              : null;
          if (data['INTERESES'] != null) {
            final intereses = Map<String, bool>.from(data['INTERESES']);
            interesesTuristicos = {...interesesTuristicos, ...intereses};
            _guardarInteresesLocales();
          }
          if (data['LUGARES_VISITADOS'] != null) {
            final raw = List<dynamic>.from(data['LUGARES_VISITADOS']);
            _lugaresVisitados =
                raw.map((e) => Map<String, String>.from(e as Map)).toList();
          }
          _cargando = false;
        });
      } else {
        setState(() {
          _emailController.text = user.email ?? '';
          _fotoUrl = user.photoURL;
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _guardarDatos(AppState appState) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final nombre = _nombreController.text.trim().split(' ');
      final nombres = nombre.first;
      final apellidos = nombre.length > 1 ? nombre.sublist(1).join(' ') : '';
      final Map<String, dynamic> datosActualizar = {
        'NOMBRE': nombres,
        'APELLIDO': apellidos,
        'TELEFONO': _telefonoController.text.trim(),
        'CIUDAD': _ciudadController.text.trim(),
        'INTERESES': interesesTuristicos,
        'LUGARES_VISITADOS': _lugaresVisitados,
      };
      if (_imagenSeleccionada != null) {
        datosActualizar['FOTO_BASE64'] = base64Encode(_imagenSeleccionada!);
        datosActualizar['FOTO_URL'] = '';
      }
      if (_imagenSeleccionada == null &&
          _fotoBase64 == null &&
          _fotoUrl == null) {
        datosActualizar['FOTO_BASE64'] = '';
        datosActualizar['FOTO_URL'] = '';
      }
      await Future.wait([
        FirebaseFirestore.instance
            .collection('USUARIO')
            .doc(user.uid)
            .update(datosActualizar),
        _guardarInteresesLocales(),
      ]);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(appState.t('perfil_actualizado')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al guardar: $e'), backgroundColor: Colors.red));
    }
  }

  void _toggleInteres(String interes) {
    if (_isEditing) {
      setState(
          () => interesesTuristicos[interes] = !interesesTuristicos[interes]!);
      _guardarInteresesLocales();
    }
  }

  // ─── ELIMINAR LUGAR — sincroniza corazón en mapas y cards ─────────────────
  Future<void> _eliminarLugar(int index) async {
    final nombre = _lugaresVisitados[index]['lugar'] ?? '';
    setState(() => _lugaresVisitados.removeAt(index));

    // 1. Elimina de favoritos en Firestore → el corazón se quita en mapas y cards
    await FavoritosService().eliminarFavorito(nombre);

    // 2. Actualiza LUGARES_VISITADOS en Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('USUARIO')
            .doc(user.uid)
            .update({'LUGARES_VISITADOS': _lugaresVisitados});
      }
    } catch (_) {}
  }

  // ─── MAPA lugar → departamento ────────────────────────────────────────────
  static const Map<String, String> _lugarDep = {
    'amazonas': 'Amazonas',
    'leticia': 'Amazonas',
    'medellín': 'Antioquia',
    'medellin': 'Antioquia',
    'guatapé': 'Antioquia',
    'guatape': 'Antioquia',
    'el peñol': 'Antioquia',
    'el penol': 'Antioquia',
    'santa fe de antioquia': 'Antioquia',
    'jericó': 'Antioquia',
    'jerico': 'Antioquia',
    'jardín': 'Antioquia',
    'jardin': 'Antioquia',
    'concordia': 'Antioquia',
    'fredonia': 'Antioquia',
    'envigado': 'Antioquia',
    'sabaneta': 'Antioquia',
    'barranquilla': 'Atlántico',
    'puerto colombia': 'Atlántico',
    'cartagena': 'Bolívar',
    'mompox': 'Bolívar',
    'mompós': 'Bolívar',
    'mompos': 'Bolívar',
    'islas del rosario': 'Bolívar',
    'isla barú': 'Bolívar',
    'isla baru': 'Bolívar',
    'villa de leyva': 'Boyacá',
    'tunja': 'Boyacá',
    'ráquira': 'Boyacá',
    'raquira': 'Boyacá',
    'sogamoso': 'Boyacá',
    'paipa': 'Boyacá',
    'duitama': 'Boyacá',
    'chiquinquirá': 'Boyacá',
    'chiquinquira': 'Boyacá',
    'lago de tota': 'Boyacá',
    'tota': 'Boyacá',
    'puente de boyacá': 'Boyacá',
    'puente de boyaca': 'Boyacá',
    'manizales': 'Caldas',
    'chinchiná': 'Caldas',
    'chinchina': 'Caldas',
    'florencia': 'Caquetá',
    'yopal': 'Casanare',
    'popayán': 'Cauca',
    'popayan': 'Cauca',
    'tierradentro': 'Cauca',
    'silvia': 'Cauca',
    'valledupar': 'Cesar',
    'nuquí': 'Chocó',
    'nuqui': 'Chocó',
    'bahía solano': 'Chocó',
    'bahia solano': 'Chocó',
    'capurganá': 'Chocó',
    'capurgana': 'Chocó',
    'quibdó': 'Chocó',
    'quibdo': 'Chocó',
    'montería': 'Córdoba',
    'monteria': 'Córdoba',
    'bogotá': 'Cundinamarca',
    'bogota': 'Cundinamarca',
    'monserrate': 'Cundinamarca',
    'zipaquirá': 'Cundinamarca',
    'zipaquira': 'Cundinamarca',
    'laguna de guatavita': 'Cundinamarca',
    'catedral de sal': 'Cundinamarca',
    'plaza bolívar': 'Cundinamarca',
    'plaza bolivar': 'Cundinamarca',
    'candelaria': 'Cundinamarca',
    'la candelaria': 'Cundinamarca',
    'parque nacional': 'Cundinamarca',
    'museo del oro': 'Cundinamarca',
    'museo botero': 'Cundinamarca',
    'museo nacional': 'Cundinamarca',
    'museo nacional de colombia': 'Cundinamarca',
    'teatro colón': 'Cundinamarca',
    'teatro colon': 'Cundinamarca',
    'teatro gaitán': 'Cundinamarca',
    'teatro gaitan': 'Cundinamarca',
    'jardín botánico': 'Cundinamarca',
    'jardin botanico': 'Cundinamarca',
    'simon bolivar': 'Cundinamarca',
    'simón bolívar': 'Cundinamarca',
    'parque simón bolívar': 'Cundinamarca',
    'parque simon bolivar': 'Cundinamarca',
    'usaquén': 'Cundinamarca',
    'usaquen': 'Cundinamarca',
    'paloquemao': 'Cundinamarca',
    'mercado de paloquemao': 'Cundinamarca',
    'andrés carne de res': 'Cundinamarca',
    'andres carne de res': 'Cundinamarca',
    'theatron': 'Cundinamarca',
    'salto de tequendama': 'Cundinamarca',
    'inírida': 'Guainía',
    'inirida': 'Guainía',
    'caño cristales': 'Meta',
    'cano cristales': 'Meta',
    'serranía de la macarena': 'Meta',
    'serrania de la macarena': 'Meta',
    'desierto de la tatacoa': 'Huila',
    'tatacoa': 'Huila',
    'neiva': 'Huila',
    'san agustín': 'Huila',
    'san agustin': 'Huila',
    'cabo de la vela': 'La Guajira',
    'punta gallinas': 'La Guajira',
    'riohacha': 'La Guajira',
    'palomino': 'La Guajira',
    'ciudad perdida': 'Magdalena',
    'santa marta': 'Magdalena',
    'minca': 'Magdalena',
    'parque tayrona': 'Magdalena',
    'tayrona': 'Magdalena',
    'ciénaga grande': 'Magdalena',
    'cienaga grande': 'Magdalena',
    'villavicencio': 'Meta',
    'pasto': 'Nariño',
    'laguna de la cocha': 'Nariño',
    'tumaco': 'Nariño',
    'santuario de las lajas': 'Nariño',
    'las lajas': 'Nariño',
    'cúcuta': 'Norte de Santander',
    'cucuta': 'Norte de Santander',
    'mocoa': 'Putumayo',
    'armenia': 'Quindío',
    'salento': 'Quindío',
    'valle de cocora': 'Quindío',
    'parque nacional del café': 'Quindío',
    'parque del café': 'Quindío',
    'pereira': 'Risaralda',
    'santa rosa de cabal': 'Risaralda',
    'san andrés': 'San Andrés',
    'san andres': 'San Andrés',
    'providencia': 'San Andrés',
    'bucaramanga': 'Santander',
    'barichara': 'Santander',
    'cañón del chicamocha': 'Santander',
    'chicamocha': 'Santander',
    'san gil': 'Santander',
    'socorro': 'Santander',
    'sincelejo': 'Sucre',
    'ibagué': 'Tolima',
    'ibague': 'Tolima',
    'nevado del ruiz': 'Tolima',
    'honda': 'Tolima',
    'cali': 'Valle del Cauca',
    'buenaventura': 'Valle del Cauca',
    'buga': 'Valle del Cauca',
    'mitú': 'Vaupés',
    'mitu': 'Vaupés',
    'puerto carreño': 'Vichada',
    'puerto carreno': 'Vichada',
  };

  String _sugerirDepartamento(String lugar) {
    if (lugar.isEmpty) return '';
    final lugarLower = lugar.toLowerCase().trim();
    if (_lugarDep.containsKey(lugarLower)) return _lugarDep[lugarLower]!;
    if (lugarLower.length >= 5) {
      for (final k in _lugarDep.keys) {
        if (k.startsWith(lugarLower)) return _lugarDep[k]!;
      }
    }
    return '';
  }

  // ─── MAPA lugar → imagePath ───────────────────────────────────────────────
  static const Map<String, String> _lugarImg = {
    'parque simón bolívar': 'assets/images/parque_simon_bolivar.jpg',
    'parque simon bolivar': 'assets/images/parque_simon_bolivar.jpg',
    'monserrate': 'assets/images/Monserrate.jpg',
    'plaza de bolívar': 'assets/images/plaza_simon_bolivar.jpg',
    'plaza de bolivar': 'assets/images/plaza_simon_bolivar.jpg',
    'playa el rodadero': 'assets/images/playa_rodadero.jpg',
    'rodadero': 'assets/images/playa_rodadero.jpg',
    'parque nacional': 'assets/images/parque_nacional.jpg',
    'amazonas': 'assets/images/amazonas.jpg',
    'cartagena': 'assets/images/cartagena.jpg',
    'ciudad perdida': 'assets/images/ciudad_perdida.jpg',
    'valle de cocora': 'assets/images/cocora.jpg',
    'cocora': 'assets/images/cocora.jpg',
    'ráquira': 'assets/images/raquira.png',
    'raquira': 'assets/images/raquira.png',
    'parque tayrona': 'assets/images/destino2_parque_tayrona.jpg',
    'tayrona': 'assets/images/destino2_parque_tayrona.jpg',
    'caño cristales': 'assets/images/destino1_cano_cristales.jpg',
    'cano cristales': 'assets/images/destino1_cano_cristales.jpg',
    'desierto de la tatacoa':
        'assets/images/destino3_desierto_de_la_tatacoa.jpg',
    'tatacoa': 'assets/images/destino3_desierto_de_la_tatacoa.jpg',
    'catedral primada': 'assets/images/la_catedral_primada.jpg',
    'casa de nariño': 'assets/images/casa_de_nariño.png',
    'casa de narino': 'assets/images/casa_de_nariño.png',
    'playa blanca': 'assets/images/playa_blanca.jpg',
    'andrés carne de res': 'assets/images/andres_carne_de_res.jpg',
    'andres carne de res': 'assets/images/andres_carne_de_res.jpg',
    'capitalino restaurante': 'assets/images/capitalino_restaurant.jpg',
    'hornitos': 'assets/images/hornitos.jpg',
    'central cevicheria': 'assets/images/central_cevicheria.jpg',
    'plaza paloquemao': 'assets/images/plaza_paloquemao.jpg',
    'mercado de paloquemao': 'assets/images/plaza_paloquemao.jpg',
    'paloquemao': 'assets/images/plaza_paloquemao.jpg',
    'la cabrera': 'assets/images/la_cabrera.jpg',
    'café san alberto': 'assets/images/cafe_san_alberto.jpg',
    'cafe san alberto': 'assets/images/cafe_san_alberto.jpg',
    'juan valdez café': 'assets/images/juan_valdez.jpg',
    'juan valdez cafe': 'assets/images/juan_valdez.jpg',
    'harry sasson': 'assets/images/harry_sasson.jpg',
    'museo del oro': 'assets/images/museo_del_oro.jpg',
    'museo botero': 'assets/images/museo_d_botero.jpg',
    'museo nacional': 'assets/images/museo_nacional_de_colombia.jpg',
    'teatro colón': 'assets/images/teatro_colon.jpg',
    'teatro colon': 'assets/images/teatro_colon.jpg',
    'teatro gaitán': 'assets/images/teatro_jorge_eliecer_gaitan.jpeg',
    'teatro gaitan': 'assets/images/teatro_jorge_eliecer_gaitan.jpeg',
    'teatro mayor': 'assets/images/teatro_Mayor_Julio_Mario_Santo_Domingo.jpg',
    'capitolio nacional': 'assets/images/capitolio_nacional.jpg',
    'theatron': 'assets/images/theatron.jpg',
    'el bembé': 'assets/images/el_bembe.jpg',
    'el bembe': 'assets/images/el_bembe.jpg',
    'vintrash': 'assets/images/vintrash2.png',
    'sonora social club': 'assets/images/sonora.jpg',
    'octava': 'assets/images/octava.jpg',
    'karaoke box': 'assets/images/karaoke_box.png',
    'armenia pub': 'assets/images/armenia_pub.png',
    'la villa bar': 'assets/images/la_viila_gastrobar.png',
    'video club': 'assets/images/video_club.jpg',
    'capital drinks': 'assets/images/karaoke_box.png',
    'la casa de la salsa': 'assets/images/la_casa_de_la_salsa.jpg',
    'el candelario': 'assets/images/el_calendario.jpg',
  };

  String _sugerirImagePath(String lugar) {
    final key = lugar.toLowerCase().trim();
    if (_lugarImg.containsKey(key)) return _lugarImg[key]!;
    for (final k in _lugarImg.keys) {
      if (key.contains(k) || k.contains(key)) return _lugarImg[k]!;
    }
    return '';
  }

  void _mostrarDialogoAgregarLugar(AppState appState) {
    final dark = appState.modoOscuro;
    final bgColor = dark ? Colors.grey[900]! : Colors.white;
    final textColor = dark ? Colors.white : Colors.black87;
    final subTextColor = dark ? Colors.grey[400]! : Colors.black54;
    const golden = Color(0xFFFFBB02);

    final lugarCtrl = TextEditingController();
    final depCtrl = TextEditingController();
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: bgColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: golden.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.add_location_alt,
                    color: golden, size: 24)),
            const SizedBox(width: 12),
            Text(appState.t('agregar_lugar'),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  height: 2,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFFBB02), Color(0xFFF5C400)]),
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              TextField(
                  controller: lugarCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: textColor),
                  onChanged: (val) {
                    final dep = _sugerirDepartamento(val);
                    if (dep.isNotEmpty)
                      setStateDialog(() => depCtrl.text = dep);
                  },
                  decoration: InputDecoration(
                    labelText: appState.t('nombre_lugar'),
                    labelStyle: TextStyle(color: subTextColor),
                    prefixIcon: const Icon(Icons.place_outlined, color: golden),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: golden, width: 2)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color:
                                dark ? Colors.grey[700]! : Colors.grey[300]!)),
                  )),
              const SizedBox(height: 16),
              TextField(
                  controller: depCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: appState.t('departamento'),
                    labelStyle: TextStyle(color: subTextColor),
                    prefixIcon: const Icon(Icons.map_outlined, color: golden),
                    suffixIcon: depCtrl.text.isNotEmpty
                        ? Tooltip(
                            message: appState.esIngles
                                ? 'Auto-suggested'
                                : 'Sugerido automáticamente',
                            child: const Icon(Icons.auto_awesome,
                                color: golden, size: 18))
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: golden, width: 2)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color:
                                dark ? Colors.grey[700]! : Colors.grey[300]!)),
                    helperText: appState.esIngles
                        ? '✨ Auto-filled if the place is recognized'
                        : '✨ Se completa automáticamente si el lugar es reconocido',
                    helperMaxLines: 2,
                    helperStyle: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic),
                  )),
              if (errorMsg != null) ...[
                const SizedBox(height: 12),
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200)),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                          child: Text(errorMsg!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13))),
                    ])),
              ],
              const SizedBox(height: 4),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(appState.t('cancelar'),
                    style: TextStyle(
                        color: dark ? Colors.grey[400] : Colors.black54))),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: golden,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12)),
                icon: const Icon(Icons.add_location_alt,
                    size: 18, color: Colors.white),
                label: Text(appState.t('agregar'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: () {
                  final lugar = lugarCtrl.text.trim();
                  if (lugar.isEmpty) {
                    setStateDialog(() => errorMsg = appState.esIngles
                        ? 'Please enter the place name.'
                        : 'Por favor ingresa el nombre del lugar.');
                    return;
                  }
                  final imagePath = _sugerirImagePath(lugar);
                  setState(() => _lugaresVisitados.add({
                        'lugar': lugar,
                        'departamento': depCtrl.text.trim(),
                        'imagePath': imagePath,
                      }));
                  Navigator.pop(ctx);
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarOpcionesImagen(AppState appState) async {
    showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
                child: Wrap(children: [
              ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: Color(0xFFFFC302)),
                  title: Text(appState.t('galeria')),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarImagen(ImageSource.gallery, appState);
                  }),
              ListTile(
                  leading:
                      const Icon(Icons.photo_camera, color: Color(0xFFFFC302)),
                  title: Text(appState.t('camara')),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarImagen(ImageSource.camera, appState);
                  }),
              if (_imagenSeleccionada != null ||
                  _fotoBase64 != null ||
                  _fotoUrl != null)
                ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text(appState.t('eliminar_foto')),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _imagenSeleccionada = null;
                        _fotoBase64 = null;
                        _fotoUrl = null;
                      });
                    }),
            ])));
  }

  Future<void> _seleccionarImagen(ImageSource source, AppState appState) async {
    try {
      final XFile? imagen = await _picker.pickImage(
          source: source, maxWidth: 512, maxHeight: 512, imageQuality: 75);
      if (imagen != null) {
        final bytes = await imagen.readAsBytes();
        setState(() {
          _imagenSeleccionada = bytes;
          _fotoBase64 = null;
          _fotoUrl = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('📸 Foto seleccionada — toca ✓ para guardar'),
            duration: Duration(seconds: 3)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(appState.t('error_imagen')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2)));
    }
  }

  void _mostrarVistaPrevia() {
    Widget imagenGrande;
    if (_imagenSeleccionada != null) {
      imagenGrande = Image.memory(_imagenSeleccionada!, fit: BoxFit.contain);
    } else if (_fotoBase64 != null && _fotoBase64!.isNotEmpty) {
      imagenGrande =
          Image.memory(base64Decode(_fotoBase64!), fit: BoxFit.contain);
    } else if (_fotoUrl != null && _fotoUrl!.isNotEmpty) {
      imagenGrande = Image.network(
          _fotoUrl!
              .replaceAll('=s96-c', '=s400-c')
              .replaceAll('=s50-c', '=s400-c'),
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) =>
              Image.asset(imagenPorDefecto!, fit: BoxFit.contain),
          loadingBuilder: (c, child, progress) => progress == null
              ? child
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white)));
    } else {
      imagenGrande = Image.asset(imagenPorDefecto!, fit: BoxFit.contain);
    }
    showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Stack(children: [
              Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxWidth: 400, maxHeight: 400),
                          child: imagenGrande))),
              Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30)),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 22)))),
            ])));
  }

  Widget _buildFotoPerfil() {
    Widget imageWidget;
    if (_imagenSeleccionada != null) {
      imageWidget = Image.memory(_imagenSeleccionada!,
          width: 126, height: 126, fit: BoxFit.cover);
    } else if (_fotoBase64 != null && _fotoBase64!.isNotEmpty) {
      imageWidget = Image.memory(base64Decode(_fotoBase64!),
          width: 126, height: 126, fit: BoxFit.cover);
    } else if (_fotoUrl != null && _fotoUrl!.isNotEmpty) {
      imageWidget = Image.network(
          _fotoUrl!
              .replaceAll('=s96-c', '=s200-c')
              .replaceAll('=s50-c', '=s200-c'),
          width: 126,
          height: 126,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Image.asset(imagenPorDefecto!,
              width: 126, height: 126, fit: BoxFit.cover),
          loadingBuilder: (c, child, progress) => progress == null
              ? child
              : const CircularProgressIndicator(strokeWidth: 2));
    } else {
      imageWidget = Image.asset(imagenPorDefecto!,
          width: 126, height: 126, fit: BoxFit.cover);
    }
    return ClipOval(child: imageWidget);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _ciudadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dark = appState.modoOscuro;
    final r = R(context);

    if (_cargando) {
      return Scaffold(
          body: Stack(children: [
        Image.asset(
            dark ? 'assets/images/fondo_noche.png' : 'assets/images/fondo.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity),
        const Center(child: CircularProgressIndicator(color: Colors.white)),
      ]));
    }

    return Scaffold(
      body: Stack(children: [
        Image.asset(
            dark ? 'assets/images/fondo_noche.png' : 'assets/images/fondo.jpeg',
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
            child: Center(
                child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: r.isDesktop ? 800 : double.infinity),
          child: Column(children: [
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: r.isDesktop ? 32 : 16, vertical: 8),
                child: Row(children: [
                  _headerBtn(Icons.arrow_back, () => Navigator.pop(context)),
                  Expanded(
                      child: Text(appState.t('perfil_titulo'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'LobsterTwo',
                              fontSize: r.fs(28),
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              shadows: const [
                                Shadow(
                                    offset: Offset(-1.5, -1.5),
                                    color: Colors.black),
                                Shadow(
                                    offset: Offset(1.5, 1.5),
                                    color: Colors.black),
                              ]))),
                  _headerBtn(_isEditing ? Icons.check : Icons.edit, () async {
                    if (_isEditing) await _guardarDatos(appState);
                    setState(() => _isEditing = !_isEditing);
                  }),
                ])),
            Expanded(
                child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: r.isDesktop
                      ? 48
                      : r.isTablet
                          ? 32
                          : 24),
              child: Column(children: [
                const SizedBox(height: 10),

                Stack(children: [
                  GestureDetector(
                      onTap: _mostrarVistaPrevia,
                      child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ]),
                          child: CircleAvatar(
                              radius: 63,
                              backgroundColor: Colors.grey[300],
                              child: _buildFotoPerfil()))),
                  if (_isEditing)
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFC302),
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2)),
                            child: IconButton(
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 20),
                                onPressed: () =>
                                    _mostrarOpcionesImagen(appState)))),
                ]),
                const SizedBox(height: 24),

                if (!_isEditing && _nombreController.text.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(_nombreController.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: r.fs(22),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 6,
                                    color: Colors.black54)
                              ]))),

                _buildInfoCard(Icons.person_outline,
                    appState.t('nombre_completo'), _nombreController, dark),
                const SizedBox(height: 12),
                _buildInfoCard(Icons.email_outlined,
                    appState.t('correo_perfil'), _emailController, dark,
                    keyboardType: TextInputType.emailAddress, enabled: false),
                const SizedBox(height: 12),
                _buildInfoCard(Icons.phone_outlined, appState.t('telefono'),
                    _telefonoController, dark,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildInfoCard(Icons.location_on_outlined, appState.t('ciudad'),
                    _ciudadController, dark),
                const SizedBox(height: 24),

                // ── Intereses Turísticos ──────────────────────────────────────
                _buildCard(
                    dark,
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFFFFBB02),
                                      Color(0xFFF5C400)
                                    ]),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.favorite_rounded,
                                    color: Colors.white, size: 18)),
                            const SizedBox(width: 10),
                            Text(appState.t('intereses'),
                                style: TextStyle(
                                    fontSize: r.fs(17),
                                    fontWeight: FontWeight.bold,
                                    color:
                                        dark ? Colors.white : Colors.black87)),
                            const Spacer(),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFFFBB02)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFFFBB02)
                                            .withOpacity(0.4))),
                                child: Text(
                                    '${interesesTuristicos.values.where((v) => v).length}/${interesesTuristicos.length}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFFBB02)))),
                          ]),
                          if (_isEditing) ...[
                            const SizedBox(height: 6),
                            Text(appState.t('toca_seleccionar'),
                                style: TextStyle(
                                    fontSize: r.fs(12),
                                    color: dark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontStyle: FontStyle.italic)),
                          ],
                          const SizedBox(height: 16),
                          GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.8,
                              children: interesesTuristicos.entries
                                  .map((e) => _buildInteresChip(
                                      e.key, e.value, dark, r))
                                  .toList()),
                        ])),
                const SizedBox(height: 24),

                // ── Lugares Visitados ─────────────────────────────────────────
                _buildCard(
                    dark,
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFFFFBB02),
                                      Color(0xFFF5C400)
                                    ]),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.place_rounded,
                                    color: Colors.white, size: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(appState.t('lugares_visitados'),
                                    style: TextStyle(
                                        fontSize: r.fs(17),
                                        fontWeight: FontWeight.bold,
                                        color: dark
                                            ? Colors.white
                                            : Colors.black87))),
                            if (_isEditing)
                              GestureDetector(
                                  onTap: () =>
                                      _mostrarDialogoAgregarLugar(appState),
                                  child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFFBB02),
                                                Color(0xFFF5C400)
                                              ]),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 20))),
                            if (!_isEditing &&
                                _lugaresVisitados.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFFFBB02)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFFFBB02)
                                              .withOpacity(0.4))),
                                  child: Text('${_lugaresVisitados.length}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFFFBB02)))),
                            ],
                          ]),
                          const SizedBox(height: 16),
                          if (_lugaresVisitados.isEmpty)
                            Center(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Column(children: [
                                      Icon(Icons.travel_explore_rounded,
                                          size: 40,
                                          color: dark
                                              ? Colors.grey[600]
                                              : Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      Text(appState.t('sin_lugares'),
                                          style: TextStyle(
                                              fontSize: r.fs(14),
                                              color: dark
                                                  ? Colors.grey[500]
                                                  : Colors.grey[500],
                                              fontStyle: FontStyle.italic)),
                                    ])))
                          else
                            ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _lugaresVisitados.length,
                                separatorBuilder: (_, __) => Divider(
                                    height: 20,
                                    color: dark ? Colors.grey[700] : null),
                                itemBuilder: (_, index) {
                                  final item = _lugaresVisitados[index];
                                  return _buildPlaceItem(
                                      item['lugar'] ?? '',
                                      item['departamento'] ?? '',
                                      item['imagePath'] ?? '',
                                      index,
                                      dark,
                                      r);
                                }),
                        ])),
                const SizedBox(height: 32),
              ]),
            )),
          ]),
        ))),
      ]),
    );
  }

  Widget _headerBtn(IconData icon, VoidCallback onTap) => Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8)),
      child: IconButton(
          icon: Icon(icon, color: Colors.black87, size: 24), onPressed: onTap));

  Widget _buildCard(bool dark, Widget child) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: dark
              ? Colors.grey[900]!.withOpacity(0.85)
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: child);

  Widget _buildInfoCard(IconData icon, String label,
          TextEditingController controller, bool dark,
          {TextInputType? keyboardType, bool enabled = true}) =>
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
              color: dark
                  ? Colors.grey[900]!.withOpacity(0.85)
                  : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]),
          child: Row(children: [
            Icon(icon,
                color: dark ? Colors.grey[400] : Colors.grey[700], size: 24),
            const SizedBox(width: 15),
            Expanded(
                child: TextField(
                    controller: controller,
                    enabled: _isEditing && enabled,
                    keyboardType: keyboardType,
                    style: TextStyle(
                        fontSize: 16,
                        color: dark ? Colors.white : Colors.black87,
                        fontWeight:
                            _isEditing ? FontWeight.normal : FontWeight.w500),
                    decoration: InputDecoration(
                        labelText: label,
                        labelStyle: TextStyle(
                            color: dark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12)))),
          ]));

  Widget _buildInteresChip(String label, bool isSelected, bool dark, R r) {
    final icono = _interesIconos[label] ?? Icons.star_rounded;
    return GestureDetector(
        onTap: () => _toggleInteres(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFFBB02), Color(0xFFF5C400)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : null,
            color: isSelected
                ? null
                : (dark ? Colors.grey[800] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (dark ? Colors.grey[600]! : Colors.grey[300]!),
                width: 1.5),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: const Color(0xFFFFBB02).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]
                : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icono,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (dark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(width: 6),
            Flexible(
                child: Text(label,
                    style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (dark ? Colors.white70 : Colors.black87),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: r.fs(12)),
                    overflow: TextOverflow.ellipsis)),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 14),
            ],
          ]),
        ));
  }

  Widget _buildPlaceItem(String lugar, String dep, String imagePath, int index,
          bool dark, R r) =>
      Row(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imagePath.isNotEmpty
                ? Image.asset(imagePath,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _placeholderIcon(dark))
                : _placeholderIcon(dark)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lugar,
              style: TextStyle(
                  fontSize: r.fs(15),
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white : Colors.black87)),
          if (dep.isNotEmpty)
            Text(dep,
                style: TextStyle(
                    fontSize: r.fs(13),
                    color: dark ? Colors.grey[400] : Colors.grey[600])),
        ])),
        if (_isEditing)
          GestureDetector(
              onTap: () => _eliminarLugar(index),
              child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.red, size: 18))),
      ]);

  Widget _placeholderIcon(bool dark) => Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
          color: dark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10)),
      child: Icon(Icons.place_rounded,
          color: dark ? Colors.grey[600] : Colors.grey[400], size: 26));
}
