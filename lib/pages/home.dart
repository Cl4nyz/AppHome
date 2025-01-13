import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const AZULCLARO = Color.fromARGB(255, 32, 143, 167);
const AZULESCURO = Color.fromARGB(255, 11, 55, 94);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        'Elevadores',
        style: TextStyle(
          color: AZULESCURO,
          fontSize: 22,
          fontWeight: FontWeight.bold
        )
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
          GestureDetector(
            onTap: () {

            },
            child: Container(
            margin: EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 37,
            child: SvgPicture.asset(
              'assets/icons/x.svg',
              height: 13,
              width: 13
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