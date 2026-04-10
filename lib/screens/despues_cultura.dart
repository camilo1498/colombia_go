import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'app_state.dart';
import 'app_drawer.dart';
import 'cultura.dart';
import 'responsive_helper.dart';
import 'favoritos_service.dart';

class _LugarData {
  final String nombre, imagePath, categoria;
  final double lat, lng;
  final IconData icono;
  const _LugarData(this.nombre, this.imagePath, this.lat, this.lng,
      this.categoria, this.icono);
}

class DespuesCulturaScreen extends StatefulWidget {
  const DespuesCulturaScreen({super.key});

  @override
  State<DespuesCulturaScreen> createState() => _DespuesCulturaScreenState();
}

class _DespuesCulturaScreenState extends State<DespuesCulturaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<_LugarData> todosLosLugares = [
    _LugarData('Museo del Oro', 'assets/images/museo_del_oro.jpg', 4.5981,
        -74.0739, 'Museo', Icons.museum),
    _LugarData('Museo Botero', 'assets/images/museo_d_botero.jpg', 4.5960,
        -74.0730, 'Museo', Icons.museum),
    _LugarData('Museo Nacional', 'assets/images/museo_nacional_de_colombia.jpg',
        4.6150, -74.0690, 'Museo', Icons.museum),
    _LugarData('Teatro Colón', 'assets/images/teatro_colon.jpg', 4.5981,
        -74.0761, 'Teatro', Icons.theater_comedy),
    _LugarData(
        'Teatro Gaitán',
        'assets/images/teatro_jorge_eliecer_gaitan.jpeg',
        4.6180,
        -74.0710,
        'Teatro',
        Icons.theater_comedy),
    _LugarData(
        'Teatro Mayor',
        'assets/images/teatro_Mayor_Julio_Mario_Santo_Domingo.jpg',
        4.6850,
        -74.0950,
        'Teatro',
        Icons.theater_comedy),
    _LugarData('Plaza de Bolívar', 'assets/images/plaza_simon_bolivar.jpg',
        4.5981, -74.0758, 'Monumento', Icons.account_balance),
    _LugarData('Catedral Primada', 'assets/images/la_catedral_primada.jpg',
        4.5975, -74.0752, 'Monumento', Icons.church),
    _LugarData('Capitolio Nacional', 'assets/images/capitolio_nacional.jpg',
        4.5965, -74.0760, 'Monumento', Icons.account_balance),
    _LugarData('Parque Nacional', 'assets/images/parque_nacional.jpg', 4.6250,
        -74.0700, 'Parque Cultural', Icons.park),
    _LugarData('Parque Simón Bolívar', 'assets/images/parque_simon_bolivar.jpg',
        4.6580, -74.0940, 'Parque Cultural', Icons.nature),
    _LugarData('Cartagena', 'assets/images/cartagena.jpg', 10.3910, -75.4794,
        'Patrimonio', Icons.location_city),
    _LugarData('Ciudad Perdida', 'assets/images/ciudad_perdida.jpg', 11.0390,
        -73.9250, 'Arqueológico', Icons.explore),
    _LugarData('Caño Cristales', 'assets/images/destino1_cano_cristales.jpg',
        2.2000, -73.7833, 'Destino Natural', Icons.water),
    _LugarData(
        'Desierto de la Tatacoa',
        'assets/images/destino3_desierto_de_la_tatacoa.jpg',
        3.2167,
        -75.1667,
        'Destino Natural',
        Icons.wb_sunny),
    _LugarData('Monserrate', 'assets/images/Monserrate.jpg', 4.6097, -74.0817,
        'Mirador', Icons.landscape),
  ];

  List<_LugarData> get _lugaresFiltrados {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return todosLosLugares;
    return todosLosLugares
        .where((l) =>
            l.nombre.toLowerCase().contains(query) ||
            l.categoria.toLowerCase().contains(query))
        .toList();
  }

  void _navegarAlMapa(
          BuildContext context, String nombre, double lat, double lng) =>
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (c) => CulturaScreen(
                  ubicacionInicial: LatLng(lat, lng),
                  lugarSeleccionado: nombre)));

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final dark = appState.modoOscuro;
    final responsive = R(context);
    final filtrados = _lugaresFiltrados;
    final sinResultados = filtrados.isEmpty && _searchQuery.isNotEmpty;

    return Scaffold(
      endDrawer: const AppDrawer(pantallaActual: AppDrawer.despuesCultura),
      body: Builder(
          builder: (context) => LayoutBuilder(
                builder: (context, constraints) {
                  final screenH = constraints.maxHeight;
                  final logoH = screenH * 0.12;

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
                          color: Colors.black.withValues(alpha: 0.6),
                          width: double.infinity,
                          height: double.infinity),
                    SafeArea(
                        child: Center(
                            child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth:
                              responsive.isDesktop ? 900 : double.infinity),
                      child: Column(children: [
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: responsive.isDesktop ? 32 : 16,
                                vertical: 4),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: IconButton(
                                          icon: Icon(Icons.menu,
                                              color: Colors.black87,
                                              size: responsive.iconSize + 4),
                                          onPressed: () => Scaffold.of(context)
                                              .openEndDrawer())),
                                ])),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: responsive.isDesktop ? 100 : 24),
                            child: Image.asset('assets/images/logo.png',
                                width: responsive.isTablet ? 200 : 280,
                                height: logoH,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) =>
                                    SizedBox(height: logoH))),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: responsive.isDesktop
                                    ? 60
                                    : responsive.isTablet
                                        ? 30
                                        : 16,
                                vertical: 8),
                            child: Column(children: [
                              Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                      color: dark
                                          ? Colors.grey[800]!
                                              .withValues(alpha: 0.95)
                                          : Colors.white
                                              .withValues(alpha: 0.95),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 10)
                                      ]),
                                  child: TextField(
                                      controller: _searchController,
                                      onChanged: (v) =>
                                          setState(() => _searchQuery = v),
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
                                        suffixIcon: _searchQuery.isNotEmpty
                                            ? IconButton(
                                                icon: Icon(Icons.clear,
                                                    color: dark
                                                        ? Colors.grey[400]
                                                        : Colors.grey[500],
                                                    size: 18),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  setState(
                                                      () => _searchQuery = '');
                                                })
                                            : null,
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 12),
                                      ))),
                              if (sinResultados)
                                Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: Colors.red.shade50
                                                .withValues(alpha: 0.95),
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                                      color: Colors.red))),
                                        ]))),
                            ])),
                        Expanded(
                          child: filtrados.isEmpty && !sinResultados
                              ? Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                      Icon(Icons.museum,
                                          size: 60,
                                          color: dark
                                              ? Colors.grey[600]
                                              : Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      Text('No hay lugares disponibles',
                                          style: TextStyle(
                                              color: dark
                                                  ? Colors.grey[500]
                                                  : Colors.grey[600],
                                              fontSize: 16)),
                                    ]))
                              : GridView.builder(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: responsive.isDesktop
                                          ? 60
                                          : responsive.isTablet
                                              ? 30
                                              : 16,
                                      vertical: 8),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        responsive.isDesktop ? 3 : 2,
                                    childAspectRatio: responsive.isDesktop
                                        ? 0.9
                                        : responsive.isTablet
                                            ? 1.0
                                            : 0.82,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                  ),
                                  itemCount: filtrados.length,
                                  itemBuilder: (context, index) => _Card(
                                    lugar: filtrados[index],
                                    dark: dark,
                                    responsive: responsive,
                                    onVerMapa: () => _navegarAlMapa(
                                        context,
                                        filtrados[index].nombre,
                                        filtrados[index].lat,
                                        filtrados[index].lng),
                                  ),
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: responsive.isDesktop ? 60 : 20,
                              vertical: 10),
                          child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade600
                                          .withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(25)),
                                  child: Text(appState.t('volver_mapa'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: responsive.fs(17),
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500)))),
                        ),
                        const SizedBox(height: 10),
                      ]),
                    ))),
                  ]);
                },
              )),
    );
  }
}

