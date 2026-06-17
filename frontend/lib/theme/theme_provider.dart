import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AmbientModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    try {
      final box = Hive.box('settings');
      return box.get('ambient_mode', defaultValue: true) as bool;
    } catch (e) {
      return true; // Fallback if Hive fails to initialize
    }
  }

  void toggleAmbientMode() {
    try {
      final box = Hive.box('settings');
      final newState = !state;
      box.put('ambient_mode', newState);
      state = newState;
    } catch (e) {
      state = !state;
    }
  }
}

final ambientModeProvider = NotifierProvider<AmbientModeNotifier, bool>(() {
  return AmbientModeNotifier();
});
enum FeedLayoutMode { grid, card }

class FeedLayoutNotifier extends Notifier<FeedLayoutMode> {
  @override
  FeedLayoutMode build() {
    return FeedLayoutMode.grid;
  }

  void toggleLayout() {
    state = state == FeedLayoutMode.grid ? FeedLayoutMode.card : FeedLayoutMode.grid;
  }

  void setLayout(FeedLayoutMode mode) {
    state = mode;
  }
}

class BrightnessNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.system; // Default to system brightness
  }

  void toggleBrightness() {
    if (state == ThemeMode.system) {
      state = ThemeMode.dark;
    } else if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }

  void setBrightness(ThemeMode mode) {
    state = mode;
  }
}

final feedLayoutProvider = NotifierProvider<FeedLayoutNotifier, FeedLayoutMode>(() {
  return FeedLayoutNotifier();
});

final brightnessProvider = NotifierProvider<BrightnessNotifier, ThemeMode>(() {
  return BrightnessNotifier();
});

enum NavbarStyle { standard, hiddenLabels, floatingPill }

class NavbarStyleNotifier extends Notifier<NavbarStyle> {
  @override
  NavbarStyle build() {
    return NavbarStyle.standard;
  }

  void setStyle(NavbarStyle style) {
    state = style;
  }
}

final navbarStyleProvider = NotifierProvider<NavbarStyleNotifier, NavbarStyle>(() {
  return NavbarStyleNotifier();
});

enum ColorThemeStyle { pastelPop, cyberNeon, ultraMinimalist }

class ColorThemeNotifier extends Notifier<ColorThemeStyle> {
  @override
  ColorThemeStyle build() {
    return ColorThemeStyle.pastelPop;
  }

  void setStyle(ColorThemeStyle style) {
    state = style;
  }
}

final colorThemeProvider = NotifierProvider<ColorThemeNotifier, ColorThemeStyle>(() {
  return ColorThemeNotifier();
});

enum ProfileLayoutStyle { modernCover, centeredMinimalist }

class ProfileLayoutNotifier extends Notifier<ProfileLayoutStyle> {
  @override
  ProfileLayoutStyle build() {
    return ProfileLayoutStyle.modernCover;
  }

  void setStyle(ProfileLayoutStyle style) {
    state = style;
  }
}

final profileLayoutProvider = NotifierProvider<ProfileLayoutNotifier, ProfileLayoutStyle>(() {
  return ProfileLayoutNotifier();
});
