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
              image: Image.network(src).image, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

Function showError(BuildContext context) => (String errorMessage) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
Function showSuccess(BuildContext context) => (String message) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success!"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
