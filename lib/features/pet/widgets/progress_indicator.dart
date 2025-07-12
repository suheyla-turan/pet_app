import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final IconData icon;
  final int value;

  const StatusIndicator({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: LinearProgressIndicator(
              value: value / 10,
              minHeight: 10,
              color: Colors.teal,
              backgroundColor: Colors.teal.shade100,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
