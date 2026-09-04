import 'package:flutter/material.dart';

enum GameThemeType {
  aurora('Neo-Aurora', Icons.auto_awesome, 0),
  cyberpunk('Cyberpunk', Icons.electric_bolt, 300),
  gold('Golden Royalty', Icons.stars, 1000),
  emerald('Emerald Nature', Icons.eco, 500),
  glacier('Glacier Ice', Icons.ac_unit, 500),
  classic('Classic Warm', Icons.grid_view, 0);

  final String label;
  final IconData icon;
  final int coinCost;

  const GameThemeType(this.label, this.icon, this.coinCost);
}

class TileStyle {
  final Gradient gradient;
  final Color textColor;
  final Border? border;
  final List<BoxShadow> shadows;

  const TileStyle({
    required this.gradient,
    required this.textColor,
    this.border,
    this.shadows = const [],
  });
}

class AppTheme {
  static const Color background = Color(0xFFFAF8EF);
  static const Color boardBackground = Color(0xFFBBADA0);
  static const Color emptyCell = Color(0xFFCDC1B4);
  static const Color darkText = Color(0xFF776E65);
  static const Color lightText = Color(0xFFF9F6F2);
  static const Color buttonColor = Color(0xFF8F7A66);
  static const Color scoreBoxBackground = Color(0xFFBBADA0);
  static const Color scoreLabelColor = Color(0xFFEEE4DA);
  static const Color scoreValueColor = Colors.white;
  static const Color subtitleText = Color(0xFF776E65);

