import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

const CLARO = 0xFF208FA7;
const ESCURO = 0xFF0B375E;

class PDFGenerator {
  static Future<Uint8List> generateOrcamentoPDF({
    String cidade = 'São Paulo',
    String estado = 'SP',
    String cliente = 'João',
    bool galvanizado = false,
    double valorColuna = 0,
    double valorCabine = 0,
    double quantidadeColuna = 1,
    double quantidadeCabine = 1,
    int frete = 0,
    required String alturaElevacao,
    required double preco,
    required String alturaCabine,
    required List<Map<String, dynamic>> adicionais,
  }) async {
    final pdf = pw.Document();
    
    // Carregar a logo
    final ByteData logoData = await rootBundle.load('assets/icons/home.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logo = pw.MemoryImage(logoBytes);

    // Formatador de moeda
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho com logo
              pw.Row(
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
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF0B375E),
                        ),
                      ),
                      pw.Text(
                        'CNPJ: 44.567.572/0001-22\n'
                        'R. 20 de Novembro, 780 - Rio Abaixo, Atibaia',
                        style: pw.TextStyle(
                          fontSize: 11,
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
                        ),
                      ),
                      pw.Text(
                        'contato@homelevadores.com',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: const PdfColor.fromInt(ESCURO),
                        ),
                      ),
                    ]
                  )
                ],
              ),
              
              pw.SizedBox(height: 10),
              
              // Linha divisória
              pw.Divider(
                color: const PdfColor.fromInt(0xFF208FA7),
                thickness: 2,
              ),
              
              pw.SizedBox(height: 10),
              
              // Data
              //pw.Text(
              //  'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
              //  style: pw.TextStyle(fontSize: 12),
              //),
              pw.Container(
              color: const PdfColor.fromInt(ESCURO),
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: pw.Text(
                'COTAÇÃO',
                style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
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
                    child: pw.Text(
                      'DESCRIÇÃO',
                      style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(ESCURO),
                      letterSpacing: 1,
                      ),
                    ),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'QUANTIDADE',
                      style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(ESCURO),
                      letterSpacing: 1,
                      ),
                    ),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'VALOR',
                      style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(ESCURO),
                      letterSpacing: 1,
                      ),
                    ),
                    ),
                  ],
                  ),
                  pw.TableRow(
                  children: [
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('COLUNA DE ELEVAÇÃO${galvanizado ? ' EM AÇO GALVANIZADO' : ''} COM PERCURSO DE ${alturaElevacao.toUpperCase()} MOTOR BIFÁSICO (220V)'),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(quantidadeColuna.toString()),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(currencyFormatter.format(valorColuna)),
                    ),
                  ],
                  ),
                  pw.TableRow(
                  children: [
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('CABINE DO PASSAGEIRO${galvanizado ? ' EM AÇO GALVANIZADO' : ''} COM ALTURA DE ${alturaCabine.toUpperCase()}'),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(quantidadeCabine.toString()),
                    ),
                    pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(currencyFormatter.format(valorCabine)),
                    ),
                  ],
                  ),
                  ...adicionais.map(
                  (item) => pw.TableRow(
                    children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['descricao'].toString().toUpperCase()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['quantidade'].toString()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['valor'] != null ? currencyFormatter.format(item['valor']) : '-'),
                    ),
                    ],
                  ),
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
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      currencyFormatter.format(preco),
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Observações
              pw.Text(
                'OBSERVAÇÕES:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF0B375E),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '> Orçamento válido por 30 dias\n'
                '> Instalação e manutenção incluídas\n'
                '> Garantia de 12 meses\n'
                '> Prazo de entrega: 45 dias úteis\n',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'CONDIÇÕES DE PAGAMENTO',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF208FA7),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '- Capacidade de carga - 250 KG;\n'			
                '- Sistema de elevação - Fuso especial trapezoidal / eletromecânico;\n'
                '- Dimensões do poço - (C) 1.500mm X (L) 1.500mm\n'
                '- Dimensões (aprox.) da cabine - (C) 1.450 mm X (L) 1.200mm X (A) 1.100 mm\n'
                '- As medidas podem sofrer alterações de acordo com a necessidade do cliente\n'
                '- Número de paradas - 2\n'
                '- Alimentação 220v',
                style: pw.TextStyle(fontSize: 12),
              ),
              
              pw.Spacer(),
              
              // Rodapé
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFF208FA7),
                ),
                child: pw.Text(
                  'Home Elevadores - Qualidade e Confiança em Movimento',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
