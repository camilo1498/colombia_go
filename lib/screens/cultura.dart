import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'app_state.dart';
import 'app_drawer.dart';
import 'despues_cultura.dart';
import 'favoritos_service.dart';

enum CategoriaCultura { museos, teatros, monumentos, parques }

extension CategoriaCulturaExtension on CategoriaCultura {
  String get nombre {
    switch (this) {
      case CategoriaCultura.museos:
        return 'Museos';
      case CategoriaCultura.teatros:
        return 'Teatros';
      case CategoriaCultura.monumentos:
        return 'Monumentos Históricos';
      case CategoriaCultura.parques:
        return 'Parques Culturales';
    }
  }

  Color get color {
    switch (this) {
      case CategoriaCultura.museos:
        return Colors.purple;
      case CategoriaCultura.teatros:
        return Colors.deepOrange;
      case CategoriaCultura.monumentos:
        return Colors.brown;
      case CategoriaCultura.parques:
        return Colors.green;
    }
  }

  IconData get icono {
    switch (this) {
      case CategoriaCultura.museos:
        return Icons.museum;
      case CategoriaCultura.teatros:
        return Icons.theater_comedy;
      case CategoriaCultura.monumentos:
        return Icons.account_balance;
      case CategoriaCultura.parques:
        return Icons.park;
    }
  }
}

class LugarCultural {
  final String nombre, descripcion, direccion, horario;
  final LatLng ubicacion;
  final CategoriaCultura categoria;
  final double calificacion;
  final int numResenas;
  final String? telefono;

  LugarCultural({
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.categoria,
    required this.direccion,
    required this.horario,
    required this.calificacion,
    this.numResenas = 150,
    this.telefono,
  });
}

class CulturaScreen extends StatefulWidget {
  final LatLng? ubicacionInicial;
  final String? lugarSeleccionado;
  const CulturaScreen(
      {super.key, this.ubicacionInicial, this.lugarSeleccionado});

  @override
  State<CulturaScreen> createState() => _CulturaScreenState();
}

class _CulturaScreenState extends State<CulturaScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialPosition = const LatLng(4.5709, -74.2973);
  final TextEditingController _searchController = TextEditingController();
  LatLng? _userLocation;
  bool _locationEnabled = false;
  String _searchQuery = '';
  CategoriaCultura? _categoriaSeleccionada;
  late List<LugarCultural> _lugares;

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
      // Museos (morado)
      // --- Bogotá ---
      LugarCultural(
          nombre: 'Museo del Oro',
          descripcion:
              'El museo de orfebrería precolombina más importante del mundo. Alberga más de 55.000 piezas de oro de las culturas indígenas de Colombia.',
          ubicacion: const LatLng(4.60184, -74.07185),
          categoria: CategoriaCultura.museos,
          direccion: 'Carrera 6 #15-82, Bogotá',
          horario: 'Mar-Sáb: 9am-6pm, Dom: 10am-4pm',
          calificacion: 4.9,
          telefono: '+57 601 3432222'),
      LugarCultural(
          nombre: 'Museo Nacional de Colombia',
          descripcion:
              'El museo más antiguo de Colombia. Su colección abarca arte, historia, arqueología y etnografía, desde la época precolombina hasta la contemporánea.',
          ubicacion: const LatLng(4.6155, -74.0683),
          categoria: CategoriaCultura.museos,
          direccion: 'Carrera 7 #28-66, Bogotá',
          horario: 'Mar-Sáb: 10am-5pm, Dom: 10am-4pm',
          calificacion: 4.8,
          telefono: '+57 601 3816470'),
      LugarCultural(
          nombre: 'Museo Botero',
          descripcion:
              'Ubicado en una hermosa casa colonial, exhibe obras de Fernando Botero y su colección privada de artistas internacionales como Picasso, Dalí y Monet.',
          ubicacion: const LatLng(4.5960, -74.0730),
          categoria: CategoriaCultura.museos,
          direccion: 'Calle 11 #4-41, Bogotá',
          horario: 'Mar-Sáb: 9am-7pm, Dom: 9am-5pm',
          calificacion: 4.8,
          telefono: '+57 601 3431331'),
      LugarCultural(
          nombre: 'Museo de Arte Colonial',
          descripcion:
              'Instalado en una casa del siglo XVII, preserva una valiosa colección de arte religioso, pintura, escultura y mobiliario de la época colonial.',
          ubicacion: const LatLng(4.5965, -74.0735),
          categoria: CategoriaCultura.museos,
          direccion: 'Carrera 6 #9-77, Bogotá',
          horario: 'Mar-Sáb: 9am-5pm, Dom: 10am-4pm',
          calificacion: 4.7,
          telefono: '+57 601 3416017'),
      LugarCultural(
          nombre: 'Museo de Memoria de Colombia',
          descripcion:
              'Un espacio dedicado a la conmemoración de las víctimas del conflicto armado en Colombia. Promueve la reflexión, la no repetición y la construcción de paz.',
          ubicacion: const LatLng(4.62490, -74.08039),
          categoria: CategoriaCultura.museos,
          direccion: 'Carrera 29B #24-20, Teusaquillo, Bogotá',
          horario: 'Mar-Sáb: 10am-5pm, Dom: 10am-3pm',
          calificacion: 4.8,
          telefono: '+57 601 3820345'),

