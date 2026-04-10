import 'package:flutter/material.dart';

class R {
  final double w;
  final double h;
  final bool isTablet;
  final bool isDesktop;
  final bool isMobile;

  // Breakpoints basados en dp (density-independent pixels) de Android
  // Móvil pequeño: < 360dp (ej: Galaxy A series antiguos)
  // Móvil normal:  360-411dp (ej: Galaxy S21, Pixel 6)
  // Móvil grande:  412-479dp (ej: Galaxy S21 Ultra, Pixel 7 Pro)
  // Tablet:        >= 480dp  (ej: Galaxy Tab, iPad)
  // Desktop:       >= 1024dp

  R(BuildContext context)
      : w = MediaQuery.of(context).size.width,
        h = MediaQuery.of(context).size.height,
        isTablet = MediaQuery.of(context).size.width >= 480 &&
            MediaQuery.of(context).size.width < 1024,
        isDesktop = MediaQuery.of(context).size.width >= 1024,
        isMobile = MediaQuery.of(context).size.width < 480;

  // Detectar tamaño de móvil Android
  bool get isSmallPhone => w < 360; // Galaxy A series, viejos
  bool get isNormalPhone => w >= 360 && w < 412; // Galaxy S21, Pixel 6
  bool get isLargePhone => w >= 412 && w < 480; // S21 Ultra, Pixel 7 Pro

  // Padding horizontal adaptado a Android
  double get hPad {
    if (isDesktop) return w * 0.25;
    if (isTablet) return w * 0.12;
    if (isLargePhone) return w * 0.06;
    if (isNormalPhone) return w * 0.07;
    return w * 0.08; // small phone
  }

  // Ancho máximo del contenido
  double get maxW {
    if (isDesktop) return 500;
    if (isTablet) return w * 0.75;
    return double.infinity;
  }

  // Tamaño de fuente — base en dp Android estándar
  double fs(double base) {
    if (isDesktop) return base * 1.1;
    if (isTablet) return base * 1.05;
    if (isSmallPhone) return base * 0.9;
    return base; // normal y large phone usan base
  }

  // Espaciado vertical
  double sp(double base) {
    if (isDesktop) return base * 1.2;
    if (isTablet) return base * 1.1;
    if (isSmallPhone) return base * 0.85;
    return base;
  }

  // Tamaño de íconos
  double get iconSize {
    if (isTablet) return 28;
    if (isLargePhone) return 26;
    return 24;
  }

  // Altura de botones
  double get buttonHeight {
    if (isTablet) return 56;
    if (isLargePhone) return 52;
    if (isNormalPhone) return 50;
    return 46; // small phone
  }

  // Border radius estándar Android Material 3
  double get cardRadius => isTablet ? 20 : 16;
  double get buttonRadius => isTablet ? 28 : 25;

  // Columnas del grid según dispositivo
  int get gridColumns {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }

  // Aspect ratio del grid
  double get gridAspectRatio {
    if (isDesktop) return 1.2;
    if (isTablet) return 1.25;
    if (isLargePhone) return 1.15;
    if (isNormalPhone) return 1.1;
    return 1.05;
  }
}
