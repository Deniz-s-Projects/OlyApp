import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String title;
  const ItemCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.shade800),
      ),
      child: Center(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
