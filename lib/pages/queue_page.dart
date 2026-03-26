import 'package:flutter/material.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Queue')),
      body: const Center(child: Text('Download queue')),
    );
  }
}
