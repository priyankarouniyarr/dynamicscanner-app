import 'package:flutter/material.dart';

class Viewdocuments extends StatefulWidget {
  const Viewdocuments({super.key});

  @override
  State<Viewdocuments> createState() => _ViewdocumentsState();
}

class _ViewdocumentsState extends State<Viewdocuments> {
  @override
  Widget build(BuildContext context) {
    const appTitle = ' Information Documents';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(46, 25, 96, 1),
            Color.fromRGBO(93, 16, 73, 1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            appTitle,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          centerTitle: true,
          leading: BackButton(color: Colors.white),
        ),
        body: Container(),
      ),
    );
  }
}
