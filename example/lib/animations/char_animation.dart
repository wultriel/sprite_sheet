import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:sprite_sheet/sprite_sheet.dart';

class CharAnimation extends StatefulWidget {
  const CharAnimation({super.key});

  @override
  State<CharAnimation> createState() => _CharAnimationState();
}

enum CharState { idle, run }

class _CharAnimationState extends State<CharAnimation> {
  SpriteController<CharState>? controller;

  Future<(Image, Image)> _loadImages() async {
    final data = await Future.wait([
      rootBundle.load('assets/char-run.png'),
      rootBundle.load('assets/char-idle.png'),
    ]);

    final codec = await Future.wait([
      instantiateImageCodec(data.first.buffer.asUint8List()),
      instantiateImageCodec(data.last.buffer.asUint8List()),
    ]);

    final frames = await Future.wait([
      codec.first.getNextFrame(),
      codec.last.getNextFrame(),
    ]);

    return (frames.first.image, frames.last.image);
  }

  @override
  void initState() {
    super.initState();

    _loadImages().then((images) {
      setState(() {
        controller = SpriteController<CharState>({
          CharState.run: AnimationSheet(image: images.$1, columns: 4, rows: 1, isLooping: true),
          CharState.idle: AnimationSheet(image: images.$2, columns: 6, rows: 1, isLooping: true),
        });

        controller?.play(animation: CharState.idle);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.white;
    final controller = this.controller;

    return ColoredBox(
      color: backgroundColor,
      child: Center(
        child: SizedBox(
          height: 250,
          width: 250,
          child: controller != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (controller.currentAnimation == CharState.idle) {
                              controller.play(animation: CharState.run);
                            } else if (!controller.isFlippedX) {
                              controller.isFlippedX = true;
                            } else if (!controller.isFlippedY) {
                              controller.isFlippedY = true;
                            } else {
                              controller.isFlippedX = false;
                              controller.isFlippedY = false;
                              controller.play(animation: CharState.idle);
                            }
                          },
                          child: SpriteSheet(controller: controller),
                        ),
                      ),
                      Text(
                        'Try to tap on the sprite!',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
        ),
      ),
    );
  }
}