  static BoxDecoration getScreenBackground(GameThemeType theme) {
    switch (theme) {
      case GameThemeType.aurora:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF090D16), Color(0xFF0E1726), Color(0xFF111E36), Color(0xFF0A0F1D)],
          ),
        );
      case GameThemeType.cyberpunk:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF140A22), Color(0xFF1D0B34), Color(0xFF0F061D)],
          ),
        );
      case GameThemeType.gold:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF12100E), Color(0xFF2B2117), Color(0xFF1A140E)],
          ),
        );
      case GameThemeType.emerald:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF061A14), Color(0xFF0B2E24), Color(0xFF04120E)],
          ),
        );
      case GameThemeType.glacier:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A192F), Color(0xFF0D2547), Color(0xFF06101E)],
          ),
        );
      case GameThemeType.classic:
        return const BoxDecoration(color: Color(0xFFFAF8EF));
    }
  }

  static Color getBoardBackground(GameThemeType theme) {
    switch (theme) {
      case GameThemeType.aurora:
        return const Color(0x28FFFFFF);
      case GameThemeType.cyberpunk:
        return const Color(0x35000000);
      case GameThemeType.gold:
        return const Color(0x35000000);
      case GameThemeType.emerald:
        return const Color(0x2E041E15);
      case GameThemeType.glacier:
        return const Color(0x2A1E3A5F);
      case GameThemeType.classic:
        return const Color(0xFFBBADA0);
    }
  }

  static Border? getBoardBorder(GameThemeType theme) {
    switch (theme) {
      case GameThemeType.aurora:
        return Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5);
      case GameThemeType.cyberpunk:
        return Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.4), width: 2);
      case GameThemeType.gold:
        return Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4), width: 2);
      case GameThemeType.emerald:
        return Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35), width: 1.5);
      case GameThemeType.glacier:
        return Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.5);
      case GameThemeType.classic:
        return null;
    }
  }

  static List<BoxShadow> getBoardShadow(GameThemeType theme) {
    switch (theme) {
      case GameThemeType.aurora:
        return [
          BoxShadow(color: const Color(0xFF00F5D4).withValues(alpha: 0.08), blurRadius: 30),
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10)),
        ];
      case GameThemeType.cyberpunk:
        return [
          BoxShadow(color: const Color(0xFFFF007F).withValues(alpha: 0.2), blurRadius: 25),
          BoxShadow(color: const Color(0xFF00F0FF).withValues(alpha: 0.15), blurRadius: 30),
        ];
      case GameThemeType.gold:
        return [
          BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.15), blurRadius: 25),
        ];
      case GameThemeType.emerald:
        return [
          BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.15), blurRadius: 25),
        ];
      case GameThemeType.glacier:
        return [
          BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.2), blurRadius: 25),
        ];
      case GameThemeType.classic:
        return [];
    }
  }

  static Color getEmptyCellColor(GameThemeType theme) {
    switch (theme) {
      case GameThemeType.aurora:
        return const Color(0x15FFFFFF);
      case GameThemeType.cyberpunk:
        return const Color(0x20FF007F);
      case GameThemeType.gold:
        return const Color(0x15FFD700);
      case GameThemeType.emerald:
        return const Color(0x1810B981);
      case GameThemeType.glacier:
        return const Color(0x1E38BDF8);
      case GameThemeType.classic:
        return const Color(0xFFCDC1B4);
    }
  }

  static Color getTextColor(GameThemeType theme) {
    if (theme == GameThemeType.classic) return const Color(0xFF776E65);
    return Colors.white;
  }

  static Color getSubtitleColor(GameThemeType theme) {
    switch (theme) {
      case GameThemeType.aurora:
        return const Color(0xFF94A3B8);
      case GameThemeType.cyberpunk:
        return const Color(0xFFE2E8F0);
      case GameThemeType.gold:
        return const Color(0xFFD4AF37);
      case GameThemeType.emerald:
        return const Color(0xFFA7F3D0);
      case GameThemeType.glacier:
        return const Color(0xFFBAE6FD);
      case GameThemeType.classic:
        return const Color(0xFF776E65);
    }
  }

  static Color getCardBackground(GameThemeType theme) {
    switch (theme) {
      case GameThemeType.aurora:
        return const Color(0x2EFFFFFF);
      case GameThemeType.cyberpunk:
        return const Color(0x401A0B2E);
      case GameThemeType.gold:
        return const Color(0x353B2D1B);
      case GameThemeType.emerald:
        return const Color(0x35064E3B);
      case GameThemeType.glacier:
        return const Color(0x350C4A6E);
      case GameThemeType.classic:
        return const Color(0xFFBBADA0);
    }
  }

  static Color getButtonColor(GameThemeType theme) {
    switch (theme) {
      case GameThemeType.aurora:
        return const Color(0xFF38BDF8);
      case GameThemeType.cyberpunk:
        return const Color(0xFFFF007F);
      case GameThemeType.gold:
        return const Color(0xFFFFD700);
      case GameThemeType.emerald:
        return const Color(0xFF10B981);
      case GameThemeType.glacier:
        return const Color(0xFF0EA5E9);
      case GameThemeType.classic:
        return const Color(0xFF8F7A66);
    }
  }

  static Gradient getLogoGradient(GameThemeType theme) {
    switch (theme) {
      case GameThemeType.aurora:
        return const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF818CF8), Color(0xFFC084FC)]);
      case GameThemeType.cyberpunk:
        return const LinearGradient(colors: [Color(0xFF00F0FF), Color(0xFFFF007F), Color(0xFFFFE600)]);
      case GameThemeType.gold:
        return const LinearGradient(colors: [Color(0xFFFFDF73), Color(0xFFFFD700), Color(0xFFD4AF37)]);
      case GameThemeType.emerald:
        return const LinearGradient(colors: [Color(0xFF6EE7B7), Color(0xFF10B981), Color(0xFF047857)]);
      case GameThemeType.glacier:
        return const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFF38BDF8), Color(0xFF0284C7)]);
      case GameThemeType.classic:
        return const LinearGradient(colors: [Color(0xFF776E65), Color(0xFF776E65)]);
    }
  }

  static TileStyle getTileStyle(int value, GameThemeType theme) {
    switch (theme) {
      case GameThemeType.aurora:
        return _getAuroraTileStyle(value);
      case GameThemeType.cyberpunk:
        return _getCyberpunkTileStyle(value);
      case GameThemeType.gold:
        return _getGoldTileStyle(value);
      case GameThemeType.emerald:
        return _getEmeraldTileStyle(value);
      case GameThemeType.glacier:
        return _getGlacierTileStyle(value);
      case GameThemeType.classic:
        return _getClassicTileStyle(value);
    }
  }

  static TileStyle _getAuroraTileStyle(int value) {
    switch (value) {
      case 2:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
          textColor: const Color(0xFFE2E8F0),
          border: Border.all(color: const Color(0xFF64748B).withValues(alpha: 0.5)),
        );
      case 4:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]),
          textColor: Colors.white,
          border: Border.all(color: const Color(0xFF2DD4BF)),
          shadows: [BoxShadow(color: const Color(0xFF14B8A6).withValues(alpha: 0.3), blurRadius: 8)],
        );
      case 8:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)]),
          textColor: Colors.white,
          border: Border.all(color: const Color(0xFF38BDF8)),
          shadows: [BoxShadow(color: const Color(0xFF0EA5E9).withValues(alpha: 0.4), blurRadius: 10)],
        );
      case 16:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFF4338CA), Color(0xFF6366F1)]),
          textColor: Colors.white,
          border: Border.all(color: const Color(0xFF818CF8)),
          shadows: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.45), blurRadius: 12)],
        );
      case 32:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFF7E22CE), Color(0xFFA855F7)]),
          textColor: Colors.white,
          border: Border.all(color: const Color(0xFFC084FC)),
          shadows: [BoxShadow(color: const Color(0xFFA855F7).withValues(alpha: 0.5), blurRadius: 14)],
        );
      case 64:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFFBE185D), Color(0xFFEC4899)]),
          textColor: Colors.white,
          border: Border.all(color: const Color(0xFFF472B6)),
          shadows: [BoxShadow(color: const Color(0xFFEC4899).withValues(alpha: 0.55), blurRadius: 16)],
        );
      case 128:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFFC2410C), Color(0xFFF97316)]),
          textColor: Colors.white,
          border: Border.all(color: const Color(0xFFFB923C)),
          shadows: [BoxShadow(color: const Color(0xFFF97316).withValues(alpha: 0.6), blurRadius: 18, spreadRadius: 1)],
        );
      case 256:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFFB45309), Color(0xFFF59E0B)]),
          textColor: Colors.white,
          border: Border.all(color: const Color(0xFFFBBF24)),
          shadows: [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.65), blurRadius: 20, spreadRadius: 2)],
        );
      case 512:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFF15803D), Color(0xFF22C55E)]),
          textColor: Colors.white,
          border: Border.all(color: const Color(0xFF4ADE80), width: 2),
          shadows: [BoxShadow(color: const Color(0xFF22C55E).withValues(alpha: 0.7), blurRadius: 22, spreadRadius: 2)],
        );
      case 1024:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF06B6D4), Color(0xFF3B82F6)]),
          textColor: Colors.white,
          border: Border.all(color: const Color(0xFF67E8F9), width: 2),
          shadows: [BoxShadow(color: const Color(0xFF06B6D4).withValues(alpha: 0.8), blurRadius: 24, spreadRadius: 3)],
        );
      case 2048:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFF8B5CF6), Color(0xFF06B6D4)]),
          textColor: Colors.white,
          border: Border.all(color: Colors.white, width: 2.5),
          shadows: [
            BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.9), blurRadius: 28, spreadRadius: 4),
            BoxShadow(color: const Color(0xFFF43F5E).withValues(alpha: 0.7), blurRadius: 32, spreadRadius: 2),
          ],
        );
      default:
        return TileStyle(
          gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)]),
          textColor: const Color(0xFF38BDF8),
          border: Border.all(color: const Color(0xFF38BDF8), width: 2),
          shadows: [BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.8), blurRadius: 30, spreadRadius: 4)],
        );
    }
  }

  static TileStyle _getCyberpunkTileStyle(int value) {
    if (value <= 2) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF26123D), Color(0xFF3B1C5E)]), textColor: const Color(0xFF00F0FF));
    } else if (value <= 4) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF4A154B), Color(0xFF701A75)]), textColor: const Color(0xFFFFE600));
    } else if (value <= 8) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF831843), Color(0xFFBE185D)]), textColor: Colors.white, shadows: [BoxShadow(color: const Color(0xFFFF007F).withValues(alpha: 0.5), blurRadius: 10)]);
    } else if (value <= 32) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF0369A1), Color(0xFF0284C7)]), textColor: Colors.white, shadows: [BoxShadow(color: const Color(0xFF00F0FF).withValues(alpha: 0.5), blurRadius: 12)]);
    } else if (value <= 128) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFFB45309), Color(0xFFEAB308)]), textColor: Colors.black, shadows: [BoxShadow(color: const Color(0xFFFFE600).withValues(alpha: 0.6), blurRadius: 14)]);
    } else {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFFFF007F), Color(0xFF00F0FF)]), textColor: Colors.white, border: Border.all(color: Colors.white, width: 2), shadows: [BoxShadow(color: const Color(0xFF00F0FF).withValues(alpha: 0.8), blurRadius: 25)]);
    }
  }

  static TileStyle _getGoldTileStyle(int value) {
    if (value <= 4) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF262018), Color(0xFF3B3020)]), textColor: const Color(0xFFFFDF73));
    } else if (value <= 32) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF5C4813), Color(0xFF8A6C1D)]), textColor: Colors.white, shadows: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.4), blurRadius: 10)]);
    } else if (value <= 256) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFFB38F24), Color(0xFFD4AF37)]), textColor: const Color(0xFF1E1404), border: Border.all(color: const Color(0xFFFFF1A8), width: 1.5), shadows: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.6), blurRadius: 16)]);
    } else {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFFFFE680), Color(0xFFFFD700), Color(0xFFB8860B)]), textColor: const Color(0xFF1A1202), border: Border.all(color: Colors.white, width: 2.5), shadows: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.8), blurRadius: 25, spreadRadius: 3)]);
    }
  }

  static TileStyle _getEmeraldTileStyle(int value) {
    if (value <= 4) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF0B2E24), Color(0xFF0F3D30)]), textColor: const Color(0xFFA7F3D0));
    } else if (value <= 32) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF065F46), Color(0xFF047857)]), textColor: Colors.white, shadows: [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.4), blurRadius: 10)]);
    } else if (value <= 256) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]), textColor: Colors.white, shadows: [BoxShadow(color: const Color(0xFF34D399).withValues(alpha: 0.6), blurRadius: 16)]);
    } else {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF10B981), Color(0xFF064E3B)]), textColor: Colors.white, border: Border.all(color: Colors.white, width: 2), shadows: [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.8), blurRadius: 25)]);
    }
  }

  static TileStyle _getGlacierTileStyle(int value) {
    if (value <= 4) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF0F2B48), Color(0xFF173D66)]), textColor: const Color(0xFFBAE6FD));
    } else if (value <= 32) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF0369A1), Color(0xFF0284C7)]), textColor: Colors.white, shadows: [BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), blurRadius: 10)]);
    } else if (value <= 256) {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF38BDF8)]), textColor: Colors.white, shadows: [BoxShadow(color: const Color(0xFF7DD3FC).withValues(alpha: 0.6), blurRadius: 16)]);
    } else {
      return TileStyle(gradient: const LinearGradient(colors: [Color(0xFFBAE6FD), Color(0xFF38BDF8), Color(0xFF0369A1)]), textColor: const Color(0xFF082F49), border: Border.all(color: Colors.white, width: 2), shadows: [BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.8), blurRadius: 25)]);
    }
  }

  static TileStyle _getClassicTileStyle(int value) {
    const Map<int, Color> classicColors = {
      2: Color(0xFFEEE4DA),
      4: Color(0xFFEDE0C8),
      8: Color(0xFFF2B179),
      16: Color(0xFFF59563),
      32: Color(0xFFF67C5F),
      64: Color(0xFFF65E3B),
      128: Color(0xFFEDCF72),
      256: Color(0xFFEDCC61),
      512: Color(0xFFEDC850),
      1024: Color(0xFFEDC53F),
      2048: Color(0xFFEDC22E),
      4096: Color(0xFF3C3A32),
      8192: Color(0xFF2E2C26),
    };
    final color = classicColors[value] ?? const Color(0xFF1E1D19);
    final textColor = value <= 4 ? const Color(0xFF776E65) : const Color(0xFFF9F6F2);
    return TileStyle(gradient: LinearGradient(colors: [color, color]), textColor: textColor);
  }

  static double getTileFontSize(int value, double tileSize) {
    if (value < 100) return tileSize * 0.44;
    if (value < 1000) return tileSize * 0.38;
    if (value < 10000) return tileSize * 0.30;
    return tileSize * 0.24;
  }
}
