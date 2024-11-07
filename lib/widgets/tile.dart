import 'package:flutter/material.dart';

class PreferenceTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const PreferenceTile({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      child: Material(
        color: Colors.grey[200],
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
