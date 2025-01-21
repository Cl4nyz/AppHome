import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:home_elevadores/models/selectionBox.dart';
import 'package:home_elevadores/util/TapFunction.dart';
import 'package:home_elevadores/util/globals.dart';

class TextDisplay extends StatelessWidget {
  String title;
  String innerText;

  TextDisplay({
    super.key,
    required this.title,
    required this.innerText
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'TOTAL',
          style: TextStyle(
            color: Colors.black,
            fontSize: TAMTITULO*MULFACT[0],
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
              innerText,
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
  
  void setState(Null Function() param0) {}    
}