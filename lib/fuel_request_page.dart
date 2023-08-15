import 'package:flutter/material.dart';


class FuelRequestPage extends StatefulWidget {
  const FuelRequestPage({Key? key}) : super(key: key);

  @override
  State<FuelRequestPage> createState() => _FuelRequestPageState();
}

class _FuelRequestPageState extends State<FuelRequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Fuel ",
        ),
      ),
    );
  }
}
