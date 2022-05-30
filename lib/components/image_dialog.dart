import 'package:flutter/material.dart';

class ImageDialog extends StatelessWidget {
  const ImageDialog({Key? key, required this.src}) : super(key: key);
  final String src;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.network(src).image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
