import 'package:flutter/material.dart';

// CORES
const AZUL_CLARO = Color.fromARGB(255, 32, 143, 167);
const AZUL_ESCURO = Color.fromARGB(255, 11, 55, 94);

// CORES PDF (valores em hexadecimal)
const PDF_CLARO = 0xFF208FA7;
const PDF_ESCURO = 0xFF0B375E;

// TAMANHOS DE FONTE
class FontSizes {
  static double _fontScale = 1.0;
  
  static void setFontScale(double scale) {
    _fontScale = scale;
  }
  
  static double get fontScale => _fontScale;
  
  // Tamanhos base
  static double get small => 12.0 * _fontScale;
  static double get medium => 14.0 * _fontScale;
  static double get large => 16.0 * _fontScale;
  static double get extraLarge => 18.0 * _fontScale;
  static double get title => 20.0 * _fontScale;
  static double get bigTitle => 25.0 * _fontScale;
  static double get display => 28.0 * _fontScale;
  static double get totalValue => 24.0 * _fontScale;
  
  // Tamanhos específicos da calculadora
  static double get calculatorTitle => bigTitle * 0.8;
  static double get calculatorSmallTitle => bigTitle * 0.65;
  static double get calculatorText => extraLarge;
  static double get calculatorSmallText => medium;
  
  // Tamanhos para cliente info (padrão de referência)
  static double get clienteLabel => medium;
  static double get clienteText => medium;
  static double get clienteTitle => large;
}

// DIMENSÕES
class Dimensions {
  static const double buttonHeight = 60.0;
  static const double buttonHeightSmall = 32.0;
  static const double arrowSize = 45.0;
  static const double borderRadius = 10.0;
  static const double borderRadiusSmall = 8.0;
  static const double padding = 16.0;
  static const double paddingSmall = 8.0;
  static const double spacing = 20.0;
  static const double spacingSmall = 10.0;
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 20.0;
}

// OPÇÕES DE ESCALA DE FONTE
enum FontScale {
  pequena(0.85, 'Pequena'),
  normal(1.0, 'Normal'),
  grande(1.15, 'Grande'),
  extraGrande(1.3, 'Extra Grande');
  
  const FontScale(this.scale, this.label);
  final double scale;
  final String label;
}
