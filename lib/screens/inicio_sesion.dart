import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'app_state.dart';
import 'login_screen.dart';
import 'gastronomia.dart';
import 'turismo.dart';
import 'cultura.dart';
import 'bares_y_discotecas.dart';
import 'mi_perfil.dart';
import 'configuracion.dart';
import 'responsive_helper.dart';
import 'app_drawer.dart';

class PantallaPrincipalScreen extends StatefulWidget {
  const PantallaPrincipalScreen({super.key});

  @override
  State<PantallaPrincipalScreen> createState() =>
      _PantallaPrincipalScreenState();
}

class _PantallaPrincipalScreenState extends State<PantallaPrincipalScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color _amarillo = Color(0xFFF5C400);

  // Destinos con info completa para el diálogo
  static const List<Map<String, dynamic>> _destinos = [
    {
      'imagen': 'assets/images/destino1_cano_cristales.jpg',
      'nombre': 'Caño Cristales',
      'categoria': 'Destino Natural',
      'icono': Icons.water,
      'descripcion':
          'Conocido como "el río de los cinco colores". Sus aguas cristalinas y plantas acuáticas crean un espectáculo de colores únicos en el mundo.',
      'direccion': 'La Macarena, Meta, Colombia',
      'horario': 'Jul – Nov (temporada de colores)',
      'lat': 2.2000,
      'lng': -73.7833,
    },
    {
      'imagen': 'assets/images/destino2_parque_tayrona.jpg',
      'nombre': 'Parque Tayrona',
      'categoria': 'Lugar y Pueblo',
      'icono': Icons.beach_access,
      'descripcion':
          'Paraíso natural donde la selva se encuentra con el mar Caribe. Playas vírgenes, biodiversidad única y sitios arqueológicos de la civilización Tayrona.',
      'direccion': 'Santa Marta, Magdalena, Colombia',
      'horario': 'Lun-Dom: 8am-5pm',
      'lat': 11.3150,
      'lng': -74.0270,
    },
    {
      'imagen': 'assets/images/destino3_desierto_de_la_tatacoa.jpg',
      'nombre': 'Desierto de la Tatacoa',
      'categoria': 'Destino Natural',
      'icono': Icons.wb_sunny,
      'descripcion':
          'El segundo desierto más grande de Colombia. Paisaje lunar de arcillas rojas y grises, cielos estrellados únicos y fósiles de millones de años.',
      'direccion': 'Villavieja, Huila, Colombia',
      'horario': 'Todo el año',
      'lat': 3.2167,
      'lng': -75.1667,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Diálogo premium al tocar destino ────────────────────────
  void _mostrarDialogoDestino(BuildContext context, Map<String, dynamic> d) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 12)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Imagen superior ──────────────────────────────
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      d['imagen'],
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.landscape,
                            size: 60, color: Colors.grey[500]),
                      ),
                    ),
                    // Degradado
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.65)
                          ],
                        ),
                      ),
                    ),
                    // Nombre
                    Positioned(
                      bottom: 14,
                      left: 16,
                      right: 16,
                      child: Text(
                        d['nombre'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                        ),
                      ),
                    ),
                    // Chip categoría
                    Positioned(
                      top: 12,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _amarillo,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(d['icono'] as IconData,
                                color: Colors.black87, size: 12),
                            const SizedBox(width: 5),
                            Text(
                              d['categoria'],
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Contenido ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Descripción
                    Text(
                      d['descripcion'],
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[700], height: 1.5),
                    ),
                    const SizedBox(height: 14),

                    // Info dirección
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.location_on_rounded,
                                size: 15, color: Color(0xFFFFBB02)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ubicación',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5)),
                                  const SizedBox(height: 2),
                                  Text(d['direccion'],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500)),
                                ]),
                          ),
                        ]),
                    const SizedBox(height: 10),

                    // Info horario
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.access_time_rounded,
                                size: 15, color: Color(0xFFFFBB02)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Mejor época',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5)),
                                  const SizedBox(height: 2),
                                  Text(d['horario'],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500)),
                                ]),
                          ),
                        ]),

                    const SizedBox(height: 20),

                    // Botones
                    Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Text('Cancelar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => TurismoScreen(
                                        ubicacionInicial:
                                            LatLng(d['lat'], d['lng']),
                                        lugarSeleccionado: d['nombre'],
                                      )),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: _amarillo,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: _amarillo.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map,
                                    color: Colors.black87, size: 16),
                                SizedBox(width: 6),
                                Text('Ver en mapa',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dark = appState.modoOscuro;
    final r = R(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      endDrawer: const AppDrawer(pantallaActual: AppDrawer.inicio),
      body: Builder(
        builder: (BuildContext context) {
          return Stack(
            children: [
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
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: r.isDesktop ? 900 : double.infinity),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Menú
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: r.isDesktop ? 32 : 16, vertical: 4),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.menu,
                                          color: Colors.black87,
                                          size: r.iconSize + 4),
                                      onPressed: () =>
                                          Scaffold.of(context).openEndDrawer(),
                                    ),
                                  ),
                                ]),
                          ),

                          // Logo
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: r.isDesktop ? 100 : 24),
                            child: Image.asset('assets/images/logo.png',
                                width: r.isDesktop
                                    ? 400
                                    : r.isTablet
                                        ? 300
                                        : r.w * 0.85,
                                height: r.isTablet
                                    ? 130
                                    : r.isSmallPhone
                                        ? 140
                                        : 160,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) =>
                                    const SizedBox(height: 160)),
                          ),

                          SizedBox(height: r.isSmallPhone ? 4 : 8),

                          // Grid categorías
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: r.isDesktop
                                    ? 80
                                    : r.isTablet
                                        ? 40
                                        : 16),
                            child: GridView.count(
                              crossAxisCount: r.gridColumns,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: r.isDesktop
                                  ? 1.2
                                  : r.isTablet
                                      ? 1.25
                                      : 1.05,
                              children: [
                                _buildCategoryCard(
                                    context,
                                    appState.t('gastronomia'),
                                    'assets/images/Imagen_gastronomia_COLOMBIAgo.jpg',
                                    () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                const GastronomiaScreen())),
                                    dark,
                                    r),
                                _buildCategoryCard(
                                    context,
                                    appState.t('turismo'),
                                    'assets/images/colombia_go_turismo.jpg',
                                    () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                const TurismoScreen())),
                                    dark,
                                    r),
                                _buildCategoryCard(
                                    context,
                                    appState.t('cultura'),
                                    'assets/images/colombia_go_cultura.jpg',
                                    () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                const CulturaScreen())),
                                    dark,
                                    r),
                                _buildCategoryCard(
                                    context,
                                    appState.t('bares'),
                                    'assets/images/colombia_go_discotecas.jpg',
                                    () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                const BaresYDiscotecasScreen())),
                                    dark,
                                    r),
                              ],
                            ),
                          ),

                          SizedBox(height: r.isTablet ? 20 : 16),

                          // Label destinos recomendados
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: r.isTablet ? 40 : 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(appState.t('destino_recomendado'),
                                style: TextStyle(
                                    fontSize: r.fs(14),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                          ),

                          SizedBox(height: r.isTablet ? 15 : 12),

                          // ── Carrusel premium con tap ───────────────────────
                          SizedBox(
                            height: r.isDesktop
                                ? 240
                                : r.isTablet
                                    ? 210
                                    : r.isSmallPhone
                                        ? 150
                                        : 170,
                            child:
                                Stack(alignment: Alignment.center, children: [
                              PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) =>
                                    setState(() => _currentPage = index),
                                itemCount: _destinos.length,
                                itemBuilder: (context, index) {
                                  final d = _destinos[index];
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: r.isDesktop
                                            ? 150
                                            : r.isTablet
                                                ? 100
                                                : 60),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _mostrarDialogoDestino(context, d),
                                      child:
                                          _DestinoCard(destino: d, dark: dark),
                                    ),
                                  );
                                },
                              ),
                              // Flecha izquierda
                              Positioned(
                                left: r.isDesktop ? 60 : 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      shape: BoxShape.circle),
                                  child: IconButton(
                                    icon: Icon(Icons.chevron_left,
                                        color: Colors.white,
                                        size: r.isTablet ? 38 : 30),
                                    onPressed: () {
                                      if (_currentPage > 0) {
                                        _pageController.previousPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut);
                                      } else {
                                        _pageController.animateToPage(
                                            _destinos.length - 1,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              // Flecha derecha
                              Positioned(
                                right: r.isDesktop ? 60 : 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      shape: BoxShape.circle),
                                  child: IconButton(
                                    icon: Icon(Icons.chevron_right,
                                        color: Colors.white,
                                        size: r.isTablet ? 38 : 30),
                                    onPressed: () {
                                      if (_currentPage < _destinos.length - 1) {
                                        _pageController.nextPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut);
                                      } else {
                                        _pageController.animateToPage(0,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ]),
                          ),

                          const SizedBox(height: 10),

                          // Indicadores
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                                _destinos.length,
                                (index) => Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentPage == index
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.4),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.6),
                                            width: 1),
                                      ),
                                    )),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title,
      String imagePath, VoidCallback onTap, bool dark, R r) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: dark ? Colors.black.withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(r.cardRadius),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(children: [
          Expanded(
            flex: 7,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(r.cardRadius)),
              child: Image.asset(imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image,
                          size: 50, color: Colors.grey))),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: dark ? Colors.black.withOpacity(0.5) : Colors.white,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(r.cardRadius)),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: r.fs(13),
                          fontWeight: FontWeight.w600,
                          color: dark ? Colors.white : Colors.black87)),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Card premium para el carrusel ─────────────────────────────
class _DestinoCard extends StatelessWidget {
  final Map<String, dynamic> destino;
  final bool dark;

  const _DestinoCard({required this.destino, required this.dark});

  static const Color _amarillo = Color(0xFFF5C400);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(destino['imagen'],
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                  color: dark ? Colors.grey[800] : Colors.grey[300],
                  child: Icon(Icons.landscape,
                      size: 60, color: Colors.grey[500]))),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 70,
              child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent
                  ])))),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 28, 14, 14),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.55),
                      Colors.transparent
                    ])),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: _amarillo,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(destino['icono'] as IconData,
                              color: Colors.black87, size: 11),
                          const SizedBox(width: 4),
                          Text(destino['categoria'],
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      const SizedBox(height: 6),
                      Text(destino['nombre'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              shadows: [
                                Shadow(blurRadius: 6, color: Colors.black)
                              ]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ]),
              )),
          // Ícono de mapa esquina superior derecha
          Positioned(
              top: 10,
              right: 10,
              child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 1),
                  ),
                  child: const Icon(Icons.map_outlined,
                      color: Colors.white, size: 14))),
        ]),
      ),
    );
  }
}
