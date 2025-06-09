import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sprite_sheet/sprite_sheet.dart';

/// A widget that displays a sprite animation using a sprite sheet.
///
/// The [SpriteSheet] widget renders a single sprite composed of tiled frames from a
/// sprite sheet image. It supports playback control (via [SpriteController]), axis flipping,
/// and optional visual effects like a glow.
///
/// ### Features
/// - Animates a sprite using a grid-based sprite sheet.
/// - Play, pause, and stop control via [SpriteController].
/// - Support for flipping on the horizontal and vertical axes.
/// - Optional [SpriteGlow] visual effect.
///
/// This widget is ideal for lightweight, customizable 2D animations in Flutter UIs or games.
///
/// ### Example
/// ```dart
/// SpriteSheet(
///   controller: spriteController,
///   glow: SpriteGlow.color(
///     color: Colors.orangeAccent,
///     blurX: 4,
///     blurY: 4,
///     thicknessX: 1,
///     thicknessY: 1,
///   ),
/// )
/// ```
///
/// See also:
/// - [SpriteController], which drives the animation.
/// - [SpriteGlow], for adding glow effects to your sprite.
///
class SpriteSheet<T> extends LeafRenderObjectWidget {
  /// The controller that manages the animation state, frame index, and flipping.
  ///
  /// This is required to control which sprite frame is rendered and when.
  final SpriteController<T> controller;

  /// Optional glow effect applied to the sprite.
  ///
  /// The glow can be customized in color, blur, and thickness per frame.
  final SpriteGlow? glow;

  /// Creates a [SpriteSheet] widget.
  ///
  /// The [controller] is required to manage animation and rendering logic.
  /// The [glow] can be used to apply visual effects to the sprite.
  const SpriteSheet({
    required this.controller,
    this.glow,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSprite(controller: controller, glow: glow);

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) =>
      (renderObject as _RenderSprite<T>)
        ..controller = controller
        ..glow = glow
        ..markNeedsLayout();
}

/// Internal render object that draws the animated sprite on the canvas.
///
/// It handles sprite sheet layout, frame selection, axis flipping,
/// scaling, and glow effects.
class _RenderSprite<T> extends RenderBox {
  SpriteController<T> controller;
  SpriteGlow? glow;

  _RenderSprite({required this.controller, this.glow});

  T? lastAnimation;

  double scale = 1.0;

  @override
  void attach(PipelineOwner owner) {
    lastAnimation = controller.currentAnimation;
    controller.addListener(update);
    super.attach(owner);
  }

  @override
  void detach() {
    controller.removeListener(update);
    super.detach();
  }

  /// Updates the state of the sprite.
  ///
  /// This method should be called on each update of the controller.
  void update() {
    if (controller.currentAnimation != lastAnimation) {
      lastAnimation = controller.currentAnimation;
      markNeedsLayout();
    }

    markNeedsPaint();
  }

  @override
  void performLayout() {
    final image = controller.currentAnimationSheet;

    final width = image?.width.toDouble() ?? 0.0;
    final height = image?.height.toDouble() ?? 0.0;

    scale = image == null
        ? 1.0
        : min(
            constraints.maxWidth / width,
            constraints.maxHeight / height,
          );

    if (constraints.isTight) {
      size = constraints.biggest;
    } else {
      size = Size(
        clampDouble(width * scale, constraints.minWidth, constraints.maxWidth),
        clampDouble(height * scale, constraints.minHeight, constraints.maxHeight),
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    return Rect.fromLTWH(0, 0, size.width, size.height).contains(position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final animation = controller.currentAnimationSheet;
    if (animation == null) {
      return;
    }

    final image = controller.currentAnimationSheet;
    final width = image?.width.toDouble() ?? 0.0;
    final height = image?.height.toDouble() ?? 0.0;

    final flipX = controller.isFlippedX;
    final flipY = controller.isFlippedY;
    final isHorizontal = animation.axis == Axis.horizontal;

    final matrix4 = Matrix4.identity();

    /// Apply transform matrix if sprite should be fliped.
    if (flipX || flipY) {
      final scaleX = flipX ? -1.0 : 1.0;
      final scaleY = flipY ? -1.0 : 1.0;
      final dx = flipX ? width * scale : 0.0;
      final dy = flipY ? height * scale : 0.0;

      matrix4
        ..translate(dx, dy)
        ..scale(scaleX, scaleY);
    }

    void paintSprite(PaintingContext context, Offset offset) {
      final canvas = context.canvas;
      final srcRect = Rect.fromLTWH(
        (isHorizontal ? controller.offsetFrame.dx : controller.offsetFrame.dy) /
            animation.totalFrames *
            animation.image.width,
        (isHorizontal ? controller.offsetFrame.dy : controller.offsetFrame.dx) /
            animation.totalFrames *
            animation.image.height,
        animation.width,
        animation.height,
      );

      final dstRect = Rect.fromLTWH(offset.dx, offset.dy, width * scale, height * scale);

      /// Draw glow effect.
      final glow = this.glow;
      if (glow != null) {
        final frame = controller.offsetFrame.dx + controller.offsetFrame.dy * animation.columns;

        final paintGlow = Paint()
          ..colorFilter = ColorFilter.mode(glow.colorDelegate.getColor(animation, frame.toInt()), BlendMode.srcIn)
          ..imageFilter = ImageFilter.blur(sigmaX: glow.blurX, sigmaY: glow.blurY);

        canvas.saveLayer((offset & size).inflate(100), paintGlow);
        canvas.drawImageRect(
          animation.image,
          srcRect,
          dstRect,
          Paint()
            ..imageFilter = ImageFilter.dilate(radiusX: glow.thicknessX, radiusY: glow.thicknessY)
            ..filterQuality = FilterQuality.none
            ..isAntiAlias = false,
        );
        canvas.restore();
      }

      canvas.drawImageRect(animation.image, srcRect, dstRect, Paint()..filterQuality = FilterQuality.none);
    }

    layer = context.pushTransform(
      needsCompositing,
      offset,
      matrix4,
      paintSprite,
      oldLayer: layer as TransformLayer?,
    );
  }
}
