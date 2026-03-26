import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FLACidal')),
      body: const Center(child: Text('Paste a Tidal or Qobuz URL to get started')),
    );
  }
}
