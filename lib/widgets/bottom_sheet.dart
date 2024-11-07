import 'package:flutter/material.dart';

class BottomSheetUtil {
  static void show(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 100,
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
