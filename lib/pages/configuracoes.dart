import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../constants/app_constants.dart';
import '../services/settings_service.dart';

class ConfiguracoesPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const ConfiguracoesPage({super.key, required this.themeProvider});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  FontScale _fontScaleSelecionada = FontScale.normal;
  final TextEditingController _vendedorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Aplicar a escala de fonte salva (seria melhor usar SharedPreferences em uma implementação real)
    FontSizes.setFontScale(_fontScaleSelecionada.scale);
    _carregarNomeVendedor();
  }

  Future<void> _carregarNomeVendedor() async {
    final nome = await SettingsService.obterNomeVendedor();
    setState(() {
      _vendedorController.text = nome;
    });
  }

  Future<void> _salvarNomeVendedor() async {
    await SettingsService.salvarNomeVendedor(_vendedorController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nome do vendedor salvo com sucesso!'),
        backgroundColor: AZUL_CLARO,
      ),
    );
  }

  @override
  void dispose() {
    _vendedorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: Container(
          height: 50,
          child: Image.asset('assets/icons/home.png'),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xffF7F8F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONFIGURAÇÕES',
              style: TextStyle(
                fontSize: FontSizes.display,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle(context, 'Vendedor'),
            const SizedBox(height: 15),
            _buildVendedorCard(context),
            const SizedBox(height: 30),
            _buildSectionTitle(context, 'Aparência'),
            const SizedBox(height: 15),
            _buildThemeToggle(context),
            const SizedBox(height: 20),
            _buildFontScaleSelector(context),
            const SizedBox(height: 30),
            _buildSectionTitle(context, 'Sobre'),
            const SizedBox(height: 15),
            _buildInfoCard(
              context,
              'Versão do App',
              '1.0.0',
              Icons.info_outline,
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              context,
              'Desenvolvido por',
              'Home Elevadores',
              Icons.code,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendedorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome do Vendedor',
                      style: TextStyle(
                        fontSize: FontSizes.large,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Nome que aparecerá nos orçamentos',
                      style: TextStyle(
                        fontSize: FontSizes.small,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _vendedorController,
            decoration: InputDecoration(
              hintText: 'Digite o nome do vendedor',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: _salvarNomeVendedor,
                icon: Icon(
                  Icons.save,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: FontSizes.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: FontSizes.title,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildFontScaleSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.text_fields,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tamanho da Fonte',
                      style: TextStyle(
                        fontSize: FontSizes.large,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Ajuste o tamanho do texto',
                      style: TextStyle(
                        fontSize: FontSizes.small,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            children: FontScale.values.map((scale) {
              return ChoiceChip(
                label: Text(
                  scale.label,
                  style: TextStyle(
                    fontSize: FontSizes.medium,
                    fontWeight: _fontScaleSelecionada == scale 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                ),
                selected: _fontScaleSelecionada == scale,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _fontScaleSelecionada = scale;
                      FontSizes.setFontScale(scale.scale);
                    });
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(
                  color: _fontScaleSelecionada == scale 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey.withOpacity(0.3),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo Escuro',
                  style: TextStyle(
                    fontSize: FontSizes.large,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.themeProvider.isDarkMode 
                      ? 'Tema escuro ativado' 
                      : 'Tema claro ativado',
                  style: TextStyle(
                    fontSize: FontSizes.small,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.themeProvider.isDarkMode,
            onChanged: (value) {
              setState(() {
                widget.themeProvider.toggleTheme();
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: FontSizes.large,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: FontSizes.small,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
