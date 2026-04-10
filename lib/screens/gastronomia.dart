import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'app_state.dart';
import 'app_drawer.dart';
import 'despues_gastronomia.dart';
import 'favoritos_service.dart';

enum CategoriaRestaurante { cafeteria, mercado, tipico, internacional }

extension CategoriaExtension on CategoriaRestaurante {
  String get nombre {
    switch (this) {
      case CategoriaRestaurante.cafeteria:
        return 'Cafés y repostería';
      case CategoriaRestaurante.mercado:
        return 'Mercados Gastronómicos';
      case CategoriaRestaurante.tipico:
        return 'Restaurantes típicos';
      case CategoriaRestaurante.internacional:
        return 'Rest. Internacionales';
    }
  }

  Color get color {
    switch (this) {
      case CategoriaRestaurante.cafeteria:
        return Colors.blue;
      case CategoriaRestaurante.mercado:
        return Colors.green;
      case CategoriaRestaurante.tipico:
        return Colors.orange;
      case CategoriaRestaurante.internacional:
        return Colors.purple;
    }
  }

  IconData get icono {
    switch (this) {
      case CategoriaRestaurante.cafeteria:
        return Icons.coffee;
      case CategoriaRestaurante.mercado:
        return Icons.storefront;
      case CategoriaRestaurante.tipico:
        return Icons.restaurant;
      case CategoriaRestaurante.internacional:
        return Icons.public;
    }
  }
}

class Restaurante {
  final String nombre, descripcion, direccion, horario;
  final LatLng ubicacion;
  final CategoriaRestaurante categoria;
  final double rating;
  final int numResenas;
  final String precio;

  Restaurante(
      {required this.nombre,
      required this.descripcion,
      required this.ubicacion,
      required this.categoria,
      required this.direccion,
      required this.horario,
      this.rating = 4.5,
      this.numResenas = 128,
      this.precio = '\$\$'});
}

class GastronomiaScreen extends StatefulWidget {
  final LatLng? ubicacionInicial;
  final String? restauranteSeleccionado;
  const GastronomiaScreen(
      {super.key, this.ubicacionInicial, this.restauranteSeleccionado});

  @override
  State<GastronomiaScreen> createState() => _GastronomiaScreenState();
}

