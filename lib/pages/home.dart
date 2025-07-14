import 'package:flutter/material.dart';
import 'calculadora.dart';
import 'catalogo.dart';
import 'configuracoes.dart';
import '../providers/theme_provider.dart';
import '../constants/app_constants.dart';

class HomePage extends StatelessWidget {
  final ThemeProvider themeProvider;
  
  const HomePage({super.key, required this.themeProvider});

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
      ),
      body: Padding(
        padding: EdgeInsets.all(Dimensions.spacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SELECIONE UMA FUNÇÃO',
              style: TextStyle(
                fontSize: FontSizes.display,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Dimensions.spacing * 2),
            _buildFunctionCard(
              context,
              'CALCULADORA',
              'Calcule o valor de elevadores',
              Icons.calculate,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalculadoraPage(),
                  ),
                );
              },
            ),
            SizedBox(height: Dimensions.spacing),
            _buildFunctionCard(
              context,
              'CATÁLOGO',
              'Visualize produtos disponíveis',
              Icons.list_alt,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CatalogoPage(),
                  ),
                );
              },
            ),
            SizedBox(height: Dimensions.spacing),
            _buildFunctionCard(
              context,
              'ORÇAMENTOS',
              'Gerencie seus orçamentos',
              Icons.receipt_long,
              () {
                // TODO: Implementar tela de orçamentos
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Função em desenvolvimento'),
                  ),
                );
              },
            ),
            SizedBox(height: Dimensions.spacing),
            _buildFunctionCard(
              context,
              'CONFIGURAÇÕES',
              'Ajuste as configurações do app',
              Icons.settings,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfiguracoesPage(themeProvider: themeProvider),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Dimensions.spacing),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(Dimensions.borderRadius + 5),
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
              padding: EdgeInsets.all(Dimensions.borderRadius + 5),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.borderRadius),
              ),
              child: Icon(
                icon,
                size: 30,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(width: Dimensions.spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: FontSizes.title,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: Dimensions.paddingSmall / 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: FontSizes.medium,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
