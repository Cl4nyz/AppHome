import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../constants/app_constants.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  int selectedModelIndex = 0;
  bool isARMode = false;

  // Lista de modelos com suporte a AR
  final List<ModeloElevador> modelos = [
    ModeloElevador(
      nome: "Elevador Residencial",
      descricao: "Modelo padrão para uso residencial",
      modelUrl: "https://modelviewer.dev/shared-assets/models/Astronaut.glb",
      arModelUrl: "https://modelviewer.dev/shared-assets/models/Astronaut.glb",
      preco: "R\$ 15.000",
    ),
    ModeloElevador(
      nome: "Elevador Comercial",
      descricao: "Modelo robusto para uso comercial",
      modelUrl: "https://modelviewer.dev/shared-assets/models/Horse.glb",
      arModelUrl: "https://modelviewer.dev/shared-assets/models/Horse.glb",
      preco: "R\$ 25.000",
    ),
    ModeloElevador(
      nome: "Elevador Industrial",
      descricao: "Modelo para cargas pesadas",
      modelUrl: "https://modelviewer.dev/shared-assets/models/MaterialsVariantsShoe.glb",
      arModelUrl: "https://modelviewer.dev/shared-assets/models/MaterialsVariantsShoe.glb",
      preco: "R\$ 35.000",
    ),
    ModeloElevador(
      nome: "Elevador Panorâmico",
      descricao: "Modelo com vista panorâmica",
      modelUrl: "https://modelviewer.dev/shared-assets/models/RobotExpressive.glb",
      arModelUrl: "https://modelviewer.dev/shared-assets/models/RobotExpressive.glb",
      preco: "R\$ 45.000",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTitle(),
          _buildViewModeToggle(),
          _buildModelViewer(),
          _buildModelInfo(),
          _buildModelSelector(),
        ],
      ),
    );
  }

  // AppBar personalizada
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Container(
        height: 50,
        child: Image.asset('assets/icons/home.png'),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(Dimensions.paddingSmall),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffF7F8F8),
            borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          ),
          child: Icon(
            Icons.arrow_back,
            color: AZUL_ESCURO,
            size: 20,
          ),
        ),
      ),
    );
  }

  // Título da página
  Widget _buildTitle() {
    return Container(
      padding: EdgeInsets.all(Dimensions.padding),
      child: Text(
        'CATÁLOGO DE ELEVADORES',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AZUL_ESCURO,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Toggle entre modo normal e AR
  Widget _buildViewModeToggle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(Dimensions.borderRadius),
            ),
            child: Row(
              children: [
                _buildToggleButton(
                  text: '3D Viewer',
                  isSelected: !isARMode,
                  icon: Icons.view_in_ar_outlined,
                  onTap: () => setState(() => isARMode = false),
                ),
                _buildToggleButton(
                  text: 'Realidade Aumentada',
                  isSelected: isARMode,
                  icon: Icons.view_in_ar,
                  onTap: () => setState(() => isARMode = true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Botão do toggle
  Widget _buildToggleButton({
    required String text,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.padding,
          vertical: Dimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AZUL_ESCURO : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AZUL_ESCURO,
              size: 18,
            ),
            SizedBox(width: Dimensions.paddingSmall),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : AZUL_ESCURO,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Visualizador do modelo (3D ou AR)
  Widget _buildModelViewer() {
    return Expanded(
      flex: 3,
      child: Container(
        margin: EdgeInsets.all(Dimensions.padding),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.borderRadius),
          child: isARMode ? _buildARViewer() : _buildModelViewerWidget(),
        ),
      ),
    );
  }

  // Widget para visualização AR (simulação)
  Widget _buildARViewer() {
    return Stack(
      children: [
        // Simulação de AR com fundo escuro e overlay
        Container(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 80,
                  color: Colors.white54,
                ),
                SizedBox(height: 20),
                Text(
                  'Modo AR Simulado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Toque para posicionar modelo',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Modelo posicionado com sucesso!'),
                        backgroundColor: AZUL_CLARO,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AZUL_CLARO,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    'Posicionar Modelo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Instruções de AR
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: EdgeInsets.all(Dimensions.paddingSmall),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
            ),
            child: const Text(
              'Simulação de AR - Em breve com câmera real',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // Botão de voltar ao modo 3D
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: AZUL_ESCURO,
            onPressed: () => setState(() => isARMode = false),
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Widget para visualização 3D normal
  Widget _buildModelViewerWidget() {
    return ModelViewer(
      backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
      src: modelos[selectedModelIndex].modelUrl,
      alt: modelos[selectedModelIndex].nome,
      ar: true,
      autoRotate: true,
      cameraControls: true,
      loading: Loading.eager,
    );
  }

  // Informações do modelo selecionado
  Widget _buildModelInfo() {
    return Container(
      padding: EdgeInsets.all(Dimensions.padding),
      margin: EdgeInsets.symmetric(horizontal: Dimensions.padding),
      decoration: BoxDecoration(
        color: AZUL_CLARO,
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
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
          SizedBox(height: Dimensions.paddingSmall),
          Text(
            modelos[selectedModelIndex].descricao,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: Dimensions.spacing),
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
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => isARMode = !isARMode);
                    },
                    icon: Icon(isARMode ? Icons.view_in_ar_outlined : Icons.view_in_ar),
                    label: Text(isARMode ? 'Ver em 3D' : 'Ver em AR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AZUL_ESCURO,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.paddingSmall),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Orçamento para ${modelos[selectedModelIndex].nome} solicitado!'),
                          backgroundColor: AZUL_ESCURO,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AZUL_ESCURO,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                      ),
                    ),
                    child: const Text(
                      'Orçamento',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Seletor de modelos
  Widget _buildModelSelector() {
    return Container(
      height: 120,
      padding: EdgeInsets.symmetric(vertical: Dimensions.padding),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.padding),
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
              margin: EdgeInsets.only(right: Dimensions.spacing),
              decoration: BoxDecoration(
                color: isSelected ? AZUL_ESCURO : Colors.grey[200],
                borderRadius: BorderRadius.circular(Dimensions.borderRadius),
                border: isSelected ? Border.all(color: AZUL_CLARO, width: 3) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.elevator,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 30,
                  ),
                  SizedBox(height: Dimensions.paddingSmall),
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
    );
  }
}

class ModeloElevador {
  final String nome;
  final String descricao;
  final String modelUrl;
  final String arModelUrl; // URL específica para AR
  final String preco;

  ModeloElevador({
    required this.nome,
    required this.descricao,
    required this.modelUrl,
    required this.arModelUrl,
    required this.preco,
  });
}
