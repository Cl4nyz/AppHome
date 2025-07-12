import 'package:flutter/material.dart';
import 'calculadora.dart';
import 'catalogo.dart';

const AZULCLARO = Color.fromARGB(255, 32, 143, 167);
const AZULESCURO = Color.fromARGB(255, 11, 55, 94);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Container(
          height: 50,
          child: Image.asset('assets/icons/home.png'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'SELECIONE UMA FUNÇÃO',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AZULESCURO,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            _buildFunctionCard(
              context,
              'CONFIGURAÇÕES',
              'Ajuste as configurações do app',
              Icons.settings,
              () {
                // TODO: Implementar tela de configurações
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Função em desenvolvimento'),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AZULCLARO,
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
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 30,
                color: AZULESCURO,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
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
