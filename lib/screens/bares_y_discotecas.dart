import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'app_state.dart';
import 'app_drawer.dart';
import 'despues_bares.dart';
import 'favoritos_service.dart';

enum CategoriaBar { bares, discotecas, karaokes, eventos }

extension CategoriaBarExtension on CategoriaBar {
  String get nombre {
    switch (this) {
      case CategoriaBar.bares:
        return 'Bares';
      case CategoriaBar.discotecas:
        return 'Discotecas';
      case CategoriaBar.karaokes:
        return 'Karaokes';
      case CategoriaBar.eventos:
        return 'Eventos';
    }
  }

  Color get color {
    switch (this) {
      case CategoriaBar.bares:
        return Colors.blue;
      case CategoriaBar.discotecas:
        return Colors.purple;
      case CategoriaBar.karaokes:
        return Colors.red;
      case CategoriaBar.eventos:
        return Colors.orange;
    }
  }

  IconData get icono {
    switch (this) {
      case CategoriaBar.bares:
        return Icons.local_bar;
      case CategoriaBar.discotecas:
        return Icons.nightlife;
      case CategoriaBar.karaokes:
        return Icons.mic;
      case CategoriaBar.eventos:
        return Icons.event;
    }
  }
}

class LugarNocturno {
  final String nombre, descripcion, direccion, horario;
  final LatLng ubicacion;
  final CategoriaBar categoria;
  final double calificacion;
  final int numResenas;
  final String? precio, telefono, musica;

  LugarNocturno({
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.categoria,
    required this.direccion,
    required this.horario,
    required this.calificacion,
    this.numResenas = 200,
    this.precio,
    this.telefono,
    this.musica,
  });
}

class BaresYDiscotecasScreen extends StatefulWidget {
  final LatLng? ubicacionInicial;
  final String? lugarSeleccionado;
  const BaresYDiscotecasScreen(
      {super.key, this.ubicacionInicial, this.lugarSeleccionado});

  @override
  State<BaresYDiscotecasScreen> createState() => _BaresYDiscotecasScreenState();
}

