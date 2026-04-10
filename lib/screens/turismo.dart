import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'app_state.dart';
import 'app_drawer.dart';
import 'despues_turismo.dart';
import 'favoritos_service.dart';

enum CategoriaTurismo { parques, monumentos, lugarespueblos, playas }

extension CategoriaTurismoExtension on CategoriaTurismo {
  String get nombre {
    switch (this) {
      case CategoriaTurismo.parques:
        return 'Parques Naturales';
      case CategoriaTurismo.monumentos:
        return 'Monumentos';
      case CategoriaTurismo.lugarespueblos:
        return 'Lugares y Pueblos';
      case CategoriaTurismo.playas:
        return 'Playas';
    }
  }

  Color get color {
    switch (this) {
      case CategoriaTurismo.parques:
        return Colors.green;
      case CategoriaTurismo.monumentos:
        return Colors.brown;
      case CategoriaTurismo.lugarespueblos:
        return Colors.teal;
      case CategoriaTurismo.playas:
        return Colors.blue;
    }
  }

  IconData get icono {
    switch (this) {
      case CategoriaTurismo.parques:
        return Icons.nature;
      case CategoriaTurismo.monumentos:
        return Icons.account_balance;
      case CategoriaTurismo.lugarespueblos:
        return Icons.explore;
      case CategoriaTurismo.playas:
        return Icons.beach_access;
    }
  }
}

class LugarTurismo {
  final String nombre, descripcion, direccion, horario;
  final LatLng ubicacion;
  final CategoriaTurismo categoria;
  final double calificacion;
  final int numResenas;

  LugarTurismo({
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.categoria,
    required this.direccion,
    required this.horario,
    required this.calificacion,
    this.numResenas = 120,
  });
}

class TurismoScreen extends StatefulWidget {
  final LatLng? ubicacionInicial;
  final String? lugarSeleccionado;
  const TurismoScreen(
      {super.key, this.ubicacionInicial, this.lugarSeleccionado});

  @override
  State<TurismoScreen> createState() => _TurismoScreenState();
}

