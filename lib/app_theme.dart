import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color neonBlue = Color(0xFF00FFFF);
  static const Color neonPink = Color(0xFFFF00FF);
  static const Color darkBackground = Color(0xFF0A0A14);
  static const Color glassColor = Color(0x1AFFFFFF); // Faint white for glass
  static const Color cardColor =
      Color(0xFF161A25); // Dark card color (Used for solid menus)

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF000022), Color(0xFF1A001A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      // Required for glass effect
      cardColor: glassColor,
      // This is the default glass color for GlassCard
      dividerColor: neonBlue.withOpacity(0.3),

      textTheme: GoogleFonts.poppinsTextTheme(
        baseTextTheme.copyWith(
          displayLarge: baseTextTheme.displayLarge
              ?.copyWith(color: neonBlue, fontWeight: FontWeight.w700),
          titleLarge: baseTextTheme.titleLarge
              ?.copyWith(color: neonPink, fontWeight: FontWeight.w600),
          titleMedium: baseTextTheme.titleMedium
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
          bodyMedium: baseTextTheme.bodyMedium
              ?.copyWith(color: Colors.white.withOpacity(0.8)),
          bodySmall: baseTextTheme.bodySmall
              ?.copyWith(color: Colors.white.withOpacity(0.6)),
        ),
      ),

      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.cyan,
        brightness: Brightness.dark,
      ).copyWith(
        primary: neonBlue,
        secondary: neonPink,
      ),

      // Theme for TabBar (top)
      tabBarTheme: TabBarThemeData(
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: neonPink, width: 3.0),
        ),
        labelColor: neonPink,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),

      // Theme for NavigationRail (side)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.white.withOpacity(0.05),
        indicatorColor: neonBlue.withOpacity(0.3),
        selectedIconTheme: const IconThemeData(color: neonBlue),
        unselectedIconTheme: const IconThemeData(color: Colors.white70),
        selectedLabelTextStyle: const TextStyle(color: neonBlue),
        unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
      ),

      // This styles the newer DropdownMenu widgets
      dropdownMenuTheme: DropdownMenuThemeData(
        // This styles the text inside the dropdown
        textStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.9),
          fontSize: 14,
        ),
        // This styles the container (the input field)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: glassColor.withOpacity(0.8),
          // Using the glass color for the field
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: neonBlue.withOpacity(0.5), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: neonPink, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        // This styles the menu that appears
        menuStyle: MenuStyle(
          backgroundColor: MaterialStateProperty.all(darkBackground),
          surfaceTintColor: MaterialStateProperty.all(darkBackground),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: neonBlue.withOpacity(0.5)),
            ),
          ),
        ),
      ),
    );
  }
}