class _Card extends StatefulWidget {
  final _LugarData lugar;
  final bool dark;
  final R responsive;
  final VoidCallback onVerMapa;
  const _Card(
      {required this.lugar,
      required this.dark,
      required this.responsive,
      required this.onVerMapa});
  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _mostrarDialogo() => showDialog(
      context: context,
      builder: (ctx) => _Dialogo(
          lugar: widget.lugar,
          dark: widget.dark,
          responsive: widget.responsive,
          onVerMapa: () {
            Navigator.pop(ctx);
            widget.onVerMapa();
          }));
  @override
  Widget build(BuildContext context) {
    final l = widget.lugar;
    final responsive = widget.responsive;
    return GestureDetector(
        onTap: _mostrarDialogo,
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
            scale: _scale,
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.30),
                          blurRadius: 16,
                          offset: const Offset(0, 8)),
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ]),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(fit: StackFit.expand, children: [
                      Image.asset(l.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                              color: widget.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                              child: Icon(Icons.museum,
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
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent
                              ])))),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 28, 12, 12),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                    Colors.black.withValues(alpha: 0.82),
                                    Colors.black.withValues(alpha: 0.55),
                                    Colors.transparent
                                  ])),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                            color:
                                                _DespuesCulturaDialog.amarillo,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(l.icono,
                                                  color: Colors.black87,
                                                  size: 11),
                                              const SizedBox(width: 4),
                                              Text(l.categoria,
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize:
                                                          responsive.fs(10),
                                                      fontWeight:
                                                          FontWeight.w700))
                                            ])),
                                    const SizedBox(height: 5),
                                    Text(l.nombre,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: responsive.fs(13.5),
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.3,
                                            shadows: const [
                                              Shadow(
                                                  blurRadius: 6,
                                                  color: Colors.black)
                                            ]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ]))),
                      Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      width: 1)),
                              child: const Icon(Icons.map_outlined,
                                  color: Colors.white, size: 16))),
                    ])))));
  }
}

