import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/elevador.dart';

const CLARO = 0xFF208FA7;
const ESCURO = 0xFF0B375E;

class PDFGenerator {
  // Função para criar cabeçalho padronizado
  static pw.Widget _buildHeader(pw.MemoryImage logo, pw.Font ttf) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Image(logo, width: 80, height: 48),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'HOME ELEVADORES LTDA',
              style: pw.TextStyle(
                fontSize: 16,
                font: ttf,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF0B375E),
              ),
            ),
            pw.Text(
              'CNPJ: 44.567.572/0001-22\n'
              'R. 20 de Novembro, 780 - Rio Abaixo, Atibaia',
              style: pw.TextStyle(
                fontSize: 11,
                font: ttf,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '(11) 94466-7177\n'
              '(11) 4217-1113\n',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(ESCURO),
                font: ttf,
              ),
            ),
            pw.Text(
              'contato@homelevadores.com',
              style: pw.TextStyle(
                fontSize: 11,
                color: const PdfColor.fromInt(ESCURO),
                font: ttf,
              ),
            ),
          ]
        )
      ],
    );
  }

  // Função para criar rodapé padronizado
  static pw.Widget _buildFooter(pw.MemoryImage homeEscrito) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Image(homeEscrito, width: 120, height: 40),
    );
  }

  // Função auxiliar para organizar imagens selecionadas
  static List<Map<String, dynamic>> _organizarImagensSelecionadas(
    Map<String, bool>? imagensSelecionadas,
    pw.MemoryImage semicabinadaImage,
    pw.MemoryImage semicabinadaPortasImage,
    pw.MemoryImage semicabinadaEnclausuramentoImage,
    pw.MemoryImage cabinadaPortasImage,
  ) {
    // Mapa com todas as imagens disponíveis usando as chaves corretas
    Map<String, Map<String, dynamic>> todasImagens = {
      'semicabinada': {
        'titulo': 'Semicabinada',
        'imagem': semicabinadaImage,
      },
      'semicabinadaPortas': {
        'titulo': 'Semicabinada c/ portas pavimento',
        'imagem': semicabinadaPortasImage,
      },
      'semicabinadaEnclausuramento': {
        'titulo': 'Semicabinada c/ enclausuramento',
        'imagem': semicabinadaEnclausuramentoImage,
      },
      'cabinadaPortas': {
        'titulo': 'Cabinada c/ portas pavimento',
        'imagem': cabinadaPortasImage,
      },
    };

    // Se não há seleção definida, retorna todas as imagens
    if (imagensSelecionadas == null) {
      return todasImagens.values.toList();
    }

    // Filtra apenas as imagens selecionadas na ordem definida
    List<Map<String, dynamic>> imagensOrganizadas = [];
    
    // Ordem específica para manter as imagens organizadas
    List<String> ordemImagens = [
      'semicabinada',
      'semicabinadaPortas', 
      'semicabinadaEnclausuramento',
      'cabinadaPortas'
    ];
    
    for (String chave in ordemImagens) {
      if (imagensSelecionadas[chave] == true && todasImagens.containsKey(chave)) {
        imagensOrganizadas.add(todasImagens[chave]!);
      }
    }

    return imagensOrganizadas;
  }

  static Future<Uint8List> generateOrcamentoPDF({
    String cidade = '-',
    String estado = '-',
    String cliente = '-',
    String tipoCliente = '',
    bool galvanizado = false,
    int frete = 0,
    required String alturaElevacao,
    required double preco,
    required String alturaCabine,
    required List<Map<String, dynamic>> adicionais,
    Map<String, bool>? imagensSelecionadas,
  }) async {
    final pdf = pw.Document();
    
    // Calcular valores a partir dos Maps
    double valorColuna = Elevador.alturas[alturaElevacao] ?? 0;
    double valorCabine = Elevador.cabines[alturaCabine] ?? 0;
    
    // Carregar a logo
    final ByteData logoData = await rootBundle.load('assets/icons/home.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logo = pw.MemoryImage(logoBytes);

    // Carregar a imagem do rodapé
    final ByteData footerData = await rootBundle.load('assets/icons/home-escrito.png');
    final Uint8List footerBytes = footerData.buffer.asUint8List();
    final pw.MemoryImage homeEscrito = pw.MemoryImage(footerBytes);

    // Carregar imagens das plataformas
    final ByteData semicabinadaData = await rootBundle.load('assets/plataformas/semicabinada.jpeg');
    final pw.MemoryImage semicabinadaImage = pw.MemoryImage(semicabinadaData.buffer.asUint8List());
    
    final ByteData semicabinadaPortasData = await rootBundle.load('assets/plataformas/semicabinada-portas-pavimento.jpeg');
    final pw.MemoryImage semicabinadaPortasImage = pw.MemoryImage(semicabinadaPortasData.buffer.asUint8List());
    
    final ByteData semicabinadaEnclausuramentoData = await rootBundle.load('assets/plataformas/semicabinada-enclausuramento.jpeg');
    final pw.MemoryImage semicabinadaEnclausuramentoImage = pw.MemoryImage(semicabinadaEnclausuramentoData.buffer.asUint8List());
    
    final ByteData cabinadaPortasData = await rootBundle.load('assets/plataformas/cabinada-portas-pavimento.jpeg');
    final pw.MemoryImage cabinadaPortasImage = pw.MemoryImage(cabinadaPortasData.buffer.asUint8List());

    // Formatador de moeda
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    // Definir fonte padrão para todo o documento
    final fontData = await rootBundle.load('fonts/Roboto.ttf');
    final ttf = pw.Font.ttf(fontData);

    // PÁGINA 1 - ORÇAMENTO
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho com logo
              _buildHeader(logo, ttf),
              
              pw.SizedBox(height: 10),
              
              // Linha divisória
              pw.Divider(
                color: const PdfColor.fromInt(0xFF208FA7),
                thickness: 2,
              ),
              
              pw.SizedBox(height: 10),
              
              pw.Container(
                color: const PdfColor.fromInt(ESCURO),
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: pw.Text(
                  'COTAÇÃO $tipoCliente',
                  style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  font: ttf,
                  ),
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Text(
                'DATA: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}\n'
                'CIDADE: $cidade, $estado\n'
                'CLIENTE: $cliente\n'
                'REFERÊNCIA: Plataforma ${alturaCabine.contains('2,10') ? 'cabinada' : 'semicabinada'}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: const PdfColor.fromInt(ESCURO),
                  font: ttf,
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              pw.Table(
                columnWidths: {
                  0: pw.FlexColumnWidth(2), // 60%
                  1: pw.FlexColumnWidth(1), // 20%
                  2: pw.FlexColumnWidth(1), // 20%
                },
                border: pw.TableBorder.all(
                  color: const PdfColor.fromInt(CLARO),
                  width: 1,
                ),
                children: [
                  pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                  ),
                  children: [
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        'DESCRIÇÃO',
                        style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(ESCURO),
                        letterSpacing: 1,
                        font: ttf,
                        ),
                      ),
                    ),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        'QUANTIDADE',
                        style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(ESCURO),
                        letterSpacing: 1,
                        font: ttf,
                        ),
                      ),
                    ),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        'VALOR',
                        style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(ESCURO),
                        letterSpacing: 1,
                        font: ttf,
                        ),
                      ),
                    ),
                    ),
                  ],
                  ),
                  pw.TableRow(
                  children: [
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        'COLUNA DE ELEVAÇÃO${galvanizado ? ' EM AÇO GALVANIZADO' : ''} COM PERCURSO DE ${alturaElevacao.toUpperCase()} MOTOR BIFÁSICO (220V)',
                        style: pw.TextStyle(font: ttf),
                      ),
                    ),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        '1',
                        style: pw.TextStyle(font: ttf),
                      ),
                    ),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        currencyFormatter.format(valorColuna),
                        style: pw.TextStyle(font: ttf),
                      ),
                    ),
                    ),
                  ],
                  ),
                  pw.TableRow(
                  children: [
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        'CABINE DO PASSAGEIRO${galvanizado ? ' EM AÇO GALVANIZADO' : ''} COM ALTURA DE ${alturaCabine.toUpperCase()}',
                        style: pw.TextStyle(font: ttf),
                      ),
                    ),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        '1',
                        style: pw.TextStyle(font: ttf),
                      ),
                    ),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        currencyFormatter.format(valorCabine),
                        style: pw.TextStyle(font: ttf),
                      ),
                    ),
                    ),
                  ],
                  ),
                  ...adicionais.map(
                  (item) => pw.TableRow(
                    children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Center(
                        child: pw.Text(
                          item['descricao'].toString().toUpperCase(),
                          style: pw.TextStyle(font: ttf),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Center(
                        child: pw.Text(
                          item['quantidade'].toString(),
                          style: pw.TextStyle(font: ttf),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Center(
                        child: pw.Text(
                          item['valor'] != null ? currencyFormatter.format(item['valor']) : '-',
                          style: pw.TextStyle(font: ttf),
                        ),
                      ),
                    ),
                    ],
                  ),
                  ),
                  // Linha do frete
                  pw.TableRow(
                  children: [
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        'FRETE E INSTALAÇÃO',
                        style: pw.TextStyle(font: ttf),
                      ),
                    ),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        '-',
                        style: pw.TextStyle(font: ttf),
                      ),
                    ),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        frete > 0 ? currencyFormatter.format(frete) : 'Cortesia',
                        style: pw.TextStyle(font: ttf),
                      ),
                    ),
                    ),
                  ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Valor total
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFF0B375E),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'VALOR TOTAL',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        font: ttf,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      currencyFormatter.format(preco),
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        font: ttf,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              pw.Text(
                'CONDIÇÕES DE PAGAMENTO',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(ESCURO),
                  font: ttf,
                ),
              ),

              pw.SizedBox(height: 5),
              pw.Text(
                'Entrada de 40% na assinatura do contrato, saldo restante pode ser parcelado em 6x s/ juros no cartão.',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
              ),

              pw.SizedBox(height: 15),

              pw.Text(
                'TERMOS E CONDIÇÕES',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(ESCURO),
                  font: ttf,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Este orçamento é válido por 10 dias.',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
              ),
              
              pw.Spacer(),
              
              // Rodapé da primeira página
              _buildFooter(homeEscrito),
            ],
          );
        },
      ),
    );

    // PÁGINA 2 - ESPECIFICAÇÕES TÉCNICAS
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho da segunda página
              _buildHeader(logo, ttf),
              
              pw.SizedBox(height: 10),
              
              // Linha divisória
              pw.Divider(
                color: const PdfColor.fromInt(0xFF208FA7),
                thickness: 2,
              ),
              
              pw.SizedBox(height: 10),

              pw.Container(
                color: const PdfColor.fromInt(ESCURO),
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: pw.Text(
                  'ESPECIFICAÇÕES TÉCNICAS',
                  style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  font: ttf,
                  ),
                ),
              ),
              
              pw.SizedBox(height: 5),
              
              pw.Text(
                '• Capacidade de carga: 250 KG\n'
                '• Sistema de elevação: Fuso especial trapezoidal / eletromecânico\n'
                '• Dimensões do poço: (C) 1.500mm X (L) 1.500mm\n'
                '• Dimensões (aprox.) da cabine: (C) 1.450 mm X (L) 1.200mm X (A) 1.100 mm\n'
                '• As medidas podem sofrer alterações de acordo com a necessidade do cliente\n'
                '• Número de paradas: 2\n'
                '• Alimentação: 220v',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                  height: 1.5,
                ),
              ),
              
                pw.SizedBox(height: 20),

                pw.Text(
                'COMANDO',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(ESCURO),
                  font: ttf,
                ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                'Automatizado por botoeiras superiores, inferiores e interno com botões de acionamento constante.',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                'ESPECIFICAÇÕES DOS FIOS',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(ESCURO),
                  font: ttf,
                ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                '2 fios de 4mm com disjuntor de 25 amperes bipolar e 1 fio de 2,5mm para aterramento.\n'
                'Lembrando que o ponto de alimentação deve estar interligado.',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                'MOTORIZAÇÃO',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(ESCURO),
                  font: ttf,
                ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                'Consistindo por 1 motor de 4 CV BIFÁSICO e um inversor de frequência entrada 220v.',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                'ACABAMENTO',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(ESCURO),
                  font: ttf,
                ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                'Todo conjunto pintado na cor definido pelo cliente.',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                'CABINE E COLUNA',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(ESCURO),
                  font: ttf,
                ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                'Estrutura de aço, fechamento tipo cancela e piso antiderrapante.',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
                ),
              
              
              pw.Spacer(),
              
              // Rodapé da segunda página
              _buildFooter(homeEscrito),
            ],
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho da segunda página
              _buildHeader(logo, ttf),
              
              pw.SizedBox(height: 10),
              
              // Linha divisória
              pw.Divider(
                color: const PdfColor.fromInt(0xFF208FA7),
                thickness: 2,
              ),
              
              pw.SizedBox(height: 10),

              pw.Container(
                color: const PdfColor.fromInt(ESCURO),
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: pw.Text(
                  'CONDIÇÕES GERAIS DE FORNECIMENTO',
                  style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  font: ttf,
                  ),
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Text(
                'Por conta da HOME ELEVADORES',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(ESCURO),
                  font: ttf,
                ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                '• Prazo de entrega: 20 dias úteis após assinatura do contrato e entrada depositada\n'
                '• Local de entrega definido pelo cliente\n'
                '• Frete e instalação já incluso\n'
                '• Transporte até o local de montagem\n'
                '• Obs: Se necessário içamento, o custo fica por conta do CONTRATANTE\n'
                '• Montagem do equipamento\n'
                '• Projeto detalhado para execução da obra e assessoria remota',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
                ),

              pw.SizedBox(height: 20),

              pw.Text(
                'Por conta do CLIENTE',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(ESCURO),
                  font: ttf,
                ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                '• Obras de adequação do local da instalação, intalações elétricas até o quadro de comando (220v)',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
                ),

              pw.SizedBox(height: 20),

              pw.Container(
                color: const PdfColor.fromInt(ESCURO),
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: pw.Text(
                  'GARANTIA',
                  style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  font: ttf,
                  ),
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Text(
                'Periodo de 12 meses, contados a partir da entrega do equipamento, contra eventuais defeitos de fabricação.',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Container(
                color: const PdfColor.fromInt(ESCURO),
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: pw.Text(
                  'TERMOS E CONDIÇÕES',
                  style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  font: ttf,
                  ),
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Text(
                'Todo serviço de alvenaria será por conta do CONTRATANTE. A CONTRATADA não se responsabiliza pela execução da parte de alvenaria, ficando totalmente isenta se essa for executada fora dos padrões do projeto fornecido pela CONTRATADA.\n\n'
                'Validade da proposta: 10 dias.',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Container(
                color: const PdfColor.fromInt(ESCURO),
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: pw.Text(
                  'NORMAS DE REFERÊNCIA',
                  style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  font: ttf,
                  ),
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Text(
                'A plataforma de elevação motorizada, está de acordo com os requisitos da Norma ABNT-NBR 9386-1.\n'
                'Engenheiro responsável: Lauro Fernando Braga Alves - 5071024595-SP\n\n'
                'A HOME ELEVADORES fica no aguardo de um pronunciamento sobre nossa proposta e se coloca a seu dispor para quaisquer esclarecimentos adicionais.\n\n'
                    'Atenciosamente, HOME ELEVADORES!',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: ttf,
                ),
              ),

              pw.Spacer(),

              _buildFooter(homeEscrito),
            ],
          );
        },
      ),
    );

    // Gerar páginas dinâmicas com base nas imagens selecionadas
    List<Map<String, dynamic>> imagensOrganizadas = _organizarImagensSelecionadas(
      imagensSelecionadas,
      semicabinadaImage,
      semicabinadaPortasImage,
      semicabinadaEnclausuramentoImage,
      cabinadaPortasImage,
    );

    // Criar uma única página com todas as imagens selecionadas
    if (imagensOrganizadas.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho da página
                _buildHeader(logo, ttf),
                
                pw.SizedBox(height: 10),
                
                // Linha divisória
                pw.Divider(
                  color: const PdfColor.fromInt(0xFF208FA7),
                  thickness: 2,
                ),
                
                pw.SizedBox(height: 10),

                // Título da página
                pw.Container(
                  color: const PdfColor.fromInt(ESCURO),
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: pw.Text(
                    'MODELOS DE PLATAFORMAS',
                    style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    font: ttf,
                    ),
                  ),
                ),
                
                // Nomenclatura
                pw.SizedBox(height: 5),
                pw.Text(
                  'Nomenclatura',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(ESCURO),
                    font: ttf,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '• Semicabinada: Cabine de 1,10m\n'
                  '• Cabinada: Cabine de 2,10m',
                  style: pw.TextStyle(
                    fontSize: 12,
                    font: ttf,
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Layout das imagens em grade 2x2
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      // Primeira linha (primeiras 2 imagens)
                      if (imagensOrganizadas.length >= 1)
                        pw.Expanded(
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                            children: [
                              // Primeira imagem
                              pw.Expanded(
                                child: pw.Column(
                                  children: [
                                    pw.Container(
                                      color: const PdfColor.fromInt(ESCURO),
                                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                      child: pw.Text(
                                        imagensOrganizadas[0]['titulo'],
                                        style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.white,
                                        font: ttf,
                                        ),
                                      ),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Expanded(
                                      child: pw.Container(
                                        child: pw.Image(imagensOrganizadas[0]['imagem'], fit: pw.BoxFit.contain),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              pw.SizedBox(width: 20),
                              
                              // Segunda imagem (se existir)
                              pw.Expanded(
                                child: imagensOrganizadas.length >= 2
                                  ? pw.Column(
                                      children: [
                                        pw.Container(
                                          color: const PdfColor.fromInt(ESCURO),
                                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                          child: pw.Text(
                                            imagensOrganizadas[1]['titulo'],
                                            style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.white,
                                            font: ttf,
                                            ),
                                          ),
                                        ),
                                        pw.SizedBox(height: 5),
                                        pw.Expanded(
                                          child: pw.Container(
                                            child: pw.Image(imagensOrganizadas[1]['imagem'], fit: pw.BoxFit.contain),
                                          ),
                                        ),
                                      ],
                                    )
                                  : pw.Container(),
                              ),
                            ],
                          ),
                        ),
                      
                      pw.SizedBox(height: 15),
                      
                      // Segunda linha (terceira e quarta imagens)
                      if (imagensOrganizadas.length >= 3)
                        pw.Expanded(
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                            children: [
                              // Terceira imagem
                              pw.Expanded(
                                child: pw.Column(
                                  children: [
                                    pw.Container(
                                      color: const PdfColor.fromInt(ESCURO),
                                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                      child: pw.Text(
                                        imagensOrganizadas[2]['titulo'],
                                        style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.white,
                                        font: ttf,
                                        ),
                                      ),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Expanded(
                                      child: pw.Container(
                                        child: pw.Image(imagensOrganizadas[2]['imagem'], fit: pw.BoxFit.contain),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              pw.SizedBox(width: 20),
                              
                              // Quarta imagem (se existir)
                              pw.Expanded(
                                child: imagensOrganizadas.length >= 4
                                  ? pw.Column(
                                      children: [
                                        pw.Container(
                                          color: const PdfColor.fromInt(ESCURO),
                                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                          child: pw.Text(
                                            imagensOrganizadas[3]['titulo'],
                                            style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.white,
                                            font: ttf,
                                            ),
                                          ),
                                        ),
                                        pw.SizedBox(height: 5),
                                        pw.Expanded(
                                          child: pw.Container(
                                            child: pw.Image(imagensOrganizadas[3]['imagem'], fit: pw.BoxFit.contain),
                                          ),
                                        ),
                                      ],
                                    )
                                  : pw.Container(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),
                _buildFooter(homeEscrito),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }
}