// --- Medellín ---
      LugarCultural(
          nombre: 'Museo de Antioquia',
          descripcion:
              'Uno de los museos más importantes del país. Su colección incluye obras de Fernando Botero, Pedro Nel Gómez y otros grandes artistas antioqueños.',
          ubicacion: const LatLng(6.2525, -75.5691),
          categoria: CategoriaCultura.museos,
          direccion: 'Calle 52 #52-43, Medellín',
          horario: 'Lun-Sáb: 10am-5:30pm, Dom: 10am-4:30pm',
          calificacion: 4.8,
          telefono: '+57 604 2513636'),
      LugarCultural(
          nombre: 'Museo Casa de la Memoria',
          descripcion:
              'Espacio para la dignificación de las víctimas del conflicto armado en Medellín y Antioquia. Busca contribuir a la no repetición y a la construcción de paz.',
          ubicacion: const LatLng(6.2619, -75.5661),
          categoria: CategoriaCultura.museos,
          direccion: 'Calle 51 #36-66, Medellín',
          horario: 'Mar-Vie: 9am-6pm, Sáb-Dom: 10am-5pm',
          calificacion: 4.7,
          telefono: '+57 604 3834950'),
      LugarCultural(
          nombre: 'Museo El Castillo',
          descripcion:
              'Mansión estilo castillo medieval europeo convertida en museo de artes decorativas. Exhibe muebles, porcelanas, cristalería y una hermosa colección de muñecas.',
          ubicacion: const LatLng(6.2032, -75.5731),
          categoria: CategoriaCultura.museos,
          direccion: 'Carrera 9 #32-269, El Poblado, Medellín',
          horario: 'Lun-Dom: 9am-5pm',
          calificacion: 4.7,
          telefono: '+57 604 2660900'),

// --- Cartagena ---
      LugarCultural(
          nombre: 'Museo Naval del Caribe',
          descripcion:
              'Ubicado en una hermosa edificación republicana, narra la historia naval de Cartagena y el Caribe colombiano con maquetas, armas y documentos históricos.',
          ubicacion: const LatLng(10.4222, -75.5519),
          categoria: CategoriaCultura.museos,
          direccion: 'Calle del Colegio #34-26, Centro Histórico, Cartagena',
          horario: 'Lun-Dom: 9am-5pm',
          calificacion: 4.6,
          telefono: '+57 605 6644408'),
      LugarCultural(
          nombre: 'Palacio de la Inquisición',
          descripcion:
              'Imponente edificio del siglo XVIII que albergó el Tribunal del Santo Oficio. Hoy es museo de historia colonial y exhibe instrumentos de tortura de la época.',
          ubicacion: const LatLng(10.4236, -75.5522),
          categoria: CategoriaCultura.museos,
          direccion: 'Plaza de Bolívar #32-59, Centro Histórico, Cartagena',
          horario: 'Lun-Dom: 9am-5pm',
          calificacion: 4.7,
          telefono: '+57 605 6644570'),

