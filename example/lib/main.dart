import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:appkit/appkit.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(const Demo());
}

class Demo extends StatelessWidget {
  const Demo({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double number = 1;
  int number2 = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppKit Demo')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CNumberPicker(
              value: number,
              onChanged: (newValue) => setState(() {
                number = newValue;
              }),
              min: 0,
              max: 10,
              itemCount: 1,
              step: 1,
              showDezimal: 0,
              zeroPad: true,
              axis: Axis.horizontal,
              infiniteLoop: false,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          number += 1;
        }),
      ),
    );
  }
}
