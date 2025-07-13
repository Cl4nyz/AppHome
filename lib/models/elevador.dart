class Elevador {
  static const Map<String, double> alturas = {
    'até 0,50m': 12958.06,
    'até 1,00m': 14383.44,
    'até 1,70m': 14958.81,
    'até 2,10m': 15708.60,
    'até 2,60m': 16021.80,
    'até 3,10m': 16583.40,
    'até 3,60m': 17245.44,
    'até 4,00m': 17934.26,
    'até 5,00m': 19416.00,
  };

  static const Map<String, double> cabines = {
    '1,10m': 5184.00,
    '2,10m': 10943.10,
  };

  static const Map<String, double> adicionais = {
    'Trocar cancela por portão em chapa (unidade)': 737.10,
    'Rampa de acesso (unidade)': 740.00,
    'Porta de pav. alum. vidro temp.': 2097.90,
    'Porta de pav. alum. vidro lamin.': 2300.60,
    'Automatização (por porta de pav.)': 1500.00,
    'Sistema de pulso (comando automático)': 1247.40,
    'Barreira infra-vermelho (unidade)': 1792.80,
    'Cabinado c/ acm escovado, vidro ou chapa': 12943.10,
    'Nobreak': 3240.00,
    'Porta com automação': 3250.40,
    'Portão de pav. até 1.10x1.50 (unidade)': 1944.00,
    'Guarda corpo até 1.10x1.50 (cada lado)': 1080.00,
    'Enclausuramento (lado)': 7000.00,
    '3 paradas': 6000.00,
    'Aço carbono galvanizado': 1.15,
  };

  // Getters para manter compatibilidade com código existente
  static List<String> get alturasKeys => alturas.keys.toList();
  static List<double> get alturasValues => alturas.values.toList();
  static List<String> get cabinesKeys => cabines.keys.toList();
  static List<double> get cabinesValues => cabines.values.toList();
  static List<String> get adicionaisKeys => adicionais.keys.toList();
  static List<double> get adicionaisValues => adicionais.values.toList();
}