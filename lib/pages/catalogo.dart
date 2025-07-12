import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

const AZULCLARO = Color.fromARGB(255, 32, 143, 167);
const AZULESCURO = Color.fromARGB(255, 11, 55, 94);

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  int selectedModelIndex = 0;

  // Lista de modelos dummy - você pode substituir pelos seus modelos posteriormente
  final List<ModeloElevador> modelos = [
    ModeloElevador(
      nome: "Elevador Residencial",
      descricao: "Modelo padrão para uso residencial",
      modelUrl: "assets/models/enclausurado.glb", // Modelo dummy
      preco: "R\$ 15.000",
    ),
    ModeloElevador(
      nome: "Elevador Comercial",
      descricao: "Modelo robusto para uso comercial",
      modelUrl: "https://github.com/Cl4nyz/test_assets/blob/858f17472641b4c0c8c4991b8936440592ab5336/enclausurado.glb", // Modelo dummy
      preco: "R\$ 25.000",
    ),
    ModeloElevador(
      nome: "Elevador Industrial",
      descricao: "Modelo para cargas pesadas",
      modelUrl: "https://modelviewer.dev/shared-assets/models/Horse.glb", // Modelo dummy
      preco: "R\$ 35.000",
    ),
    ModeloElevador(
      nome: "Elevador Panorâmico",
      descricao: "Modelo com vista panorâmica",
      modelUrl: "https://modelviewer.dev/shared-assets/models/MaterialsVariantsShoe.glb", // Modelo dummy
      preco: "R\$ 45.000",
    ),
  ];

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
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xffF7F8F8),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(
              Icons.arrow_back,
              color: AZULESCURO,
              size: 20
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              'CATÁLOGO DE ELEVADORES',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AZULESCURO,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Visualizador 3D
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ModelViewer(
                  backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
                  src: modelos[selectedModelIndex].modelUrl,
                  alt: modelos[selectedModelIndex].nome,
                  ar: true,
                  autoRotate: true,
                  cameraControls: true,
                  loading: Loading.eager,
                ),
              ),
            ),
          ),

          // Informações do modelo selecionado
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AZULCLARO,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modelos[selectedModelIndex].nome,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  modelos[selectedModelIndex].descricao,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      modelos[selectedModelIndex].preco,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Orçamento para ${modelos[selectedModelIndex].nome} solicitado!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AZULESCURO,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Solicitar Orçamento',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista horizontal de modelos
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: modelos.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedModelIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedModelIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: isSelected ? AZULESCURO : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected 
                          ? Border.all(color: AZULCLARO, width: 3)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.elevator,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Modelo ${index + 1}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ModeloElevador {
  final String nome;
  final String descricao;
  final String modelUrl;
  final String preco;

  ModeloElevador({
    required this.nome,
    required this.descricao,
    required this.modelUrl,
    required this.preco,
  });
}
