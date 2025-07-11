import 'package:flutter/material.dart';

Widget buildPanel({
  required String title,
  required IconData icon,
  required Color color,
  required String message,
}) {
  return Card(
    color: color.withValues(alpha: 0.1),
    elevation: 1,
    child: ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(message),
    ),
  );
}

Widget buildInfoCard(String label, String value) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: ListTile(
      title: Text(label),
      subtitle: Text(value.isEmpty ? 'None' : value),
    ),
  );
}
