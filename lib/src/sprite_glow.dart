import 'dart:ui';

import 'package:sprite_sheet/sprite_sheet.dart';

/// A configuration class for applying a glow effect to a sprite.
///
/// The glow effect is fully customizable in terms of color, blur radius,
/// and spread (thickness). You can use either a static or dynamic color
/// via different constructors.
///
/// This class is typically used with a [SpriteSheet] that support glow effects.
///
/// If both blur and thickness are set to zero, the glow will not be visible.
class SpriteGlow {
  /// Delegate that provides the color of the glow.
  final GlowColorDelegate colorDelegate;

  /// Horizontal blur radius of the glow effect.
  ///
  /// A larger value results in a softer horizontal blur.
  final double blurX;

  /// Vertical blur radius of the glow effect.
  ///
  /// A larger value results in a softer vertical blur.
  final double blurY;

  /// Horizontal thickness (spread) of the glow.
  ///
  /// Controls how far the glow extends along the X-axis.
  final double thicknessX;

  /// Vertical thickness (spread) of the glow.
  ///
  /// Controls how far the glow extends along the Y-axis.
  final double thicknessY;

  /// Creates a glow configuration using a custom [GlowColorDelegate].
  ///
  /// Use this constructor if you want full control over how the glow color is calculated.
  ///
  /// If both blur and thickness are zero, no glow will be visible.
  SpriteGlow({
    required this.colorDelegate,
    this.blurX = 0,
    this.blurY = 0,
    this.thicknessX = 0,
    this.thicknessY = 0,
  });

  /// Creates a glow configuration with a constant static [color].
  ///
  /// Useful for simple glow effects that don't depend on animation state.
  ///
  /// The [color] parameter specifies the color of the glow effect.
  ///
  /// Additional parameters can be used to customize the glow's appearance,
  /// such as thickness, blur.
  ///
  /// ### Example usage:
  /// ```dart
  /// final glowConfig = SpriteGlowConfig.color(
  ///   color: Colors.blue,
  ///   blurX: 15.0,
  ///   thicknessX: 15.0,
  ///   thicknessY: 10.0
  /// );
  /// ```
  ///
  /// If both blur and thickness are zero, no glow will be visible.
  SpriteGlow.color({
    required Color color,
    this.blurX = 0,
    this.blurY = 0,
    this.thicknessX = 0,
    this.thicknessY = 0,
  }) : colorDelegate = GlowStaticColor(color);

  /// Creates a glow configuration with a dynamically changing color.
  ///
  /// The [colorCallback] determines the glow color for each frame based on the
  /// current animation and frame index. This allows for animated glow effects
  /// like rainbow cycling or heat maps.
  ///
  /// Additional parameters can be used to customize the glow's appearance,
  /// such as thickness, blur.
  ///
  /// ### Example usage:
  /// ```dart
  /// SpriteGlow.dynamicColor(
  ///   colorCallback: (animation, frame) =>
  ///       HSLColor.fromAHSL(1, frame / animation.totalFrames * 360, 1, 0.9).toColor(),
  ///   thicknessX: 25,
  ///   thicknessY: 25,
  ///   blurY: 15,
  /// )
  /// ```
  /// If both blur and thickness are zero, no glow will be visible.
  SpriteGlow.dynamicColor({
    required Color Function(AnimationSheet animation, int frame) colorCallback,
    this.blurX = 0,
    this.blurY = 0,
    this.thicknessX = 0,
    this.thicknessY = 0,
  }) : colorDelegate = GlowDynamicColor(colorCallback);
}

/// Base class for delegating the color logic used by [SpriteGlow].
///
/// Implementations determine the glow color for each frame, allowing
/// for static or dynamic glow color behaviors.
sealed class GlowColorDelegate {
  /// Returns the [Color] for the specified [frame] in the given [animation].
  ///
  /// [animation] is the currently played [AnimationSheet].
  /// [frame] is the index of the frame.
  Color getColor(AnimationSheet animation, int frame);
}

/// A [GlowColorDelegate] that returns a fixed, constant color.
class GlowStaticColor extends GlowColorDelegate {
  /// The static color to be used for all glow frames.
  final Color color;

  /// Creates a [GlowStaticColor] instance with the specified [color].
  ///
  /// The [color] parameter defines the static color used for the glow effect.
  GlowStaticColor(this.color);

  @override
  Color getColor(AnimationSheet animation, int frame) => color;
}

/// A [GlowColorDelegate] that computes color dynamically per frame.
///
/// Responsible for determining the color of a glow effect dynamically,
/// based on animation state or the current `frame` of animation.
class GlowDynamicColor extends GlowColorDelegate {
  /// A callback function to determine color based on animation state and frame.
  ///
  /// It takes an [AnimationSheet] and a frame index, and returns a [Color]
  /// representing the color for that specific animation frame.
  ///
  /// This allows dynamic color selection based on the animation state and frame.
  ///
  /// ### Example usage:
  /// ```dart
  /// (animation, frame) => Colors.red.withAlpha(frame / animation.totalFrames * 255),
  /// ```
  Color Function(AnimationSheet animation, int frame) color;

  /// Creates a [GlowDynamicColor] with the specified [color].
  ///
  /// The [color] parameter determines the dynamic color used for the glow effect.
  GlowDynamicColor(this.color);

  @override
  Color getColor(AnimationSheet animation, int frame) =>
      color.call(animation, frame);
}