class _TurismoScreenState extends State<TurismoScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialPosition = const LatLng(4.5709, -74.2973);
  final TextEditingController _searchController = TextEditingController();
  LatLng? _userLocation;
  bool _locationEnabled = false;
  String _searchQuery = '';
  CategoriaTurismo? _categoriaSeleccionada;
  late List<LugarTurismo> _lugares;

  @override
  void initState() {
    super.initState();
    _initLugares();
    _requestLocationPermission();
    if (widget.ubicacionInicial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(widget.ubicacionInicial!, 16);
        if (widget.lugarSeleccionado != null)
          _mostrarInfoLugarPorNombre(widget.lugarSeleccionado!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initLugares() {
    _lugares = [
      LugarTurismo(
        nombre: 'Parque Nacional Natural Tayrona',
        descripcion:
            'Paraíso caribeño donde la selva se encuentra con el mar. Playas vírgenes, senderos ecológicos y biodiversidad única.',
        ubicacion: const LatLng(11.3150, -74.0270),
        categoria: CategoriaTurismo.parques,
        direccion: 'Santa Marta, Magdalena',
        horario: 'Mar-Dom: 8am-5pm (cierra 1-15 feb y 1-15 jun)',
        calificacion: 4.9,
        numResenas: 7400,
      ),
      LugarTurismo(
        nombre: 'Parque Nacional Natural El Cocuy',
        descripcion:
            'El conjunto glaciar más grande de Colombia. Picos que superan los 5.300 msnm. Ideal para montañismo y senderismo.',
        ubicacion: const LatLng(6.4333, -72.2833),
        categoria: CategoriaTurismo.parques,
        direccion: 'Sierra Nevada del Cocuy, Boyacá',
        horario: 'Requiere registro previo y guía obligatorio',
        calificacion: 4.9,
        numResenas: 980,
      ),
      LugarTurismo(
        nombre: 'Parque Nacional Natural Los Nevados',
        descripcion:
            'Parque con volcanes nevados como el Ruiz, Santa Isabel y Tolima. Páramos, lagunas y frailejones en el Eje Cafetero.',
        ubicacion: const LatLng(4.8220, -75.3840),
        categoria: CategoriaTurismo.parques,
        direccion: 'Entre Caldas, Risaralda, Quindío y Tolima',
        horario: 'Lun-Dom: 6am-5pm (requiere guía)',
        calificacion: 4.8,
        numResenas: 2100,
      ),
      LugarTurismo(
        nombre: 'Parque Nacional Natural Chingaza',
        descripcion:
            'Ecosistema de páramo con frailejones y lagunas glaciares. Provee el agua para Bogotá.',
        ubicacion: const LatLng(4.6333, -73.7500),
        categoria: CategoriaTurismo.parques,
        direccion: 'Vía La Calera - El Calvario, Cundinamarca',
        horario: 'Mié-Dom: 8am-2pm (requiere reserva)',
        calificacion: 4.7,
        numResenas: 1200,
      ),
      LugarTurismo(
        nombre: 'Parque Nacional Natural Puracé',
        descripcion:
            'Volcán activo rodeado de páramos y aguas termales. Nacen los ríos Magdalena, Cauca, Caquetá y Patía.',
        ubicacion: const LatLng(2.3200, -76.4000),
        categoria: CategoriaTurismo.parques,
        direccion: 'Vía Popayán - Puracé, Cauca',
        horario: 'Lun-Dom: 7am-5pm',
        calificacion: 4.6,
        numResenas: 890,
      ),
      LugarTurismo(
        nombre: 'Parque Nacional Natural Pisba',
        descripcion:
            'Parque con importancia histórica por la "Ruta Libertadora" de Simón Bolívar en 1819.',
        ubicacion: const LatLng(5.8667, -72.5500),
        categoria: CategoriaTurismo.parques,
        direccion: 'Municipios de Pisba, Mongua, Tasco, Socha y Socotá, Boyacá',
        horario: 'Requiere permiso de ingreso',
        calificacion: 4.5,
        numResenas: 450,
      ),
      LugarTurismo(
        nombre: 'Santuario de Fauna y Flora Iguaque',
        descripcion:
            'Laguna sagrada para la cultura muisca. Según la leyenda, de sus aguas emergió Bachué, madre de la humanidad.',
        ubicacion: const LatLng(5.7000, -73.4500),
        categoria: CategoriaTurismo.parques,
        direccion: 'Vía Villa de Leyva - Arcabuco, Boyacá',
        horario: 'Mar-Dom: 7am-4pm',
        calificacion: 4.7,
        numResenas: 780,
      ),
      LugarTurismo(
        nombre: 'Santuario de Fauna y Flora Los Flamencos',
        descripcion:
            'Hábitat de flamencos rosados en la Guajira. Lagunas costeras y aves migratorias.',
        ubicacion: const LatLng(11.7333, -72.2833),
        categoria: CategoriaTurismo.parques,
        direccion: 'Camino a Riohacha, La Guajira',
        horario: 'Lun-Dom: 7am-5pm',
        calificacion: 4.6,
        numResenas: 560,
      ),
      LugarTurismo(
        nombre: 'Parque Nacional Natural Utría',
        descripcion:
            'Santuario de ballenas jorobadas en el Pacífico colombiano. Manglares, arrecifes y biodiversidad marina.',
        ubicacion: const LatLng(6.0167, -77.3500),
        categoria: CategoriaTurismo.parques,
        direccion: 'El Valle, Chocó',
        horario: 'Lun-Dom: 7am-5pm (mejor época: jul-oct)',
        calificacion: 4.8,
        numResenas: 670,
      ),
      LugarTurismo(
        nombre: 'Parque Nacional Natural Gorgona',
        descripcion:
            'Isla-prisión convertida en paraíso natural. Buceo con tiburones ballena y serpientes endémicas.',
        ubicacion: const LatLng(2.9700, -78.1840),
        categoria: CategoriaTurismo.parques,
        direccion: 'Frente a Guapi, Cauca',
        horario: 'Requiere reserva con anticipación',
        calificacion: 4.9,
        numResenas: 520,
      ),
      LugarTurismo(
        nombre: 'Parque Nacional Natural Amacayacu',
        descripcion:
            'Selva amazónica con delfines rosados, monos y plantas medicinales. Comunidades indígenas tikuna.',
        ubicacion: const LatLng(-3.4833, -70.2000),
        categoria: CategoriaTurismo.parques,
        direccion: 'Leticia, Amazonas',
        horario: 'Lun-Dom: 8am-5pm',
        calificacion: 4.7,
        numResenas: 890,
      ),
      LugarTurismo(
        nombre: 'Castillo San Felipe de Barajas',
        descripcion:
            'La fortaleza más grande construida por los españoles en sus colonias. Patrimonio de la Humanidad por la UNESCO.',
        ubicacion: const LatLng(10.4225, -75.5408),
        categoria: CategoriaTurismo.monumentos,
        direccion: 'Avenida Pedro Heredia, Cartagena',
        horario: 'Lun-Dom: 8am-6pm',
        calificacion: 4.8,
        numResenas: 5600,
      ),
      LugarTurismo(
        nombre: 'Catedral de Sal de Zipaquirá',
        descripcion:
            'Impresionante catedral subterránea construida dentro de una mina de sal. Primera Maravilla de Colombia.',
        ubicacion: const LatLng(5.0225, -74.0092),
        categoria: CategoriaTurismo.monumentos,
        direccion: 'Zipaquirá, Cundinamarca',
        horario: 'Lun-Dom: 9am-6:30pm',
        calificacion: 4.8,
        numResenas: 4200,
      ),
      LugarTurismo(
        nombre: 'Santuario de Las Lajas',
        descripcion:
            'Basílica construida dentro del cañón del río Guáitara. Considerada una de las iglesias más bellas del mundo.',
        ubicacion: const LatLng(0.8056, -77.5856),
        categoria: CategoriaTurismo.monumentos,
        direccion: 'Ipiales, Nariño',
        horario: 'Lun-Dom: 6am-6pm',
        calificacion: 4.9,
        numResenas: 3100,
      ),
      LugarTurismo(
        nombre: 'Teatro Colón',
        descripcion:
            'Teatro histórico de Bogotá, joya arquitectónica de estilo neoclásico. Uno de los más importantes de América Latina.',
        ubicacion: const LatLng(4.6000, -74.0740),
        categoria: CategoriaTurismo.monumentos,
        direccion: 'Calle 10 #5-32, Bogotá',
        horario: 'Visitas guiadas Lun-Vie: 9am-5pm',
        calificacion: 4.7,
        numResenas: 980,
      ),
      LugarTurismo(
        nombre: 'Puente de Boyacá',
        descripcion:
            'Puente histórico donde ocurrió la Batalla de Boyacá el 7 de agosto de 1819, sellando la independencia de Colombia.',
        ubicacion: const LatLng(5.4531, -73.3903),
        categoria: CategoriaTurismo.monumentos,
        direccion: 'Vía Tunja - Bogotá, Boyacá',
        horario: 'Lun-Dom: 8am-5pm',
        calificacion: 4.6,
        numResenas: 2100,
      ),
      LugarTurismo(
        nombre: 'Iglesia de San Francisco',
        descripcion:
            'Iglesia colonial del siglo XVI en el centro de Bogotá. Su altar mayor es una obra maestra del barroco.',
        ubicacion: const LatLng(4.5985, -74.0725),
        categoria: CategoriaTurismo.monumentos,
        direccion: 'Carrera 7 #15-45, Bogotá',
        horario: 'Lun-Dom: 7am-7pm',
        calificacion: 4.5,
        numResenas: 890,
      ),
      LugarTurismo(
        nombre: 'Monasterio de La Popa',
        descripcion:
            'Monasterio en la cima de una montaña en Cartagena. Vista panorámica de toda la ciudad.',
        ubicacion: const LatLng(10.4167, -75.5333),
        categoria: CategoriaTurismo.monumentos,
        direccion: 'Cerro de La Popa, Cartagena',
        horario: 'Lun-Dom: 8am-5pm',
        calificacion: 4.6,
        numResenas: 1450,
      ),
      LugarTurismo(
        nombre: 'Paredón de los Mártires',
        descripcion:
            'Sitio histórico donde fueron fusilados los próceres de la independencia en 1816.',
        ubicacion: const LatLng(4.5975, -74.0760),
        categoria: CategoriaTurismo.monumentos,
        direccion: 'Plaza de los Mártires, Bogotá',
        horario: '24 horas',
        calificacion: 4.4,
        numResenas: 560,
      ),
      LugarTurismo(
        nombre: 'Barichara',
        descripcion:
            'Considerado el pueblo más bonito de Colombia. Calles empedradas, casas blancas y miradores espectaculares.',
        ubicacion: const LatLng(6.6350, -73.2200),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Barichara, Santander',
        horario: '24 horas',
        calificacion: 4.9,
        numResenas: 4500,
      ),
      LugarTurismo(
        nombre: 'Villa de Leyva',
        descripcion:
            'Pueblo colonial con la plaza principal más grande de Colombia. Calles empedradas y arquitectura blanca.',
        ubicacion: const LatLng(5.6300, -73.5200),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Villa de Leyva, Boyacá',
        horario: '24 horas',
        calificacion: 4.8,
        numResenas: 8900,
      ),
      LugarTurismo(
        nombre: 'Salento',
        descripcion:
            'Pueblo colorido del Eje Cafetero. Puerta de entrada al Valle de Cocora y sus palmas de cera.',
        ubicacion: const LatLng(4.6370, -75.5700),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Salento, Quindío',
        horario: '24 horas',
        calificacion: 4.8,
        numResenas: 6700,
      ),
      LugarTurismo(
        nombre: 'Filandia',
        descripcion:
            'Pueblo tradicional cafetero con mirador del Quindío. Famoso por su arquitectura y cestería artesanal.',
        ubicacion: const LatLng(4.6700, -75.6580),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Filandia, Quindío',
        horario: '24 horas',
        calificacion: 4.7,
        numResenas: 3400,
      ),
      LugarTurismo(
        nombre: 'Jardín',
        descripcion:
            'Uno de los pueblos más bonitos de Antioquia. Balcones floridos y la Basílica de la Inmaculada Concepción.',
        ubicacion: const LatLng(5.6000, -75.8200),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Jardín, Antioquia',
        horario: '24 horas',
        calificacion: 4.8,
        numResenas: 3200,
      ),
      LugarTurismo(
        nombre: 'Santa Fe de Antioquia',
        descripcion:
            'Primera capital de Antioquia. Puente colonial de Occidente y arquitectura colonial.',
        ubicacion: const LatLng(6.5600, -75.8300),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Santa Fe de Antioquia, Antioquia',
        horario: '24 horas',
        calificacion: 4.7,
        numResenas: 2800,
      ),
      LugarTurismo(
        nombre: 'Mompox',
        descripcion:
            'Pueblo mágico a orillas del río Magdalena. Patrimonio de la Humanidad por la UNESCO.',
        ubicacion: const LatLng(9.2400, -74.4300),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Santa Cruz de Mompox, Bolívar',
        horario: '24 horas',
        calificacion: 4.8,
        numResenas: 2100,
      ),
      LugarTurismo(
        nombre: 'San Gil',
        descripcion:
            'Capital turística de Santander. Centro de deportes extremos: rafting, parapente y espeleología.',
        ubicacion: const LatLng(6.5600, -73.1400),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'San Gil, Santander',
        horario: '24 horas',
        calificacion: 4.7,
        numResenas: 3100,
      ),
      LugarTurismo(
        nombre: 'Guatavita',
        descripcion:
            'Famoso por su laguna sagrada, donde se originó la leyenda de El Dorado.',
        ubicacion: const LatLng(4.9300, -73.8300),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Guatavita, Cundinamarca',
        horario: '24 horas',
        calificacion: 4.6,
        numResenas: 1900,
      ),
      LugarTurismo(
        nombre: 'Monguí',
        descripcion:
            'Pueblo conocido por sus artesanías en lana y el puente colonial más antiguo de América (El Arco).',
        ubicacion: const LatLng(5.7200, -72.8500),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Monguí, Boyacá',
        horario: '24 horas',
        calificacion: 4.7,
        numResenas: 1200,
      ),
      LugarTurismo(
        nombre: 'Ráquira',
        descripcion:
            'El pueblo más colorido de Colombia. Capital artesanal del país, famoso por sus artesanías en barro.',
        ubicacion: const LatLng(5.5314, -73.6349),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Ráquira, Boyacá',
        horario: 'Lun-Dom: 8am-6pm',
        calificacion: 4.7,
        numResenas: 2100,
      ),
      LugarTurismo(
        nombre: 'Salamina',
        descripcion:
            'Pueblo Patrimonio de Colombia. Arquitectura colonial con bahareque y balcones.',
        ubicacion: const LatLng(5.4200, -75.4900),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Salamina, Caldas',
        horario: '24 horas',
        calificacion: 4.6,
        numResenas: 890,
      ),
      LugarTurismo(
        nombre: 'Aguadas',
        descripcion:
            'Conocido como "El Balcón del Occidente Caldense". Famoso por sus artesanías en caña flecha.',
        ubicacion: const LatLng(5.3100, -75.4800),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Aguadas, Caldas',
        horario: '24 horas',
        calificacion: 4.5,
        numResenas: 780,
      ),
      LugarTurismo(
        nombre: 'Curití',
        descripcion:
            'Pueblo encantador cerca del Cañón del Chicamocha. Conocido por sus telares artesanales.',
        ubicacion: const LatLng(6.6050, -73.0700),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Curití, Santander',
        horario: '24 horas',
        calificacion: 4.5,
        numResenas: 560,
      ),
      LugarTurismo(
        nombre: 'San Agustín',
        descripcion:
            'Parque arqueológico con estatuas precolombinas. Patrimonio de la Humanidad por la UNESCO.',
        ubicacion: const LatLng(1.8800, -76.2700),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'San Agustín, Huila',
        horario: 'Lun-Dom: 8am-4pm',
        calificacion: 4.8,
        numResenas: 2300,
      ),
      LugarTurismo(
        nombre: 'Tierradentro',
        descripcion:
            'Parque arqueológico con hipogeos (tumbas subterráneas) pintadas. Patrimonio de la Humanidad.',
        ubicacion: const LatLng(2.5833, -76.0333),
        categoria: CategoriaTurismo.lugarespueblos,
        direccion: 'Inzá, Cauca',
        horario: 'Lun-Dom: 8am-4pm',
        calificacion: 4.7,
        numResenas: 890,
      ),
      LugarTurismo(
        nombre: 'Cabo San Juan del Guía',
        descripcion:
            'Una de las playas más hermosas del Parque Tayrona. Mirador natural con vista panorámica al mar Caribe.',
        ubicacion: const LatLng(11.2900, -74.0500),
        categoria: CategoriaTurismo.playas,
        direccion: 'Interior Parque Tayrona, Santa Marta',
        horario: 'Mar-Dom: 8am-4pm',
        calificacion: 4.9,
        numResenas: 3400,
      ),
      LugarTurismo(
        nombre: 'Playa El Rodadero',
        descripcion:
            'La playa más concurrida de Santa Marta. Ideal para familias, con excelente infraestructura turística.',
        ubicacion: const LatLng(11.2200, -74.1800),
        categoria: CategoriaTurismo.playas,
        direccion: 'El Rodadero, Santa Marta',
        horario: 'Lun-Dom: 24 horas',
        calificacion: 4.5,
        numResenas: 3100,
      ),
      LugarTurismo(
        nombre: 'Playa Blanca',
        descripcion:
            'Playa de arena blanca y aguas cristalinas en Isla Barú. Un paraíso tropical cerca de Cartagena.',
        ubicacion: const LatLng(10.2800, -75.7100),
        categoria: CategoriaTurismo.playas,
        direccion: 'Isla Barú, Cartagena',
        horario: 'Lun-Dom: 8am-5pm',
        calificacion: 4.8,
        numResenas: 4700,
      ),
      LugarTurismo(
        nombre: 'Playa Spratt Bright',
        descripcion:
            'Playa principal de San Andrés en el sector de Spratt Bright. Arena blanca y mar de 7 colores.',
        ubicacion: const LatLng(12.5800, -81.6980),
        categoria: CategoriaTurismo.playas,
        direccion: 'Spratt Bright, San Andrés Islas',
        horario: 'Lun-Dom: 24 horas',
        calificacion: 4.6,
        numResenas: 2900,
      ),
      LugarTurismo(
        nombre: 'Playa de San Luis',
        descripcion:
            'Playa tranquila en San Andrés. Ideal para descansar y practicar snorkel.',
        ubicacion: const LatLng(12.5500, -81.7200),
        categoria: CategoriaTurismo.playas,
        direccion: 'San Luis, San Andrés Islas',
        horario: 'Lun-Dom: 24 horas',
        calificacion: 4.7,
        numResenas: 1800,
      ),
      LugarTurismo(
        nombre: 'Playa La Boquilla',
        descripcion:
            'Playa al norte de Cartagena. Ideal para practicar kitesurf y disfrutar del atardecer.',
        ubicacion: const LatLng(10.4500, -75.5300),
        categoria: CategoriaTurismo.playas,
        direccion: 'La Boquilla, Cartagena',
        horario: 'Lun-Dom: 24 horas',
        calificacion: 4.4,
        numResenas: 1200,
      ),
      LugarTurismo(
        nombre: 'Playa El Cabo San Juan',
        descripcion:
            'Hermosa playa con aguas turquesas y rocas imponentes. Una de las mejores del Tayrona.',
        ubicacion: const LatLng(11.2870, -74.0480),
        categoria: CategoriaTurismo.playas,
        direccion: 'Parque Tayrona, Santa Marta',
        horario: 'Mar-Dom: 8am-4pm',
        calificacion: 4.9,
        numResenas: 2100,
      ),
      LugarTurismo(
        nombre: 'Playa Cristal',
        descripcion:
            'Playa con aguas cristalinas en la Guajira. Perfecta para snorkel y buceo.',
        ubicacion: const LatLng(11.8600, -71.4200),
        categoria: CategoriaTurismo.playas,
        direccion: 'Cabo de la Vela, La Guajira',
        horario: 'Lun-Dom: 24 horas',
        calificacion: 4.7,
        numResenas: 890,
      ),
      LugarTurismo(
          nombre: 'Parque Simón Bolívar',
          descripcion:
              'Gran parque urbano ideal para deportes, recreación y eventos masivos. Pulmón verde de Bogotá.',
          ubicacion: const LatLng(4.6580, -74.0940),
          categoria: CategoriaTurismo.parques,
          direccion: 'Calle 63, Bogotá',
          horario: 'Lun-Dom: 5am-8pm',
          calificacion: 4.6,
          numResenas: 2340),
      LugarTurismo(
          nombre: 'Parque Nacional',
          descripcion:
              'Parque urbano con áreas verdes, senderos ecológicos y zonas deportivas en el corazón de Bogotá.',
          ubicacion: const LatLng(4.6250, -74.0700),
          categoria: CategoriaTurismo.parques,
          direccion: 'Carrera 7 #36-01, Bogotá',
          horario: 'Lun-Dom: 6am-6pm',
          calificacion: 4.5,
          numResenas: 870),
      LugarTurismo(
          nombre: 'Cerro de Monserrate',
          descripcion:
              'Icónico mirador natural con vista panorámica de toda Bogotá. Santuario religioso y atractivo turístico.',
          ubicacion: const LatLng(4.6097, -74.0817),
          categoria: CategoriaTurismo.parques,
          direccion: 'Cerro de Monserrate, Bogotá',
          horario: 'Lun-Dom: 6am-6pm',
          calificacion: 4.8,
          numResenas: 5120),
      LugarTurismo(
          nombre: 'Caño Cristales',
          descripcion:
              'Conocido como "el río de los cinco colores". Sus aguas cristalinas y plantas acuáticas crean un espectáculo único en el mundo.',
          ubicacion: const LatLng(2.2000, -73.7833),
          categoria: CategoriaTurismo.parques,
          direccion: 'La Macarena, Meta, Colombia',
          horario: 'Jul – Nov (temporada de colores)',
          calificacion: 4.9,
          numResenas: 4100),
      LugarTurismo(
          nombre: 'Desierto de la Tatacoa',
          descripcion:
              'El segundo desierto más grande de Colombia. Paisaje lunar de arcillas rojas y grises, cielos estrellados únicos y fósiles de millones de años.',
          ubicacion: const LatLng(3.2167, -75.1667),
          categoria: CategoriaTurismo.parques,
          direccion: 'Villavieja, Huila, Colombia',
          horario: 'Todo el año',
          calificacion: 4.7,
          numResenas: 2800),
      LugarTurismo(
          nombre: 'Plaza de Bolívar',
          descripcion:
              'Plaza principal de Bogotá y corazón histórico de Colombia. Rodeada de edificios emblemáticos.',
          ubicacion: const LatLng(4.5981, -74.0758),
          categoria: CategoriaTurismo.monumentos,
          direccion: 'Plaza de Bolívar, Bogotá',
          horario: '24 horas',
          calificacion: 4.7,
          numResenas: 3600),
      LugarTurismo(
          nombre: 'Catedral Primada',
          descripcion:
              'Catedral principal de Bogotá, joya de la arquitectura colonial con más de 300 años de historia.',
          ubicacion: const LatLng(4.5975, -74.0752),
          categoria: CategoriaTurismo.monumentos,
          direccion: 'Carrera 7 #10-10, Bogotá',
          horario: 'Lun-Dom: 7am-7pm',
          calificacion: 4.7,
          numResenas: 1890),
      LugarTurismo(
          nombre: 'Casa de Nariño',
          descripcion:
              'Palacio Presidencial de Colombia. Visitas guiadas los domingos con acceso a sus hermosos jardines.',
          ubicacion: const LatLng(4.5965, -74.0765),
          categoria: CategoriaTurismo.monumentos,
          direccion: 'Carrera 8 #7-26, Bogotá',
          horario: 'Dom: Visitas guiadas 9am-4pm',
          calificacion: 4.6,
          numResenas: 760),
      LugarTurismo(
          nombre: 'Amazonas',
          descripcion:
              'El pulmón del mundo. Selva tropical exuberante, fauna única y comunidades indígenas ancestrales.',
          ubicacion: const LatLng(-4.2150, -69.9400),
          categoria: CategoriaTurismo.lugarespueblos,
          direccion: 'Leticia, Amazonas, Colombia',
          horario: 'Todo el año',
          calificacion: 4.9,
          numResenas: 3200),
      LugarTurismo(
          nombre: 'Cartagena',
          descripcion:
              'Ciudad amurallada declarada Patrimonio de la Humanidad. Historia, cultura y playas del Caribe.',
          ubicacion: const LatLng(10.3910, -75.4794),
          categoria: CategoriaTurismo.lugarespueblos,
          direccion: 'Cartagena de Indias, Bolívar',
          horario: 'Todo el año',
          calificacion: 4.8,
          numResenas: 8900),
      LugarTurismo(
          nombre: 'Ciudad Perdida',
          descripcion:
              'Maravilla arqueológica escondida en la Sierra Nevada de Santa Marta. Tesoro de la civilización Tayrona.',
          ubicacion: const LatLng(11.0390, -73.9250),
          categoria: CategoriaTurismo.lugarespueblos,
          direccion: 'Sierra Nevada de Santa Marta',
          horario: 'Trek 4-6 días',
          calificacion: 4.9,
          numResenas: 1800),
      LugarTurismo(
          nombre: 'Valle de Cocora',
          descripcion:
              'Hogar de las palmas de cera, árbol nacional de Colombia. Paisaje mágico en el Eje Cafetero.',
          ubicacion: const LatLng(4.6380, -75.4977),
          categoria: CategoriaTurismo.lugarespueblos,
          direccion: 'Salento, Quindío',
          horario: 'Lun-Dom: 6am-5pm',
          calificacion: 4.8,
          numResenas: 5600),
      LugarTurismo(
          nombre: 'Ráquira',
          descripcion:
              'El pueblo de las ollas. Artesanías en barro, coloridas fachadas y tradición alfarera centenaria.',
          ubicacion: const LatLng(5.5314, -73.6349),
          categoria: CategoriaTurismo.lugarespueblos,
          direccion: 'Ráquira, Boyacá',
          horario: 'Lun-Dom: 8am-6pm',
          calificacion: 4.7,
          numResenas: 2100),
      LugarTurismo(
          nombre: 'Parque Tayrona',
          descripcion:
              'Paraíso natural donde la selva se encuentra con el mar Caribe. Playas vírgenes y biodiversidad única.',
          ubicacion: const LatLng(11.3150, -74.0270),
          categoria: CategoriaTurismo.lugarespueblos,
          direccion: 'Santa Marta, Magdalena',
          horario: 'Lun-Dom: 8am-5pm',
          calificacion: 4.9,
          numResenas: 7400),
      LugarTurismo(
          nombre: 'Playa El Rodadero',
          descripcion:
              'Hermosa playa en Santa Marta. Aguas cálidas del Caribe, deportes acuáticos y ambiente vibrante.',
          ubicacion: const LatLng(11.2200, -74.1800),
          categoria: CategoriaTurismo.playas,
          direccion: 'El Rodadero, Santa Marta',
          horario: 'Lun-Dom: 8am-6pm',
          calificacion: 4.5,
          numResenas: 3100),
      LugarTurismo(
          nombre: 'Playa Blanca',
          descripcion:
              'Arena blanca y aguas turquesa en Isla Barú. Una de las playas más hermosas del Caribe colombiano.',
          ubicacion: const LatLng(10.2800, -75.7100),
          categoria: CategoriaTurismo.playas,
          direccion: 'Isla Barú, Cartagena',
          horario: 'Lun-Dom: 8am-5pm',
          calificacion: 4.8,
          numResenas: 4700),
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

  void _irAlLugarEnMapa(LugarTurismo lugar) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _mapController.move(lugar.ubicacion, 17);
    });
  }

  List<LugarTurismo> get _lugaresFiltrados {
    final query = _searchQuery.trim().toLowerCase();
    return _lugares.where((l) {
      if (_categoriaSeleccionada != null &&
          l.categoria != _categoriaSeleccionada) return false;
      if (query.isEmpty) return true;
      return l.nombre.toLowerCase().contains(query) ||
          l.descripcion.toLowerCase().contains(query) ||
          l.direccion.toLowerCase().contains(query) ||
          l.categoria.nombre.toLowerCase().contains(query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    final filtrados = _lugaresFiltrados;
    if (filtrados.isNotEmpty) {
      _mapController.move(filtrados.first.ubicacion, 15);
    }
  }

  void _limpiarBusqueda() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    _mapController.move(_initialPosition, 12);
  }

  void _seleccionarCategoria(CategoriaTurismo categoria) {
    setState(() {
      _categoriaSeleccionada =
          _categoriaSeleccionada == categoria ? null : categoria;
      _searchQuery = '';
      _searchController.clear();
    });
    final filtrados = _lugaresFiltrados;
    if (filtrados.isNotEmpty) {
      _mapController.move(filtrados.first.ubicacion, 13);
    } else {
      _mapController.move(_initialPosition, 12);
    }
  }

  void _mostrarInfoLugar(LugarTurismo lugar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (context) => _BottomSheetTurismo(
        lugar: lugar,
        onIrAlMapa: () => _irAlLugarEnMapa(lugar),
      ),
    );
  }

  void _mostrarInfoLugarPorNombre(String nombre) {
    try {
      final l = _lugares.firstWhere(
          (l) => l.nombre.toLowerCase().contains(nombre.toLowerCase()));
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _mostrarInfoLugar(l);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dark = appState.modoOscuro;
    final sinResultados = _lugaresFiltrados.isEmpty && _searchQuery.isNotEmpty;

    return Scaffold(
      endDrawer: const AppDrawer(pantallaActual: AppDrawer.turismo),
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
                            child: Text(appState.t('turismo'),
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
                                          ? Colors.grey[800]!.withOpacity(0.95)
                                          : Colors.white.withOpacity(0.95),
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
                                          hintText:
                                              'Buscar lugares turísticos...',
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
                                          suffixIcon:
                                              _searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.clear, color: dark ? Colors.grey[400] : Colors.grey[500], size: 18), onPressed: _limpiarBusqueda) : null,
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
                                            .withOpacity(0.95),
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
                                          color: Colors.white.withOpacity(0.2),
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
              options: MapOptions(
                  initialCenter: _initialPosition,
                  initialZoom: widget.ubicacionInicial != null ? 11 : 12),
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
                    markers: _lugaresFiltrados
                        .map((l) => Marker(
                            point: l.ubicacion,
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                                onTap: () => _mostrarInfoLugar(l),
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: l.categoria.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4)
                                        ]),
                                    child: Icon(l.categoria.icono,
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
                  _btn(appState.t('cat_parques_naturales'), Icons.nature,
                      CategoriaTurismo.parques, dark),
                  const SizedBox(height: 10),
                  _btn(appState.t('cat_monumentos'), Icons.account_balance,
                      CategoriaTurismo.monumentos, dark),
                ])),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(children: [
                  _btn('Lugares y Pueblos', Icons.explore,
                      CategoriaTurismo.lugarespueblos, dark),
                  const SizedBox(height: 10),
                  _btn(appState.t('cat_playas'), Icons.beach_access,
                      CategoriaTurismo.playas, dark),
                ])),
              ])));

  Widget _btn(
      String texto, IconData icono, CategoriaTurismo categoria, bool dark) {
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
                    builder: (c) => const DespuesTurismoScreen())),
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
class _BottomSheetTurismo extends StatefulWidget {
  final LugarTurismo lugar;
  final VoidCallback onIrAlMapa;
  const _BottomSheetTurismo({required this.lugar, required this.onIrAlMapa});

