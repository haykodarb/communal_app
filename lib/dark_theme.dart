import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const ColorScheme _darkScheme = ColorScheme.dark(
  background: Color(0xFF191724),
  surface: Color(0xFF1f1d2e),
  primary: Color(0xFF92BFB1),
  secondary: Color(0xFFebbcba),
  tertiary: Color(0xFFEC9B98),
  onBackground: Color(0xFFFFFFFF),
  onPrimary: Color(0xFFFFFFFF),
  onSecondary: Color(0xFFFFFFFF),
  onTertiary: Color(0xFFFFFFFF),
  onSurface: Color(0xFFFFFFFF),
  error: Color(0xFFeb6f92),
);

final BottomNavigationBarThemeData _bottomNavigationBarTheme = BottomNavigationBarThemeData(
  type: BottomNavigationBarType.fixed,
  selectedItemColor: _darkScheme.primary,
  unselectedItemColor: _darkScheme.onPrimary,
  elevation: 10,
  unselectedLabelStyle: TextStyle(color: _darkScheme.onPrimary),
  selectedLabelStyle: TextStyle(color: _darkScheme.primary),
  showUnselectedLabels: false,
  showSelectedLabels: false,
);

final AppBarTheme _appBarTheme = AppBarTheme(
  backgroundColor: _darkScheme.surface,
  iconTheme: const IconThemeData(
    size: 30,
  ),
  centerTitle: true,
  titleTextStyle: GoogleFonts.scada(
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: _darkScheme.onBackground,
  ),
);

final ElevatedButtonThemeData _elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    shadowColor: _darkScheme.primary,
    backgroundColor: _darkScheme.primary,
    foregroundColor: _darkScheme.onPrimary,
    disabledBackgroundColor: _darkScheme.onSurface,
    textStyle: GoogleFonts.scada(
      fontSize: 20,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    minimumSize: const Size.fromHeight(50),
  ),
);

const DividerThemeData _dividerThemeData = DividerThemeData(color: Colors.transparent);

final OutlinedButtonThemeData _outlinedButtonThemeData = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: _darkScheme.primary,
    side: BorderSide(
      color: _darkScheme.primary,
      width: 2,
    ),
    textStyle: GoogleFonts.scada(
      fontSize: 20,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    minimumSize: const Size.fromHeight(50),
  ),
);

final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
  labelStyle: TextStyle(
    color: _darkScheme.primary,
  ),
  floatingLabelStyle: TextStyle(
    color: _darkScheme.primary,
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _darkScheme.primary,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _darkScheme.primary,
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _darkScheme.error,
    ),
  ),
  errorStyle: TextStyle(
    color: _darkScheme.error,
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _darkScheme.primary,
    ),
  ),
  isDense: true,
  contentPadding: const EdgeInsets.all(20),
);

final IconThemeData _iconThemeData = IconThemeData(
  color: _darkScheme.onSurface,
);

final FloatingActionButtonThemeData _floatingActionButtonThemeData = FloatingActionButtonThemeData(
  backgroundColor: _darkScheme.primary,
  foregroundColor: _darkScheme.background,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
);

final CardTheme _cardTheme = CardTheme(
  color: _darkScheme.surface,
  shadowColor: _darkScheme.primary,
  elevation: 2,
);

final PopupMenuThemeData _popupMenuTheme = PopupMenuThemeData(
  color: _darkScheme.surface,
  shape: RoundedRectangleBorder(
    side: BorderSide(
      color: _darkScheme.primary,
      width: 0.5,
    ),
    borderRadius: BorderRadius.circular(5),
  ),
);

final ThemeData darkTheme = ThemeData(
  colorScheme: _darkScheme,
  textTheme: GoogleFonts.interTextTheme().apply(
    displayColor: _darkScheme.onSurface,
    bodyColor: _darkScheme.onBackground,
    decorationColor: _darkScheme.onBackground,
  ),
  elevatedButtonTheme: _elevatedButtonThemeData,
  outlinedButtonTheme: _outlinedButtonThemeData,
  inputDecorationTheme: _inputDecorationTheme,
  iconTheme: _iconThemeData,
  appBarTheme: _appBarTheme,
  cardTheme: _cardTheme,
  canvasColor: _darkScheme.background,
  disabledColor: _darkScheme.onBackground,
  scaffoldBackgroundColor: _darkScheme.background,
  floatingActionButtonTheme: _floatingActionButtonThemeData,
  dividerTheme: _dividerThemeData,
  popupMenuTheme: _popupMenuTheme,
  bottomNavigationBarTheme: _bottomNavigationBarTheme,
);
