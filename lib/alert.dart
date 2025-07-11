import 'package:flutter/material.dart';

showAlert({required BuildContext bContext, String? title, String? content}) {
  return showDialog(
    context: bContext,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title ?? "", style: TextStyle(color: Colors.black)),
        content: Text(content ?? ""),
        contentTextStyle: TextStyle(color: Colors.red),
        actions: [
          TextButton(
            onPressed: () => {Navigator.pop(context)},
            child: Text("Okay"),
          ),
        ],
      );
    },
  );
}
