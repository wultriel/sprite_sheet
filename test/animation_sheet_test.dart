import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprite_sheet/sprite_sheet.dart';

void main() {
  group('AnimationSheet', () {
    late Image image;

    setUpAll(() async {
      image = await createTestImage(width: 120, height: 80);
    });

    test('calculates width and height correctly', () {
      final sheet = AnimationSheet(
        image: image,
        columns: 6,
        rows: 4,
      );

      expect(sheet.width, equals(20)); // 120 / 6
      expect(sheet.height, equals(20)); // 80 / 4
    });

    test('infers rows/columns if frame size is given', () {
      final sheet = AnimationSheet(
        image: image,
        frameWidth: 30,
        frameHeight: 20,
      );

      expect(sheet.columns, equals(4)); // 120 / 30
      expect(sheet.rows, equals(4)); // 80 / 20
    });

    test('detects reverse directions correctly', () {
      expect(
        AnimationSheet(
          image: image,
          columns: 2,
          rows: 2,
          direction: AnimationDirection.reverse,
        ).isReversed,
        isTrue,
      );

      expect(
        AnimationSheet(
          image: image,
          columns: 2,
          rows: 2,
          direction: AnimationDirection.forward,
        ).isReversed,
        isFalse,
      );
    });
  });
}