// --- Cali ---
      LugarCultural(
          nombre: 'Museo La Tertulia',
          descripcion:
              'Uno de los museos de arte más importantes del suroccidente colombiano. Cuenta con una amplia colección de arte moderno y contemporáneo.',
          ubicacion: const LatLng(3.4535, -76.5320),
          categoria: CategoriaCultura.museos,
          direccion: 'Avenida Colombia #5-105 Oeste, Cali',
          horario: 'Mar-Sáb: 10am-6pm, Dom: 2pm-6pm',
          calificacion: 4.7,
          telefono: '+57 602 8932931'),
      LugarCultural(
          nombre: 'Museo Caliwood',
          descripcion:
              'Museo de cine que alberga una colección de más de 4000 piezas, incluyendo cámaras, proyectores, carteles y otros objetos relacionados con la historia del cine.',
          ubicacion: const LatLng(3.45042, -76.54724),
          categoria: CategoriaCultura.museos,
          direccion: 'Avenida Belalcázar #5A-55, Cali',
          horario: 'Mar-Sáb: 9am-5pm',
          calificacion: 4.6,
          telefono: '+57 602 5556677'),
      LugarCultural(
          nombre: 'Museo Arqueológico de Cali',
          descripcion:
              'Instalado en el Colegio Santa Librada, presenta una colección de más de 6000 piezas arqueológicas de las culturas Calima, Tierradentro y San Agustín.',
          ubicacion: const LatLng(3.4588, -76.5333),
          categoria: CategoriaCultura.museos,
          direccion: 'Carrera 7 #10-35, Cali',
          horario: 'Lun-Vie: 8am-5pm',
          calificacion: 4.5,
          telefono: '+57 602 8861133'),

// --- Santa Marta ---
      LugarCultural(
          nombre: 'Museo del Oro Tayrona',
          descripcion:
              'Posee una valiosa colección de piezas de orfebrería de la cultura Tayrona, incluyeros y pectorales que representan la cosmovisión de este pueblo.',
          ubicacion: const LatLng(11.2419, -74.2053),
          categoria: CategoriaCultura.museos,
          direccion: 'Carrera 2 #14-02, Santa Marta',
          horario: 'Mar-Sáb: 9am-5pm, Dom: 10am-3pm',
          calificacion: 4.6,
          telefono: '+57 605 4217195'),
      LugarCultural(
          nombre: 'Quinta de San Pedro Alejandrino',
          descripcion:
              'Hacienda donde murió Simón Bolívar. Es un museo histórico que conserva la última morada del Libertador y un monumento en su honor.',
          ubicacion: const LatLng(11.2120, -74.2000),
          categoria: CategoriaCultura.museos,
          direccion: 'Vía al Mar, Kilómetro 5, Santa Marta',
          horario: 'Lun-Dom: 9am-5pm',
          calificacion: 4.7,
          telefono: '+57 605 4218491'),
      LugarCultural(
        nombre: 'Museo del Oro',
        descripcion: 'Famoso museo con colección de arte precolombino en oro',
        ubicacion: const LatLng(4.5981, -74.0739),
        categoria: CategoriaCultura.museos,
        direccion: 'Carrera 6 #15-88, Bogotá',
        horario: 'Mar-Sáb: 9am-6pm, Dom: 9am-4pm',
        calificacion: 4.9,
        telefono: '+57 601 3432222',
      ),
      LugarCultural(
        nombre: 'Museo Botero',
        descripcion: 'Obras del maestro Fernando Botero y arte internacional',
        ubicacion: const LatLng(4.5960, -74.0730),
        categoria: CategoriaCultura.museos,
        direccion: 'Calle 11 #4-41, Bogotá',
        horario: 'Lun: Cerrado, Mar-Sáb: 9am-7pm, Dom: 9am-5pm',
        calificacion: 4.8,
        telefono: '+57 601 3431331',
      ),
      LugarCultural(
        nombre: 'Museo Nacional de Colombia',
        descripcion: 'Museo más antiguo del país, historia y arte colombiano',
        ubicacion: const LatLng(4.6150, -74.0690),
        categoria: CategoriaCultura.museos,
        direccion: 'Carrera 7 #28-66, Bogotá',
        horario: 'Mar-Sáb: 10am-5pm, Dom: 10am-4pm',
        calificacion: 4.7,
      ),

      // Teatros (naranja)
      // --- Bogotá ---
      LugarCultural(
          nombre: 'Teatro Colón',
          descripcion:
              'El teatro nacional de Colombia. Joya arquitectónica neoclásica inaugurada en 1892. Es el máximo escenario para las artes escénicas del país.',
          ubicacion: const LatLng(4.59667, -74.07440),
          categoria: CategoriaCultura.teatros,
          direccion: 'Calle 10 #5-32, Bogotá',
          horario: 'Funciones según programación',
          calificacion: 4.9,
          telefono: '+57 601 2847420'),
      LugarCultural(
          nombre: 'Teatro Jorge Eliécer Gaitán',
          descripcion:
              'Importante centro cultural que alberga una variada programación de teatro, danza, música y cine. Recientemente remodelado y modernizado.',
          ubicacion: const LatLng(4.6180, -74.0710),
          categoria: CategoriaCultura.teatros,
          direccion: 'Carrera 7 #22-47, Bogotá',
          horario: 'Lun-Dom: 8am-8pm',
          calificacion: 4.6,
          telefono: '+57 601 3824888'),
      LugarCultural(
          nombre: 'Teatro Mayor Julio Mario Santo Domingo',
          descripcion:
              'Teatro moderno con acústica excepcional. Sede de las mejores orquestas, compañías de danza y artistas del mundo.',
          ubicacion: const LatLng(4.6850, -74.0950),
          categoria: CategoriaCultura.teatros,
          direccion: 'Calle 170 #67-51, Bogotá',
          horario: 'Según programación',
          calificacion: 4.8,
          telefono: '+57 601 7458282'),
      LugarCultural(
          nombre: 'Teatro Faenza',
          descripcion:
              'Histórico teatro de estilo art nouveau inaugurado en 1924. Ha sido testigo de la vida cultural de Bogotá por más de un siglo.',
          ubicacion: const LatLng(4.5975, -74.0740),
          categoria: CategoriaCultura.teatros,
          direccion: 'Calle 22 #5-32, Bogotá',
          horario: 'Funciones según programación',
          calificacion: 4.7,
          telefono: '+57 601 3418355'),
      LugarCultural(
          nombre: 'Teatro Libre',
          descripcion:
              'Reconocido grupo teatral con dos sedes. Ofrece una programación constante de obras de alta calidad artística.',
          ubicacion: const LatLng(4.6535, -74.0580),
          categoria: CategoriaCultura.teatros,
          direccion: 'Calle 63 #12-12, Bogotá',
          horario: 'Funciones según programación',
          calificacion: 4.7,
          telefono: '+57 601 2547214'),

