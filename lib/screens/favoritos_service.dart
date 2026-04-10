import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritosService {
  static final FavoritosService _instance = FavoritosService._internal();
  factory FavoritosService() => _instance;
  FavoritosService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _favRef {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('favoritos').doc(uid).collection('lugares');
  }

  DocumentReference<Map<String, dynamic>>? get _usuarioRef {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('USUARIO').doc(uid);
  }

  String _docId(String nombre) =>
      nombre.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9áéíóúüñ]'), '_');

  // ─────────────────────────────────────────────────────────────────────────
  // Mapa lugar → imagePath (nombres exactos del pubspec.yaml)
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, String> _lugarImg = {
    // Turismo
    'monserrate': 'assets/images/Monserrate.jpg',
    'cerro de monserrate': 'assets/images/Monserrate.jpg',
    'parque simón bolívar': 'assets/images/parque_simon_bolivar.jpg',
    'parque simon bolivar': 'assets/images/parque_simon_bolivar.jpg',
    'plaza de bolívar': 'assets/images/plaza_simon_bolivar.jpg',
    'plaza de bolivar': 'assets/images/plaza_simon_bolivar.jpg',
    'playa el rodadero': 'assets/images/playa_rodadero.jpg',
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
    // Gastronomía
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
    // Cultura
    'museo del oro': 'assets/images/museo_del_oro.jpg',
    'museo botero': 'assets/images/museo_d_botero.jpg',
    'museo de la moneda': 'assets/images/museo_de_la_moneda.jpg',
    'museo nacional': 'assets/images/museo_nacional_de_colombia.jpg',
    'museo nacional de colombia':
        'assets/images/museo_nacional_de_colombia.jpg',
    'teatro colón': 'assets/images/teatro_colon.jpg',
    'teatro colon': 'assets/images/teatro_colon.jpg',
    'teatro gaitán': 'assets/images/teatro_jorge_eliecer_gaitan.jpeg',
    'teatro gaitan': 'assets/images/teatro_jorge_eliecer_gaitan.jpeg',
    'teatro jorge eliécer gaitán':
        'assets/images/teatro_jorge_eliecer_gaitan.jpeg',
    'teatro jorge eliecer gaitan':
        'assets/images/teatro_jorge_eliecer_gaitan.jpeg',
    'teatro mayor': 'assets/images/teatro_Mayor_Julio_Mario_Santo_Domingo.jpg',
    'teatro mayor julio mario santo domingo':
        'assets/images/teatro_Mayor_Julio_Mario_Santo_Domingo.jpg',
    'cinemateca bogotá': 'assets/images/cinemateca_bogota.jpg',
    'cinemateca bogota': 'assets/images/cinemateca_bogota.jpg',
    'monumento a policarpa': 'assets/images/monumento_a_policarpa.jpg',
    'capitolio nacional': 'assets/images/capitolio_nacional.jpg',
    // Bares
    'theatron': 'assets/images/theatron.jpg',
    'el bembé': 'assets/images/el_bembe.jpg',
    'el bembe': 'assets/images/el_bembe.jpg',
    'vintrash': 'assets/images/vintrash2.png',
    'sonora social club': 'assets/images/sonora.jpg',
    'octava': 'assets/images/octava.jpg',
    'video club': 'assets/images/video_club.jpg',
    'karaoke box': 'assets/images/karaoke_box.png',
    'karaoke box zona t': 'assets/images/karaoke_box.png',
    'capital drinks': 'assets/images/karaoke_box.png',
    'armenia pub': 'assets/images/armenia_pub.png',
    'la villa bar': 'assets/images/la_viila_gastrobar.png',
    'la casa de la salsa': 'assets/images/la_casa_de_la_salsa.jpg',
    'el candelario': 'assets/images/el_calendario.jpg',
  };

  String _sugerirImagePath(String nombre) {
    final key = nombre.toLowerCase().trim();
    if (_lugarImg.containsKey(key)) return _lugarImg[key]!;
    for (final k in _lugarImg.keys) {
      if (key.contains(k) || k.contains(key)) return _lugarImg[k]!;
    }
    return '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mapeo categoría/subcategoría → interés del perfil
  // ─────────────────────────────────────────────────────────────────────────
  String _categoriaToInteres(String categoria, String subcategoria) {
    switch (categoria) {
      case 'Gastronomía':
        return 'Gastronomía';
      case 'Cultura':
        return 'Cultura';
      case 'Bares':
        return 'Vida Nocturna';
      case 'Turismo':
        final sub = subcategoria.toLowerCase();
        if (sub.contains('monumento') ||
            sub.contains('histórico') ||
            sub.contains('historico')) return 'Historia';
        if (sub.contains('pueblo') ||
            sub.contains('lugar') ||
            sub.contains('ciudad')) return 'Aventura';
        return 'Naturaleza';
      default:
        return 'Aventura';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TOGGLE — guarda o elimina + sincroniza perfil
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> toggleFavorito({
    required String nombre,
    required String categoria,
    required String subcategoria,
    required double lat,
    required double lng,
    String imagePath = '',
  }) async {
    final ref = _favRef;
    final usuRef = _usuarioRef;
    if (ref == null || usuRef == null) return false;

    final finalImagePath =
        imagePath.isNotEmpty ? imagePath : _sugerirImagePath(nombre);
    final docId = _docId(nombre);
    final doc = await ref.doc(docId).get();

    if (doc.exists) {
      await ref.doc(docId).delete();
      await _quitarLugarVisitado(usuRef, nombre);
      return false;
    } else {
      await ref.doc(docId).set({
        'nombre': nombre,
        'categoria': categoria,
        'subcategoria': subcategoria,
        'lat': lat,
        'lng': lng,
        'imagePath': finalImagePath,
        'fechaGuardado': FieldValue.serverTimestamp(),
      });
      await Future.wait([
        _agregarLugarVisitado(usuRef, nombre, finalImagePath),
        _activarInteres(usuRef, categoria, subcategoria),
      ]);
      return true;
    }
  }

  Future<void> _agregarLugarVisitado(
    DocumentReference<Map<String, dynamic>> usuRef,
    String nombre,
    String imagePath,
  ) async {
    try {
      final doc = await usuRef.get();
      final data = doc.data() ?? {};
      final raw = List<dynamic>.from(data['LUGARES_VISITADOS'] ?? []);
      final lista = raw.map((e) => Map<String, String>.from(e as Map)).toList();
      if (lista.any((l) => l['lugar']?.toLowerCase() == nombre.toLowerCase()))
        return;
      final dep = _sugerirDepartamento(nombre);
      final finalImagePath =
          imagePath.isNotEmpty ? imagePath : _sugerirImagePath(nombre);
      lista.add(
          {'lugar': nombre, 'departamento': dep, 'imagePath': finalImagePath});
      await usuRef.update({'LUGARES_VISITADOS': lista});
    } catch (_) {}
  }

  Future<void> _quitarLugarVisitado(
    DocumentReference<Map<String, dynamic>> usuRef,
    String nombre,
  ) async {
    try {
      final doc = await usuRef.get();
      final data = doc.data() ?? {};
      final raw = List<dynamic>.from(data['LUGARES_VISITADOS'] ?? []);
      final lista = raw.map((e) => Map<String, String>.from(e as Map)).toList();
      lista.removeWhere(
          (l) => l['lugar']?.toLowerCase() == nombre.toLowerCase());
      await usuRef.update({'LUGARES_VISITADOS': lista});
    } catch (_) {}
  }

  Future<void> _activarInteres(
    DocumentReference<Map<String, dynamic>> usuRef,
    String categoria,
    String subcategoria,
  ) async {
    try {
      final interes = _categoriaToInteres(categoria, subcategoria);
      final doc = await usuRef.get();
      final data = doc.data() ?? {};
      final intereses = Map<String, bool>.from(data['INTERESES'] ??
          {
            'Gastronomía': false,
            'Cultura': false,
            'Naturaleza': false,
            'Aventura': false,
            'Vida Nocturna': false,
            'Historia': false,
          });
      if (intereses[interes] != true) {
        intereses[interes] = true;
        await usuRef.update({'INTERESES': intereses});
      }
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sugeridor de departamento
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, String> _lugarDep = {
    'amazonas': 'Amazonas',
    'leticia': 'Amazonas',
    'medellín': 'Antioquia',
    'medellin': 'Antioquia',
    'guatapé': 'Antioquia',
    'guatape': 'Antioquia',
    'barranquilla': 'Atlántico',
    'cartagena': 'Bolívar',
    'mompox': 'Bolívar',
    'playa blanca': 'Bolívar',
    'isla barú': 'Bolívar',
    'villa de leyva': 'Boyacá',
    'tunja': 'Boyacá',
    'ráquira': 'Boyacá',
    'raquira': 'Boyacá',
    'manizales': 'Caldas',
    'popayán': 'Cauca',
    'popayan': 'Cauca',
    'bogotá': 'Cundinamarca',
    'bogota': 'Cundinamarca',
    'monserrate': 'Cundinamarca',
    'cerro de monserrate': 'Cundinamarca',
    'zipaquirá': 'Cundinamarca',
    'zipaquira': 'Cundinamarca',
    'plaza bolívar': 'Cundinamarca',
    'plaza bolivar': 'Cundinamarca',
    'plaza de bolívar': 'Cundinamarca',
    'plaza de bolivar': 'Cundinamarca',
    'parque nacional': 'Cundinamarca',
    'parque simón bolívar': 'Cundinamarca',
    'parque simon bolivar': 'Cundinamarca',
    'museo del oro': 'Cundinamarca',
    'museo botero': 'Cundinamarca',
    'museo nacional': 'Cundinamarca',
    'museo nacional de colombia': 'Cundinamarca',
    'teatro colón': 'Cundinamarca',
    'teatro colon': 'Cundinamarca',
    'teatro gaitán': 'Cundinamarca',
    'teatro gaitan': 'Cundinamarca',
    'teatro mayor': 'Cundinamarca',
    'catedral primada': 'Cundinamarca',
    'capitolio nacional': 'Cundinamarca',
    'casa de nariño': 'Cundinamarca',
    'casa de narino': 'Cundinamarca',
    'paloquemao': 'Cundinamarca',
    'mercado de paloquemao': 'Cundinamarca',
    'andrés carne de res': 'Cundinamarca',
    'andres carne de res': 'Cundinamarca',
    'capitalino restaurante': 'Cundinamarca',
    'hornitos': 'Cundinamarca',
    'central cevicheria': 'Cundinamarca',
    'la cabrera': 'Cundinamarca',
    'café san alberto': 'Cundinamarca',
    'cafe san alberto': 'Cundinamarca',
    'juan valdez café': 'Cundinamarca',
    'juan valdez cafe': 'Cundinamarca',
    'harry sasson': 'Cundinamarca',
    'theatron': 'Cundinamarca',
    'sonora social club': 'Cundinamarca',
    'octava': 'Cundinamarca',
    'karaoke box': 'Cundinamarca',
    'armenia pub': 'Cundinamarca',
    'la villa bar': 'Cundinamarca',
    'video club': 'Cundinamarca',
    'capital drinks': 'Cundinamarca',
    'la casa de la salsa': 'Cundinamarca',
    'el candelario': 'Cundinamarca',
    'caño cristales': 'Meta',
    'cano cristales': 'Meta',
    'desierto de la tatacoa': 'Huila',
    'tatacoa': 'Huila',
    'ciudad perdida': 'Magdalena',
    'santa marta': 'Magdalena',
    'parque tayrona': 'Magdalena',
    'tayrona': 'Magdalena',
    'playa el rodadero': 'Magdalena',
    'rodadero': 'Magdalena',
    'armenia': 'Quindío',
    'salento': 'Quindío',
    'valle de cocora': 'Quindío',
    'cocora': 'Quindío',
    'pereira': 'Risaralda',
    'san andrés': 'San Andrés',
    'bucaramanga': 'Santander',
    'barichara': 'Santander',
    'cali': 'Valle del Cauca',
  };

  String _sugerirDepartamento(String nombre) {
    final key = nombre.toLowerCase().trim();
    if (_lugarDep.containsKey(key)) return _lugarDep[key]!;
    for (final k in _lugarDep.keys) {
      if (key.startsWith(k) || k.startsWith(key)) return _lugarDep[k]!;
    }
    return '';
  }

  Future<bool> esFavorito(String nombre) async {
    try {
      final ref = _favRef;
      if (ref == null) return false;
      return (await ref.doc(_docId(nombre)).get()).exists;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerFavoritos() async {
    try {
      final ref = _favRef;
      if (ref == null) return [];
      final snapshot =
          await ref.orderBy('fechaGuardado', descending: true).get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> obtenerFavoritosPorCategoria(
      String categoria) async {
    try {
      final ref = _favRef;
      if (ref == null) return [];
      final snapshot = await ref
          .where('categoria', isEqualTo: categoria)
          .orderBy('fechaGuardado', descending: true)
          .get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamFavoritos() {
    final ref = _favRef;
    if (ref == null) return const Stream.empty();
    return ref
        .orderBy('fechaGuardado', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<void> eliminarFavorito(String nombre) async {
    try {
      final ref = _favRef;
      final usuRef = _usuarioRef;
      if (ref == null || usuRef == null) return;
      await ref.doc(_docId(nombre)).delete();
      await _quitarLugarVisitado(usuRef, nombre);
    } catch (_) {}
  }

  Future<void> limpiarFavoritos() async {
    try {
      final ref = _favRef;
      if (ref == null) return;
      final snapshot = await ref.get();
      final batch = _db.batch();
      for (final doc in snapshot.docs) batch.delete(doc.reference);
      await batch.commit();
    } catch (_) {}
  }
}
