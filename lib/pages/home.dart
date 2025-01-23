// Passar mesma função como parametro para direita e esquerda

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../models/elevador.dart';

const AZULCLARO = Color.fromARGB(255, 32, 143, 167);
const AZULESCURO = Color.fromARGB(255, 11, 55, 94);
const TAM = 30.0;
const TAMTITULO = 25.0;
const TAMSETA = 45.0;
const ALTGRANDE = 60.0;
const ALTPEQ = 32.0;
const TEXTOGRAN = 22.0;
const TEXTOPEQ = 18.0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pos = 0;
  int posCabine = 0;
  bool trifasico = true;
  List<int> quantias = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  
  TextEditingController _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: ListView(
        children: [
          //_searchField(),
          _selectionBox(
            bigTitle('ALTURA DE ELEVAÇÃO'),
            Elevador.alturas[pos],
            ALTGRANDE,
            TEXTOGRAN,
            () => setState(() => pos = (pos - 1) % Elevador.alturas.length),
            () => setState(() => pos = (pos + 1) % Elevador.alturas.length)
          ),
          _selectionBox(
            bigTitle('ALTURA CABINE'),
            Elevador.cabines[posCabine],
            ALTGRANDE,
            TEXTOGRAN,
            () => setState(() => posCabine = (posCabine - 1) % Elevador.cabines.length),
            () => setState(() => posCabine = (posCabine + 1) % Elevador.cabines.length)
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
                color: AZULESCURO,
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
          const SizedBox(height: 20,),
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
    return Container(
          height: 250,
          color: Color.fromARGB(255, 161, 183, 194),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (context, index) => const SizedBox(height: 1.5,),
              itemCount: quantias.length,
              itemBuilder: (context, index) {
                return _selectionBox(
                  smallTitle(Elevador.adicionais[index]),
                  quantias[index].toString(),
                  ALTPEQ,
                  TEXTOPEQ,
                  () => setState(() { if (quantias[index] > 0) quantias[index]--;}),
                  () => setState(() => quantias[index]++),
                  );
              },
            ),
          ),
        );
  }

  double totalValue() {
    double value = Elevador.valores[pos];
    // if (!trifasico && pos <= 2)
    //   value *= 1.0826;
    value += Elevador.valoresCabines[posCabine];
    int posGalvanizado = 13;
    if (quantias[posGalvanizado] > 0)
      value *= Elevador.valoresAdicionais[posGalvanizado];

    double distancia = double.tryParse(_controller.text) ?? 0.0;
    if (distancia > 100) {
      value += distancia * 6;
    }
    for (int i = 0; i < quantias.length-1; i++) {
      value += (Elevador.valoresAdicionais[i] * quantias[i]);
    }
    return value;
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
        const Text(
          'TOTAL',
          style: TextStyle(
            color: Colors.black,
            fontSize: TAMTITULO,
            fontWeight: FontWeight.w900
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: AZULESCURO,
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
                hintText: 'Insira a distância ao destino em km',
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
                    width: TAMSETA,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                    width: TAMSETA,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
      pos = 0;
      posCabine = 0;
      trifasico = true;
      quantias = List.filled(quantias.length, 0);
      _controller.clear();
    });
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Container(
        height: 50,
        child: Image.asset('assets/icons/home.png')
        ),
//      leading: GestureDetector(
//        onTap: () {},
//        child: Container(
//          margin: EdgeInsets.all(10),
//          alignment: Alignment.center,
//          decoration: BoxDecoration(
//            color: Color(0xffF7F8F8),  // Color not constant, use 0xff...
//            borderRadius: BorderRadius.circular(10)
//          ),
//          child: SvgPicture.asset(
//            'assets/icons/left-arrow.svg',
//            height: 20,
//            width: 20
//          ),
//        ),
//      ),
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