// --- Medellín ---
      LugarCultural(
          nombre: 'Teatro Metropolitano de Medellín',
          descripcion:
              'Escenario moderno con capacidad para más de 1500 personas. Es la sede principal de la Orquesta Filarmónica de Medellín.',
          ubicacion: const LatLng(6.24298, -75.5774),
          categoria: CategoriaCultura.teatros,
          direccion: 'Calle 41 #52-15, Medellín',
          horario: 'Según programación',
          calificacion: 4.8,
          telefono: '+57 604 5111313'),
      LugarCultural(
          nombre: 'Teatro Pablo Tobón Uribe',
          descripcion:
              'Una de las salas de teatro más tradicionales de Medellín. Es un centro cultural de puertas abiertas con una variada programación.',
          ubicacion: const LatLng(6.24746, -75.5591),
          categoria: CategoriaCultura.teatros,
          direccion: 'Carrera 40 #51-24, Medellín',
          horario: 'Según programación',
          calificacion: 4.7,
          telefono: '+57 604 2397500'),
      LugarCultural(
          nombre: 'Teatro Lido',
          descripcion:
              'Cine-teatro histórico en el centro de Medellín. Su imponente fachada es un símbolo de la ciudad y su programación es muy variada.',
          ubicacion: const LatLng(6.2520, -75.5660),
          categoria: CategoriaCultura.teatros,
          direccion: 'Carrera 52 #50-44, Medellín',
          horario: 'Funciones según programación',
          calificacion: 4.5,
          telefono: '+57 604 2394500'),

