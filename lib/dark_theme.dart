import 'package:flutter/material.dart';

const ColorScheme _darkScheme = ColorScheme.dark(
  surface: Color(0xFF191724),
  surfaceContainer: Color(0xFF1f1d2e),
  primary: Color(0xFFebbcba),
  shadow: Color(0xFF524f67),
  secondary: Color(0xFF9ccfd8),
  tertiary: Color(0xFFc4a7e7),
  error: Color(0xFFeb6f92),
  onPrimary: Color(0xFF191724),
  onSecondary: Color(0xFF191724),
  onTertiary: Color(0xFF191724),
  onSurface: Color(0xFFe0def4),
  onSurfaceVariant: Color(0xFF908caa),
  onError: Color(0xFFe0def4),
);

final BottomNavigationBarThemeData _bottomNavigationBarTheme = BottomNavigationBarThemeData(
  type: BottomNavigationBarType.fixed,
  selectedItemColor: _darkScheme.primary,
  unselectedItemColor: _darkScheme.onSurface,
  elevation: 10,
  unselectedLabelStyle: TextStyle(color: _darkScheme.onSurface),
  selectedLabelStyle: TextStyle(color: _darkScheme.primary),
  showUnselectedLabels: false,
  showSelectedLabels: true,
);

final AppBarTheme _appBarTheme = AppBarTheme(
  backgroundColor: _darkScheme.surface,
  elevation: 1,
  iconTheme: const IconThemeData(
    size: 30,
  ),
  surfaceTintColor: Colors.transparent,
  centerTitle: true,
  titleTextStyle: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: _darkScheme.onSurface,
  ),
);

final ElevatedButtonThemeData _elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    shadowColor: _darkScheme.primary,
    backgroundColor: _darkScheme.primary,
    foregroundColor: _darkScheme.onPrimary,
    disabledBackgroundColor: _darkScheme.onSurface,
    textStyle: const TextStyle(
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
    foregroundColor: _darkScheme.primary,
    side: BorderSide(
      color: _darkScheme.primary,
      width: 2,
    ),
    textStyle: const TextStyle(
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
  foregroundColor: _darkScheme.onPrimary,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
);

final CardTheme _cardTheme = CardTheme(
  color: _darkScheme.surfaceContainer,
  shadowColor: _darkScheme.shadow,
  elevation: 1,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
);

final PopupMenuThemeData _popupMenuTheme = PopupMenuThemeData(
  color: _darkScheme.surface,
  surfaceTintColor: Colors.transparent,
  shape: RoundedRectangleBorder(
    side: BorderSide(
      color: _darkScheme.primary,
      width: 0.5,
    ),
    borderRadius: BorderRadius.circular(5),
  ),
);

final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    padding: EdgeInsets.zero,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkScheme,
  fontFamily: 'Poppins',
  elevatedButtonTheme: _elevatedButtonThemeData,
  outlinedButtonTheme: _outlinedButtonThemeData,
  inputDecorationTheme: _inputDecorationTheme,
  iconTheme: _iconThemeData,
  appBarTheme: _appBarTheme,
  textButtonTheme: _textButtonTheme,
  cardTheme: _cardTheme,
  canvasColor: _darkScheme.surface,
  disabledColor: _darkScheme.onSurface,
  scaffoldBackgroundColor: _darkScheme.surface,
  floatingActionButtonTheme: _floatingActionButtonThemeData,
  dividerTheme: _dividerThemeData,
  popupMenuTheme: _popupMenuTheme,
  bottomNavigationBarTheme: _bottomNavigationBarTheme,
  applyElevationOverlayColor: true,
);
