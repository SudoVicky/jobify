import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              // child: CircularProgressIndicator(),
              child: Lottie.asset(
                'assets/animations/atom.json', // Update this path to your Lottie file
                width: 100, // Customize width
                height: 100, // Customize height
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }
}
