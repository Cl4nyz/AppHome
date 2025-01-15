import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const AZULCLARO = Color.fromARGB(255, 32, 143, 167);
const AZULESCURO = Color.fromARGB(255, 11, 55, 94);
const TAM = 30.0;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          _searchField()
        ]
      )
    );
  }

  Container _searchField() {
    return Container(
          margin: EdgeInsets.only(top:40, left:20, right:20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xff101617).withOpacity(0.11),
                blurRadius: 40,
                spreadRadius: 0.0
              )
            ]
          ),
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(15),
              hintText: 'Search Pancake',
              hintStyle: TextStyle(
                color: Color(0xffDDDADA),
                fontSize: 14,
              ),
              prefixIcon: Container(
                height: TAM,
                width: TAM,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset('assets/icons/search.svg'),
                ),
              ),
              suffixIcon: Container(
                width: TAM*2,
                height: TAM,
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      VerticalDivider(
                        color: Colors.black,
                        indent: 10,
                        endIndent: 10,
                        thickness: 0.1,
                      ),
                      Container(
                        width: TAM,
                        height: TAM,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset('assets/icons/filter.svg'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none
              )
            ),
          ),
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