class _BaresYDiscotecasScreenState extends State<BaresYDiscotecasScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialPosition = const LatLng(4.6200, -74.0700);
  final TextEditingController _searchController = TextEditingController();
  LatLng? _userLocation;
  bool _locationEnabled = false;
  String _searchQuery = '';
  CategoriaBar? _categoriaSeleccionada;
  late List<LugarNocturno> _lugares;

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
      // Bares (azul)
      LugarNocturno(
          nombre: 'El Colette Bogotá',
          descripcion:
              'Bar de autor con coctelería de vanguardia. Ambiente exclusivo y elegante en la Zona T.',
          ubicacion: const LatLng(4.6598, -74.0545),
          categoria: CategoriaBar.bares,
          direccion: 'Calle 84 #13-45, Zona Rosa, Bogotá',
          horario: 'Mar-Sáb: 7pm-2am',
          calificacion: 4.8,
          precio: '\$\$\$',
          musica: 'Jazz, Lounge'),
      LugarNocturno(
          nombre: 'Bar La Perseverancia',
          descripcion:
              'Bar tradicional en el barrio La Perseverancia. Cerveza artesanal y ambiente popular.',
          ubicacion: const LatLng(4.6220, -74.0650),
          categoria: CategoriaBar.bares,
          direccion: 'Carrera 5 #31-24, Bogotá',
          horario: 'Lun-Dom: 12pm-12am',
          calificacion: 4.4,
          precio: '\$',
          musica: 'Popular, Vallenato'),
      LugarNocturno(
          nombre: 'Johnny\'s Bar',
          descripcion:
              'Bar temático de los años 50. Rockabilly, hamburguesas y cerveza fría.',
          ubicacion: const LatLng(4.6345, -74.0598),
          categoria: CategoriaBar.bares,
          direccion: 'Calle 69 #6-23, Chapinero, Bogotá',
          horario: 'Mar-Dom: 5pm-2am',
          calificacion: 4.5,
          precio: '\$\$',
          musica: 'Rock, Rockabilly'),
      LugarNocturno(
          nombre: 'El Irish Pub',
          descripcion:
              'Pub irlandés auténtico con gran variedad de cervezas importadas. Música en vivo los fines de semana.',
          ubicacion: const LatLng(4.6510, -74.0575),
          categoria: CategoriaBar.bares,
          direccion: 'Calle 85 #12-34, Bogotá',
          horario: 'Lun-Dom: 3pm-2am',
          calificacion: 4.6,
          precio: '\$\$',
          musica: 'Rock, Folk, En vivo'),
      LugarNocturno(
          nombre: 'Bar Chiquita',
          descripcion:
              'Bar de coctelería de autor con ambiente íntimo. Uno de los mejores bares de Latinoamérica.',
          ubicacion: const LatLng(4.6395, -74.0582),
          categoria: CategoriaBar.bares,
          direccion: 'Calle 69 #5-34, Chapinero, Bogotá',
          horario: 'Mar-Sáb: 6pm-2am',
          calificacion: 4.9,
          precio: '\$\$\$',
          musica: 'Electrónica, Ambient'),
      LugarNocturno(
          nombre: 'Cervecería Libre',
          descripcion:
              'Fábrica de cerveza artesanal con taproom. Pruebas de diferentes estilos y visitas guiadas.',
          ubicacion: const LatLng(4.6590, -74.0520),
          categoria: CategoriaBar.bares,
          direccion: 'Calle 84 #12-40, Bogotá',
          horario: 'Mar-Dom: 2pm-12am',
          calificacion: 4.5,
          precio: '\$\$',
          musica: 'Rock, Alternativo'),
      LugarNocturno(
          nombre: 'Gaira Café Bar',
          descripcion:
              'Bar de Carlos Vives en la Candelaria. Música caribeña, comida colombiana y ambiente costeño.',
          ubicacion: const LatLng(4.5995, -74.0720),
          categoria: CategoriaBar.bares,
          direccion: 'Calle 11 #5-28, La Candelaria, Bogotá',
          horario: 'Mar-Sáb: 12pm-12am',
          calificacion: 4.6,
          precio: '\$\$',
          musica: 'Vallenato, Caribe, En vivo'),
      LugarNocturno(
          nombre: 'Bolívar Pub Medellín',
          descripcion:
              'Pub tradicional en Provenza. Rock clásico, cerveza artesanal y ambiente acogedor.',
          ubicacion: const LatLng(6.2085, -75.5665),
          categoria: CategoriaBar.bares,
          direccion: 'Carrera 35 #8-25, El Poblado, Medellín',
          horario: 'Lun-Dom: 5pm-2am',
          calificacion: 4.5,
          precio: '\$\$',
          musica: 'Rock clásico, Blues'),
      LugarNocturno(
          nombre: 'La Octava Bar',
          descripcion:
              'Bar de coctelería con vista a las luces de Medellín. Terraza exclusiva en El Poblado.',
          ubicacion: const LatLng(6.2105, -75.5670),
          categoria: CategoriaBar.bares,
          direccion: 'Calle 10 #40-20, El Poblado, Medellín',
          horario: 'Mar-Sáb: 6pm-2am',
          calificacion: 4.7,
          precio: '\$\$\$',
          musica: 'Electrónica, Lounge'),
      LugarNocturno(
          nombre: 'Café del Mar Cartagena',
          descripcion:
              'Bar en las murallas de Cartagena con vista espectacular al mar Caribe. Atardeceres inolvidables.',
          ubicacion: const LatLng(10.4250, -75.5510),
          categoria: CategoriaBar.bares,
          direccion: 'Murallas de Cartagena, Centro Histórico',
          horario: 'Lun-Dom: 4pm-11pm',
          calificacion: 4.7,
          precio: '\$\$\$',
          musica: 'Chill out, Latina'),
      LugarNocturno(
          nombre: 'Alquímico Bar',
          descripcion:
              'Uno de los mejores bares del mundo. Coctelería de autor en un edificio restaurado de 3 pisos.',
          ubicacion: const LatLng(10.4235, -75.5480),
          categoria: CategoriaBar.bares,
          direccion: 'Calle 34 #10-20, Getsemaní, Cartagena',
          horario: 'Mar-Dom: 6pm-2am',
          calificacion: 4.9,
          precio: '\$\$\$',
          musica: 'Electrónica, Latina'),
      LugarNocturno(
          nombre: 'Tin Tin Deo Cali',
          descripcion:
              'Club de salsa histórico en Cali. El templo de la salsa caleña con música en vivo.',
          ubicacion: const LatLng(3.4545, -76.5320),
          categoria: CategoriaBar.bares,
          direccion: 'Calle 5 #14-80, Granada, Cali',
          horario: 'Jue-Sáb: 8pm-3am',
          calificacion: 4.8,
          precio: '\$\$',
          musica: 'Salsa en vivo'),
      LugarNocturno(
          nombre: 'La Topa Tolondra',
          descripcion:
              'Bar temático de salsa. Ambiente alegre y bailador, referente de la cultura salsera caleña.',
          ubicacion: const LatLng(3.4520, -76.5380),
          categoria: CategoriaBar.bares,
          direccion: 'Avenida 6N #22-45, Cali',
          horario: 'Vie-Sáb: 9pm-3am',
          calificacion: 4.6,
          precio: '\$\$',
          musica: 'Salsa, Timba'),
      LugarNocturno(
          nombre: 'Vintrash Bar',
          descripcion:
              'Bar vintage con música de los 80s y 90s. Ambiente retro y coctelería clásica.',
          ubicacion: const LatLng(10.9950, -74.7950),
          categoria: CategoriaBar.bares,
          direccion: 'Carrera 54 #74-23, Barranquilla',
          horario: 'Mar-Dom: 6pm-2am',
          calificacion: 4.5,
          precio: '\$\$',
          musica: '80s, 90s, Retro'),
      LugarNocturno(
          nombre: 'La Cuadra Bar',
          descripcion:
              'Bar tradicional en Bucaramanga. Rock nacional e internacional en vivo.',
          ubicacion: const LatLng(7.1200, -73.1200),
          categoria: CategoriaBar.bares,
          direccion: 'Carrera 33 #52-45, Cabecera, Bucaramanga',
          horario: 'Jue-Sáb: 7pm-2am',
          calificacion: 4.4,
          precio: '\$\$',
          musica: 'Rock, Alternativo'),
      LugarNocturno(
        nombre: 'Sonora Social Club',
        descripcion: 'Bar de salsa y música latina con ambiente único',
        ubicacion: const LatLng(4.6421, -74.0571),
        categoria: CategoriaBar.bares,
        direccion: 'Calle 62 #9-50, Bogotá',
        horario: 'Jue-Sáb: 8pm-3am',
        calificacion: 4.7,
        precio: '\$\$',
        telefono: '+57 601 1234567',
        musica: 'Salsa, Latina',
      ),
      LugarNocturno(
        nombre: 'La Villa Bar',
        descripcion: 'Bar coctelería con música electrónica y ambiente moderno',
        ubicacion: const LatLng(4.6350, -74.0650),
        categoria: CategoriaBar.bares,
        direccion: 'Calle 85 #12-34, Bogotá',
        horario: 'Mar-Dom: 6pm-2am',
        calificacion: 4.5,
        precio: '\$\$\$',
        musica: 'Electrónica, House',
      ),
      LugarNocturno(
        nombre: 'El Candelario',
        descripcion:
            'Bar tradicional en el centro histórico con música en vivo',
        ubicacion: const LatLng(4.5950, -74.0740),
        categoria: CategoriaBar.bares,
        direccion: 'Calle 12 #4-23, Bogotá',
        horario: 'Mié-Dom: 6pm-1am',
        calificacion: 4.6,
        precio: '\$\$',
        musica: 'Rock, Alternativo',
      ),

      // Discotecas (morado)
      LugarNocturno(
          nombre: 'Theatron Bogotá',
          descripcion:
              'El club más grande de Latinoamérica con 13 ambientes temáticos diferentes bajo un mismo techo.',
          ubicacion: const LatLng(4.6477, -74.0559),
          categoria: CategoriaBar.discotecas,
          direccion: 'Calle 58 #10-40, Chapinero, Bogotá',
          horario: 'Vie-Sáb: 9pm-6am',
          calificacion: 4.9,
          precio: '\$\$',
          musica: 'Electrónica, Pop, Latino'),
      LugarNocturno(
          nombre: 'Octava Bogotá',
          descripcion:
              'Discoteca de referencia para amantes de la música electrónica y el techno en Bogotá.',
          ubicacion: const LatLng(4.6380, -74.0600),
          categoria: CategoriaBar.discotecas,
          direccion: 'Carrera 11 #85-23, Chicó, Bogotá',
          horario: 'Vie-Sáb: 10pm-5am',
          calificacion: 4.6,
          precio: '\$\$',
          musica: 'Techno, House'),
      LugarNocturno(
          nombre: 'Video Club Bogotá',
          descripcion:
              'Discoteca con temática retro y música de los 80s y 90s. Ambiente único y nostálgico.',
          ubicacion: const LatLng(4.6520, -74.0580),
          categoria: CategoriaBar.discotecas,
          direccion: 'Calle 85 #12-45, El Nogal, Bogotá',
          horario: 'Jue-Sáb: 9pm-4am',
          calificacion: 4.7,
          precio: '\$\$',
          musica: '80s, 90s, Pop'),
      LugarNocturno(
          nombre: 'Kaputt Bogotá',
          descripcion:
              'Discoteca underground de música electrónica. Artistas nacionales e internacionales.',
          ubicacion: const LatLng(4.6450, -74.0620),
          categoria: CategoriaBar.discotecas,
          direccion: 'Calle 63 #10-15, Chapinero, Bogotá',
          horario: 'Vie-Sáb: 10pm-6am',
          calificacion: 4.5,
          precio: '\$\$',
          musica: 'Techno, House, Minimal'),
      LugarNocturno(
          nombre: 'Salón Amador Medellín',
          descripcion:
              'Discoteca de referencia en Medellín. Música electrónica y ambiente exclusivo en El Poblado.',
          ubicacion: const LatLng(6.2095, -75.5680),
          categoria: CategoriaBar.discotecas,
          direccion: 'Carrera 35 #8-34, El Poblado, Medellín',
          horario: 'Vie-Sáb: 10pm-4am',
          calificacion: 4.7,
          precio: '\$\$\$',
          musica: 'Electrónica, House'),
      LugarNocturno(
          nombre: 'La Chula Medellín',
          descripcion:
              'Discoteca temática mexicana con ambiente festivo y música latina.',
          ubicacion: const LatLng(6.2105, -75.5690),
          categoria: CategoriaBar.discotecas,
          direccion: 'Calle 10 #40-15, El Poblado, Medellín',
          horario: 'Jue-Sáb: 9pm-3am',
          calificacion: 4.5,
          precio: '\$\$',
          musica: 'Latina, Reguetón'),
      LugarNocturno(
          nombre: 'Bazurto Social Club',
          descripcion:
              'Discoteca con temática costeña. Champeta, salsa y ambiente caribeño en Medellín.',
          ubicacion: const LatLng(6.2120, -75.5700),
          categoria: CategoriaBar.discotecas,
          direccion: 'Calle 10 #40-50, El Poblado, Medellín',
          horario: 'Vie-Sáb: 10pm-4am',
          calificacion: 4.6,
          precio: '\$\$',
          musica: 'Champeta, Salsa, Caribe'),
      LugarNocturno(
          nombre: 'Casa Envidia Cartagena',
          descripcion:
              'Discoteca exclusiva en la ciudad amurallada. Música latina y ambiente sofisticado.',
          ubicacion: const LatLng(10.4220, -75.5490),
          categoria: CategoriaBar.discotecas,
          direccion: 'Calle 36 #4-45, Centro Histórico, Cartagena',
          horario: 'Vie-Sáb: 10pm-3am',
          calificacion: 4.6,
          precio: '\$\$\$',
          musica: 'Latina, Reguetón'),
      LugarNocturno(
          nombre: 'Eivissa Cartagena',
          descripcion:
              'Discoteca temática ibicenca con piscina y show en vivo. Música electrónica y comercial.',
          ubicacion: const LatLng(10.4150, -75.5550),
          categoria: CategoriaBar.discotecas,
          direccion: 'Bocagrande, Cartagena',
          horario: 'Vie-Sáb: 9pm-3am',
          calificacion: 4.4,
          precio: '\$\$\$',
          musica: 'Electrónica, Comercial'),
      LugarNocturno(
          nombre: 'Zaperoco Cali',
          descripcion:
              'Discoteca histórica de salsa en Cali. El lugar donde los mejores salseros bailan.',
          ubicacion: const LatLng(3.4535, -76.5340),
          categoria: CategoriaBar.discotecas,
          direccion: 'Calle 5 #14-50, Granada, Cali',
          horario: 'Jue-Sáb: 9pm-3am',
          calificacion: 4.7,
          precio: '\$\$',
          musica: 'Salsa en vivo'),
      LugarNocturno(
          nombre: 'Frogg Barranquilla',
          descripcion:
              'Discoteca con temática de los 80s. Música retro y ambiente nostálgico.',
          ubicacion: const LatLng(11.0000, -74.8100),
          categoria: CategoriaBar.discotecas,
          direccion: 'Carrera 54 #74-23, Barranquilla',
          horario: 'Vie-Sáb: 9pm-3am',
          calificacion: 4.5,
          precio: '\$\$',
          musica: '80s, Pop, Retro'),
      LugarNocturno(
          nombre: 'Casa Blanca Santa Marta',
          descripcion:
              'Discoteca frente al mar en El Rodadero. Música latina y ambiente playero.',
          ubicacion: const LatLng(11.2200, -74.1800),
          categoria: CategoriaBar.discotecas,
          direccion: 'El Rodadero, Santa Marta',
          horario: 'Vie-Sáb: 9pm-3am',
          calificacion: 4.3,
          precio: '\$\$',
          musica: 'Latina, Reguetón'),
      LugarNocturno(
        nombre: 'Theatron',
        descripcion:
            'Club más grande de Latinoamérica, 13 ambientes diferentes',
        ubicacion: const LatLng(4.6477, -74.0559),
        categoria: CategoriaBar.discotecas,
        direccion: 'Calle 58 #10-40, Bogotá',
        horario: 'Vie-Sáb: 9pm-6am',
        calificacion: 4.9,
        precio: '\$\$',
        telefono: '+57 601 3456789',
        musica: 'Electrónica, Pop, Latino, Varios',
      ),
      LugarNocturno(
        nombre: 'Octava',
        descripcion: 'Discoteca de música electrónica y techno',
        ubicacion: const LatLng(4.6380, -74.0600),
        categoria: CategoriaBar.discotecas,
        direccion: 'Carrera 11 #85-23, Bogotá',
        horario: 'Vie-Sáb: 10pm-5am',
        calificacion: 4.6,
        precio: '\$\$',
        musica: 'Techno, House',
      ),
      LugarNocturno(
        nombre: 'Video Club',
        descripcion: 'Discoteca con temática retro y música ochentera',
        ubicacion: const LatLng(4.6520, -74.0580),
        categoria: CategoriaBar.discotecas,
        direccion: 'Calle 85 #12-45, Bogotá',
        horario: 'Jue-Sáb: 9pm-4am',
        calificacion: 4.7,
        precio: '\$\$',
        musica: '80s, 90s, Pop',
      ),

      // Karaokes (rojo)
      LugarNocturno(
          nombre: 'Karaoke Box Zona T',
          descripcion:
              'Karaoke en salas privadas con gran variedad de canciones en español, inglés y más.',
          ubicacion: const LatLng(4.6600, -74.0550),
          categoria: CategoriaBar.karaokes,
          direccion: 'Calle 84 #13-45, Zona Rosa, Bogotá',
          horario: 'Lun-Dom: 4pm-2am',
          calificacion: 4.4,
          precio: '\$\$',
          musica: 'Variada'),
      LugarNocturno(
          nombre: 'Capital Drinks Bogotá',
          descripcion:
              'Karaoke al estilo asiático con cabinas privadas para grupos. Reservas disponibles para 4 a 15 personas.',
          ubicacion: const LatLng(4.6660, -74.0540),
          categoria: CategoriaBar.karaokes,
          direccion: 'Calle 83 #14-17, Zona Rosa, Bogotá',
          horario: 'Mar-Dom: 5pm-1am',
          calificacion: 4.5,
          precio: '\$\$',
          musica: 'Variada'),
      LugarNocturno(
          nombre: 'Vip Karaoke Bar',
          descripcion:
              'Karaoke en salas privadas con servicio de barra. Ideal para celebraciones con amigos.',
          ubicacion: const LatLng(4.6550, -74.0600),
          categoria: CategoriaBar.karaokes,
          direccion: 'Calle 84 #14-23, Bogotá',
          horario: 'Lun-Dom: 3pm-1am',
          calificacion: 4.3,
          precio: '\$\$',
          musica: 'Variada'),
      LugarNocturno(
          nombre: 'K-Town Karaoke Medellín',
          descripcion:
              'Karaoke con salas privadas estilo coreano. Gran variedad de canciones internacionales.',
          ubicacion: const LatLng(6.2090, -75.5670),
          categoria: CategoriaBar.karaokes,
          direccion: 'Carrera 35 #8-40, El Poblado, Medellín',
          horario: 'Mar-Dom: 5pm-1am',
          calificacion: 4.5,
          precio: '\$\$',
          musica: 'K-pop, Pop, Latino'),
      LugarNocturno(
          nombre: 'Kali Karaoke Cali',
          descripcion:
              'Karaoke en salas privadas en el sur de Cali. Ambiente familiar y buena música.',
          ubicacion: const LatLng(3.4400, -76.5400),
          categoria: CategoriaBar.karaokes,
          direccion: 'Calle 5 #4-23, San Antonio, Cali',
          horario: 'Mar-Dom: 5pm-12am',
          calificacion: 4.3,
          precio: '\$\$',
          musica: 'Salsa, Pop, Latino'),
      LugarNocturno(
          nombre: 'Karaoke La 75 Barranquilla',
          descripcion:
              'Karaoke tradicional en Barranquilla. Ambiente costeño y buena energía.',
          ubicacion: const LatLng(11.0000, -74.8000),
          categoria: CategoriaBar.karaokes,
          direccion: 'Carrera 54 #75-23, Barranquilla',
          horario: 'Jue-Sáb: 7pm-1am',
          calificacion: 4.2,
          precio: '\$',
          musica: 'Vallenato, Popular'),
      LugarNocturno(
        nombre: 'Karaoke Box Zona T',
        descripcion: 'Karaoke en salas privadas con gran variedad de canciones',
        ubicacion: const LatLng(4.6600, -74.0550),
        categoria: CategoriaBar.karaokes,
        direccion: 'Calle 84 #13-45, Bogotá',
        horario: 'Lun-Dom: 4pm-2am',
        calificacion: 4.4,
        precio: '\$\$',
        musica: 'Variada',
      ),
      LugarNocturno(
        nombre: 'K-Town Karaoke',
        descripcion: 'Karaoke con temática asiática y ambiente juvenil',
        ubicacion: const LatLng(4.6480, -74.0600),
        categoria: CategoriaBar.karaokes,
        direccion: 'Carrera 15 #88-12, Bogotá',
        horario: 'Mar-Dom: 5pm-1am',
        calificacion: 4.5,
        precio: '\$\$',
      ),

      // Eventos (naranja)
      LugarNocturno(
          nombre: 'Armenia Pub Bogotá',
          descripcion:
              'Pub con eventos en vivo de rock y música alternativa. Referente de la escena indie bogotana.',
          ubicacion: const LatLng(4.6200, -74.0800),
          categoria: CategoriaBar.eventos,
          direccion: 'Calle 45 #12-34, Chapinero, Bogotá',
          horario: 'Mié-Sáb: 7pm-3am',
          calificacion: 4.6,
          precio: '\$\$',
          musica: 'Rock, Alternativo'),
      LugarNocturno(
          nombre: 'La Casa de la Salsa Bogotá',
          descripcion:
              'Eventos de salsa en vivo con orquestas reconocidas. La mejor salsa de Bogotá.',
          ubicacion: const LatLng(4.6420, -74.0650),
          categoria: CategoriaBar.eventos,
          direccion: 'Calle 64 #13-52, Chapinero, Bogotá',
          horario: 'Vie-Sáb: 8pm-4am',
          calificacion: 4.7,
          precio: '\$\$\$',
          musica: 'Salsa en vivo'),
      LugarNocturno(
          nombre: 'Salón de Teatrino',
          descripcion:
              'Eventos de comedia y stand-up comedy. Noches de risas y buen ambiente.',
          ubicacion: const LatLng(4.6360, -74.0610),
          categoria: CategoriaBar.eventos,
          direccion: 'Calle 68 #10-23, Chapinero, Bogotá',
          horario: 'Jue-Sáb: 7pm-11pm',
          calificacion: 4.5,
          precio: '\$\$',
          musica: 'Comedia, Stand-up'),
      LugarNocturno(
          nombre: 'Teatro Victoria Medellín',
          descripcion:
              'Eventos culturales, conciertos y obras de teatro en un espacio histórico restaurado.',
          ubicacion: const LatLng(6.2480, -75.5700),
          categoria: CategoriaBar.eventos,
          direccion: 'Calle 51 #50-12, Medellín',
          horario: 'Eventos programados',
          calificacion: 4.7,
          precio: '\$\$',
          musica: 'Cultural, Conciertos'),
      LugarNocturno(
          nombre: 'Pley Club Cartagena',
          descripcion:
              'Eventos temáticos y fiestas exclusivas en la ciudad amurallada. DJs internacionales.',
          ubicacion: const LatLng(10.4230, -75.5470),
          categoria: CategoriaBar.eventos,
          direccion: 'Calle 35 #8-23, Getsemaní, Cartagena',
          horario: 'Vie-Sáb: 10pm-3am',
          calificacion: 4.5,
          precio: '\$\$\$',
          musica: 'Electrónica, Comercial'),
      LugarNocturno(
          nombre: 'Salsa al Parque Cali',
          descripcion:
              'Evento gratuito de salsa en el parque del Perro. Grandes orquestas nacionales e internacionales.',
          ubicacion: const LatLng(3.4600, -76.5300),
          categoria: CategoriaBar.eventos,
          direccion: 'Parque del Perro, Cali',
          horario: 'Evento anual en septiembre',
          calificacion: 4.8,
          precio: '\$',
          musica: 'Salsa en vivo'),
      LugarNocturno(
        nombre: 'Armenia Pub',
        descripcion: 'Pub con eventos en vivo, rock y música alternativa',
        ubicacion: const LatLng(4.6200, -74.0800),
        categoria: CategoriaBar.eventos,
        direccion: 'Calle 45 #12-34, Bogotá',
        horario: 'Mié-Sáb: 7pm-3am',
        calificacion: 4.6,
        precio: '\$\$',
        musica: 'Rock, Alternativo',
      ),
      LugarNocturno(
        nombre: 'La Casa de la Salsa',
        descripcion: 'Eventos de salsa en vivo con orquestas reconocidas',
        ubicacion: const LatLng(4.6250, -74.0700),
        categoria: CategoriaBar.eventos,
        direccion: 'Calle 53 #12-34, Bogotá',
        horario: 'Vie-Sáb: 8pm-4am',
        calificacion: 4.7,
        precio: '\$\$\$',
        musica: 'Salsa en vivo',
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

  void _irAlLugarEnMapa(LugarNocturno lugar) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _mapController.move(lugar.ubicacion, 17);
    });
  }

  List<LugarNocturno> get _lugaresFiltrados {
    final query = _searchQuery.trim().toLowerCase();
    return _lugares.where((l) {
      if (_categoriaSeleccionada != null &&
          l.categoria != _categoriaSeleccionada) return false;
      if (query.isEmpty) return true;
      return l.nombre.toLowerCase().contains(query) ||
          l.descripcion.toLowerCase().contains(query) ||
          l.direccion.toLowerCase().contains(query) ||
          l.categoria.nombre.toLowerCase().contains(query) ||
          (l.musica?.toLowerCase().contains(query) ?? false);
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

  void _seleccionarCategoria(CategoriaBar categoria) {
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

  void _mostrarInfoLugar(LugarNocturno lugar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (context) => _BottomSheetBares(
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
      endDrawer: const AppDrawer(pantallaActual: AppDrawer.bares),
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
                            child: Text(appState.t('bares_drawer'),
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
                                              'Buscar bares, discotecas...',
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
                  MapOptions(initialCenter: _initialPosition, initialZoom: 13),
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
                  _btn(appState.t('cat_bares'), Icons.local_bar,
                      CategoriaBar.bares, dark),
                  const SizedBox(height: 10),
                  _btn(appState.t('cat_discotecas'), Icons.nightlife,
                      CategoriaBar.discotecas, dark),
                ])),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(children: [
                  _btn(appState.t('cat_karaokes'), Icons.mic,
                      CategoriaBar.karaokes, dark),
                  const SizedBox(height: 10),
                  _btn(appState.t('cat_eventos'), Icons.event,
                      CategoriaBar.eventos, dark),
                ])),
              ])));

  Widget _btn(String texto, IconData icono, CategoriaBar categoria, bool dark) {
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
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (c) => const DespuesBaresScreen())),
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
class _BottomSheetBares extends StatefulWidget {
  final LugarNocturno lugar;
  final VoidCallback onIrAlMapa;
  const _BottomSheetBares({required this.lugar, required this.onIrAlMapa});

  @override
  State<_BottomSheetBares> createState() => _BottomSheetBaresState();
}

class _BottomSheetBaresState extends State<_BottomSheetBares> {
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
      categoria: 'Bares',
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
                                if (l.precio != null) ...[
                                  const Spacer(),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.10),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Text(l.precio!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                              color: Colors.black87))),
                                ],
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
                        if (l.musica != null) ...[
                          const SizedBox(height: 14),
                          _infoRow(
                              context: context,
                              icono: Icons.music_note_rounded,
                              label: 'Música',
                              valor: l.musica!),
                        ],
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

  List<String> _getTags(CategoriaBar cat) {
    switch (cat) {
      case CategoriaBar.bares:
        return ['Cócteles', 'Música', 'Ambiente'];
      case CategoriaBar.discotecas:
        return ['Baile', 'Electrónica', 'Noche'];
      case CategoriaBar.karaokes:
        return ['Karaoke', 'Diversión', 'Grupos'];
      case CategoriaBar.eventos:
        return ['Eventos', 'En vivo', 'Espectáculos'];
    }
  }
}