class _GastronomiaScreenState extends State<GastronomiaScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialPosition = const LatLng(4.6350, -74.0650);
  final TextEditingController _searchController = TextEditingController();
  LatLng? _userLocation;
  bool _locationEnabled = false;
  String _searchQuery = '';
  CategoriaRestaurante? _categoriaSeleccionada;
  late List<Restaurante> _restaurantes;

  @override
  void initState() {
    super.initState();
    _initRestaurantes();
    _requestLocationPermission();
    if (widget.ubicacionInicial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(widget.ubicacionInicial!, 16);
        if (widget.restauranteSeleccionado != null)
          _mostrarInfoRestaurantePorNombre(widget.restauranteSeleccionado!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initRestaurantes() {
    _restaurantes = [
      // ============================================================
      // 1. CAFETERÍAS Y CAFÉS DE ESPECIALIDAD (CategoriaRestaurante.cafeteria)
      // ============================================================
      // ========== CAFETERÍAS (CategoriaRestaurante.cafeteria) ==========

// --- Bogotá y Cundinamarca ---
      Restaurante(
        nombre: 'Arte y Pasión Café',
        descripcion:
            'Café de especialidad con tostado artesanal. Galería de arte en el lugar. Perfecto para amantes del café y el arte.',
        ubicacion: const LatLng(4.6250, -74.0600),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 5 #68-34, Chapinero, Bogotá',
        horario:
            'Lun – Vie: 8:00 AM – 8:00 PM\nSáb: 9:00 AM – 6:00 PM\nDom: Cerrado',
        rating: 4.6,
        numResenas: 145,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Café Cultor',
        descripcion:
            'Café de origen con métodos de filtro V60, Chemex y Aeropress. Ambiente íntimo y música de jazz.',
        ubicacion: const LatLng(4.6400, -74.0680),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 70 #6-12, Chapinero, Bogotá',
        horario:
            'Mar – Sáb: 7:00 AM – 7:00 PM\nDom: 8:00 AM – 5:00 PM\nLun: Cerrado',
        rating: 4.7,
        numResenas: 98,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Catación Pública',
        descripcion:
            'Laboratorio de café donde puedes aprender a catar. Experiencia educativa y degustación de variedades colombianas.',
        ubicacion: const LatLng(4.6100, -74.0700),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 3 #12-45, La Candelaria, Bogotá',
        horario: 'Lun – Sáb: 9:00 AM – 6:00 PM\nDom: 10:00 AM – 4:00 PM',
        rating: 4.8,
        numResenas: 234,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Café Quindío',
        descripcion:
            'Tradicional cadena de café colombiano con granos del Eje Cafetero. Bebidas calientes y frías.',
        ubicacion: const LatLng(4.6500, -74.0600),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 7 #76-23, Chicó, Bogotá',
        horario: 'Lun – Dom: 6:30 AM – 9:00 PM',
        rating: 4.2,
        numResenas: 567,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Tostao Café',
        descripcion:
            'Cadena colombiana de café económico pero de buena calidad. Perfecto para el día a día.',
        ubicacion: const LatLng(4.6700, -74.0500),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 85 #12-45, Usaquén, Bogotá',
        horario: 'Lun – Dom: 6:00 AM – 8:00 PM',
        rating: 4.0,
        numResenas: 1234,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Café Arbóleo',
        descripcion:
            'Café escondido en un árbol gigante. Experiencia única en medio de la naturaleza urbana.',
        ubicacion: const LatLng(4.6350, -74.0550),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 68 #4-23, Chapinero, Bogotá',
        horario: 'Mar – Dom: 8:00 AM – 7:00 PM\nLun: Cerrado',
        rating: 4.9,
        numResenas: 345,
        precio: '\$\$',
      ),

// --- Antioquia (Medellín y municipios) ---
      Restaurante(
        nombre: 'Café Velvet',
        descripcion:
            'Café de especialidad con ambiente vintage. Postres caseros y desayunos saludables.',
        ubicacion: const LatLng(6.2200, -75.5720),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 37 #8-12, El Poblado, Medellín',
        horario: 'Lun – Dom: 7:00 AM – 8:00 PM',
        rating: 4.5,
        numResenas: 267,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Labrador Coffee',
        descripcion:
            'Café de especialidad con perritos labradores en el local. Ambiente familiar y acogedor.',
        ubicacion: const LatLng(6.2350, -75.5800),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 10 #40-20, El Poblado, Medellín',
        horario: 'Lun – Vie: 6:30 AM – 8:00 PM\nSáb – Dom: 7:00 AM – 7:00 PM',
        rating: 4.6,
        numResenas: 345,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Café Zorba',
        descripcion:
            'Pizzas vegetarianas, cervezas artesanales y música en vivo. Ambiente bohemio en Laureles.',
        ubicacion: const LatLng(6.2450, -75.5900),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 35 #80-45, Laureles, Medellín',
        horario: 'Lun – Dom: 8:00 AM – 11:00 PM',
        rating: 4.4,
        numResenas: 423,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Café Santa Rita',
        descripcion:
            'Cafetería tradicional en Jardín. Famoso por su café de origen y sus pandequesos artesanales.',
        ubicacion: const LatLng(5.6000, -75.8200),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 6 #8-34, Jardín, Antioquia',
        horario: 'Lun – Dom: 6:00 AM – 8:00 PM',
        rating: 4.7,
        numResenas: 189,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Café de la Plaza',
        descripcion:
            'Cafetería en la plaza principal de Santa Fe de Antioquia. Ambiente colonial y café tradicional.',
        ubicacion: const LatLng(6.5600, -75.8300),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Plaza Principal #3-12, Santa Fe de Antioquia',
        horario: 'Lun – Dom: 7:00 AM – 9:00 PM',
        rating: 4.3,
        numResenas: 234,
        precio: '\$',
      ),

// --- Eje Cafetero (Quindío, Risaralda, Caldas) ---
      Restaurante(
        nombre: 'Café Jesús Martín',
        descripcion:
            'Cafetería en una finca cafetera tradicional. Tostión artesanal y vista a las montañas del Quindío.',
        ubicacion: const LatLng(4.5200, -75.7000),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Vereda El Tiempo, Salento, Quindío',
        horario: 'Lun – Dom: 8:00 AM – 6:00 PM',
        rating: 4.8,
        numResenas: 312,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Café Quindío Salento',
        descripcion:
            'Café de especialidad en el corazón de Salento. Mirador al Valle de Cocora.',
        ubicacion: const LatLng(4.6370, -75.5700),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 6 #5-23, Salento, Quindío',
        horario: 'Lun – Dom: 7:00 AM – 8:00 PM',
        rating: 4.6,
        numResenas: 456,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Café Macanas',
        descripcion:
            'Café artesanal en Filandia. Mirador espectacular y café de origen de la región.',
        ubicacion: const LatLng(4.6700, -75.6580),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 6 #7-34, Filandia, Quindío',
        horario: 'Lun – Dom: 8:00 AM – 7:00 PM',
        rating: 4.7,
        numResenas: 278,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Café de la Casa',
        descripcion:
            'Café tradicional en Pereira. Especialidad en tinto campesino y pandebonos.',
        ubicacion: const LatLng(4.8100, -75.7000),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 20 #8-34, Pereira, Risaralda',
        horario: 'Lun – Dom: 6:00 AM – 8:00 PM',
        rating: 4.2,
        numResenas: 345,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Café Ararat',
        descripcion:
            'Café de especialidad en Manizales. Con vista a los nevados y granos de la región.',
        ubicacion: const LatLng(5.0600, -75.5200),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 23 #65-34, Manizales, Caldas',
        horario: 'Lun – Vie: 7:00 AM – 8:00 PM\nSáb – Dom: 8:00 AM – 6:00 PM',
        rating: 4.5,
        numResenas: 189,
        precio: '\$\$',
      ),

// --- Costa Caribe (Cartagena, Santa Marta, Barranquilla) ---
      Restaurante(
        nombre: 'Café Stepping Stone',
        descripcion:
            'Café social con causa. Emplean a madres cabeza de hogar. Café orgánico del Caribe.',
        ubicacion: const LatLng(10.4230, -75.5480),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 38 #8-23, Getsemaní, Cartagena',
        horario: 'Lun – Dom: 7:00 AM – 9:00 PM',
        rating: 4.8,
        numResenas: 567,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Época Café Bar',
        descripcion:
            'Café de especialidad en el centro histórico de Cartagena. Ambiente relajado y música en vivo.',
        ubicacion: const LatLng(10.4220, -75.5500),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 34 #4-56, Centro, Cartagena',
        horario: 'Lun – Dom: 8:00 AM – 10:00 PM',
        rating: 4.6,
        numResenas: 423,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Café de la Abuela',
        descripcion:
            'Cafetería tradicional en Santa Marta. Especialidad en café con pan de bono y queso costeño.',
        ubicacion: const LatLng(11.2400, -74.2100),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 20 #5-34, El Rodadero, Santa Marta',
        horario: 'Lun – Dom: 6:00 AM – 8:00 PM',
        rating: 4.3,
        numResenas: 234,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Café Tinto',
        descripcion:
            'Café tradicional barranquillero. Punto de encuentro de artistas y escritores.',
        ubicacion: const LatLng(11.0000, -74.8100),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 54 #74-23, Barranquilla',
        horario: 'Lun – Sáb: 7:00 AM – 8:00 PM\nDom: 8:00 AM – 5:00 PM',
        rating: 4.2,
        numResenas: 345,
        precio: '\$',
      ),

// --- Costa Pacífica (Buenaventura, Tumaco, Nuquí) ---
      Restaurante(
        nombre: 'Café del Pacífico',
        descripcion:
            'Café con granos de la región del Pacífico. Ambiente relajado frente al mar.',
        ubicacion: const LatLng(3.8800, -77.0300),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Malecón #12-34, Buenaventura, Valle',
        horario: 'Lun – Dom: 7:00 AM – 7:00 PM',
        rating: 4.3,
        numResenas: 98,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Café Tumaco',
        descripcion:
            'Café de especialidad del Pacífico nariñense. Granos cultivados en la selva.',
        ubicacion: const LatLng(1.8100, -78.8200),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 12 #5-34, Tumaco, Nariño',
        horario: 'Lun – Dom: 6:00 AM – 6:00 PM',
        rating: 4.5,
        numResenas: 67,
        precio: '\$',
      ),

// --- Santanderes (Bucaramanga, San Gil, Barichara) ---
      Restaurante(
        nombre: 'Café Barichara',
        descripcion:
            'Café de especialidad en el pueblo más bonito de Colombia. Ambiente colonial y acogedor.',
        ubicacion: const LatLng(6.6350, -73.2200),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 5 #6-34, Barichara, Santander',
        horario: 'Lun – Dom: 8:00 AM – 8:00 PM',
        rating: 4.8,
        numResenas: 345,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Café San Gil',
        descripcion:
            'Cafetería tradicional en San Gil. Energía para los aventureros del rafting.',
        ubicacion: const LatLng(6.5600, -73.1400),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 12 #7-45, San Gil, Santander',
        horario: 'Lun – Dom: 6:00 AM – 9:00 PM',
        rating: 4.3,
        numResenas: 234,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Café Batuta',
        descripcion:
            'Café musical en Bucaramanga. Música clásica y café de especialidad.',
        ubicacion: const LatLng(7.1200, -73.1200),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 33 #52-45, Bucaramanga',
        horario: 'Lun – Sáb: 7:00 AM – 8:00 PM\nDom: 8:00 AM – 5:00 PM',
        rating: 4.5,
        numResenas: 189,
        precio: '\$\$',
      ),

// --- Valle del Cauca (Cali, Palmira, Buga) ---
      Restaurante(
        nombre: 'Café Macondo',
        descripcion:
            'Café temático inspirado en García Márquez. Ambiente literario y café de alta calidad.',
        ubicacion: const LatLng(3.4500, -76.5320),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 9 #3-45, Granada, Cali',
        horario: 'Lun – Sáb: 8:00 AM – 9:00 PM\nDom: 9:00 AM – 6:00 PM',
        rating: 4.4,
        numResenas: 178,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Café Buga',
        descripcion:
            'Cafetería tradicional en la ciudad de los milagros. Café con pan de yuca.',
        ubicacion: const LatLng(3.9000, -76.3000),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 15 #6-34, Buga, Valle',
        horario: 'Lun – Dom: 6:00 AM – 8:00 PM',
        rating: 4.2,
        numResenas: 234,
        precio: '\$',
      ),

// --- Boyacá (Villa de Leyva, Tunja, Paipa) ---
      Restaurante(
        nombre: 'Café de la Villa',
        descripcion:
            'Cafetería en Villa de Leyva. Ambiente colonial y café con pan de queso boyacense.',
        ubicacion: const LatLng(5.6300, -73.5200),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 13 #6-45, Villa de Leyva, Boyacá',
        horario: 'Lun – Dom: 8:00 AM – 8:00 PM',
        rating: 4.6,
        numResenas: 345,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Café Paipa',
        descripcion:
            'Cafetería en Paipa, famoso por sus aguas termales. Café con almojábanas.',
        ubicacion: const LatLng(5.7800, -73.1200),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 12 #8-34, Paipa, Boyacá',
        horario: 'Lun – Dom: 6:00 AM – 7:00 PM',
        rating: 4.3,
        numResenas: 156,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Café Tunja',
        descripcion:
            'Cafetería tradicional en el centro histórico de Tunja. Ambiente universitario.',
        ubicacion: const LatLng(5.5300, -73.3700),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 20 #9-45, Tunja, Boyacá',
        horario: 'Lun – Sáb: 7:00 AM – 8:00 PM\nDom: 8:00 AM – 5:00 PM',
        rating: 4.1,
        numResenas: 234,
        precio: '\$',
      ),

// --- Huila (San Agustín, Neiva, Tatacoa) ---
      Restaurante(
        nombre: 'Café San Agustín',
        descripcion:
            'Café de especialidad cerca del parque arqueológico. Granos cultivados en la región.',
        ubicacion: const LatLng(1.8800, -76.2700),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 5 #4-23, San Agustín, Huila',
        horario: 'Lun – Dom: 7:00 AM – 7:00 PM',
        rating: 4.5,
        numResenas: 145,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Café Neiva',
        descripcion:
            'Cafetería en el calor de Neiva. Café frío y jugos naturales.',
        ubicacion: const LatLng(2.9300, -75.2800),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 5 #8-34, Neiva, Huila',
        horario: 'Lun – Dom: 6:00 AM – 8:00 PM',
        rating: 4.0,
        numResenas: 234,
        precio: '\$',
      ),

// --- Amazonía (Leticia, Puerto Nariño) ---
      Restaurante(
        nombre: 'Café Amazónico',
        descripcion:
            'Café con granos cultivados en la selva amazónica. Sabores exóticos y únicos.',
        ubicacion: const LatLng(-4.2000, -69.9400),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 8 #5-34, Leticia, Amazonas',
        horario: 'Lun – Dom: 7:00 AM – 7:00 PM',
        rating: 4.6,
        numResenas: 89,
        precio: '\$\$',
      ),

// --- Llanos Orientales (Villavicencio, Yopal) ---
      Restaurante(
        nombre: 'Café Llanero',
        descripcion:
            'Cafetería con ambiente de los llanos. Café con guarapo y pan de arroz.',
        ubicacion: const LatLng(4.1400, -73.6300),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 33 #15-45, Villavicencio, Meta',
        horario: 'Lun – Dom: 6:00 AM – 8:00 PM',
        rating: 4.3,
        numResenas: 234,
        precio: '\$',
      ),
      // --- Bogotá ---
      Restaurante(
        nombre: 'Café San Alberto',
        descripcion:
            'Café de especialidad con granos colombianos de origen único. Reconocido por su método de preparación artesanal y ambiente acogedor. Considerado uno de los mejores cafés de Bogotá.',
        ubicacion: const LatLng(4.6012, -74.0725),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 93A #14-46, Chapinero, Bogotá',
        horario:
            'Lun – Vie: 7:30 AM – 7:00 PM\nSáb: 8:00 AM – 6:00 PM\nDom: Cerrado',
        rating: 4.8,
        numResenas: 342,
        precio: '\$\$\$',
      ),
      Restaurante(
        nombre: 'Amor Perfecto',
        descripcion:
            'Tostadores de café especial con métodos de extracción de precisión. Ambiente minimalista y académico del café. Pioneros en café de especialidad en Colombia.',
        ubicacion: const LatLng(4.6310, -74.0650),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 4 #66-09, Chapinero Alto, Bogotá',
        horario: 'Lun – Vie: 7:00 AM – 8:00 PM\nSáb – Dom: 8:00 AM – 7:00 PM',
        rating: 4.7,
        numResenas: 278,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Colo Coffee',
        descripcion:
            'Coffee shop de especialidad con granos colombianos de diferentes regiones. Perfecto para trabajar y degustar. Ambiente moderno y relajado.',
        ubicacion: const LatLng(4.6890, -74.0450),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 93 #12-25, Usaquén, Bogotá',
        horario:
            'Lun – Vie: 7:30 AM – 8:30 PM\nSáb: 8:00 AM – 7:00 PM\nDom: 9:00 AM – 6:00 PM',
        rating: 4.5,
        numResenas: 156,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Juan Valdez Café',
        descripcion:
            'Cadena insignia del café colombiano con granos 100% colombianos. Variedad de bebidas calientes, frías y snacks. Icono nacional.',
        ubicacion: const LatLng(4.6450, -74.0640),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 7 #72-45, Chapinero, Bogotá',
        horario: 'Lun – Vie: 6:30 AM – 9:00 PM\nSáb – Dom: 7:00 AM – 9:00 PM',
        rating: 4.3,
        numResenas: 215,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Azahar Coffee',
        descripcion:
            'Café de origen con tostado artesanal. Métodos de filtro y espresso de alta calidad. Ambiente acogedor y música suave.',
        ubicacion: const LatLng(4.6210, -74.0580),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 70 #10-23, Chapinero, Bogotá',
        horario: 'Lun – Sáb: 7:00 AM – 8:00 PM\nDom: 8:00 AM – 5:00 PM',
        rating: 4.6,
        numResenas: 189,
        precio: '\$\$',
      ),

      // --- Medellín ---
      Restaurante(
        nombre: 'Pergamino Café',
        descripcion:
            'Referente del café de especialidad en Medellín. Granos seleccionados de diferentes regiones de Colombia. Métodos de extracción cuidadosos.',
        ubicacion: const LatLng(6.2100, -75.5680),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Carrera 36 #10A-45, El Poblado, Medellín',
        horario: 'Lun – Vie: 7:00 AM – 8:00 PM\nSáb – Dom: 8:00 AM – 7:00 PM',
        rating: 4.7,
        numResenas: 423,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Hija Mía Coffee',
        descripcion:
            'Café con enfoque femenino y sostenible. Postres artesanales y panadería. Ambiente cálido y familiar.',
        ubicacion: const LatLng(6.2150, -75.5600),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 10 #40-20, El Poblado, Medellín',
        horario: 'Lun – Dom: 8:00 AM – 8:00 PM',
        rating: 4.6,
        numResenas: 312,
        precio: '\$\$',
      ),

      // --- Cartagena ---
      Restaurante(
        nombre: 'Café del Mar',
        descripcion:
            'Café con vista espectacular al mar Caribe. Perfecto para ver el atardecer con una taza de café colombiano.',
        ubicacion: const LatLng(10.4250, -75.5510),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Murallas de Cartagena, Centro Histórico',
        horario: 'Lun – Dom: 4:00 PM – 11:00 PM',
        rating: 4.5,
        numResenas: 567,
        precio: '\$\$\$',
      ),
      Restaurante(
        nombre: 'San Alberto Café Cartagena',
        descripcion:
            'La sucursal cartagenera del famoso café de especialidad. Ambiente colonial y fresco.',
        ubicacion: const LatLng(10.4220, -75.5480),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle de los Estribos #32-15, Centro Histórico',
        horario: 'Lun – Dom: 8:00 AM – 8:00 PM',
        rating: 4.6,
        numResenas: 234,
        precio: '\$\$',
      ),

      // --- Cali ---
      Restaurante(
        nombre: 'Macondo Café',
        descripcion:
            'Café temático inspirado en García Márquez. Ambiente literario y café de alta calidad.',
        ubicacion: const LatLng(3.4500, -76.5320),
        categoria: CategoriaRestaurante.cafeteria,
        direccion: 'Calle 9 #3-45, Granada, Cali',
        horario: 'Lun – Sáb: 8:00 AM – 9:00 PM\nDom: 9:00 AM – 6:00 PM',
        rating: 4.4,
        numResenas: 178,
        precio: '\$\$',
      ),

      // ============================================================
      // 2. MERCADOS GASTRONÓMICOS (CategoriaRestaurante.mercado)
      // ============================================================

      // --- Bogotá ---
      // ========== MERCADOS (CategoriaRestaurante.mercado) ==========

// --- Bogotá ---
      Restaurante(
        nombre: 'Mercado La Concordia',
        descripcion:
            'Mercado tradicional en La Candelaria. Especialidad en frutas exóticas y jugos naturales.',
        ubicacion: const LatLng(4.6000, -74.0700),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Calle 10 #1-23, La Candelaria, Bogotá',
        horario: 'Lun – Dom: 6:00 AM – 6:00 PM',
        rating: 4.3,
        numResenas: 234,
        precio: '\$',
      ),

// --- Antioquia ---
      Restaurante(
        nombre: 'Mercado de Envigado',
        descripcion:
            'Mercado tradicional en el sur del Valle de Aburrá. Famoso por sus arepas y comida típica antioqueña.',
        ubicacion: const LatLng(6.1700, -75.5900),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Calle 40 #35-23, Envigado, Antioquia',
        horario: 'Lun – Dom: 5:00 AM – 6:00 PM',
        rating: 4.5,
        numResenas: 456,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Mercado de San Javier',
        descripcion:
            'Mercado tradicional en la comuna 13 de Medellín. Gradas y arte urbano alrededor.',
        ubicacion: const LatLng(6.2600, -75.6100),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Calle 44 #96-23, San Javier, Medellín',
        horario: 'Lun – Dom: 6:00 AM – 5:00 PM',
        rating: 4.2,
        numResenas: 234,
        precio: '\$',
      ),

// --- Eje Cafetero ---
      Restaurante(
        nombre: 'Mercado de Salento',
        descripcion:
            'Mercado campesino en Salento. Frutas frescas, café artesanal y comidas típicas quindianas.',
        ubicacion: const LatLng(4.6370, -75.5700),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Plaza Principal, Salento, Quindío',
        horario: 'Sáb – Dom: 7:00 AM – 4:00 PM',
        rating: 4.7,
        numResenas: 567,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Mercado de Pereira',
        descripcion:
            'Mercado central de Pereira. Especialidad en café, arepas y pandebonos.',
        ubicacion: const LatLng(4.8100, -75.7000),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Calle 20 #8-45, Pereira, Risaralda',
        horario: 'Lun – Dom: 5:00 AM – 6:00 PM',
        rating: 4.3,
        numResenas: 345,
        precio: '\$',
      ),

// --- Costa Caribe ---
      Restaurante(
        nombre: 'Mercado de Getsemaní',
        descripcion:
            'Mercado tradicional en el barrio Getsemaní de Cartagena. Comida costeña y artesanías.',
        ubicacion: const LatLng(10.4240, -75.5460),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Calle 30 #10-23, Getsemaní, Cartagena',
        horario: 'Lun – Dom: 7:00 AM – 7:00 PM',
        rating: 4.4,
        numResenas: 456,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Mercado de Santa Marta',
        descripcion:
            'Mercado principal de Santa Marta. Pescado fresco, frutas tropicales y comida samaria.',
        ubicacion: const LatLng(11.2400, -74.2100),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Calle 20 #10-45, Santa Marta',
        horario: 'Lun – Dom: 5:00 AM – 5:00 PM',
        rating: 4.2,
        numResenas: 345,
        precio: '\$',
      ),

// --- Valle del Cauca ---
      Restaurante(
        nombre: 'Mercado de San Antonio',
        descripcion:
            'Mercado tradicional en Cali. Comida del Pacífico, jugos y frutas exóticas.',
        ubicacion: const LatLng(3.4400, -76.5400),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Calle 5 #4-23, San Antonio, Cali',
        horario: 'Lun – Dom: 6:00 AM – 6:00 PM',
        rating: 4.5,
        numResenas: 456,
        precio: '\$',
      ),

// --- Boyacá ---
      Restaurante(
        nombre: 'Mercado de Villa de Leyva',
        descripcion:
            'Mercado campesino en Villa de Leyva. Productos orgánicos, pan artesanal y comidas boyacenses.',
        ubicacion: const LatLng(5.6300, -73.5200),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Plaza Principal, Villa de Leyva, Boyacá',
        horario: 'Sáb – Dom: 8:00 AM – 4:00 PM',
        rating: 4.7,
        numResenas: 456,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Mercado de Paloquemao',
        descripcion:
            'El mercado mayorista más importante de Bogotá. Frutas exóticas, flores, verduras frescas y comidas típicas a precios populares.',
        ubicacion: const LatLng(4.6100, -74.0890),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Carrera 19 #25-59, Los Mártires, Bogotá',
        horario:
            'Lun – Dom: 4:30 AM – 2:00 PM\n(Mejor horario: antes de las 9 AM)',
        rating: 4.6,
        numResenas: 180,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Mercado de Usaquén',
        descripcion:
            'Mercado campesino que se instala cada domingo. Artesanías, comidas típicas, frutas frescas y ambiente familiar.',
        ubicacion: const LatLng(4.6950, -74.0350),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Carrera 6 #119B-10, Usaquén, Bogotá',
        horario: 'Dom: 8:00 AM – 4:00 PM\n(Los domingos solamente)',
        rating: 4.8,
        numResenas: 423,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Plaza de la Perseverancia',
        descripcion:
            'Mercado tradicional con puestos de comida típica colombiana. Ajiaco, tamales, lechona y más a excelentes precios.',
        ubicacion: const LatLng(4.6210, -74.0650),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Carrera 5 #31-24, La Perseverancia, Bogotá',
        horario: 'Lun – Dom: 6:00 AM – 6:00 PM',
        rating: 4.4,
        numResenas: 312,
        precio: '\$',
      ),

      // --- Medellín ---
      Restaurante(
        nombre: 'Plaza Minorista',
        descripcion:
            'El mercado más grande de Medellín. Productos frescos, carnes, pescados y comidas típicas antioqueñas.',
        ubicacion: const LatLng(6.2550, -75.5670),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Calle 55 #48-05, La Candelaria, Medellín',
        horario: 'Lun – Dom: 5:00 AM – 5:00 PM',
        rating: 4.5,
        numResenas: 289,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Mercado del Río',
        descripcion:
            'Gastromercado moderno con más de 50 puestos de comida. Cocina internacional, street food y coctelería.',
        ubicacion: const LatLng(6.2000, -75.5650),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Carrera 32 #10-20, El Poblado, Medellín',
        horario:
            'Lun – Jue: 12:00 PM – 11:00 PM\nVie – Sáb: 12:00 PM – 1:00 AM\nDom: 12:00 PM – 9:00 PM',
        rating: 4.7,
        numResenas: 678,
        precio: '\$\$',
      ),

      // --- Cartagena ---
      Restaurante(
        nombre: 'Mercado de Bazurto',
        descripcion:
            'El mercado auténtico de Cartagena. Experiencia cultural única con sabores y olores caribeños.',
        ubicacion: const LatLng(10.4000, -75.5300),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Calle 30 #10-45, Bazurto, Cartagena',
        horario: 'Lun – Dom: 5:00 AM – 4:00 PM',
        rating: 4.3,
        numResenas: 156,
        precio: '\$',
      ),

      // --- Cali ---
      Restaurante(
        nombre: 'Mercado Alameda',
        descripcion:
            'Mercado tradicional caleño. Especialidades en frutas tropicales, jugos naturales y comidas del Pacífico.',
        ubicacion: const LatLng(3.4400, -76.5300),
        categoria: CategoriaRestaurante.mercado,
        direccion: 'Calle 8 #26-45, Alameda, Cali',
        horario: 'Lun – Dom: 6:00 AM – 5:00 PM',
        rating: 4.4,
        numResenas: 201,
        precio: '\$',
      ),

      // ============================================================
      // 3. RESTAURANTES TÍPICOS COLOMBIANOS (CategoriaRestaurante.tipico)
      // ============================================================

      // --- Bogotá ---
      // ========== RESTAURANTES TÍPICOS (CategoriaRestaurante.tipico) ==========

// --- Boyacá y Santanderes ---
      Restaurante(
        nombre: 'El Rincón Boyacense',
        descripcion:
            'Auténtica comida boyacense. Especialidad en mute, cuchuco y arepas de maíz pelao.',
        ubicacion: const LatLng(5.5300, -73.3700),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 15 #8-34, Tunja, Boyacá',
        horario: 'Lun – Dom: 11:00 AM – 8:00 PM',
        rating: 4.4,
        numResenas: 234,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Fonda La Santandereana',
        descripcion:
            'Comida típica santandereana. Especialidad en hormigas culonas, mute y cabro.',
        ubicacion: const LatLng(7.1200, -73.1200),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Carrera 33 #52-45, Bucaramanga',
        horario: 'Lun – Dom: 11:00 AM – 9:00 PM',
        rating: 4.5,
        numResenas: 345,
        precio: '\$\$',
      ),

// --- Huila y Tolima ---
      Restaurante(
        nombre: 'Asadero Huilense',
        descripcion:
            'Especialidad en lechona, tamal y asados huilenses. Ambiente familiar.',
        ubicacion: const LatLng(2.9300, -75.2800),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Carrera 5 #8-34, Neiva, Huila',
        horario: 'Lun – Dom: 10:00 AM – 8:00 PM',
        rating: 4.6,
        numResenas: 345,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Lechonería El Tolimense',
        descripcion:
            'La mejor lechona tolimense. Tradicional y crujiente, rellena de arroz y carne de cerdo.',
        ubicacion: const LatLng(4.4500, -75.2400),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 10 #5-34, Ibagué, Tolima',
        horario: 'Lun – Dom: 9:00 AM – 7:00 PM',
        rating: 4.7,
        numResenas: 567,
        precio: '\$\$',
      ),

// --- Nariño ---
      Restaurante(
        nombre: 'La Cosecha Pastusa',
        descripcion:
            'Comida típica pastusa. Especialidad en cuy asado, hornado y empanadas de pipián.',
        ubicacion: const LatLng(1.2100, -77.2800),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 15 #10-34, Pasto, Nariño',
        horario: 'Lun – Dom: 11:00 AM – 8:00 PM',
        rating: 4.5,
        numResenas: 234,
        precio: '\$\$',
      ),

// --- Chocó ---
      Restaurante(
        nombre: 'Sabor Pacífico',
        descripcion:
            'Comida típica del Pacífico colombiano. Especialidad en arroz con coco, pescado frito y patacones.',
        ubicacion: const LatLng(5.6900, -76.6500),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Malecón #12-34, Quibdó, Chocó',
        horario: 'Lun – Dom: 10:00 AM – 8:00 PM',
        rating: 4.4,
        numResenas: 156,
        precio: '\$',
      ),

// --- Cesar y Guajira ---
      Restaurante(
        nombre: 'Asadero Vallenato',
        descripcion:
            'Carne asada al carbón, arepas de huevo y queso costeño. Ambiente vallenato.',
        ubicacion: const LatLng(10.4700, -73.2500),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 15 #8-34, Valledupar, Cesar',
        horario: 'Lun – Dom: 11:00 AM – 10:00 PM',
        rating: 4.5,
        numResenas: 345,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Fonda Wayuu',
        descripcion:
            'Comida tradicional wayuu. Especialidad en chivo asado, friche y arepas de maíz.',
        ubicacion: const LatLng(11.5400, -72.9100),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 8 #5-34, Riohacha, La Guajira',
        horario: 'Lun – Dom: 10:00 AM – 8:00 PM',
        rating: 4.3,
        numResenas: 189,
        precio: '\$',
      ),

// --- Cauca ---
      Restaurante(
        nombre: 'Mora Castilla Popayán',
        descripcion:
            'Herencia del Cauca. Especialidad en empanadas de pipián, carantantas y champús.',
        ubicacion: const LatLng(2.4410, -76.6060),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 4 #6-45, Popayán, Cauca',
        horario: 'Lun – Dom: 8:00 AM – 8:00 PM',
        rating: 4.6,
        numResenas: 345,
        precio: '\$',
      ),
      Restaurante(
        nombre: 'Andrés Carne de Res',
        descripcion:
            'Ícono gastronómico colombiano. Famoso por sus carnes a la brasa, ambiente festivo y decoración única. Imprescindible en Bogotá.',
        ubicacion: const LatLng(4.6650, -74.0570),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 82 #12-21, El Retiro, Bogotá',
        horario:
            'Jue – Vie: 12:00 PM – 3:00 AM\nSáb: 12:00 PM – 4:00 AM\nDom: 12:00 PM – 1:00 AM\nLun – Mié: Cerrado',
        rating: 4.7,
        numResenas: 892,
        precio: '\$\$\$',
      ),
      Restaurante(
        nombre: 'Capitalino Restaurante',
        descripcion:
            'Auténtica cocina criolla bogotana. Especialidad en ajiaco santafereño, bandeja paisa y changua. Ambiente cálido y familiar.',
        ubicacion: const LatLng(4.6150, -74.0680),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 10 #5-51, La Candelaria, Bogotá',
        horario: 'Lun – Sáb: 11:30 AM – 8:30 PM\nDom: 11:30 AM – 5:00 PM',
        rating: 4.2,
        numResenas: 95,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'La Puerta de la Catedral',
        descripcion:
            'Restaurante tradicional en la Candelaria. Famoso por su sobrebarriga y la tradicional bandeja paisa.',
        ubicacion: const LatLng(4.5980, -74.0750),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 11 #6-27, La Candelaria, Bogotá',
        horario: 'Lun – Dom: 11:00 AM – 9:00 PM',
        rating: 4.2,
        numResenas: 231,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'La Cabrera',
        descripcion:
            'Uno de los mejores restaurantes de carnes de Bogotá. Cortes premium, ambiente sofisticado y servicio de primera.',
        ubicacion: const LatLng(4.6750, -74.0550),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Carrera 15 #99-48, Usaquén, Bogotá',
        horario:
            'Lun – Jue: 12:00 PM – 11:00 PM\nVie – Sáb: 12:00 PM – 12:00 AM\nDom: 12:00 PM – 10:00 PM',
        rating: 4.5,
        numResenas: 410,
        precio: '\$\$\$',
      ),
      Restaurante(
        nombre: 'El Tambor',
        descripcion:
            'Cocina tradicional colombiana con énfasis en platos de la costa Caribe. Música en vivo y ambiente festivo.',
        ubicacion: const LatLng(4.6820, -74.0520),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 85 #12-45, El Chicó, Bogotá',
        horario: 'Lun – Sáb: 12:00 PM – 11:00 PM\nDom: 12:00 PM – 9:00 PM',
        rating: 4.3,
        numResenas: 187,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'El Mono Bandido',
        descripcion:
            'Auténtica comida boyacense. Especialidad en mute, cuchuco de trigo y arepas boyacenses.',
        ubicacion: const LatLng(4.6480, -74.0780),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Carrera 13 #70-28, Chapinero, Bogotá',
        horario: 'Mar – Dom: 11:30 AM – 8:30 PM\nLun: Cerrado',
        rating: 4.6,
        numResenas: 98,
        precio: '\$\$',
      ),

      // --- Medellín ---
      Restaurante(
        nombre: 'El Rancherito',
        descripcion:
            'Tradicional restaurante antioqueño. Bandeja paisa, arepas, frijoles y carne asada. Ambiente familiar y campestre.',
        ubicacion: const LatLng(6.2350, -75.5750),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Carrera 43A #8-50, El Poblado, Medellín',
        horario: 'Lun – Dom: 11:00 AM – 10:00 PM',
        rating: 4.4,
        numResenas: 523,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Hacienda La Junta',
        descripcion:
            'Comida tradicional antioqueña en ambiente de hacienda. Especialidad en bandeja paisa y sancocho.',
        ubicacion: const LatLng(6.2050, -75.5600),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 10 #40-15, El Poblado, Medellín',
        horario: 'Lun – Dom: 11:00 AM – 9:00 PM',
        rating: 4.5,
        numResenas: 312,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Ajiacos y Mondongos',
        descripcion:
            'Especialistas en ajiaco y mondongo antioqueño. Sabor casero y porciones generosas.',
        ubicacion: const LatLng(6.2600, -75.5800),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 55 #45-12, La Candelaria, Medellín',
        horario: 'Lun – Dom: 7:00 AM – 7:00 PM',
        rating: 4.3,
        numResenas: 198,
        precio: '\$',
      ),

      // --- Cartagena ---
      Restaurante(
        nombre: 'La Mulata',
        descripcion:
            'Comida típica cartagenera. Especialidad en pescado frito, arroz con coco y patacones.',
        ubicacion: const LatLng(10.4200, -75.5450),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle del Guerrero #29-45, Getsemaní, Cartagena',
        horario: 'Lun – Dom: 11:00 AM – 10:00 PM',
        rating: 4.5,
        numResenas: 289,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'La Cevichería',
        descripcion:
            'Famoso por sus ceviches y cócteles de mariscos. Ambiente relajado y playero.',
        ubicacion: const LatLng(10.4230, -75.5500),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle del Tripita y Media #31-20, Getsemaní',
        horario: 'Mar – Dom: 12:00 PM – 9:00 PM\nLun: Cerrado',
        rating: 4.6,
        numResenas: 456,
        precio: '\$\$',
      ),

      // --- Cali ---
      Restaurante(
        nombre: 'Platillos Voladores',
        descripcion:
            'Sabores del Pacífico con técnicas internacionales. Especialidad en mariscos y pescados.',
        ubicacion: const LatLng(3.4600, -76.5300),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 9 #4-20, Granada, Cali',
        horario: 'Lun – Sáb: 12:00 PM – 10:00 PM\nDom: 12:00 PM – 5:00 PM',
        rating: 4.6,
        numResenas: 234,
        precio: '\$\$\$',
      ),

      // --- Eje Cafetero ---
      Restaurante(
        nombre: 'Restaurante José Fernando',
        descripcion:
            'Comida tradicional de la región cafetera. Ambiente campestre y acogedor en Filandia, Quindío.',
        ubicacion: const LatLng(4.6700, -75.6580),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Carrera 6 #8-45, Filandia, Quindío',
        horario: 'Lun – Dom: 11:00 AM – 9:00 PM',
        rating: 4.5,
        numResenas: 167,
        precio: '\$\$',
      ),

      // --- Popayán ---
      Restaurante(
        nombre: 'Mora Castilla',
        descripcion:
            'Herencia del Cauca. Especialidad en empanadas de pipián y carantantas.',
        ubicacion: const LatLng(2.4410, -76.6060),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Calle 4 #6-45, Centro Histórico, Popayán',
        horario: 'Lun – Sáb: 8:00 AM – 8:00 PM\nDom: 8:00 AM – 4:00 PM',
        rating: 4.4,
        numResenas: 189,
        precio: '\$',
      ),

      // --- Santa Marta ---
      Restaurante(
        nombre: 'Donde Chucho',
        descripcion:
            'Pescado frito, arroz con coco y patacones en la playa. Sabor samario auténtico.',
        ubicacion: const LatLng(11.2400, -74.2100),
        categoria: CategoriaRestaurante.tipico,
        direccion: 'Playa El Rodadero, Santa Marta',
        horario: 'Lun – Dom: 10:00 AM – 8:00 PM',
        rating: 4.4,
        numResenas: 345,
        precio: '\$\$',
      ),

      // ============================================================
      // 4. RESTAURANTES INTERNACIONALES (CategoriaRestaurante.internacional)
      // ============================================================

      // --- Bogotá (Alta Cocina / Fine Dining) ---
      // ========== RESTAURANTES INTERNACIONALES (CategoriaRestaurante.internacional) ==========

// --- Santa Marta (Magdalena) ---
      Restaurante(
        nombre: 'Ouzo Restaurante',
        descripcion:
            'Comida griega frente al mar. Especialidad en moussaka, souvlaki y baklava.',
        ubicacion: const LatLng(11.2400, -74.2100),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'El Rodadero, Santa Marta',
        horario: 'Mar – Dom: 12:00 PM – 10:00 PM\nLun: Cerrado',
        rating: 4.5,
        numResenas: 234,
        precio: '\$\$\$',
      ),

// --- San Andrés Islas ---
      Restaurante(
        nombre: 'Sea Flower',
        descripcion:
            'Cocina caribeña con influencia internacional. Especialidad en langosta, caracol y pescado fresco.',
        ubicacion: const LatLng(12.5800, -81.7000),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Sprat Bright, San Andrés Islas',
        horario: 'Lun – Dom: 11:00 AM – 9:00 PM',
        rating: 4.7,
        numResenas: 567,
        precio: '\$\$\$',
      ),

// --- Providencia ---
      Restaurante(
        nombre: 'Roland Root Bar',
        descripcion:
            'Cocina internacional con ingredientes locales en una isla paradisíaca. Ambiente rastafari.',
        ubicacion: const LatLng(13.3800, -81.3800),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Agua Dulce, Providencia',
        horario: 'Mar – Dom: 12:00 PM – 9:00 PM\nLun: Cerrado',
        rating: 4.8,
        numResenas: 234,
        precio: '\$\$\$',
      ),
      Restaurante(
        nombre: 'El Chato',
        descripcion:
            'El mejor restaurante de Latinoamérica 2025. Cocina contemporánea colombiana que combina ingredientes autóctonos con técnicas de vanguardia.',
        ubicacion: const LatLng(4.6305, -74.0645),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Carrera 4 #66-09, Chapinero Alto, Bogotá',
        horario: 'Mar – Sáb: 7:00 PM – 10:30 PM\nDom – Lun: Cerrado',
        rating: 4.9,
        numResenas: 567,
        precio: '\$\$\$\$',
      ),
      Restaurante(
        nombre: 'Leo',
        descripcion:
            'Exploración biocultural de Leonor Espinosa. Ingredientes ancestrales y biodiversidad colombiana en cada plato.',
        ubicacion: const LatLng(4.6380, -74.0620),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Calle 69A #5-75, Chapinero, Bogotá',
        horario: 'Mar – Sáb: 7:00 PM – 10:30 PM\nDom – Lun: Cerrado',
        rating: 4.9,
        numResenas: 623,
        precio: '\$\$\$\$',
      ),
      Restaurante(
        nombre: 'Harry Sasson',
        descripcion:
            'Alta cocina de autor con influencias mediterráneas, asiáticas y colombianas. Considerado uno de los mejores de Colombia.',
        ubicacion: const LatLng(4.6564, -74.0584),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Carrera 9 #75-70, Chicó, Bogotá',
        horario:
            'Mar – Jue: 12:30 PM – 10:30 PM\nVie – Sáb: 12:30 PM – 11:30 PM\nDom: 12:30 PM – 9:00 PM\nLun: Cerrado',
        rating: 4.8,
        numResenas: 567,
        precio: '\$\$\$\$',
      ),
      Restaurante(
        nombre: 'El Cielo',
        descripcion:
            'Experiencia multisensorial del primer colombiano con estrella Michelin. Juan Manuel Barrientos lleva la cocina colombiana al siguiente nivel.',
        ubicacion: const LatLng(4.6430, -74.0600),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Calle 70 #4-85, Chapinero, Bogotá',
        horario: 'Mar – Sáb: 7:00 PM – 11:00 PM\nDom – Lun: Cerrado',
        rating: 4.8,
        numResenas: 432,
        precio: '\$\$\$\$',
      ),
      Restaurante(
        nombre: 'Prudencia',
        descripcion:
            'Cocina artesanal en La Candelaria. Ahumados, fermentados y técnicas ancestrales con productos locales.',
        ubicacion: const LatLng(4.5980, -74.0730),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Calle 12 #2-25, La Candelaria, Bogotá',
        horario:
            'Mar – Sáb: 12:30 PM – 3:00 PM, 7:00 PM – 10:00 PM\nDom: 12:30 PM – 4:00 PM\nLun: Cerrado',
        rating: 4.7,
        numResenas: 298,
        precio: '\$\$\$\$',
      ),
      Restaurante(
        nombre: 'WOK',
        descripcion:
            'Cocina asiática de autor con influencias japonesas, chinas y tailandesas. Rolls, dumplings y currys espectaculares.',
        ubicacion: const LatLng(4.6720, -74.0550),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Calle 86 #12-34, El Chicó, Bogotá',
        horario: 'Lun – Sáb: 12:00 PM – 10:30 PM\nDom: 12:00 PM – 9:00 PM',
        rating: 4.5,
        numResenas: 456,
        precio: '\$\$\$',
      ),
      Restaurante(
        nombre: 'Hornitos',
        descripcion:
            'Auténtica cocina mexicana con tacos al pastor, enchiladas y margaritas artesanales. Ambiente colorido y familiar.',
        ubicacion: const LatLng(4.6650, -74.0580),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Calle 85 #12-34, El Nogal, Bogotá',
        horario:
            'Lun – Jue: 12:00 PM – 10:00 PM\nVie – Sáb: 12:00 PM – 11:30 PM\nDom: 12:00 PM – 9:00 PM',
        rating: 4.4,
        numResenas: 203,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Central Cevicheria',
        descripcion:
            'Especialista en ceviches peruanos y mariscos frescos. Reconocida por su leche de tigre y tiraditos.',
        ubicacion: const LatLng(4.6400, -74.0620),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Carrera 15 #88-45, Chicó Norte, Bogotá',
        horario: 'Mar – Dom: 12:00 PM – 9:00 PM\nLun: Cerrado',
        rating: 4.6,
        numResenas: 318,
        precio: '\$\$\$',
      ),
      Restaurante(
        nombre: 'La Bodega',
        descripcion:
            'Comida italiana auténtica con pastas frescas, pizzas al horno de leña y excelentes vinos. Ambiente acogedor.',
        ubicacion: const LatLng(4.6380, -74.0820),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Carrera 12 #68-55, Chapinero, Bogotá',
        horario:
            'Lun – Vie: 12:00 PM – 11:00 PM\nSáb – Dom: 1:00 PM – 10:00 PM',
        rating: 4.4,
        numResenas: 289,
        precio: '\$\$',
      ),

      // --- Medellín ---
      Restaurante(
        nombre: 'Carmen',
        descripcion:
            'La chef Carmen Ángel fusiona técnicas internacionales con productos colombianos. Ceviche del Pacífico y solomillo con papa andina.',
        ubicacion: const LatLng(6.2080, -75.5700),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Calle 10 #40-50, El Poblado, Medellín',
        horario:
            'Lun – Sáb: 12:00 PM – 3:00 PM, 7:00 PM – 10:00 PM\nDom: 12:00 PM – 4:00 PM',
        rating: 4.7,
        numResenas: 892,
        precio: '\$\$\$',
      ),
      Restaurante(
        nombre: 'El Cielo Medellín',
        descripcion:
            'Experiencia sensorial de Juan Manuel Barrientos. Cocina molecular y emociones en cada bocado.',
        ubicacion: const LatLng(6.2120, -75.5650),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Calle 10 #40-15, El Poblado, Medellín',
        horario:
            'Mar – Sáb: 7:00 PM – 11:00 PM\nDom: 12:00 PM – 3:00 PM\nLun: Cerrado',
        rating: 4.8,
        numResenas: 534,
        precio: '\$\$\$\$',
      ),
      Restaurante(
        nombre: 'Sambombi Bistró',
        descripcion:
            'Menú cambia cada 15 días con ingredientes frescos y de temporada. Cocina creativa y sorprendente.',
        ubicacion: const LatLng(6.2150, -75.5720),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Carrera 35 #8A-25, El Poblado, Medellín',
        horario: 'Mar – Sáb: 6:30 PM – 10:30 PM\nDom – Lun: Cerrado',
        rating: 4.7,
        numResenas: 234,
        precio: '\$\$\$',
      ),

      // --- Cartagena ---
      Restaurante(
        nombre: 'Celele',
        descripcion:
            'Cocina caribeña en Getsemaní. Conservación de recetas ancestrales y productos del Caribe colombiano.',
        ubicacion: const LatLng(10.4250, -75.5450),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Calle del Guerrero #29-80, Getsemaní, Cartagena',
        horario: 'Mar – Dom: 6:30 PM – 10:00 PM\nLun: Cerrado',
        rating: 4.8,
        numResenas: 423,
        precio: '\$\$\$',
      ),
      Restaurante(
        nombre: 'Carmen Cartagena',
        descripcion:
            'Ceviche del Pacífico y solomillo con papa andina. Ambiente elegante en el corazón de la ciudad amurallada.',
        ubicacion: const LatLng(10.4220, -75.5500),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Calle 36 #3-55, Centro Histórico, Cartagena',
        horario:
            'Lun – Sáb: 12:30 PM – 3:00 PM, 7:00 PM – 10:30 PM\nDom: 12:30 PM – 4:00 PM',
        rating: 4.7,
        numResenas: 567,
        precio: '\$\$\$\$',
      ),

      // --- Barranquilla ---
      Restaurante(
        nombre: 'Manuel',
        descripcion:
            'Destacado en 50 Best Latam 2025 puesto #46. Cocina caribeña con técnica y creatividad.',
        ubicacion: const LatLng(11.0000, -74.8100),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Carrera 54 #74-23, Alto Prado, Barranquilla',
        horario:
            'Mar – Sáb: 12:30 PM – 3:00 PM, 7:00 PM – 10:00 PM\nDom: 12:30 PM – 4:00 PM\nLun: Cerrado',
        rating: 4.7,
        numResenas: 345,
        precio: '\$\$\$',
      ),

      // --- Bucaramanga ---
      Restaurante(
        nombre: 'Battuto',
        descripcion:
            'Italiano inspirado con pizzas y risottos de alta calidad. Ambiente acogedor y elegante.',
        ubicacion: const LatLng(7.1200, -73.1200),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Carrera 33 #52-45, Cabecera, Bucaramanga',
        horario: 'Lun – Sáb: 12:00 PM – 10:00 PM\nDom: 12:00 PM – 8:00 PM',
        rating: 4.5,
        numResenas: 234,
        precio: '\$\$',
      ),
      Restaurante(
        nombre: 'Republicano',
        descripcion:
            'Cocina mediterránea en casa de los años 40. Ambiente vintage y platos cuidados.',
        ubicacion: const LatLng(7.1150, -73.1150),
        categoria: CategoriaRestaurante.internacional,
        direccion: 'Calle 55 #33-12, Cabecera, Bucaramanga',
        horario: 'Lun – Sáb: 12:00 PM – 10:30 PM\nDom: 12:00 PM – 9:00 PM',
        rating: 4.4,
        numResenas: 178,
        precio: '\$\$',
      ),
    ];
  }

  Future<void> _requestLocationPermission() async {
    try {
      await Permission.location.request();
      _getCurrentLocation();
    } catch (e) {}
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied)
        perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted)
        setState(() {
          _userLocation = LatLng(pos.latitude, pos.longitude);
          _locationEnabled = true;
        });
    } catch (e) {}
  }

  void _centerOnUser() {
    if (_userLocation != null) _mapController.move(_userLocation!, 15);
  }

  void _irAlLugarEnMapa(Restaurante r) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _mapController.move(r.ubicacion, 17);
    });
  }

  List<Restaurante> get _restaurantesFiltrados {
    final query = _searchQuery.trim().toLowerCase();
    return _restaurantes.where((r) {
      if (_categoriaSeleccionada != null &&
          r.categoria != _categoriaSeleccionada) return false;
      if (query.isEmpty) return true;
      return r.nombre.toLowerCase().contains(query) ||
          r.descripcion.toLowerCase().contains(query) ||
          r.direccion.toLowerCase().contains(query) ||
          r.categoria.nombre.toLowerCase().contains(query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    final f = _restaurantesFiltrados;
    if (f.isNotEmpty) _mapController.move(f.first.ubicacion, 15);
  }

  void _limpiarBusqueda() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    _mapController.move(_initialPosition, 12);
  }

  void _seleccionarCategoria(CategoriaRestaurante categoria) {
    setState(() {
      _categoriaSeleccionada =
          _categoriaSeleccionada == categoria ? null : categoria;
      _searchQuery = '';
      _searchController.clear();
    });
    final f = _restaurantesFiltrados;
    _mapController.move(f.isNotEmpty ? f.first.ubicacion : _initialPosition,
        f.isNotEmpty ? 13 : 12);
  }

  void _mostrarInfoRestaurante(Restaurante r) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.55),
        builder: (context) => _BottomSheetGastronomia(
            restaurante: r, onIrAlMapa: () => _irAlLugarEnMapa(r)));
  }

  void _mostrarInfoRestaurantePorNombre(String nombre) {
    try {
      final r = _restaurantes.firstWhere(
          (r) => r.nombre.toLowerCase().contains(nombre.toLowerCase()));
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _mostrarInfoRestaurante(r);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dark = appState.modoOscuro;
    final sinResultados =
        _restaurantesFiltrados.isEmpty && _searchQuery.isNotEmpty;

    return Scaffold(
      endDrawer: const AppDrawer(pantallaActual: AppDrawer.gastronomia),
      body: Builder(
          builder: (context) => LayoutBuilder(
                builder: (context, constraints) {
                  final screenH = constraints.maxHeight;
                  final screenW = constraints.maxWidth;
                  final logoH = screenH * 0.14;
                  final logoTop = -(logoH * 0.15);
                  final titleTop = logoH * 0.82;
                  final searchTop = logoH * 0.82 + 38.0;
                  final mapTop = searchTop + (sinResultados ? 96.0 : 50.0);
                  final bottomBar = screenH * 0.27;
                  final mapBottom = bottomBar + 4;

                  return Stack(children: [
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
                    Positioned(
                        top: logoTop,
                        left: 0,
                        right: 0,
                        child: Center(
                            child: SizedBox(
                                width: logoH,
                                height: logoH,
                                child: Image.asset('assets/images/logo.png',
                                    fit: BoxFit.contain)))),
                    Positioned(
                        top: titleTop,
                        left: 0,
                        right: 0,
                        child: Center(
                            child: Text(appState.t('gastronomia'),
                                style: TextStyle(
                                    fontSize: screenW < 360 ? 22 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                          blurRadius: 10,
                                          color: Colors.black,
                                          offset: Offset(2, 2))
                                    ])))),
                    Positioned(
                        top: searchTop,
                        left: 16,
                        right: 16,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                      color: dark
                                          ? Colors.grey[800]!.withValues(alpha: .95)
                                          : Colors.white.withValues(alpha: .95),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 10)
                                      ]),
                                  child: TextField(
                                      controller: _searchController,
                                      onChanged: _onSearchChanged,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: dark
                                              ? Colors.white
                                              : Colors.black),
                                      decoration: InputDecoration(
                                          hintText: 'Buscar restaurantes...',
                                          hintStyle: TextStyle(
                                              fontSize: 13,
                                              color: dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[500]),
                                          prefixIcon: Icon(Icons.search,
                                              color: dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[500],
                                              size: 20),
                                          suffixIcon: _searchQuery.isNotEmpty
                                              ? IconButton(icon: Icon(Icons.clear, color: dark ? Colors.grey[400] : Colors.grey[500], size: 18), onPressed: _limpiarBusqueda)
                                              : null,
                                          border: InputBorder.none,
                                          isCollapsed: true,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 12)))),
                              if (sinResultados)
                                Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.red.shade50
                                            .withValues(alpha: .95),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.red.shade200)),
                                    child: Row(children: [
                                      const Icon(Icons.search_off,
                                          color: Colors.red, size: 16),
                                      const SizedBox(width: 8),
                                      Flexible(
                                          child: Text(
                                              'No se encontró "$_searchQuery"',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red),
                                              overflow: TextOverflow.ellipsis))
                                    ])),
                            ])),
                    Positioned(
                        top: mapTop,
                        left: 20,
                        right: 20,
                        bottom: mapBottom,
                        child: _buildMap(dark)),
                    if (_locationEnabled)
                      Positioned(
                          bottom: mapBottom + 10,
                          right: 30,
                          child: FloatingActionButton.small(
                              onPressed: _centerOnUser,
                              backgroundColor: Colors.white,
                              child: const Icon(Icons.my_location,
                                  color: Colors.blue))),
                    _buildCategoryButtons(appState, screenH, dark),
                    _buildExploreButton(context, appState, screenH),
                    SafeArea(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: .2),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: IconButton(
                                          icon: const Icon(Icons.menu,
                                              color: Colors.black87, size: 28),
                                          onPressed: () => Scaffold.of(context)
                                              .openEndDrawer())),
                                ]))),
                  ]);
                },
              )),
    );
  }

  Widget _buildMap(bool dark) => Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
          ]),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: FlutterMap(
              mapController: _mapController,
              options:
                  MapOptions(initialCenter: _initialPosition, initialZoom: 12),
              children: [
                TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.colombia_go'),
                if (_userLocation != null)
                  MarkerLayer(markers: [
                    Marker(
                        point: _userLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.my_location,
                                color: Colors.blue, size: 30)))
                  ]),
                MarkerLayer(
                    markers: _restaurantesFiltrados
                        .map((r) => Marker(
                            point: r.ubicacion,
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                                onTap: () => _mostrarInfoRestaurante(r),
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: r.categoria.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4)
                                        ]),
                                    child: Icon(r.categoria.icono,
                                        color: Colors.white, size: 20)))))
                        .toList()),
              ])));

  Widget _buildCategoryButtons(AppState appState, double screenH, bool dark) =>
      Positioned(
          bottom: screenH * 0.12,
          left: 25,
          right: 25,
          child: SizedBox(
              height: screenH * 0.145,
              child: Row(children: [
                Expanded(
                    child: Column(children: [
                  _btn(appState.t('cat_cafes'), Icons.coffee,
                      CategoriaRestaurante.cafeteria, dark),
                  const SizedBox(height: 10),
                  _btn(appState.t('cat_mercados'), Icons.storefront,
                      CategoriaRestaurante.mercado, dark),
                ])),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(children: [
                  _btn(appState.t('cat_restaurantes_tipicos'), Icons.restaurant,
                      CategoriaRestaurante.tipico, dark),
                  const SizedBox(height: 10),
                  _btn(appState.t('cat_restaurantes_inter'), Icons.public,
                      CategoriaRestaurante.internacional, dark),
                ])),
              ])));

  Widget _btn(
      String texto, IconData icono, CategoriaRestaurante categoria, bool dark) {
    final isSelected = _categoriaSeleccionada == categoria;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: dark
              ? Colors.grey[850]!.withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isSelected ? categoria.color : Colors.transparent,
              width: 2),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => _seleccionarCategoria(categoria),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono,
                    color: isSelected ? categoria.color : Colors.blue,
                    size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    texto,
                    style: TextStyle(
                      color: isSelected
                          ? categoria.color
                          : (dark ? Colors.white70 : Colors.black87),
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExploreButton(
          BuildContext context, AppState appState, double screenH) =>
      Positioned(
        bottom: screenH * 0.04,
        left: 25,
        right: 25,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
              color: Colors.grey.shade600.withOpacity(0.75),
              borderRadius: BorderRadius.circular(25)),
          child: TextButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => const DespuesGastronomiaScreen())),
            child: Text(appState.t('explorar'),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      );
}

