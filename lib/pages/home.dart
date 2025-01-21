// Passar mesma função como parametro para direita e esquerda

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_elevadores/models/display.dart';
import 'package:home_elevadores/models/insertionBox.dart';
import 'package:home_elevadores/models/scrollableMenu.dart';
import 'package:home_elevadores/models/selectionBox.dart';
import 'package:home_elevadores/util/TapFunction.dart';
import 'package:intl/intl.dart';

import '../models/elevador.dart';

const TAM = 30.0;    // Obsoleto, usa só em searchfield

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pos = 0;
  int posCabine = 0;

  GlobalKey<InsertionBoxState> distanceKey = GlobalKey<InsertionBoxState>();
  GlobalKey<ScrollableMenuState> optionKey = GlobalKey<ScrollableMenuState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: ListView(
        children: [
          SelectionBox(
            title: 'ALTURA DE ELEVAÇÃO',
            innerText: Elevador.alturas[pos],
            functions: TapFunctions(
              () => setState(() => pos = (pos - 1) % Elevador.alturas.length),
              () => setState(() => pos = (pos + 1) % Elevador.alturas.length)
            )
          ),
          SelectionBox(
            title: 'ALTURA CABINE',
            innerText: Elevador.cabines[posCabine],
            functions: TapFunctions(
              () => setState(() => posCabine = (posCabine - 1) % Elevador.cabines.length),
              () => setState(() => posCabine = (posCabine + 1) % Elevador.cabines.length)
            )
          ),
          InsertionBox(
            key: distanceKey,
            title: 'DISTÂNCIA',
            hint: 'Distância ao local em km',
            type: TextInputType.number,
            onChanged: (text) {
              setState(() {});  // Atualiza o estado quando o texto muda
            },
          ),
          ScrollableMenu(
            key: optionKey,
            superTitle: 'ADICIONAIS',
            titleList: Elevador.adicionais,
            valueList: Elevador.valoresAdicionais),
          TextDisplay(
            title: 'TOTAL',
            innerText: 'R\$${NumberFormat('#,##0.00', 'pt_BR').format(totalValue())}',
          ),
          const SizedBox(height: 20,),
        ]
      )
    );
  }

  double totalValue() {
    double value = Elevador.valores[pos];
    // if (!trifasico && pos <= 2)
    //   value *= 1.0826;
    double distancia = double.tryParse(distanceKey.currentState?.controller.text ?? '') ?? 0.0;
    if (distancia > 100) {
      value += distancia * 6;
    }
    value += Elevador.valoresCabines[posCabine];
    for (int i = 0; i < (optionKey.currentState?.quantities.length ?? 0); i++) {
      value += ((optionKey.currentState?.valueList[i] ?? 0) * (optionKey.currentState?.quantities[i] ?? 0));
    }
    return value;
  }

  void _resetValues() {
    setState(() {
      pos = 0;
      posCabine = 0;
      distanceKey.currentState?.controller.clear();
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
      leading: GestureDetector(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xffF7F8F8),  // Color not constant, use 0xff...
            borderRadius: BorderRadius.circular(10)
          ),
          child: SvgPicture.asset(
            'assets/icons/left-arrow.svg',
            height: 20,
            width: 20
          ),
        ),
      ),
      actions: [
        InkWell(
          onTap: () {
            _resetValues();
          },
          child: Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          width: 37,
          child: SvgPicture.asset(
            'assets/icons/circularArrow.svg',
            height: 20,
            width: 20
          ),
          decoration: BoxDecoration(
            color: Color(0xffF7F8F8),  // Color not constant, use 0xff...
            borderRadius: BorderRadius.circular(10)
          )
        ),
      )
    ]
    );
  }
}