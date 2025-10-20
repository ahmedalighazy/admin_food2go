import 'package:flutter/material.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Status',
            style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: const Color.fromRGBO(158, 9, 15, 1),
        elevation: 0,
      ),
    );
  }
}
