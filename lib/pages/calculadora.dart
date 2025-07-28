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
import '../services/settings_service.dart';
import '../constants/app_constants.dart';

const TAM = 30.0;
const TAMTITULO = 25.0;
const TAMSETA = 45.0;
const ALTGRANDE = 50.0;
const ALTPEQ = 32.0;
const TEXTOGRAN = 22.0;
const TEXTOPEQ = 18.0;

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
  String tipoCliente = '';
  bool _clienteInfoExpanded = false;

  // Controle do vendedor
  String _nomeVendedor = '';

  // Controle de seleção de imagens para o PDF
  Map<String, bool> imagensSelecionadas = {
    'semicabinada': true,
    'semicabinadaPortas': true,
    'semicabinadaEnclausuramento': true,
    'cabinadaPortas': true,
  };
  bool _imagensInfoExpanded = false;

  // Controle de configurações adicionais
  bool _configuracoesExpanded = false;
  
  // Controle da aba de valores
  bool _valoresExpanded = false;
  Map<String, double> _valoresPersonalizados = {};
  Map<String, TextEditingController> _valoresControllers = {};
  double _porcentagemValor = 100.0; // Porcentagem padrão: 100%
  bool _ocultarValoresIndividuais = false; // Controla se os valores individuais devem ser ocultados no PDF
  bool _valorTotalPersonalizado = false; // Controla se o valor total é personalizado
  double? _valorTotalCustom; // Valor total personalizado
  TextEditingController _valorTotalController = TextEditingController();
  
  // Controle do frete personalizado
  bool _fretePersonalizado = false;
  double? _freteCustom;
  TextEditingController _freteController = TextEditingController();
  
  // Prazo de entrega
  bool _prazoPersonalizado = false;
  int _prazoEntrega = 20;
  TextEditingController _prazoController = TextEditingController();
  
  // Colunas e cabines
  bool _quantidadesVinculadas = true;
  int _numeroColunas = 1;
  int _numeroCabines = 1;
  double _valorColuna = Elevador.alturas[Elevador.alturasKeys.first]?.toDouble() ?? 0;
  double _valorCabine = Elevador.cabines[Elevador.cabinesKeys.first]?.toDouble() ?? 0;
  TextEditingController _colunasController = TextEditingController();
  TextEditingController _cabinesController = TextEditingController();
  
  // Controller para porcentagem
  TextEditingController _porcentagemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar quantias dos adicionais
    for (String adicional in Elevador.adicionaisKeys) {
      quantiasAdicionais[adicional] = 0;
    }
    // Carregar nome do vendedor
    _carregarNomeVendedor();
    // Inicializar valores personalizados com valores padrão
    _inicializarValoresPersonalizados();
    // Inicializar controller de porcentagem
    _porcentagemController.text = _porcentagemValor.toStringAsFixed(1).replaceAll('.', ',');
  }

  void _inicializarValoresPersonalizados() {
    _valoresPersonalizados['coluna'] = (Elevador.alturas[alturaElevacaoSelecionada] ?? 0).toDouble();
    _valoresPersonalizados['cabine'] = (Elevador.cabines[alturaCabineSelecionada] ?? 0).toDouble();
    
    // Inicializar valores dos adicionais
    for (String adicional in Elevador.adicionaisKeys) {
      if (adicional != 'Aço carbono galvanizado') {
        _valoresPersonalizados[adicional] = (Elevador.adicionais[adicional] ?? 0).toDouble();
      }
    }
    
    // Inicializar controllers para valores
    _valoresControllers['coluna'] = TextEditingController();
    _valoresControllers['cabine'] = TextEditingController();
    for (String adicional in Elevador.adicionaisKeys) {
      if (adicional != 'Aço carbono galvanizado') {
        _valoresControllers[adicional] = TextEditingController();
      }
    }
    
    // Inicializar textos dos controllers com formatação correta
    _valoresControllers['coluna']?.text = _valoresPersonalizados['coluna']!.toStringAsFixed(2).replaceAll('.', ',');
    _valoresControllers['cabine']?.text = _valoresPersonalizados['cabine']!.toStringAsFixed(2).replaceAll('.', ',');
    for (String adicional in Elevador.adicionaisKeys) {
      if (adicional != 'Aço carbono galvanizado') {
        _valoresControllers[adicional]?.text = _valoresPersonalizados[adicional]!.toStringAsFixed(2).replaceAll('.', ',');
      }
    }
  }

  Future<void> _carregarNomeVendedor() async {
    final nome = await SettingsService.obterNomeVendedor();
    setState(() {
      _nomeVendedor = nome;
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _nomeController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _observacoesController.dispose();
    _prazoController.dispose();
    _colunasController.dispose();
    _cabinesController.dispose();
    _porcentagemController.dispose();
    _valorTotalController.dispose();
    _freteController.dispose();
    
    // Dispose dos controllers de valores
    _valoresControllers.forEach((key, controller) {
      controller.dispose();
    });
    
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Theme.of(context).colorScheme.secondary,
                child: const Row(
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
          _configuracoesExpansionTile(),
          const SizedBox(height: 15),
          _valoresExpansionTile(),
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
      // Atualizar valor personalizado se ainda não foi modificado manualmente
      double valorPadrao = (Elevador.alturas[alturaElevacaoSelecionada] ?? 0).toDouble();
      _valoresPersonalizados['coluna'] = valorPadrao;
      // Atualizar controller com formatação correta
      if (_valoresControllers['coluna'] != null) {
        _valoresControllers['coluna']!.text = valorPadrao.toStringAsFixed(2).replaceAll('.', ',');
      }
    });
  }

  void _alterarAlturaCabine(int direcao) {
    List<String> cabines = Elevador.cabinesKeys;
    int currentIndex = cabines.indexOf(alturaCabineSelecionada);
    int newIndex = (currentIndex + direcao) % cabines.length;
    if (newIndex < 0) newIndex = cabines.length - 1;
    setState(() {
      alturaCabineSelecionada = cabines[newIndex];
      // Atualizar valor personalizado se ainda não foi modificado manualmente
      double valorPadrao = (Elevador.cabines[alturaCabineSelecionada] ?? 0).toDouble();
      _valoresPersonalizados['cabine'] = valorPadrao;
      // Atualizar controller com formatação correta
      if (_valoresControllers['cabine'] != null) {
        _valoresControllers['cabine']!.text = valorPadrao.toStringAsFixed(2).replaceAll('.', ',');
      }
    });
  }

  double totalValue() {
    // Se valor total personalizado estiver ativo, usar ele
    if (_valorTotalPersonalizado && _valorTotalCustom != null) {
      return _valorTotalCustom!;
    }
    
    return _calcularValorSemPersonalizacao();
  }

  double _calcularValorSemPersonalizacao() {
    // Atualizar valores personalizados se não foram modificados manualmente
    if (_valoresPersonalizados['coluna'] == (Elevador.alturas[alturaElevacaoSelecionada] ?? 0).toDouble()) {
      _valoresPersonalizados['coluna'] = (Elevador.alturas[alturaElevacaoSelecionada] ?? 0).toDouble();
    }
    if (_valoresPersonalizados['cabine'] == (Elevador.cabines[alturaCabineSelecionada] ?? 0).toDouble()) {
      _valoresPersonalizados['cabine'] = (Elevador.cabines[alturaCabineSelecionada] ?? 0).toDouble();
    }
    
    // Aplicar porcentagem aos valores
    double porcentagemMultiplicador = _porcentagemValor / 100.0;
    _valorColuna = ((_valoresPersonalizados['coluna'] ?? 0) * porcentagemMultiplicador) * _numeroColunas;
    _valorCabine = ((_valoresPersonalizados['cabine'] ?? 0) * porcentagemMultiplicador) * _numeroCabines;
    
    double value = _valorColuna + _valorCabine;

    // Verificar se tem galvanizado
    String galvanizado = 'Aço carbono galvanizado';
    if (quantiasAdicionais[galvanizado] != null && quantiasAdicionais[galvanizado]! > 0) {
      value *= Elevador.adicionais[galvanizado] ?? 1;
      _valorColuna *= Elevador.adicionais[galvanizado] ?? 1;
      _valorCabine *= Elevador.adicionais[galvanizado] ?? 1;
    }

    double distancia = double.tryParse(_controller.text) ?? 0.0;
    if (distancia > 100) {
      value += distancia * 6;
    }
    
    // Somar valores dos adicionais (exceto galvanizado) usando valores personalizados e porcentagem
    quantiasAdicionais.forEach((adicional, quantidade) {
      if (adicional != galvanizado && quantidade > 0) {
        double valorPersonalizado = _valoresPersonalizados[adicional] ?? (Elevador.adicionais[adicional] ?? 0).toDouble();
        double valorComPorcentagem = valorPersonalizado * porcentagemMultiplicador;
        value += valorComPorcentagem * quantidade;
      }
    });
    
    return value;
  }

  double calcularFrete() {
    // Se frete personalizado estiver ativo, usar ele
    if (_fretePersonalizado && _freteCustom != null) {
      return _freteCustom!;
    }
    
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
            borderRadius: BorderRadius.circular(Dimensions.borderRadius), // Usar constante centralizada
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
                fillColor: AZUL_CLARO, // Usar constante centralizada
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
              color: AZUL_CLARO, // Usar constante centralizada
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
      tipoCliente = '';
      _clienteInfoExpanded = false;
      
      // Reset das imagens selecionadas
      imagensSelecionadas.updateAll((key, value) => true);
      _imagensInfoExpanded = false;
      
      // Reset das configurações
      _configuracoesExpanded = false;
      _prazoPersonalizado = false;
      _prazoEntrega = 20;
      _numeroColunas = 1;
      _numeroCabines = 1;
      _quantidadesVinculadas = true;
      _prazoController.text = '20';
      _colunasController.text = '1';
      _cabinesController.text = '1';
      
      // Reset dos valores personalizados
      _valoresExpanded = false;
      _porcentagemValor = 100.0;
      _porcentagemController.text = _porcentagemValor.toStringAsFixed(1).replaceAll('.', ',');
      _ocultarValoresIndividuais = false;
      _valorTotalPersonalizado = false;
      _valorTotalCustom = null;
      _valorTotalController.clear();
      _fretePersonalizado = false;
      _freteCustom = null;
      _freteController.clear();
      _inicializarValoresPersonalizados();
    });
  }

  // Botão para gerar PDF
  Widget _gerarPdfButton() {
    return Column(
      children: [
        // Confirmação do vendedor
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.borderRadius),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Vendedor: ${_nomeVendedor.isEmpty ? 'Não definido' : _nomeVendedor}',
                style: TextStyle(
                  fontSize: FontSizes.medium,
                  fontWeight: FontWeight.w600,
                  color: _nomeVendedor.isEmpty 
                      ? Colors.red 
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
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
                borderRadius: BorderRadius.circular(Dimensions.borderRadius), // Usar constante centralizada
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
        ),
      ],
    );
  }

  // Função para gerar PDF
  Future<void> _gerarPDF() async {
    try {
      // Calcular valores unitários com porcentagem aplicada para o PDF
      double porcentagemMultiplicador = _porcentagemValor / 100.0;
      double valorColunaUnitario = (_valoresPersonalizados['coluna'] ?? 0) * porcentagemMultiplicador;
      double valorCabineUnitario = (_valoresPersonalizados['cabine'] ?? 0) * porcentagemMultiplicador;
      
      final pdfBytes = await PDFGenerator.generateOrcamentoPDF(
        vendedor: _nomeVendedor,
        cidade: _cidadeController.text.isEmpty ? '' : _cidadeController.text,
        estado: _estadoController.text.isEmpty ? '' : _estadoController.text,
        cliente: _nomeController.text.isEmpty ? '' : _nomeController.text,
        tipoCliente: tipoCliente,
        observacao: _observacoesController.text,
        prazoEntrega: _prazoEntrega,
        numeroColunas: _numeroColunas,
        numeroCabines: _numeroCabines,
        valorColuna: _ocultarValoresIndividuais ? null : valorColunaUnitario,
        valorCabine: _ocultarValoresIndividuais ? null : valorCabineUnitario,
        alturaElevacao: alturaElevacaoSelecionada,
        preco: totalValue(),
        alturaCabine: alturaCabineSelecionada,
        adicionais: _gerarAdicionaisMap(),
        frete: calcularFrete().toInt(),
        galvanizado: quantiasAdicionais['Aço carbono galvanizado'] != null && quantiasAdicionais['Aço carbono galvanizado']! > 0
            ? true
            : false,
        imagensSelecionadas: imagensSelecionadas,
        ocultarValoresIndividuais: _ocultarValoresIndividuais,
      );

      // Mostrar pré-visualização
      String nomeCliente = _nomeController.text.trim().isEmpty ? 'Cliente' : _nomeController.text.trim();
      String cidade = _cidadeController.text.trim().isEmpty ? 'Cidade' : _cidadeController.text.trim();
      String estado = _estadoController.text.trim().isEmpty ? 'Estado' : _estadoController.text.trim();
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: '$nomeCliente - $cidade, $estado',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF gerado com sucesso!'),
          backgroundColor: AZUL_CLARO, // Usar constante centralizada
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
    double porcentagemMultiplicador = _porcentagemValor / 100.0;
    
    quantiasAdicionais.forEach((adicional, quantidade) {
      if (adicional != 'Aço carbono galvanizado' && quantidade > 0) {
        double valorPersonalizado = _valoresPersonalizados[adicional] ?? (Elevador.adicionais[adicional] ?? 0).toDouble();
        double valorComPorcentagem = valorPersonalizado * porcentagemMultiplicador;
        adicionais.add({
          'descricao': adicional,
          'quantidade': quantidade,
          'valor': _ocultarValoresIndividuais ? null : (valorComPorcentagem * quantidade),
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
        borderRadius: BorderRadius.circular(Dimensions.borderRadius), // Usar constante centralizada
        border: Border.all(color: AZUL_CLARO, width: 2), // Usar constante centralizada
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
            color: AZUL_ESCURO, // Usar constante centralizada
            size: 24,
          ),
          title: Text(
            'INFORMAÇÕES DO CLIENTE',
            style: TextStyle(
              color: AZUL_ESCURO, // Usar constante centralizada
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(Dimensions.padding), // Usar constante centralizada
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
            color: AZUL_ESCURO, // Usar constante centralizada
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AZUL_CLARO, size: 20), // Usar constante centralizada
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall), // Usar constante centralizada
              borderSide: BorderSide(color: AZUL_CLARO, width: 1), // Usar constante centralizada
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall), // Usar constante centralizada
              borderSide: BorderSide(color: AZUL_ESCURO, width: 2), // Usar constante centralizada
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
            color: AZUL_ESCURO, // Usar constante centralizada
          ),
        ),
        SizedBox(height: Dimensions.paddingSmall), // Usar constante centralizada
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AZUL_CLARO, width: 1), // Usar constante centralizada
            borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall), // Usar constante centralizada
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text(
                  'Nenhum',
                  style: TextStyle(fontSize: 14),
                ),
                value: '',
                groupValue: tipoCliente,
                activeColor: AZUL_ESCURO, // Usar constante centralizada
                onChanged: (value) {
                  setState(() {
                    tipoCliente = value!;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'Residencial',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: 'Residencial',
                      groupValue: tipoCliente,
                      activeColor: AZUL_ESCURO, // Usar constante centralizada
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
                      activeColor: AZUL_ESCURO, // Usar constante centralizada
                      onChanged: (value) {
                        setState(() {
                          tipoCliente = value!;
                        });
                      },
                    ),
                  ),
                ],
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
        borderRadius: BorderRadius.circular(Dimensions.borderRadius), // Usar constante centralizada
        border: Border.all(color: AZUL_CLARO, width: 2), // Usar constante centralizada
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
            color: AZUL_ESCURO, // Usar constante centralizada
            size: 24,
          ),
          title: Text(
            'SELEÇÃO DE IMAGENS PARA PDF',
            style: TextStyle(
              color: AZUL_ESCURO, // Usar constante centralizada
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(Dimensions.padding), // Usar constante centralizada
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione as imagens que aparecerão no PDF:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AZUL_ESCURO, // Usar constante centralizada
                    ),
                  ),
                  SizedBox(height: Dimensions.spacingSmall), // Usar constante centralizada
                  ...imagensSelecionadas.keys.map((nomeImagem) {
                    // Mapa para converter chaves técnicas em nomes legíveis
                    Map<String, String> nomesLisiveis = {
                      'semicabinada': 'Semicabinada',
                      'semicabinadaPortas': 'Semicabinada com Portas',
                      'semicabinadaEnclausuramento': 'Semicabinada Enclausurada',
                      'cabinadaPortas': 'Cabinada com Portas',
                    };
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: Dimensions.paddingSmall), // Usar constante centralizada
                      decoration: BoxDecoration(
                        border: Border.all(color: AZUL_CLARO.withOpacity(0.3), width: 1), // Usar constante centralizada
                        borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall), // Usar constante centralizada
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
                        activeColor: AZUL_ESCURO, // Usar constante centralizada
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
                  SizedBox(height: Dimensions.spacingSmall), // Usar constante centralizada
                  Container(
                    padding: EdgeInsets.all(Dimensions.paddingSmall * 1.5), // Usar constante centralizada
                    decoration: BoxDecoration(
                      color: AZUL_CLARO.withOpacity(0.1), // Usar constante centralizada
                      borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall), // Usar constante centralizada
                      border: Border.all(color: AZUL_CLARO.withOpacity(0.3)), // Usar constante centralizada
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AZUL_ESCURO, // Usar constante centralizada
                          size: 18,
                        ),
                        SizedBox(width: Dimensions.paddingSmall), // Usar constante centralizada
                        Expanded(
                          child: Text(
                            'As imagens selecionadas serão organizadas automaticamente no PDF, preenchendo as posições disponíveis.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AZUL_ESCURO, // Usar constante centralizada
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

  Widget _configuracoesExpansionTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        border: Border.all(color: AZUL_CLARO, width: 2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _configuracoesExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _configuracoesExpanded = expanded;
            });
          },
          leading: const Icon(
            Icons.settings,
            color: AZUL_ESCURO,
            size: 24,
          ),
          title: Text(
            'CONFIGURAÇÕES ADICIONAIS',
            style: TextStyle(
              color: AZUL_ESCURO,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        children: [
          Padding(
            padding: EdgeInsets.all(Dimensions.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção: Prazo de Entrega
                Text(
                  'Prazo de Entrega',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AZUL_ESCURO,
                  ),
                ),
                SizedBox(height: Dimensions.paddingSmall),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AZUL_CLARO, width: 1),
                    borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        title: const Text(
                          'Padrão (20 dias)',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: false,
                        groupValue: _prazoPersonalizado,
                        activeColor: AZUL_ESCURO,
                        onChanged: (bool? value) {
                          setState(() {
                            _prazoPersonalizado = value!;
                            if (!_prazoPersonalizado) {
                              _prazoEntrega = 20;
                              _prazoController.text = '20';
                            }
                          });
                        },
                      ),
                      RadioListTile<bool>(
                        title: Row(
                          children: [
                            Text(
                              'Personalizado:',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _prazoController,
                                  enabled: _prazoPersonalizado,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Dias',
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                                      borderSide: BorderSide(color: AZUL_CLARO, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                                      borderSide: BorderSide(color: AZUL_ESCURO, width: 2),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _prazoEntrega = int.tryParse(value) ?? 20;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        value: true,
                        groupValue: _prazoPersonalizado,
                        activeColor: AZUL_ESCURO,
                        onChanged: (bool? value) {
                          setState(() {
                            _prazoPersonalizado = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Seção: Quantidade de Colunas
                Text(
                  'Quantidade de Colunas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AZUL_ESCURO,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _colunasController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Colunas',
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                            borderSide: BorderSide(color: AZUL_CLARO, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                            borderSide: BorderSide(color: AZUL_ESCURO, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _numeroColunas = int.tryParse(value) ?? 1;
                            if (_quantidadesVinculadas) {
                              _numeroCabines = _numeroColunas;
                              _cabinesController.text = _numeroColunas.toString();
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _quantidadesVinculadas,
                            activeColor: AZUL_ESCURO,
                            onChanged: (bool? value) {
                              setState(() {
                                _quantidadesVinculadas = value!;
                                if (_quantidadesVinculadas) {
                                  _numeroCabines = _numeroColunas;
                                  _cabinesController.text = _numeroColunas.toString();
                                }
                              });
                            },
                          ),
                          Text(
                            'Vincular com cabines',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Seção: Quantidade de Cabines
                Text(
                  'Quantidade de Cabines',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AZUL_ESCURO,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _cabinesController,
                    enabled: !_quantidadesVinculadas,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Cabines',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                        borderSide: BorderSide(color: AZUL_CLARO, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                        borderSide: BorderSide(color: AZUL_ESCURO, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _numeroCabines = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      )
    );
  }

  Widget _valoresExpansionTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        border: Border.all(color: AZUL_CLARO, width: 2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _valoresExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _valoresExpanded = expanded;
            });
          },
          leading: const Icon(
            Icons.attach_money,
            color: AZUL_ESCURO,
            size: 24,
          ),
          title: Text(
            'VALORES',
            style: TextStyle(
              color: AZUL_ESCURO,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(Dimensions.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajuste geral de preços (porcentagem):',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AZUL_ESCURO,
                    ),
                  ),
                  SizedBox(height: Dimensions.paddingSmall),
                  
                  // Controle de Porcentagem
                  Container(
                    padding: EdgeInsets.all(Dimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PORCENTAGEM GERAL',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[800],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Multiplica todos os valores abaixo',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _porcentagemController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              suffixText: '%',
                              hintText: '100',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                                borderSide: BorderSide(color: Colors.orange, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                                borderSide: BorderSide(color: Colors.orange, width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (value) {
                              String cleanValue = value.replaceAll(',', '.').replaceAll(RegExp(r'[^\d.]'), '');
                              double? parsedValue = double.tryParse(cleanValue);
                              if (parsedValue != null && parsedValue >= 0) {
                                setState(() {
                                  _porcentagemValor = parsedValue;
                                });
                              }
                            },
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: Dimensions.padding),
                  
                  // Checkbox para ocultar valores individuais
                  Container(
                    padding: EdgeInsets.all(Dimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _ocultarValoresIndividuais,
                          activeColor: Colors.red,
                          onChanged: (bool? value) {
                            setState(() {
                              _ocultarValoresIndividuais = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OCULTAR VALORES INDIVIDUAIS NO PDF',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[800],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Mostra "-" no lugar dos valores unitários',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: Dimensions.padding),
                  
                  // Campo para valor total personalizado
                  Container(
                    padding: EdgeInsets.all(Dimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _valorTotalPersonalizado,
                              activeColor: Colors.blue,
                              onChanged: (bool? value) {
                                setState(() {
                                  _valorTotalPersonalizado = value ?? false;
                                  if (!_valorTotalPersonalizado) {
                                    _valorTotalCustom = null;
                                    _valorTotalController.clear();
                                  } else {
                                    // Inicializar com o valor atual calculado (sem usar o valor personalizado)
                                    double valorCalculado = _calcularValorSemPersonalizacao();
                                    _valorTotalCustom = valorCalculado;
                                    _valorTotalController.text = valorCalculado.toStringAsFixed(2).replaceAll('.', ',');
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'VALOR TOTAL PERSONALIZADO',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Substitui o cálculo automático',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_valorTotalPersonalizado) ...[
                          SizedBox(height: Dimensions.paddingSmall),
                          TextField(
                            controller: _valorTotalController,
                            enabled: _valorTotalPersonalizado,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixText: 'R\$ ',
                              hintText: '0,00',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                                borderSide: BorderSide(color: Colors.blue, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              String cleanValue = value.replaceAll(',', '.').replaceAll(RegExp(r'[^\d.]'), '');
                              double? parsedValue = double.tryParse(cleanValue);
                              if (parsedValue != null && parsedValue >= 0) {
                                setState(() {
                                  _valorTotalCustom = parsedValue;
                                });
                              }
                            },
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  SizedBox(height: Dimensions.padding),
                  
                  // Campo para frete personalizado
                  Container(
                    padding: EdgeInsets.all(Dimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _fretePersonalizado,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  _fretePersonalizado = value ?? false;
                                  if (!_fretePersonalizado) {
                                    _freteCustom = null;
                                    _freteController.clear();
                                  } else {
                                    // Calcular frete sem usar valor personalizado para evitar recursão
                                    double distancia = double.tryParse(_controller.text) ?? 0.0;
                                    double freteCalculado = distancia > 100 ? distancia * 6 : 0;
                                    _freteCustom = freteCalculado;
                                    _freteController.text = freteCalculado.toStringAsFixed(2).replaceAll('.', ',');
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FRETE PERSONALIZADO',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Substitui o cálculo automático do frete',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_fretePersonalizado) ...[
                          SizedBox(height: Dimensions.paddingSmall),
                          TextField(
                            controller: _freteController,
                            enabled: _fretePersonalizado,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixText: 'R\$ ',
                              hintText: '0,00',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                                borderSide: BorderSide(color: Colors.green, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                                borderSide: BorderSide(color: Colors.green, width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              String cleanValue = value.replaceAll(',', '.').replaceAll(RegExp(r'[^\d.]'), '');
                              double? parsedValue = double.tryParse(cleanValue);
                              if (parsedValue != null && parsedValue >= 0) {
                                setState(() {
                                  _freteCustom = parsedValue;
                                });
                              }
                            },
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  SizedBox(height: Dimensions.padding),
                  
                  Text(
                    'Valores base que aparecerão no PDF:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AZUL_ESCURO,
                    ),
                  ),
                  SizedBox(height: Dimensions.paddingSmall),
                  
                  // Mostrar apenas itens que serão incluídos no PDF
                  ..._buildItensValoresSelecionados(),
                  
                  SizedBox(height: Dimensions.spacingSmall),
                  Container(
                    padding: EdgeInsets.all(Dimensions.paddingSmall * 1.5),
                    decoration: BoxDecoration(
                      color: AZUL_CLARO.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                      border: Border.all(color: AZUL_CLARO.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AZUL_ESCURO,
                          size: 18,
                        ),
                        SizedBox(width: Dimensions.paddingSmall),
                        Expanded(
                          child: Text(
                            'Os valores base podem ser personalizados e serão multiplicados pela porcentagem geral antes de aparecer no PDF.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AZUL_ESCURO,
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

  List<Widget> _buildItensValoresSelecionados() {
    List<Widget> widgets = [];
    
    // Incluir coluna apenas se número de colunas > 0
    if (_numeroColunas > 0) {
      widgets.add(_buildValorItem(
        'COLUNA DE ELEVAÇÃO',
        'coluna',
        'Valor unitário da coluna',
      ));
    }
    
    // Incluir cabine apenas se número de cabines > 0
    if (_numeroCabines > 0) {
      widgets.add(_buildValorItem(
        'CABINE DO PASSAGEIRO',
        'cabine',
        'Valor unitário da cabine',
      ));
    }
    
    // Incluir apenas adicionais que estão selecionados (quantidade > 0)
    for (String adicional in Elevador.adicionaisKeys) {
      if (adicional != 'Aço carbono galvanizado' && 
          quantiasAdicionais[adicional] != null && 
          quantiasAdicionais[adicional]! > 0) {
        widgets.add(_buildValorItem(
          adicional.toUpperCase(),
          adicional,
          'Valor unitário do adicional',
        ));
      }
    }
    
    return widgets;
  }

  Widget _buildValorItem(String titulo, String chave, String hint) {
    double valorBase = _valoresPersonalizados[chave] ?? 0;
    double valorComPorcentagem = valorBase * (_porcentagemValor / 100.0);
    
    // Garantir que o controller existe
    if (!_valoresControllers.containsKey(chave)) {
      _valoresControllers[chave] = TextEditingController();
    }
    
    // Atualizar o texto do controller apenas se necessário
    // Usar formatação sem pontos de milhares para entrada do usuário
    String valorFormatado = valorBase.toStringAsFixed(2).replaceAll('.', ',');
    if (_valoresControllers[chave]!.text != valorFormatado) {
      _valoresControllers[chave]!.text = valorFormatado;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.paddingSmall),
      padding: EdgeInsets.all(Dimensions.paddingSmall),
      decoration: BoxDecoration(
        border: Border.all(color: AZUL_CLARO.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AZUL_ESCURO,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _valoresControllers[chave],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: 'R\$ ',
                    hintText: '0,00',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                      borderSide: BorderSide(color: AZUL_CLARO, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.borderRadiusSmall),
                      borderSide: BorderSide(color: AZUL_ESCURO, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    String cleanValue = value.replaceAll(',', '.').replaceAll(RegExp(r'[^\d.]'), '');
                    double? parsedValue = double.tryParse(cleanValue);
                    if (parsedValue != null && parsedValue >= 0) {
                      setState(() {
                        _valoresPersonalizados[chave] = parsedValue;
                      });
                    }
                  },
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AZUL_ESCURO,
                  ),
                ),
              ),
            ],
          ),
          if (_porcentagemValor != 100.0) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                'Valor final (${_porcentagemValor.toStringAsFixed(1)}%): R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(valorComPorcentagem)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange[800],
                ),
              ),
            ),
          ],
        ],
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
          margin: EdgeInsets.all(Dimensions.spacingSmall), // Usar constante centralizada
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xffF7F8F8),
            borderRadius: BorderRadius.circular(Dimensions.borderRadius) // Usar constante centralizada
          ),
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.secondary,
            size: 20
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
        _resetValues();
          },
          child: Container(
            margin: EdgeInsets.all(Dimensions.spacingSmall), // Usar constante centralizada
            alignment: Alignment.center,
            width: 50, // Igual à altura do AppBar
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xffF7F8F8),
              borderRadius: BorderRadius.circular(Dimensions.borderRadius) // Usar constante centralizada
            ),
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
          ),
        ),
      ]
    );
  }
}