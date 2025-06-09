import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprite_sheet/sprite_sheet.dart';

void main() {
  group('SpriteController', () {
    late Image image;
    late SpriteController<String> controller;

    setUpAll(() async {
      image = await createTestImage(width: 60, height: 20);
      final run = AnimationSheet(
        image: image,
        columns: 3,
        rows: 1,
        frameDuration: Duration(milliseconds: 100),
        isLooping: false,
      );
      final idle = AnimationSheet(image: image, columns: 2, rows: 1);
      controller = SpriteController({'run': run, 'idel': idle});
    });

    test('initializes with first frame', () {
      expect(controller.offsetFrame, Offset.zero);
    });

    test('advances frame correctly', () async {
      controller.play(animation: 'run');
      await Future.delayed(Duration(milliseconds: 110));
      // controller.update();
      expect(controller.frame, greaterThan(0));
    });

    test('resets frame on play', () async {
      controller.seekFrame(2);
      controller.play(animation: 'idel');
      expect(controller.frame, 0);
    });

    test('pauses and stops correctly', () {
      controller.pause();
      expect(controller.isPlaying, isFalse);

      controller.stop();
      expect(controller.frame, 0);
    });

    test('seek and seekFrame work correctly 3x3', () {
      final sheet = AnimationSheet(image: image, columns: 3, rows: 3);
      final controller = SpriteController({'idle': sheet});
      controller.play(animation: 'idle');
      controller.stop();

      controller.seek(Offset(1, 2));
      expect(controller.frame, 7);

      controller.seekFrame(5);
      expect(controller.offsetFrame, Offset(2, 1));
      expect(controller.frame, 5);
    });

    test('seek and seekFrame work correctly 2x3', () {
      final sheet = AnimationSheet(image: image, columns: 2, rows: 3);
      final controller = SpriteController({'idle': sheet});
      controller.play(animation: 'idle');
      controller.stop();

      controller.seek(Offset(0, 0));
      expect(controller.frame, 0);

      controller.seek(Offset(1, 2));
      expect(controller.frame, 5);

      controller.seekFrame(5);
      expect(controller.offsetFrame, Offset(1, 2));
      expect(controller.frame, 5);

      controller.seekFrame(6);
      expect(controller.frame, 6);
    });

    test('addToQueue plays next animation after current ends', () async {
      final run = AnimationSheet(
          image: image,
          columns: 2,
          rows: 1,
          isLooping: false,
          frameDuration: Duration(milliseconds: 10));
      final idle = AnimationSheet(image: image, columns: 2, rows: 1);

      final controller = SpriteController({'run': run, 'idle': idle});
      controller.play(animation: 'run');
      controller.addToQueue('idle');

      await Future.delayed(Duration(milliseconds: 500));

      expect(controller.currentAnimation, 'idle');
    });
  });
}
