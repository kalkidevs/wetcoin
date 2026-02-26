import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoadingAnimation extends StatelessWidget {
  final double width;
  final double height;

  const AppLoadingAnimation({
    super.key,
    this.width = 100,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/loading.json',
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
