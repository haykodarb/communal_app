import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const ColorScheme _lightScheme = ColorScheme.light(
  surface: Color(0xFFf2e9e1),
  surfaceContainer: Color(0xFFfffaf3),
  primary: Color(0xFFd7827e),
  secondary: Color(0xFF286983),
  // secondary: Color(0xFFebbcba),
  tertiary: Color(0xFF907aa9),
  onSurfaceVariant: Color(0xFF0F1F1B),
  shadow: Color(0xFFcecacd),
  onPrimary: Color(0xFFfaf4ed),
  onSecondary: Color(0xFFfaf4ed),
  onTertiary: Color(0xFFfaf4ed),
  onSurface: Color(0xFF575279),
  error: Color(0xFFeb6f92),
);

final BottomNavigationBarThemeData _bottomNavigationBarTheme = BottomNavigationBarThemeData(
  type: BottomNavigationBarType.fixed,
  selectedItemColor: _lightScheme.primary,
  unselectedItemColor: _lightScheme.onSurface,
  backgroundColor: _lightScheme.primary,
  elevation: 10,
  unselectedLabelStyle: TextStyle(color: _lightScheme.onSurface),
  selectedLabelStyle: TextStyle(color: _lightScheme.primary),
  showUnselectedLabels: false,
  showSelectedLabels: true,
);

final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    padding: EdgeInsets.zero,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ),
);

final AppBarTheme _appBarTheme = AppBarTheme(
  backgroundColor: _lightScheme.surface,
  elevation: 1,
  surfaceTintColor: Colors.transparent,
  iconTheme: const IconThemeData(
    size: 30,
  ),
  centerTitle: true,
  titleTextStyle: GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: _lightScheme.onSurface,
  ),
);

final ElevatedButtonThemeData _elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    shadowColor: _lightScheme.primary,
    backgroundColor: _lightScheme.primary,
    foregroundColor: _lightScheme.onPrimary,
    disabledBackgroundColor: _lightScheme.onSurface,
    textStyle: GoogleFonts.poppins(
      fontSize: 18,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    minimumSize: const Size.fromHeight(50),
  ),
);

const DividerThemeData _dividerThemeData = DividerThemeData(color: Colors.transparent);

final OutlinedButtonThemeData _outlinedButtonThemeData = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: _lightScheme.primary,
    side: BorderSide(
      color: _lightScheme.primary,
      width: 2,
    ),
    textStyle: GoogleFonts.poppins(
      fontSize: 18,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    minimumSize: const Size.fromHeight(50),
  ),
);

final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
  labelStyle: TextStyle(
    color: _lightScheme.primary,
  ),
  floatingLabelStyle: TextStyle(
    color: _lightScheme.primary,
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _lightScheme.primary,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _lightScheme.primary,
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _lightScheme.error,
    ),
  ),
  errorStyle: TextStyle(
    color: _lightScheme.error,
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _lightScheme.primary,
    ),
  ),
  isDense: true,
  contentPadding: const EdgeInsets.all(20),
);

final IconThemeData _iconThemeData = IconThemeData(
  color: _lightScheme.onSurface,
);

final FloatingActionButtonThemeData _floatingActionButtonThemeData = FloatingActionButtonThemeData(
  backgroundColor: _lightScheme.primary,
  foregroundColor: _lightScheme.onPrimary,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
);

final CardTheme _cardTheme = CardTheme(
  color: _lightScheme.surfaceContainer,
  shadowColor: _lightScheme.shadow,
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
);

final PopupMenuThemeData _popupMenuTheme = PopupMenuThemeData(
  color: _lightScheme.surface,
  shape: RoundedRectangleBorder(
    side: BorderSide(
      color: _lightScheme.primary,
      width: 0.5,
    ),
    borderRadius: BorderRadius.circular(5),
  ),
);

final ThemeData lightTheme = ThemeData(
  colorScheme: _lightScheme,
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    displayColor: _lightScheme.onSurface,
    bodyColor: _lightScheme.onSurface,
    decorationColor: _lightScheme.onSurface,
  ),
  primaryColor: _lightScheme.primary,
  secondaryHeaderColor: _lightScheme.secondary,
  textButtonTheme: _textButtonTheme,
  dialogBackgroundColor: _lightScheme.surface,
  cardColor: _lightScheme.surface,
  elevatedButtonTheme: _elevatedButtonThemeData,
  outlinedButtonTheme: _outlinedButtonThemeData,
  inputDecorationTheme: _inputDecorationTheme,
  iconTheme: _iconThemeData,
  appBarTheme: _appBarTheme,
  cardTheme: _cardTheme,
  canvasColor: _lightScheme.surface,
  disabledColor: _lightScheme.onSurface,
  scaffoldBackgroundColor: _lightScheme.surface,
  floatingActionButtonTheme: _floatingActionButtonThemeData,
  dividerTheme: _dividerThemeData,
  popupMenuTheme: _popupMenuTheme,
  bottomNavigationBarTheme: _bottomNavigationBarTheme,
);
