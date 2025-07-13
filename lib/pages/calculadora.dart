// Passar mesma função como parametro para direita e esquerda

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../models/elevador.dart';
import '../services/pdf_generator.dart';

const AZULCLARO = Color.fromARGB(255, 32, 143, 167);
const AZULESCURO = Color.fromARGB(255, 11, 55, 94);
const TAM = 30.0;
const TAMTITULO = 25.0;
const TAMSETA = 45.0;
const ALTGRANDE = 60.0;
const ALTPEQ = 32.0;
const TEXTOGRAN = 22.0;
const TEXTOPEQ = 18.0;
const POSGALVANIZADO = 13;

class CalculadoraPage extends StatefulWidget {
  const CalculadoraPage({super.key});

  @override
  _CalculadoraPageState createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  String alturaElevacaoSelecionada = Elevador.alturasKeys.first;
  String alturaCabineSelecionada = Elevador.cabinesKeys.first;
  bool trifasico = true;
  Map<String, int> quantiasAdicionais = {};
  
  TextEditingController _controller = TextEditingController();
  
  // Controladores para informações do cliente
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _cidadeController = TextEditingController();
  TextEditingController _estadoController = TextEditingController();
  TextEditingController _observacoesController = TextEditingController();
  String tipoCliente = 'Residencial';
  bool _clienteInfoExpanded = false;

  // Controle de seleção de imagens para o PDF
  Map<String, bool> imagensSelecionadas = {
    'semicabinada': true,
    'semicabinadaPortas': true,
    'semicabinadaEnclausuramento': true,
    'cabinadaPortas': true,
  };
  bool _imagensInfoExpanded = false;

