import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const ColorScheme _colorScheme = ColorScheme.dark(
  background: Color(0xFF191724),
  surface: Color(0xFF1f1d2e),
  primary: Color(0xFF92BFB1),
  secondary: Color(0xFFebbcba),
  onBackground: Color(0xFFe0def4),
  onPrimary: Color(0xFF191724),
  onSecondary: Color(0xFF191724),
  onSurface: Color(0xFFe0def4),
  error: Color(0xFFeb6f92),
);

// const ColorScheme _colorScheme = ColorScheme.dark(
//   background: Color(0xFF191724),
//   surface: Color(0xFF1f1d2e),
//   primary: Color(0xFFebbcba),
//   secondary: Color(0xFF92BFB1),
//   onBackground: Color(0xFFe0def4),
//   onPrimary: Color(0xFF191724),
//   onSecondary: Color(0xFF191724),
//   onSurface: Color(0xFFe0def4),
//   error: Color(0xFFeb6f92),
// );

final AppBarTheme _appBarTheme = AppBarTheme(
  backgroundColor: _colorScheme.surface,
  iconTheme: const IconThemeData(
    size: 30,
  ),
  centerTitle: true,
  titleTextStyle: GoogleFonts.scada(
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: _colorScheme.onBackground,
  ),
);

final ElevatedButtonThemeData _elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    shadowColor: _colorScheme.primary,
    backgroundColor: _colorScheme.primary,
    foregroundColor: _colorScheme.onPrimary,
    disabledBackgroundColor: _colorScheme.onSurface,
    textStyle: GoogleFonts.scada(
      fontSize: 22,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    minimumSize: const Size.fromHeight(60),
  ),
);

const DividerThemeData _dividerThemeData = DividerThemeData(color: Colors.transparent);

final OutlinedButtonThemeData _outlinedButtonThemeData = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: _colorScheme.primary,
    side: BorderSide(
      color: _colorScheme.primary,
      width: 2,
    ),
    textStyle: GoogleFonts.scada(
      fontSize: 22,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    minimumSize: const Size.fromHeight(60),
  ),
);

final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
  labelStyle: TextStyle(
    color: _colorScheme.primary,
  ),
  floatingLabelStyle: TextStyle(
    color: _colorScheme.primary,
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _colorScheme.primary,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _colorScheme.primary,
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _colorScheme.error,
    ),
  ),
  errorStyle: TextStyle(
    color: _colorScheme.error,
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _colorScheme.primary,
    ),
  ),
  isDense: true,
  contentPadding: const EdgeInsets.all(20),
);

final IconThemeData _iconThemeData = IconThemeData(
  color: _colorScheme.onSurface,
);

final FloatingActionButtonThemeData _floatingActionButtonThemeData = FloatingActionButtonThemeData(
  backgroundColor: _colorScheme.primary,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
);

final CardTheme _cardTheme = CardTheme(
  color: _colorScheme.surface,
  shadowColor: _colorScheme.primary,
  elevation: 2,
);

final PopupMenuThemeData _popupMenuTheme = PopupMenuThemeData(
  color: _colorScheme.surface,
  shape: RoundedRectangleBorder(
    side: BorderSide(
      color: _colorScheme.primary,
      width: 0.5,
    ),
    borderRadius: BorderRadius.circular(5),
  ),
);

final ThemeData theme = ThemeData(
  colorScheme: _colorScheme,
  textTheme: GoogleFonts.scadaTextTheme().apply(
    displayColor: _colorScheme.onSurface,
    bodyColor: _colorScheme.onBackground,
    decorationColor: _colorScheme.onBackground,
  ),
  elevatedButtonTheme: _elevatedButtonThemeData,
  outlinedButtonTheme: _outlinedButtonThemeData,
  inputDecorationTheme: _inputDecorationTheme,
  iconTheme: _iconThemeData,
  appBarTheme: _appBarTheme,
  cardTheme: _cardTheme,
  canvasColor: _colorScheme.surface,
  scaffoldBackgroundColor: _colorScheme.background,
  floatingActionButtonTheme: _floatingActionButtonThemeData,
  dividerTheme: _dividerThemeData,
  popupMenuTheme: _popupMenuTheme,
);
