import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:sprite_sheet/sprite_sheet.dart';

class SparklesAnimation extends StatefulWidget {
  const SparklesAnimation({super.key});

  @override
  State<SparklesAnimation> createState() => _SparklesAnimationState();
}

class _SparklesAnimationState extends State<SparklesAnimation> {
  SpriteController<String>? controller;

  Future<Image> _loadImage() async {
    final data = await rootBundle.load('assets/sparkles.png');
    final codec = await instantiateImageCodec(data.buffer.asUint8List());
    final frames = await codec.getNextFrame();

    return frames.image;
  }

  @override
  void initState() {
    super.initState();

    _loadImage().then((image) {
      setState(() {
        controller = SpriteController<String>({
          '': AnimationSheet(
              image: image, columns: 1, rows: 7, isLooping: true),
        });

        controller?.play(animation: '');
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
          height: 200,
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
                                        0.5)
                                    .toColor(),
                            thicknessX: 5,
                            thicknessY: 5,
                            blurY: 25,
                            blurX: 25,
                          ),
                        ),
                      ),
                      SizedBox.square(dimension: 16),
                      Text(
                        'Glow effect',
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