  @override
  void initState() {
    super.initState();
    // Inicializar quantias dos adicionais
    for (String adicional in Elevador.adicionaisKeys) {
      quantiasAdicionais[adicional] = 0;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _nomeController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: ListView(
        children: [
          //_searchField(),
          _selectionBox(
            bigTitle('ALTURA DE ELEVAÇÃO'),
            alturaElevacaoSelecionada,
            ALTGRANDE,
            TEXTOGRAN,
            () => _alterarAlturaElevacao(-1),
            () => _alterarAlturaElevacao(1)
          ),
          _selectionBox(
            bigTitle('ALTURA CABINE'),
            alturaCabineSelecionada,
            ALTGRANDE,
            TEXTOGRAN,
            () => _alterarAlturaCabine(-1),
            () => _alterarAlturaCabine(1)
          ),
          _insertionBox(
            bigTitle('DISTÂNCIA (KM)'),
            ALTGRANDE,
            TEXTOGRAN
          ),
          // if (pos <= 2)                          // Opção de trifásico somente para 3 primeiras alturas
          //   _selectionBox(
          //     bigTitle('É trifásico?'),
          //     trifasico ? 'Sim' : 'Não',
          //     ALTGRANDE,
          //     TEXTOGRAN,
          //     () => setState(() => trifasico = !trifasico),
          //     () => setState(() => trifasico = !trifasico)
          //   ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Theme.of(context).colorScheme.secondary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ADICIONAIS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: TAMTITULO*0.8,
                        fontWeight: FontWeight.w900
                      ),
                    ),
                  ],
                ),
              ),
            _scrollableMenu(),
            ],
          ),
          _totalValueDisplay(totalValue()),
          const SizedBox(height: 20),
          _clienteInfoExpansionTile(),
          const SizedBox(height: 15),
          _imagensSelecaoExpansionTile(),
          const SizedBox(height: 15),
          _gerarPdfButton(),
          const SizedBox(height: 20),
          //TextButton(
          //  style: ButtonStyle(
          //    foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          //  ),
          //  onPressed: () { },
          //  child: Text('TextButton'),
         // )
        ]
      )
    );
  }

  Container _scrollableMenu() {
    List<String> adicionaisKeys = Elevador.adicionaisKeys;
    return Container(
          height: 250,
          color: Color.fromARGB(255, 161, 183, 194),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (context, index) => const SizedBox(height: 1.5,),
              itemCount: adicionaisKeys.length,
              itemBuilder: (context, index) {
                String adicional = adicionaisKeys[index];
                return _selectionBox(
                  smallTitle(adicional),
                  quantiasAdicionais[adicional].toString(),
                  ALTPEQ,
                  TEXTOPEQ,
                  () => setState(() { 
                    if (quantiasAdicionais[adicional]! > 0) {
                      quantiasAdicionais[adicional] = quantiasAdicionais[adicional]! - 1;
                    }
                  }),
                  () => setState(() => quantiasAdicionais[adicional] = quantiasAdicionais[adicional]! + 1),
                  );
              },
            ),
          ),
        );
  }

  void _alterarAlturaElevacao(int direcao) {
    List<String> alturas = Elevador.alturasKeys;
    int currentIndex = alturas.indexOf(alturaElevacaoSelecionada);
    int newIndex = (currentIndex + direcao) % alturas.length;
    if (newIndex < 0) newIndex = alturas.length - 1;
    setState(() {
      alturaElevacaoSelecionada = alturas[newIndex];
    });
  }

  void _alterarAlturaCabine(int direcao) {
    List<String> cabines = Elevador.cabinesKeys;
    int currentIndex = cabines.indexOf(alturaCabineSelecionada);
    int newIndex = (currentIndex + direcao) % cabines.length;
    if (newIndex < 0) newIndex = cabines.length - 1;
    setState(() {
      alturaCabineSelecionada = cabines[newIndex];
    });
  }

  double totalValue() {
    double value = Elevador.alturas[alturaElevacaoSelecionada] ?? 0;
    value += Elevador.cabines[alturaCabineSelecionada] ?? 0;
    
    // Verificar se tem galvanizado
    String galvanizado = 'Aço carbono galvanizado';
    if (quantiasAdicionais[galvanizado] != null && quantiasAdicionais[galvanizado]! > 0) {
      value *= Elevador.adicionais[galvanizado] ?? 1;
    }

    double distancia = double.tryParse(_controller.text) ?? 0.0;
    if (distancia > 100) {
      value += distancia * 6;
    }
    
    // Somar valores dos adicionais (exceto galvanizado)
    quantiasAdicionais.forEach((adicional, quantidade) {
      if (adicional != galvanizado && quantidade > 0) {
        value += (Elevador.adicionais[adicional] ?? 0) * quantidade;
      }
    });
    
    return value;
  }

  double calcularFrete() {
    double distancia = double.tryParse(_controller.text) ?? 0.0;
    if (distancia > 100) {
      return distancia * 6;
    }
    return 0;
  }

  Text bigTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: TAMTITULO*0.8,
        fontWeight: FontWeight.w900
      ),
    );
  }

  Text smallTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: TAMTITULO * 0.65,
        fontWeight: FontWeight.w700
      ),
    );
  }

  Column _totalValueDisplay(double value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'TOTAL',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: TAMTITULO,
            fontWeight: FontWeight.w900
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10.0), // Opcional para cantos arredondados
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'R\$${NumberFormat('#,##0.00', 'pt_BR').format(totalValue())}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900
              ),
            ),
          ),
        ),
      ],
    );
  }

  Padding _insertionBox(Text titulo, double height, double textSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          titulo,
          Container(
            height: height,
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            child: TextField(
              textAlign: TextAlign.center,
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: AZULCLARO,
                contentPadding: EdgeInsets.all(15),
                hintText: 'Distância em km',
                hintStyle: TextStyle(
                  color: Color.fromARGB(174, 255, 255, 255),
                  fontSize: TEXTOGRAN,
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none
                )
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: textSize,
                fontWeight: FontWeight.w600
              ),
              onChanged: (text) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding _selectionBox(Text titulo, String displayText, double height, double textSize, VoidCallback leftTap, VoidCallback rightTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          titulo,
          Container(
            height: height,
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            decoration: BoxDecoration(
              color: AZULCLARO,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: leftTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 22, 97, 114),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), 
                    ),
                  ),
                  child: Container(
                    height: height,
                    width: TAMSETA/2,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: SvgPicture.asset(
                        'assets/icons/doubleArrowLeft.svg',
                        color: Colors.white
                        ),
                    ),
                  ),
                ),
                Text(
                  displayText,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: textSize,
                    fontWeight: FontWeight.w600
                  ),
                ),
                ElevatedButton(
                  onPressed: rightTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 22, 97, 114),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), 
                    ),
                  ),
                  child: Container(
                    height: height,
                    width: TAMSETA/2,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: SvgPicture.asset(
                      'assets/icons/doubleArrowRight.svg',
                      color: Colors.white
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

void _resetValues() {
    setState(() {
      alturaElevacaoSelecionada = Elevador.alturasKeys.first;
      alturaCabineSelecionada = Elevador.cabinesKeys.first;
      trifasico = true;
      quantiasAdicionais.updateAll((key, value) => 0);
      _controller.clear();
      
      // Limpar campos de informações do cliente
      _nomeController.clear();
      _cidadeController.clear();
      _estadoController.clear();
      _observacoesController.clear();
      tipoCliente = 'Residencial';
      _clienteInfoExpanded = false;
      
      // Reset das imagens selecionadas
      imagensSelecionadas.updateAll((key, value) => true);
      _imagensInfoExpanded = false;
    });
  }

  // Botão para gerar PDF
  Widget _gerarPdfButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () async {
          await _gerarPDF();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 24),
            SizedBox(width: 10),
            Text(
              'GERAR ORÇAMENTO PDF',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para gerar PDF
  Future<void> _gerarPDF() async {
    try {
      
      final pdfBytes = await PDFGenerator.generateOrcamentoPDF(
        cidade: _cidadeController.text.isEmpty ? '-' : _cidadeController.text,
        estado: _estadoController.text.isEmpty ? '-' : _estadoController.text,
        cliente: _nomeController.text.isEmpty ? '-' : _nomeController.text,
        tipoCliente: tipoCliente,
        alturaElevacao: alturaElevacaoSelecionada,
        preco: totalValue(),
        alturaCabine: alturaCabineSelecionada,
        adicionais: _gerarAdicionaisMap(),
        frete: calcularFrete().toInt(),
        galvanizado: quantiasAdicionais['Aço carbono galvanizado'] != null && quantiasAdicionais['Aço carbono galvanizado']! > 0
            ? true
            : false,
        imagensSelecionadas: imagensSelecionadas,
      );

      // Mostrar pré-visualização
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Orçamento_Elevador_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF gerado com sucesso!'),
          backgroundColor: AZULCLARO,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Função para gerar lista de adicionais selecionados
  List<Map<String, dynamic>> _gerarAdicionaisMap() {
    List<Map<String, dynamic>> adicionais = [];
    quantiasAdicionais.forEach((adicional, quantidade) {
      if (adicional != 'Aço carbono galvanizado' && quantidade > 0) {
        adicionais.add({
          'descricao': adicional,
          'quantidade': quantidade,
          'valor': (Elevador.adicionais[adicional] ?? 0) * quantidade,
        });
      }
    });
    return adicionais;
  }

  // Widget para aba expansível de informações do cliente
  Widget _clienteInfoExpansionTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AZULCLARO, width: 2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _clienteInfoExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _clienteInfoExpanded = expanded;
            });
          },
          leading: const Icon(
            Icons.person,
            color: AZULESCURO,
            size: 24,
          ),
          title: Text(
            'INFORMAÇÕES DO CLIENTE',
            style: TextStyle(
              color: AZULESCURO,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Campo Nome do Cliente
                  _buildClienteTextField(
                    controller: _nomeController,
                    label: 'Nome do Cliente',
                    hint: 'Digite o nome do cliente',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 15),
                  
                  // Linha com Cidade e Estado
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildClienteTextField(
                          controller: _cidadeController,
                          label: 'Cidade',
                          hint: 'Digite a cidade',
                          icon: Icons.location_city,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 1,
                        child: _buildClienteTextField(
                          controller: _estadoController,
                          label: 'Estado',
                          hint: 'UF',
                          icon: Icons.map,
                          maxLength: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // Seleção de Tipo de Cliente
                  _buildTipoClienteSelector(),
                  const SizedBox(height: 15),
                  
                  // Campo de Observações
                  _buildClienteTextField(
                    controller: _observacoesController,
                    label: 'Observações Adicionais',
                    hint: 'Informações extras sobre o projeto...',
                    icon: Icons.note,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para campos de texto do cliente
  Widget _buildClienteTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AZULESCURO,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AZULCLARO, size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AZULCLARO, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AZULESCURO, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            counterText: '', // Remove contador de caracteres
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Widget para seleção do tipo de cliente
  Widget _buildTipoClienteSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Cliente',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AZULESCURO,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AZULCLARO, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text(
                    'Residencial',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: 'Residencial',
                  groupValue: tipoCliente,
                  activeColor: AZULESCURO,
                  onChanged: (value) {
                    setState(() {
                      tipoCliente = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text(
                    'Comercial',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: 'Comercial',
                  groupValue: tipoCliente,
                  activeColor: AZULESCURO,
                  onChanged: (value) {
                    setState(() {
                      tipoCliente = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget para aba expansível de seleção de imagens
  Widget _imagensSelecaoExpansionTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AZULCLARO, width: 2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _imagensInfoExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _imagensInfoExpanded = expanded;
            });
          },
          leading: const Icon(
            Icons.image,
            color: AZULESCURO,
            size: 24,
          ),
          title: Text(
            'SELEÇÃO DE IMAGENS PARA PDF',
            style: TextStyle(
              color: AZULESCURO,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione as imagens que aparecerão no PDF:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AZULESCURO,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...imagensSelecionadas.keys.map((nomeImagem) {
                    // Mapa para converter chaves técnicas em nomes legíveis
                    Map<String, String> nomesLisiveis = {
                      'semicabinada': 'Semicabinada',
                      'semicabinadaPortas': 'Semicabinada com Portas',
                      'semicabinadaEnclausuramento': 'Semicabinada Enclausurada',
                      'cabinadaPortas': 'Cabinada com Portas',
                    };
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AZULCLARO.withOpacity(0.3), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          nomesLisiveis[nomeImagem] ?? nomeImagem,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: imagensSelecionadas[nomeImagem],
                        activeColor: AZULESCURO,
                        onChanged: (bool? value) {
                          setState(() {
                            imagensSelecionadas[nomeImagem] = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AZULCLARO.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AZULCLARO.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AZULESCURO,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'As imagens selecionadas serão organizadas automaticamente no PDF, preenchendo as posições disponíveis.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AZULESCURO,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      centerTitle: true,
      title: Container(
        height: 50,
        child: Image.asset('assets/icons/home.png')
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
            color: Theme.of(context).colorScheme.secondary,
            size: 20
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            _resetValues();
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), 
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(3),
            alignment: Alignment.center,
            width: 37,
            child: SvgPicture.asset(
              'assets/icons/circularArrow.svg',
              height: 20,
              width: 20
            ),
          ),
        )
      ]
    );
  }
}