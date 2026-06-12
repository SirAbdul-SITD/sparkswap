// lib/utils/constants.dart
import 'package:flutter/material.dart';

// ── SparkSwap palette: vintage copper circuitry on dark bronze ──────────
const Color kBg          = Color(0xFF140D06);
const Color kSurface     = Color(0xFF221608);
const Color kBorder      = Color(0xFF4A3014);
const Color kAccent      = Color(0xFFFFB74D); // warm copper-amber
const Color kTraceOff    = Color(0xFF6B4A1E);
const Color kTraceOn     = Color(0xFFFFC56E);
const Color kSourceColor = Color(0xFFFF7043); // hot filament orange
const Color kBulbOff     = Color(0xFF4E443A);
const Color kBulbOn      = Color(0xFFFFE082); // warm lamp glow
const Color kSelect      = Color(0xFFFFD180);
const Color kTextPrimary = Color(0xFFFFF3E0);
const Color kTextDim     = Color(0xFFBE9B6B);

const Color kStarOn  = Color(0xFFFFD54F);
const Color kStarOff = Color(0xFF3A2A14);

const Color kEasyColor   = Color(0xFF9CCC65);
const Color kMediumColor = Color(0xFFFFB74D);
const Color kHardColor   = Color(0xFFFF7043);

const int kTotalLevels = 150;

TextStyle techno(double size,
        {Color color = kTextPrimary,
        FontWeight weight = FontWeight.bold,
        double letterSpacing = 1.5}) =>
    TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing);
