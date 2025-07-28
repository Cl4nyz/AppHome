import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _vendedorKey = 'vendedor_nome';

  // Salvar nome do vendedor
  static Future<void> salvarNomeVendedor(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vendedorKey, nome);
  }

  // Obter nome do vendedor
  static Future<String> obterNomeVendedor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_vendedorKey) ?? '';
  }

  // Limpar nome do vendedor
  static Future<void> limparNomeVendedor() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vendedorKey);
  }
}
