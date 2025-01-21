import 'package:flutter/material.dart';
import 'package:home_elevadores/util/globals.dart';

class InsertionBox extends StatefulWidget {
  final String title;
  final String hint;
  final int size;
  final TextInputType type;
  final Function(String)? onChanged;
  String content;

  InsertionBox({
    super.key,
    required this.title,
    this.hint = '',
    this.size = 1,
    this.type = TextInputType.text,
    this.content = '',
    this.onChanged
  });

  @override
  InsertionBoxState createState() => InsertionBoxState();
}

class InsertionBoxState extends State<InsertionBox> {
  TextEditingController _controller = TextEditingController();

  TextEditingController get controller => _controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.black,
              fontSize: TAMTITULO * MULFACT[widget.size],
              fontWeight: FontWeight.w900
            ),
          ),
          Container(
            height: HEIGHT * MULFACT[widget.size],
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            child: TextField(
              textAlign: TextAlign.center,
              controller: _controller,
              keyboardType: widget.type,
              decoration: InputDecoration(
                filled: true,
                fillColor: AZULCLARO,
                contentPadding: EdgeInsets.all(15),
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: Color.fromARGB(174, 255, 255, 255),
                  fontSize: TEXTSIZE * MULFACT[widget.size],
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none
                )
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: TEXTSIZE * MULFACT[widget.size],
                fontWeight: FontWeight.w600
              ),
              onChanged: widget.onChanged
            ),
          ),
        ],
      ),
    );
  }
}