// --- Cali ---
      LugarCultural(
          nombre: 'Teatro Jorge Isaacs',
          descripcion:
              'Teatro neoclásico inaugurado en 1927. Es el escenario más importante de Cali y símbolo de la ciudad.',
          ubicacion: const LatLng(3.45334, -76.53230),
          categoria: CategoriaCultura.teatros,
          direccion: 'Calle 12 #3-12, Cali',
          horario: 'Según programación',
          calificacion: 4.8,
          telefono: '+57 602 8976969'),
      LugarCultural(
          nombre: 'Teatro Experimental de Cali',
          descripcion:
              'Centro cultural dedicado a la experimentación teatral y a las artes vivas. Es un referente para el teatro independiente.',
          ubicacion: const LatLng(3.44754, -76.53514),
          categoria: CategoriaCultura.teatros,
          direccion: 'Calle 15 #5-54, Cali',
          horario: 'Funciones según programación',
          calificacion: 4.6,
          telefono: '+57 602 8937675'),

// --- Barranquilla ---
      LugarCultural(
          nombre: 'Teatro Amira de la Rosa',
          descripcion:
              'Principal centro de artes escénicas de Barranquilla. Alberga la Temporada de Teatro y el Festival de Orquestas del Carnaval.',
          ubicacion: const LatLng(10.9915, -74.7815),
          categoria: CategoriaCultura.teatros,
          direccion: 'Calle 56 #38-50, Barranquilla',
          horario: 'Según programación',
          calificacion: 4.7,
          telefono: '+57 605 3562575'),
      LugarCultural(
        nombre: 'Teatro Colón',
        descripcion: 'Teatro histórico de Bogotá, joya arquitectónica',
        ubicacion: const LatLng(4.5981, -74.0761),
        categoria: CategoriaCultura.teatros,
        direccion: 'Calle 10 #5-32, Bogotá',
        horario: 'Funciones según programación',
        calificacion: 4.9,
        telefono: '+57 601 2847420',
      ),
      LugarCultural(
        nombre: 'Teatro Jorge Eliécer Gaitán',
        descripcion: 'Importante centro cultural y teatral',
        ubicacion: const LatLng(4.6180, -74.0710),
        categoria: CategoriaCultura.teatros,
        direccion: 'Carrera 7 #22-47, Bogotá',
        horario: 'Lun-Dom: 8am-8pm',
        calificacion: 4.6,
      ),
      LugarCultural(
        nombre: 'Teatro Mayor Julio Mario Santo Domingo',
        descripcion: 'Teatro moderno con acústica excepcional',
        ubicacion: const LatLng(4.6850, -74.0950),
        categoria: CategoriaCultura.teatros,
        direccion: 'Calle 170 #67-51, Bogotá',
        horario: 'Según programación',
        calificacion: 4.8,
      ),

      // Monumentos Históricos (marrón)
      // --- Bogotá ---
      LugarCultural(
          nombre: 'Plaza de Bolívar',
          descripcion:
              'Plaza principal de Bogotá y corazón histórico de Colombia. Rodeada de edificios emblemáticos como la Catedral Primada y el Capitolio Nacional.',
          ubicacion: const LatLng(4.5981, -74.0758),
          categoria: CategoriaCultura.monumentos,
          direccion: 'Plaza de Bolívar, Bogotá',
          horario: '24 horas',
          calificacion: 4.8,
          telefono: ''),
      LugarCultural(
          nombre: 'Catedral Primada de Colombia',
          descripcion:
              'Catedral principal de Bogotá, joya de la arquitectura colonial con más de 300 años de historia. Alberga obras de arte de gran valor.',
          ubicacion: const LatLng(4.5975, -74.0752),
          categoria: CategoriaCultura.monumentos,
          direccion: 'Carrera 7 #10-10, Bogotá',
          horario: 'Lun-Dom: 7am-7pm',
          calificacion: 4.7,
          telefono: '+57 601 3411954'),
      LugarCultural(
          nombre: 'Capitolio Nacional',
          descripcion:
              'Sede del Congreso de la República. Monumento arquitectónico de estilo republicano construido a finales del siglo XIX e inicios del XX.',
          ubicacion: const LatLng(4.5965, -74.0760),
          categoria: CategoriaCultura.monumentos,
          direccion: 'Carrera 8 #7-26, Bogotá',
          horario: 'Visitas guiadas los domingos',
          calificacion: 4.6,
          telefono: ''),
      LugarCultural(
          nombre: 'Torre Colpatria',
          descripcion:
              'El rascacielos más emblemático de Bogotá. Desde su mirador se obtiene una vista panorámica inigualable de la ciudad.',
          ubicacion: const LatLng(4.6120, -74.0675),
          categoria: CategoriaCultura.monumentos,
          direccion: 'Carrera 7 #24-89, Bogotá',
          horario: 'Mirador: Lun-Dom: 9am-8pm',
          calificacion: 4.5,
          telefono: ''),