class _Dialogo extends StatefulWidget {
  final _LugarData lugar;
  final bool dark;
  final R responsive;
  final VoidCallback onVerMapa;
  const _Dialogo(
      {required this.lugar,
      required this.dark,
      required this.responsive,
      required this.onVerMapa});
  @override
  State<_Dialogo> createState() => _DialogoState();
}

class _DialogoState extends State<_Dialogo> {
  static const Color amarillo = Color(0xFFF5C400);
  final _svc = FavoritosService();
  bool _esFavorito = false, _cargando = true;
  @override
  void initState() {
    super.initState();
    _svc.esFavorito(widget.lugar.nombre).then((v) => setState(() {
          _esFavorito = v;
          _cargando = false;
        }));
  }

  Future<void> _toggleFav() async {
    final nuevo = await _svc.toggleFavorito(
        nombre: widget.lugar.nombre,
        categoria: 'Cultura',
        subcategoria: widget.lugar.categoria,
        lat: widget.lugar.lat,
        lng: widget.lugar.lng,
        imagePath: widget.lugar.imagePath);
    setState(() => _esFavorito = nuevo);
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              nuevo ? '❤️ Guardado en favoritos' : '💔 Eliminado de favoritos'),
          duration: const Duration(seconds: 2),
          backgroundColor: nuevo ? Colors.green : Colors.grey[700]));
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lugar;
    final dark = widget.dark;
    final bgColor = dark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF1a1a1a);
    final subColor = dark ? Colors.grey[400]! : Colors.black54;
    final borderColor = dark ? Colors.grey[700]! : Colors.grey.shade300;
    final cancelBg = dark ? Colors.grey[800]! : Colors.grey.shade100;
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
        child: Container(
            decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 12))
                ]),
            clipBehavior: Clip.antiAlias,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Stack(fit: StackFit.expand, children: [
                    Image.asset(l.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.museum,
                                size: 60, color: Colors.grey[500]))),
                    Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6)
                        ]))),
                    Positioned(
                        bottom: 14,
                        left: 16,
                        right: 56,
                        child: Text(l.nombre,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(blurRadius: 8, color: Colors.black)
                                ]))),
                    Positioned(
                        top: 12,
                        left: 14,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: amarillo,
                                borderRadius: BorderRadius.circular(20)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(l.icono, color: Colors.black87, size: 12),
                              const SizedBox(width: 5),
                              Text(l.categoria,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700))
                            ]))),
                    Positioned(
                        bottom: 10,
                        right: 12,
                        child: GestureDetector(
                            onTap: _cargando ? null : _toggleFav,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: _esFavorito
                                        ? Colors.red.withValues(alpha: 0.9)
                                        : Colors.black.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.6),
                                        width: 1.5)),
                                child: _cargando
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : Icon(
                                        _esFavorito
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: Colors.white,
                                        size: 20)))),
                  ])),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('¿Quieres ver este lugar en el mapa?',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textColor)),
                        const SizedBox(height: 6),
                        Text(
                            'Podrás ver su ubicación exacta y más información sobre este lugar.',
                            style: TextStyle(
                                fontSize: 13, color: subColor, height: 1.4)),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(
                              child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13),
                                      decoration: BoxDecoration(
                                          color: cancelBg,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border:
                                              Border.all(color: borderColor)),
                                      child: Text('Cancelar',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: subColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14))))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: GestureDetector(
                                  onTap: widget.onVerMapa,
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13),
                                      decoration: BoxDecoration(
                                          color: amarillo,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                                color: amarillo.withValues(
                                                    alpha: 0.5),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4))
                                          ]),
                                      child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.map,
                                                color: Colors.black87,
                                                size: 16),
                                            SizedBox(width: 6),
                                            Text('Ver en mapa',
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14))
                                          ])))),
                        ]),
                      ])),
            ])));
  }
}

class _DespuesCulturaDialog {
  static const Color amarillo = Color(0xFFF5C400);
}
