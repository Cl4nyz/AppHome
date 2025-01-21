import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:home_elevadores/models/selectionBox.dart';
import 'package:home_elevadores/util/TapFunction.dart';
import 'package:home_elevadores/util/globals.dart';

class ScrollableMenu extends StatefulWidget {
  final String superTitle;
  final List<String> titleList;
  final List<double> valueList;

  ScrollableMenu({
    super.key,
    required this.superTitle,
    required this.titleList,
    required this.valueList,
  });

  @override
  State<ScrollableMenu> createState() => ScrollableMenuState();
}

class ScrollableMenuState extends State<ScrollableMenu> {
  late List<int> _quantities = List.filled(widget.titleList.length, 0);

  List<int> get quantities => _quantities;
  List<double> get valueList => widget.valueList;

  @override
  void initState() {
    super.initState();
    //_quantities = List.from(widget.quantities); // Copia inicial dos valores
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          color: AZULESCURO,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.superTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: TAMTITULO*MULFACT[0],
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 250,
          color: const Color.fromARGB(255, 161, 183, 194),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (context, index) => const SizedBox(height: 1.5),
              itemCount: widget.titleList.length,
              itemBuilder: (context, index) {
                return SelectionBox(
                  title: widget.titleList[index],
                  innerText: quantities[index].toString(),
                  size: 1,
                  functions: TapFunctions(
                    () => setState(() {
                      if (quantities[index] > 0) quantities[index]--;
                    }),
                    () => setState(() {
                      quantities[index]++;
                    }),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
