import 'package:flutter/material.dart';

/// Dark Holo — Cyberpunk color palette for SafeChat Gen Z redesign.
abstract class HoloColors {
  // Backgrounds
  static const bgVoid = Color(0xFF06060F);
  static const bgCard = Color(0xFF12122A);
  static const bgSurface = Color(0xFF1A1A35);
  static const bgGlass = Color(0x2212122A); // 13% opacity card bg for glassmorphism

  // Neon Glows
  static const glowPurple = Color(0xFFA855F7);
  static const glowPurpleLight = Color(0xFFD8B4FE);
  static const glowCyan = Color(0xFF22D3EE);
  static const glowCyanLight = Color(0xFFA5F3FC);
  static const glowPink = Color(0xFFEC4899);
  static const glowPinkLight = Color(0xFFFBCFE8);

  // Semantic
  static const safeGreen = Color(0xFF4ADE80);
  static const warningAmber = Color(0xFFFBBF24);
  static const dangerRed = Color(0xFFF87171);

  // Text
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF475569);

  // Borders
  static const borderGlow = Color(0x55A855F7); // purple border for cards
  static const borderSubtle = Color(0xFF1E1E3A);

  // Mood colors for Vibe Bar (stories)
  static const moodHappy = Color(0xFFFBBF24);   // yellow
  static const moodChill = Color(0xFF22D3EE);   // cyan
  static const moodHype = Color(0xFFEC4899);    // pink
  static const moodSad = Color(0xFF818CF8);     // indigo
  static const moodAngry = Color(0xFFF87171);   // red
  static const moodNeutral = Color(0xFF94A3B8); // grey

  // Online status
  static const statusOnline = safeGreen;
  static const statusInFlow = Color(0xFF60A5FA); // blue
  static const statusOnStory = glowPink;
  static const statusOffline = Color(0xFF475569);
}