// --- Cartagena ---
      LugarCultural(
          nombre: 'Castillo San Felipe de Barajas',
          descripcion:
              'La fortaleza más grande construida por los españoles en sus colonias. Patrimonio de la Humanidad por la UNESCO.',
          ubicacion: const LatLng(10.42222, -75.53806),
          categoria: CategoriaCultura.monumentos,
          direccion: 'Avenida Pedro Heredia, Cartagena',
          horario: 'Lun-Dom: 8am-6pm',
          calificacion: 4.8,
          telefono: '+57 605 6644535'),
      LugarCultural(
          nombre: 'Murallas de Cartagena',
          descripcion:
              'Imponentes murallas que rodean el Centro Histórico. Construidas para proteger la ciudad de ataques piratas. Ofrecen un paseo único con vistas al mar.',
          ubicacion: const LatLng(10.4236, -75.5511),
          categoria: CategoriaCultura.monumentos,
          direccion: 'Centro Histórico, Cartagena',
          horario: '24 horas',
          calificacion: 4.9,
          telefono: ''),
      LugarCultural(
          nombre: 'Torre del Reloj',
          descripcion:
              'Puerta de entrada principal a la ciudad amurallada. Es uno de los símbolos más reconocidos de Cartagena.',
          ubicacion: const LatLng(10.4227, -75.5506),
          categoria: CategoriaCultura.monumentos,
          direccion: 'Boca del Puente, Centro Histórico, Cartagena',
          horario: '24 horas',
          calificacion: 4.7,
          telefono: ''),
      LugarCultural(
          nombre: 'Monumento a la India Catalina',
          descripcion:
              'Escultura en bronce que rinde homenaje a la mujer indígena Catalina, quien sirvió como intérprete para los conquistadores españoles.',
          ubicacion: const LatLng(10.4264, -75.5489),
          categoria: CategoriaCultura.monumentos,
          direccion: 'Avenida del Centenario, Cartagena',
          horario: '24 horas',
          calificacion: 4.5,
          telefono: ''),

// --- Zipaquirá ---
      LugarCultural(
          nombre: 'Catedral de Sal de Zipaquirá',
          descripcion:
              'Impresionante catedral subterránea construida dentro de una mina de sal. Es la Primera Maravilla de Colombia.',
          ubicacion: const LatLng(5.01969, -74.00895),
          categoria: CategoriaCultura.monumentos,
          direccion: 'Zipaquirá, Cundinamarca',
          horario: 'Lun-Dom: 9am-6:30pm',
          calificacion: 4.8,
          telefono: '+57 601 8510510'),

// --- Boyacá ---
      LugarCultural(
          nombre: 'Puente de Boyacá',
          descripcion:
              'Puente histórico donde ocurrió la Batalla de Boyacá el 7 de agosto de 1819, sellando la independencia de Colombia.',
          ubicacion: const LatLng(5.4531, -73.3903),
          categoria: CategoriaCultura.monumentos,
          direccion: 'Vía Tunja - Bogotá, Boyacá',
          horario: 'Lun-Dom: 8am-5pm',
          calificacion: 4.6,
          telefono: '+57 608 7894231'),

