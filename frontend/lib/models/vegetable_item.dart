import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Centralized vegetable item model and configuration for farmer selection UI.
class VegetableItem {
  /// Unique internal ID
  final String id;

  /// Backend name used in API and recommendation pipeline (e.g., 'Tomato', 'Onion')
  final String backendName;

  /// Primary icon representing the vegetable
  final IconData icon;

  /// Signature color palette for the vegetable badge
  final Color primaryColor;

  /// Localization function that retrieves the translated name
  final String Function(AppLocalizations l10n) getLocalizedName;

  const VegetableItem({
    required this.id,
    required this.backendName,
    required this.icon,
    required this.primaryColor,
    required this.getLocalizedName,
  });
}

/// Centralized configuration list of supported vegetables for Farmer Input UI.
final List<VegetableItem> supportedVegetables = [
  VegetableItem(
    id: 'tomato',
    backendName: 'Tomato',
    icon: Icons.lunch_dining,
    primaryColor: const Color(0xFFE53935),
    getLocalizedName: (l10n) => l10n.vegTomato,
  ),
  VegetableItem(
    id: 'onion',
    backendName: 'Onion',
    icon: Icons.circle,
    primaryColor: const Color(0xFF8E24AA),
    getLocalizedName: (l10n) => l10n.vegOnion,
  ),
  VegetableItem(
    id: 'potato',
    backendName: 'Potato',
    icon: Icons.egg,
    primaryColor: const Color(0xFF8D6E63),
    getLocalizedName: (l10n) => l10n.vegPotato,
  ),
  VegetableItem(
    id: 'brinjal',
    backendName: 'Brinjal',
    icon: Icons.lens,
    primaryColor: const Color(0xFF5E35B1),
    getLocalizedName: (l10n) => l10n.vegBrinjal,
  ),
  VegetableItem(
    id: 'bhindi',
    backendName: 'Bhindi',
    icon: Icons.eco,
    primaryColor: const Color(0xFF43A047),
    getLocalizedName: (l10n) => l10n.vegBhindi,
  ),
  VegetableItem(
    id: 'bottle_gourd',
    backendName: 'Bottle Gourd',
    icon: Icons.water_drop_outlined,
    primaryColor: const Color(0xFF7CB342),
    getLocalizedName: (l10n) => l10n.vegBottleGourd,
  ),
  VegetableItem(
    id: 'bitter_gourd',
    backendName: 'Bitter Gourd',
    icon: Icons.grain,
    primaryColor: const Color(0xFF2E7D32),
    getLocalizedName: (l10n) => l10n.vegBitterGourd,
  ),
  VegetableItem(
    id: 'ridge_gourd',
    backendName: 'Ridge Gourd',
    icon: Icons.line_weight,
    primaryColor: const Color(0xFF388E3C),
    getLocalizedName: (l10n) => l10n.vegRidgeGourd,
  ),
  VegetableItem(
    id: 'snake_gourd',
    backendName: 'Snake Gourd',
    icon: Icons.waves,
    primaryColor: const Color(0xFF66BB6A),
    getLocalizedName: (l10n) => l10n.vegSnakeGourd,
  ),
  VegetableItem(
    id: 'cabbage',
    backendName: 'Cabbage',
    icon: Icons.spa,
    primaryColor: const Color(0xFF4CAF50),
    getLocalizedName: (l10n) => l10n.vegCabbage,
  ),
  VegetableItem(
    id: 'cauliflower',
    backendName: 'Cauliflower',
    icon: Icons.filter_vintage,
    primaryColor: const Color(0xFF607D8B),
    getLocalizedName: (l10n) => l10n.vegCauliflower,
  ),
  VegetableItem(
    id: 'carrot',
    backendName: 'Carrot',
    icon: Icons.navigation,
    primaryColor: const Color(0xFFFB8C00),
    getLocalizedName: (l10n) => l10n.vegCarrot,
  ),
  VegetableItem(
    id: 'beans',
    backendName: 'Beans',
    icon: Icons.segment,
    primaryColor: const Color(0xFF33691E),
    getLocalizedName: (l10n) => l10n.vegBeans,
  ),
  VegetableItem(
    id: 'green_peas',
    backendName: 'Green Peas',
    icon: Icons.more_horiz,
    primaryColor: const Color(0xFF558B2F),
    getLocalizedName: (l10n) => l10n.vegGreenPeas,
  ),
  VegetableItem(
    id: 'spinach',
    backendName: 'Spinach',
    icon: Icons.grass,
    primaryColor: const Color(0xFF1B5E20),
    getLocalizedName: (l10n) => l10n.vegSpinach,
  ),
  VegetableItem(
    id: 'capsicum',
    backendName: 'Capsicum',
    icon: Icons.shield,
    primaryColor: const Color(0xFF00897B),
    getLocalizedName: (l10n) => l10n.vegCapsicum,
  ),
  VegetableItem(
    id: 'green_chilli',
    backendName: 'Green Chilli',
    icon: Icons.bolt,
    primaryColor: const Color(0xFF2E7D32),
    getLocalizedName: (l10n) => l10n.vegGreenChilli,
  ),
];
