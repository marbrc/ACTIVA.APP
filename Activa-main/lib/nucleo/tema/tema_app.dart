// ===================================================================
// Colores del logo y tema general de toda la app
// ===================================================================

import 'package:flutter/material.dart';


// Transición entre pantallas: entra con fundido y un deslizamiento corto,
// mientras la pantalla anterior se desvanece
class TransicionActiva extends PageTransitionsBuilder {
  const TransicionActiva();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final entra = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final sale = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(entra),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(entra),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(entra),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(sale),
            child: child,
          ),
        ),
      ),
    );
  }
}



// Aquí van todos los colores de la app, sacados del logo
// Nombre de la tipografía (registrada en pubspec.yaml)
class FuentesApp {
  static const century = 'Century';
}

class ColoresApp {
  // ---------- Colores del logo ----------
  // azul muy oscuro
  static const deep = Color(0xFF05245A);
  // azul marino
  static const navy = Color(0xFF0A3175);
  // azul océano
  static const ocean = Color(0xFF0A5FBF);
  // azul principal (botones, íconos activos)
  static const primary = Color(0xFF1B78E2);
  // Azul de la ola
  static const wave = Color(0xFF259CFB);
  // celeste clarito
  static const sky = Color(0xFF75D2FE);
  // azul casi blanco (fondos suaves)
  static const mist = Color(0xFFEAF4FF);

  // ---------- Neutros y de estado ----------
  // fondo de las pantallas
  static const background = Color(0xFFF2F7FE);
  // Color del texto normal
  static const ink = Color(0xFF0B1B3A);
  // Texto secundario (gris azulado)
  static const muted = Color(0xFF5B6B88);
  // color de los bordes finitos
  static const line = Color(0xFFE0EAF8);
  // verde azulado (lugares disponibles)
  static const teal = Color(0xFF14B8A6);
  // Rojo (errores, cupo lleno)
  static const danger = Color(0xFFE5484D);
  // naranja (avisos)
  static const warning = Color(0xFFF5A623);

  // degradado azul del encabezado (de esquina a esquina)
  static const heroGradient = LinearGradient(
    // Empieza arriba a la izquierda
    begin: Alignment.topLeft,
    // Termina abajo a la derecha
    end: Alignment.bottomRight,
    // Los tres azules en orden
    colors: [deep, navy, ocean],
  );

  // sombra suave que usan las tarjetas
  static final softShadow = [
    BoxShadow(
      // Azul marino bien transparente
      color: navy.withValues(alpha: 0.08),
      // Qué tan difuminada se ve
      blurRadius: 24,
      // La baja 10 pixeles
      offset: const Offset(0, 10),
    ),
  ];
}

// tema general: define cómo se ven botones, inputs, barra, etc.
class TemaApp {
  // Getter que regresa el tema claro
  static ThemeData get light {
    // Esquema de colores a partir del azul principal
    final scheme = ColorScheme.fromSeed(seedColor: ColoresApp.primary).copyWith(
      primary: ColoresApp.primary,
      onPrimary: Colors.white,
      secondary: ColoresApp.wave,
      surface: Colors.white,
      onSurface: ColoresApp.ink,
      error: ColoresApp.danger,
    );

    // Letra Century con el color de texto de la app
    final textTheme = ThemeData.light().textTheme
        .apply(fontFamily: FuentesApp.century)
        .apply(bodyColor: ColoresApp.ink, displayColor: ColoresApp.ink);

    // Función para crear bordes redondos de los campos de texto
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );

    // Transición tipo iPhone: la pantalla nueva se desliza suave
    const slide = TransicionActiva();

    return ThemeData(
      useMaterial3: true,
      fontFamily: FuentesApp.century,
      colorScheme: scheme,
      // Fondo de todas las pantallas
      scaffoldBackgroundColor: ColoresApp.background,
      textTheme: textTheme,
      // Efecto de ondita al tocar
      splashFactory: InkRipple.splashFactory,
      // Misma transición en todas las plataformas
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: slide,
          TargetPlatform.iOS: slide,
          TargetPlatform.windows: slide,
          TargetPlatform.macOS: slide,
          TargetPlatform.linux: slide,
          TargetPlatform.fuchsia: slide,
        },
      ),

      // Barra de arriba de las pantallas
      appBarTheme: AppBarTheme(
        backgroundColor: ColoresApp.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: ColoresApp.navy),
        titleTextStyle: TextStyle(
          fontFamily: FuentesApp.century,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ColoresApp.navy,
        ),
      ),

      // Botones llenos (FilledButton)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Alto de 54 y ancho completo
          minimumSize: const Size.fromHeight(58),
          backgroundColor: ColoresApp.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          // Duración de la transición de color al presionar
          animationDuration: const Duration(milliseconds: 250),
          shape: const StadiumBorder(),
          textStyle: TextStyle(
            fontFamily: FuentesApp.century,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // Botones con solo borde (OutlinedButton)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          foregroundColor: ColoresApp.primary,
          side: BorderSide(
            color: ColoresApp.primary.withValues(alpha: 0.5),
            width: 1.4,
          ),
          animationDuration: const Duration(milliseconds: 250),
          shape: const StadiumBorder(),
          textStyle: TextStyle(
            fontFamily: FuentesApp.century,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // Botones de solo texto (TextButton)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColoresApp.primary,
          textStyle: TextStyle(
            fontFamily: FuentesApp.century,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        // Fondo blanco
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9AA8C0), fontSize: 14),
        // El ícono de la izquierda se pone azul cuando escribes
        prefixIconColor: WidgetStateColor.resolveWith(
          (s) => s.contains(WidgetState.focused)
              ? ColoresApp.primary
              : ColoresApp.muted,
        ),
        suffixIconColor: ColoresApp.muted,
        // Bordes en cada estado
        border: border(ColoresApp.line),
        enabledBorder: border(ColoresApp.line),
        focusedBorder: border(ColoresApp.primary, 1.8),
        errorBorder: border(ColoresApp.danger),
        focusedErrorBorder: border(ColoresApp.danger, 1.8),
      ),

      // Barra de navegación de abajo
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        shadowColor: ColoresApp.navy.withValues(alpha: 0.18),
        height: 70,
        // Óvalo clarito detrás del ícono elegido
        indicatorColor: ColoresApp.mist,
        // Solo muestra el nombre de la pestaña elegida
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        // Ícono azul si está elegido, gris si no
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 26,
            color: s.contains(WidgetState.selected)
                ? ColoresApp.primary
                : ColoresApp.muted,
          ),
        ),
        // Letra de cada pestaña
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          final sel = s.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: FuentesApp.century,
            fontSize: 11.5,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
            color: sel ? ColoresApp.primary : ColoresApp.muted,
          );
        }),
      ),

      // Mensajes que salen abajo (SnackBar)
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ColoresApp.navy,
        contentTextStyle: TextStyle(
          fontFamily: FuentesApp.century,
          color: Colors.white,
          fontSize: 13.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      // Chips (etiquetas)
      chipTheme: ChipThemeData(
        backgroundColor: ColoresApp.mist,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          fontFamily: FuentesApp.century,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ColoresApp.navy,
        ),
      ),

      // Barras y círculos de progreso
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ColoresApp.primary,
        linearTrackColor: ColoresApp.mist,
        circularTrackColor: ColoresApp.mist,
      ),

      // Casillas de verificación
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? ColoresApp.primary : null,
        ),
      ),

      // Líneas divisorias
      dividerTheme: const DividerThemeData(color: ColoresApp.line, space: 1),

      // Ventanas que suben desde abajo
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // Ventanas de diálogo
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
