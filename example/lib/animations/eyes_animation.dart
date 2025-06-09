import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:sprite_sheet/sprite_sheet.dart';

class EyesAnimation extends StatefulWidget {
  const EyesAnimation({super.key});

  @override
  State<EyesAnimation> createState() => _EyesAnimationState();
}

enum EyesState { appear, idle }

class _EyesAnimationState extends State<EyesAnimation> {
  SpriteController<EyesState>? controller;

  Future<(Image, Image)> _loadImages() async {
    final data = await Future.wait([
      rootBundle.load('assets/eyes-appear.png'),
      rootBundle.load('assets/eyes-idle.png'),
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
        controller = SpriteController<EyesState>({
          EyesState.appear: AnimationSheet(
              image: images.$1, columns: 9, rows: 1, isLooping: false),
          EyesState.idle: AnimationSheet(
            image: images.$2,
            columns: 8,
            rows: 1,
            direction: AnimationDirection.pingPong,
          ),
        });

        controller?.play(animation: EyesState.appear);
        controller?.addToQueue(EyesState.idle);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(0xFF151B23);
    final controller = this.controller;

    return ColoredBox(
      color: backgroundColor,
      child: Center(
        child: SizedBox(
          height: 160,
          width: 200,
          child: controller != null
              ? Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: SpriteSheet(
                          controller: controller,
                          glow: SpriteGlow.dynamicColor(
                            colorCallback: (animation, frame) =>
                                HSLColor.fromAHSL(
                                        1,
                                        frame / animation.totalFrames * 360,
                                        1,
                                        0.9)
                                    .toColor(),
                            thicknessX: 25,
                            thicknessY: 25,
                            blurY: 15,
                          ),
                        ),
                      ),
                      SizedBox.square(dimension: 16),
                      Text(
                        'Queuing animations',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
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
