import 'package:atlas_icons/atlas_icons.dart';
import 'package:flutter/material.dart';

const ColorScheme _lightScheme = ColorScheme.light(
  surface: Color(0xFFf2e9e1),
  surfaceContainer: Color(0xFFfffaf3),
  primary: Color(0xFFd7827e),
  secondary: Color(0xFF286983),
  tertiary: Color(0xFF907aa9),
  shadow: Color(0xFFcecacd),
  onPrimary: Color(0xFFfffaf3),
  onSecondary: Color(0xFFfffaf3),
  onTertiary: Color(0xFFfffaf3),
  onSurface: Color(0xFF575279),
  onSurfaceVariant: Color(0xFF797593),
  error: Color(0xFFeb6f92),
);

final BottomNavigationBarThemeData _bottomNavigationBarTheme =
    BottomNavigationBarThemeData(
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
  titleTextStyle: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: _lightScheme.onSurface,
    fontFamily: 'Poppins',
  ),
);

final ElevatedButtonThemeData _elevatedButtonThemeData =
    ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    shadowColor: _lightScheme.primary,
    backgroundColor: _lightScheme.primary,
    foregroundColor: _lightScheme.onPrimary,
    disabledBackgroundColor: _lightScheme.primary.withOpacity(0.5),
    disabledForegroundColor: _lightScheme.surface,
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    minimumSize: const Size.fromHeight(20),
    fixedSize: const Size.fromHeight(60),
  ),
);

const DividerThemeData _dividerThemeData =
    DividerThemeData(color: Colors.transparent);

final OutlinedButtonThemeData _outlinedButtonThemeData =
    OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: _lightScheme.primary,
    side: BorderSide(
      color: _lightScheme.primary,
      width: 2,
    ),
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    minimumSize: const Size.fromHeight(20),
    fixedSize: const Size.fromHeight(60),
  ),
);

final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
  fillColor: _lightScheme.surfaceContainer,
  filled: true,
  labelStyle: TextStyle(color: _lightScheme.onSurfaceVariant, fontSize: 14),
  floatingLabelStyle: TextStyle(color: _lightScheme.onSurface),
  focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
  border: const OutlineInputBorder(borderSide: BorderSide.none),
  enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
  hintStyle: const TextStyle(fontSize: 14),
  floatingLabelBehavior: FloatingLabelBehavior.never,
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

final FloatingActionButtonThemeData _floatingActionButtonThemeData =
    FloatingActionButtonThemeData(
  backgroundColor: _lightScheme.primary,
  foregroundColor: _lightScheme.onPrimary,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
);

final CardTheme _cardTheme = CardTheme(
  color: _lightScheme.surfaceContainer,
  margin: EdgeInsets.zero,
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

final ActionIconThemeData _actionIconThemeData = ActionIconThemeData(
  backButtonIconBuilder: (context) => const Icon(
    Icons.chevron_left_rounded,
    size: 36,
  ),
  drawerButtonIconBuilder: (context) => const Icon(
    Atlas.justify_bold,
    size: 20,
  ),
);

final ThemeData lightTheme = ThemeData(
  colorScheme: _lightScheme,
  fontFamily: 'Poppins',
  primaryColor: _lightScheme.primary,
  brightness: Brightness.light,
  secondaryHeaderColor: _lightScheme.secondary,
  actionIconTheme: _actionIconThemeData,
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