// BOTTOM SHEET
class _BottomSheetGastronomia extends StatefulWidget {
  final Restaurante restaurante;
  final VoidCallback onIrAlMapa;
  const _BottomSheetGastronomia(
      {required this.restaurante, required this.onIrAlMapa});
  @override
  State<_BottomSheetGastronomia> createState() =>
      _BottomSheetGastronomiaState();
}

class _BottomSheetGastronomiaState extends State<_BottomSheetGastronomia> {
  bool _esFavorito = false;
  bool _cargando = true;
  static const Color _gold = Color(0xFFFFBB02);
  @override
  void initState() {
    super.initState();
    FavoritosService().esFavorito(widget.restaurante.nombre).then((v) {
      if (mounted)
        setState(() {
          _esFavorito = v;
          _cargando = false;
        });
    });
  }

  Future<void> _toggleFav() async {
    setState(() => _cargando = true);
    final nuevo = await FavoritosService().toggleFavorito(
        nombre: widget.restaurante.nombre,
        categoria: 'Gastronomía',
        subcategoria: widget.restaurante.categoria.nombre,
        lat: widget.restaurante.ubicacion.latitude,
        lng: widget.restaurante.ubicacion.longitude,
        imagePath: '');
    if (mounted) {
      setState(() {
        _esFavorito = nuevo;
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              nuevo ? '❤️ Guardado en favoritos' : '💔 Eliminado de favoritos'),
          duration: const Duration(seconds: 2),
          backgroundColor: nuevo ? Colors.green : Colors.grey[700]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.restaurante;
    return DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (_, sc) => Container(
            decoration: BoxDecoration(
                color: dark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32))),
            child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                child: ListView(
                    controller: sc,
                    padding: EdgeInsets.zero,
                    children: [
                      Center(
                          child: Container(
                              margin:
                                  const EdgeInsets.only(top: 12, bottom: 12),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: dark
                                      ? Colors.grey[700]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4)))),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFBB02),
                                    Color(0xFFF5C400)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFFFFBB02)
                                        .withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6))
                              ]),
                          child: Stack(children: [
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 60, 20),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(r.categoria.icono,
                                                    color: Colors.black87,
                                                    size: 13),
                                                const SizedBox(width: 5),
                                                Text(r.categoria.nombre,
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700))
                                              ])),
                                      const SizedBox(height: 10),
                                      Text(r.nombre,
                                          style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black87,
                                              height: 1.2)),
                                      const SizedBox(height: 10),
                                      Row(children: [
                                        ...List.generate(
                                            5,
                                            (i) => Icon(
                                                i < r.rating.floor()
                                                    ? Icons.star_rounded
                                                    : (i < r.rating
                                                        ? Icons
                                                            .star_half_rounded
                                                        : Icons
                                                            .star_outline_rounded),
                                                color: Colors.black87,
                                                size: 18)),
                                        const SizedBox(width: 6),
                                        Text('${r.rating}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                                color: Colors.black87)),
                                        const SizedBox(width: 4),
                                        Text('(${r.numResenas} reseñas)',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.black
                                                    .withOpacity(0.5))),
                                        const Spacer(),
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.10),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Text(r.precio,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13,
                                                    color: Colors.black87))),
                                      ]),
                                    ])),
                            Positioned(
                                top: 14,
                                right: 14,
                                child: GestureDetector(
                                    onTap: _cargando ? null : _toggleFav,
                                    child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withValues(alpha: .25),
                                            shape: BoxShape.circle),
                                        child: _cargando
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white))
                                            : Icon(
                                                _esFavorito
                                                    ? Icons.favorite_rounded
                                                    : Icons
                                                        .favorite_border_rounded,
                                                color: _esFavorito
                                                    ? Colors.red
                                                    : Colors.black87,
                                                size: 22)))),
                          ])),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _getTagsPorCategoria(r.categoria)
                                        .map((tag) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFFFF8E1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFFFFBB02),
                                                    width: 1)),
                                            child: Text(tag,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFF5C400)))))
                                        .toList()),
                                const SizedBox(height: 16),
                                Text(r.descripcion,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: dark
                                            ? Colors.grey[400]
                                            : Colors.grey[700],
                                        height: 1.6)),
                                const SizedBox(height: 18),
                                Divider(
                                    color: dark
                                        ? Colors.grey[800]
                                        : const Color(0xFFEEEEEE)),
                                const SizedBox(height: 14),
                                _infoRow(
                                    context: context,
                                    icono: Icons.access_time_rounded,
                                    label: 'Horario',
                                    valor: r.horario),
                                const SizedBox(height: 14),
                                _infoRow(
                                    context: context,
                                    icono: Icons.location_on_rounded,
                                    label: 'Dirección',
                                    valor: r.direccion),
                                const SizedBox(height: 24),
                                Row(children: [
                                  Expanded(
                                      child: ElevatedButton.icon(
                                          onPressed: widget.onIrAlMapa,
                                          icon: const Icon(Icons.map_rounded,
                                              size: 18),
                                          label: const Text('Cómo llegar'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFFFDB0D),
                                              foregroundColor: Colors.black87,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
                                              elevation: 0,
                                              textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13)))),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
                                              backgroundColor: dark
                                                  ? const Color(0xFF2C2C2C)
                                                  : const Color(0xFFF5F5F5)),
                                          child: Text('Cerrar',
                                              style: TextStyle(
                                                  color: dark
                                                      ? Colors.grey[400]
                                                      : Colors.black54,
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w600)))),
                                ]),
                              ])),
                    ]))));
  }

  Widget _infoRow(
      {required BuildContext context,
      required IconData icono,
      required String label,
      required String valor}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icono, size: 16, color: _gold)),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: dark ? Colors.grey[500] : Colors.grey,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 3),
        Text(valor,
            style: TextStyle(
                fontSize: 13,
                color: dark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.5)),
      ])),
    ]);
  }

  List<String> _getTagsPorCategoria(CategoriaRestaurante cat) {
    switch (cat) {
      case CategoriaRestaurante.cafeteria:
        return ['Café', 'Repostería', 'Desayunos'];
      case CategoriaRestaurante.mercado:
        return ['Frutas', 'Tradicional', 'Artesanal'];
      case CategoriaRestaurante.tipico:
        return ['Colombiano', 'Casero', 'Típico'];
      case CategoriaRestaurante.internacional:
        return ['Internacional', 'Alta cocina', 'Fusión'];
    }
  }
}