  @override
  State<_BottomSheetTurismo> createState() => _BottomSheetTurismoState();
}

class _BottomSheetTurismoState extends State<_BottomSheetTurismo> {
  bool _esFavorito = false;
  bool _cargando = true;
  static const Color _gold = Color(0xFFFFBB02);

  @override
  void initState() {
    super.initState();
    FavoritosService().esFavorito(widget.lugar.nombre).then((v) {
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
      nombre: widget.lugar.nombre,
      categoria: 'Turismo',
      subcategoria: widget.lugar.categoria.nombre,
      lat: widget.lugar.ubicacion.latitude,
      lng: widget.lugar.ubicacion.longitude,
      imagePath: '',
    );
    if (mounted) {
      setState(() {
        _esFavorito = nuevo;
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            nuevo ? '❤️ Guardado en favoritos' : '💔 Eliminado de favoritos'),
        duration: const Duration(seconds: 2),
        backgroundColor: nuevo ? Colors.green : Colors.grey[700],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l = widget.lugar;
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child:
                ListView(controller: sc, padding: EdgeInsets.zero, children: [
              Center(
                  child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: dark ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4)))),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFFBB02), Color(0xFFF5C400)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFFFBB02).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6))
                      ]),
                  child: Stack(children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 60, 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(l.categoria.icono,
                                            color: Colors.black87, size: 13),
                                        const SizedBox(width: 5),
                                        Text(l.categoria.nombre,
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700)),
                                      ])),
                              const SizedBox(height: 10),
                              Text(l.nombre,
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
                                        i < l.calificacion.floor()
                                            ? Icons.star_rounded
                                            : (i < l.calificacion
                                                ? Icons.star_half_rounded
                                                : Icons.star_outline_rounded),
                                        color: Colors.black87,
                                        size: 18)),
                                const SizedBox(width: 6),
                                Text('${l.calificacion}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: Colors.black87)),
                                const SizedBox(width: 4),
                                Text('(${l.numResenas} reseñas)',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black.withOpacity(0.5))),
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
                                    color: Colors.white.withOpacity(0.25),
                                    shape: BoxShape.circle),
                                child: _cargando
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : Icon(
                                        _esFavorito
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
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
                            children: _getTagsPorCategoria(l.categoria)
                                .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFFFF8E1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: const Color(0xFFFFBB02),
                                            width: 1)),
                                    child: Text(tag,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFF5C400)))))
                                .toList()),
                        const SizedBox(height: 16),
                        Text(l.descripcion,
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                    dark ? Colors.grey[400] : Colors.grey[700],
                                height: 1.6)),
                        const SizedBox(height: 18),
                        Divider(
                            color: dark
                                ? Colors.grey[800]
                                : _gold.withOpacity(0.2)),
                        const SizedBox(height: 14),
                        _infoRow(
                            context: context,
                            icono: Icons.access_time_rounded,
                            label: 'Horario',
                            valor: l.horario),
                        const SizedBox(height: 14),
                        _infoRow(
                            context: context,
                            icono: Icons.location_on_rounded,
                            label: 'Dirección',
                            valor: l.direccion),
                        const SizedBox(height: 24),
                        Row(children: [
                          Expanded(
                              child: ElevatedButton.icon(
                                  onPressed: widget.onIrAlMapa,
                                  icon: const Icon(Icons.map_rounded, size: 18),
                                  label: const Text('Cómo llegar'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFDB0D),
                                      foregroundColor: Colors.black87,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      elevation: 0,
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      backgroundColor: dark
                                          ? const Color(0xFF2C2C2C)
                                          : const Color(0xFFF5F5F5)),
                                  child: Text('Cerrar',
                                      style: TextStyle(
                                          color: dark
                                              ? Colors.grey[400]
                                              : Colors.black54,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)))),
                        ]),
                      ])),
            ])),
      ),
    );
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

  List<String> _getTagsPorCategoria(CategoriaTurismo cat) {
    switch (cat) {
      case CategoriaTurismo.parques:
        return ['Naturaleza', 'Recreación', 'Aire libre'];
      case CategoriaTurismo.monumentos:
        return ['Historia', 'Cultura', 'Patrimonio'];
      case CategoriaTurismo.lugarespueblos:
        return ['Destino', 'Cultura', 'Aventura'];
      case CategoriaTurismo.playas:
        return ['Mar', 'Descanso', 'Deportes acuáticos'];
    }
  }
}
