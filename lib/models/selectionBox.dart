import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:home_elevadores/util/TapFunction.dart';
import 'package:home_elevadores/util/globals.dart';

class SelectionBox extends StatelessWidget {
  String title;
  String innerText;
  int size;
  TapFunctions functions;

  SelectionBox({
    super.key,
    required this.title,
    required this.innerText,
    this.size = 1,
    required this.functions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: TAMTITULO*MULFACT[size],
              fontWeight: FontWeight.w900
            ),
          ),
          Container(
            height: HEIGHT*MULFACT[size],
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            decoration: BoxDecoration(
              color: AZULCLARO,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: functions.esquerda,
                  child: Container(
                    height: TAMSETA*MULFACT[size],
                    width: TAMSETA*MULFACT[size],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset('assets/icons/doubleArrowLeft.svg'),
                    ),
                  ),
                ),
                Text(
                  innerText,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: TEXTSIZE*MULFACT[size],
                    fontWeight: FontWeight.w600
                  ),
                ),
                InkWell(
                  onTap: functions.direita,
                  child: Container(
                    height: TAMSETA*MULFACT[size],
                    width: TAMSETA*MULFACT[size],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset('assets/icons/doubleArrowRight.svg'),
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
}