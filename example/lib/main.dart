import 'package:example/animations/char_animation.dart';
import 'package:example/animations/eyes_animation.dart';
import 'package:example/animations/sparkles_animation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: PageView(
          children: const [
            CharAnimation(),
            EyesAnimation(),
            SparklesAnimation(),
          ],
        ),
      ),
    );
  }
}