// --- Popayán ---
      LugarCultural(
          nombre: 'Torre del Reloj de Popayán',
          descripcion:
              'Arco del Caldas o Torre del Reloj es uno de los monumentos más emblemáticos de la ciudad, construido en 1737 como acceso a la ciudad.',
          ubicacion: const LatLng(2.4422, -76.6067),
          categoria: CategoriaCultura.monumentos,
          direccion: 'Carrera 6, Popayán',
          horario: '24 horas',
          calificacion: 4.7,
          telefono: ''),
      LugarCultural(
        nombre: 'Plaza de Bolívar',
        descripcion: 'Plaza principal de Bogotá, corazón histórico y cultural',
        ubicacion: const LatLng(4.5981, -74.0758),
        categoria: CategoriaCultura.monumentos,
        direccion: 'Plaza de Bolívar, Bogotá',
        horario: '24 horas',
        calificacion: 4.8,
      ),
      LugarCultural(
        nombre: 'Catedral Primada',
        descripcion: 'Catedral principal de Bogotá, arquitectura colonial',
        ubicacion: const LatLng(4.5975, -74.0752),
        categoria: CategoriaCultura.monumentos,
        direccion: 'Carrera 7 #10-10, Bogotá',
        horario: 'Lun-Dom: 7am-7pm',
        calificacion: 4.7,
      ),
      LugarCultural(
        nombre: 'Capitolio Nacional',
        descripcion: 'Sede del Congreso de la República',
        ubicacion: const LatLng(4.5965, -74.0760),
        categoria: CategoriaCultura.monumentos,
        direccion: 'Carrera 8 #7-26',
        horario: 'Visitas guiadas',
        calificacion: 4.6,
      ),

      // Parques Culturales (verde)
      // --- Bogotá ---
      LugarCultural(
          nombre: 'Parque Nacional Enrique Olaya Herrera',
          descripcion:
              'Parque emblemático de Bogotá, conocido simplemente como "Parque Nacional". Alberga monumentos históricos y es un pulmón verde para los bogotanos.',
          ubicacion: const LatLng(4.6250, -74.0700),
          categoria: CategoriaCultura.parques,
          direccion: 'Carrera 7 #36-01, Bogotá',
          horario: 'Lun-Dom: 6am-6pm',
          calificacion: 4.5,
          telefono: ''),
      LugarCultural(
          nombre: 'Parque Simón Bolívar',
          descripcion:
              'Escenario de grandes eventos culturales, conciertos y festivales al aire libre. Es el parque urbano más grande de Bogotá.',
          ubicacion: const LatLng(4.6580, -74.0940),
          categoria: CategoriaCultura.parques,
          direccion: 'Calle 63, Bogotá',
          horario: 'Lun-Dom: 5am-8pm',
          calificacion: 4.6,
          telefono: ''),
      LugarCultural(
          nombre: 'Parque 93',
          descripcion:
              'Centro cultural, gastronómico y de entretenimiento en el norte de Bogotá. Rodeado de restaurantes, bares y galerías de arte.',
          ubicacion: const LatLng(4.6820, -74.0450),
          categoria: CategoriaCultura.parques,
          direccion: 'Calle 93A, Bogotá',
          horario: '24 horas',
          calificacion: 4.6,
          telefono: ''),

// --- Medellín ---
      LugarCultural(
          nombre: 'Jardín Botánico de Medellín',
          descripcion:
              'Un oasis de biodiversidad en la ciudad. Alberga colecciones de plantas, mariposario, y es sede del reconocido Orquideorama.',
          ubicacion: const LatLng(6.2725, -75.5638),
          categoria: CategoriaCultura.parques,
          direccion: 'Calle 73 #51D-14, Medellín',
          horario: 'Lun-Dom: 9am-4pm',
          calificacion: 4.7,
          telefono: '+57 604 4445500'),
      LugarCultural(
          nombre: 'Parque de los Deseos',
          descripcion:
              'Parque cultural emblemático de Medellín, sede de eventos como la Fiesta del Libro y la Noche de los Museos.',
          ubicacion: const LatLng(6.2690, -75.5680),
          categoria: CategoriaCultura.parques,
          direccion: 'Carrera 64, Medellín',
          horario: 'Lun-Dom: 6am-10pm',
          calificacion: 4.6,
          telefono: ''),

// --- Eje Cafetero ---
      LugarCultural(
          nombre: 'Parque Nacional del Café',
          descripcion:
              'Parque temático que combina atracciones mecánicas con la cultura cafetera. Ofrece espectáculos, museos y una estación de café.',
          ubicacion: const LatLng(4.54, -75.77),
          categoria: CategoriaCultura.parques,
          direccion: 'Montenegro, Quindío',
          horario: 'Lun-Dom: 9am-6pm',
          calificacion: 4.7,
          telefono: '+57 606 7417417'),

