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
  double number = 0.4;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppKit Demo')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CNumberPicker(
            //   value: number,
            //   onChanged: (newValue) => setState(() {
            //     number = newValue;
            //   }),
            //   min: 0,
            //   max: 0.8,
            //   step: 0.1,
            //   itemCount: 1,
            //   showDezimal: 1,
            //   zeroPad: false,
            //   axis: Axis.vertical,
            //   infiniteLoop: false,
            // ),
            CDropDown(
              textMapper: (value) => value,
              options: [
                "1",
                "2",
                "3",
                "4",
                "5",
                "6",
                "7",
                "800000000000000000000000",
                "9",
                "10",
                "11",
                "12",
                "13",
                "15",
                "16",
                "17",
                "18",
                "19",
                "20",
              ],
              onChangedItem: (item) {
                print(item);
              },
              selectedItemPlaceholder: "select Item",
              iconClosed: Icons.keyboard_arrow_down,
              iconOpen: Icons.keyboard_arrow_up,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              dropDownDecoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
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