// --- San Agustín ---
      LugarCultural(
          nombre: 'Parque Arqueológico de San Agustín',
          descripcion:
              'Patrimonio de la Humanidad por la UNESCO. Alberga la mayor colección de estatuas megalíticas de América del Sur.',
          ubicacion: const LatLng(1.91667, -76.2333),
          categoria: CategoriaCultura.parques,
          direccion: 'San Agustín, Huila',
          horario: 'Lun-Dom: 8am-4pm',
          calificacion: 4.9,
          telefono: ''),

// --- Itagüí ---
      LugarCultural(
          nombre: 'Parque del Artista',
          descripcion:
              'Parque temático dedicado a la cultura y el arte en el municipio de Itagüí. Es un espacio para la recreación y el encuentro familiar.',
          ubicacion: const LatLng(6.17806, -75.60278),
          categoria: CategoriaCultura.parques,
          direccion: 'Itagüí, Antioquia',
          horario: 'Lun-Dom: 8am-6pm',
          calificacion: 4.5,
          telefono: ''),
      LugarCultural(
        nombre: 'Parque Nacional',
        descripcion: 'Parque urbano con espacios culturales y recreativos',
        ubicacion: const LatLng(4.6250, -74.0700),
        categoria: CategoriaCultura.parques,
        direccion: 'Carrera 7 #36-01, Bogotá',
        horario: 'Lun-Dom: 6am-6pm',
        calificacion: 4.5,
      ),
      LugarCultural(
        nombre: 'Parque Simón Bolívar',
        descripcion: 'Escenario de grandes eventos culturales y conciertos',
        ubicacion: const LatLng(4.7110, -74.1020),
        categoria: CategoriaCultura.parques,
        direccion: 'Calle 63, Bogotá',
        horario: 'Lun-Dom: 5am-8pm',
        calificacion: 4.6,
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

  void _irAlLugarEnMapa(LugarCultural lugar) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _mapController.move(lugar.ubicacion, 17);
    });
  }

  List<LugarCultural> get _lugaresFiltrados {
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

  void _seleccionarCategoria(CategoriaCultura categoria) {
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

  void _mostrarInfoLugar(LugarCultural lugar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (context) => _BottomSheetCultura(
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
      endDrawer: const AppDrawer(pantallaActual: AppDrawer.cultura),
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
                            child: Text(appState.t('cultura'),
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
                                              'Buscar lugares culturales...',
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
                  _btn(appState.t('cat_museos_cultura'), Icons.museum,
                      CategoriaCultura.museos, dark),
                  const SizedBox(height: 10),
                  _btn(appState.t('cat_teatros'), Icons.theater_comedy,
                      CategoriaCultura.teatros, dark),
                ])),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(children: [
                  _btn(appState.t('cat_monumentos_hist'), Icons.account_balance,
                      CategoriaCultura.monumentos, dark),
                  const SizedBox(height: 10),
                  _btn(appState.t('cat_parques_cult'), Icons.park,
                      CategoriaCultura.parques, dark),
                ])),
              ])));

  Widget _btn(
      String texto, IconData icono, CategoriaCultura categoria, bool dark) {
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
                    builder: (c) => const DespuesCulturaScreen())),
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
class _BottomSheetCultura extends StatefulWidget {
  final LugarCultural lugar;
  final VoidCallback onIrAlMapa;
  const _BottomSheetCultura({required this.lugar, required this.onIrAlMapa});

  @override
  State<_BottomSheetCultura> createState() => _BottomSheetCulturaState();
}

class _BottomSheetCulturaState extends State<_BottomSheetCultura> {
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
      categoria: 'Cultura',
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
                            children: _getTags(l.categoria)
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
                                : const Color(0xFFEEEEEE)),
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
                        if (l.telefono != null) ...[
                          const SizedBox(height: 14),
                          _infoRow(
                              context: context,
                              icono: Icons.phone_rounded,
                              label: 'Teléfono',
                              valor: l.telefono!),
                        ],
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

  List<String> _getTags(CategoriaCultura cat) {
    switch (cat) {
      case CategoriaCultura.museos:
        return ['Arte', 'Cultura', 'Historia'];
      case CategoriaCultura.teatros:
        return ['Artes escénicas', 'Espectáculos', 'Música'];
      case CategoriaCultura.monumentos:
        return ['Patrimonio', 'Historia', 'Arquitectura'];
      case CategoriaCultura.parques:
        return ['Naturaleza', 'Cultura', 'Eventos'];
    }
  }
}
