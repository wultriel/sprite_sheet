import 'dart:ui';

import 'package:flutter/material.dart' show Durations;
import 'package:flutter/rendering.dart';
import 'package:sprite_sheet/sprite_sheet.dart';

/// Defines the direction in which a sprite animation should play.
enum AnimationDirection {
  /// Plays the animation from the first frame to the last.
  forward,

  /// Plays the animation from the last frame to the first.
  reverse,

  /// Plays the animation forward to the last frame, then reverses back to the first,
  /// repeating in a back-and-forth loop.
  pingPong,

  /// Plays the animation in reverse first, then forward,
  /// repeating in a back-and-forth loop.
  reversePingPong,
}

/// A data class that defines a sprite sheet-based animation.
///
/// Used by [SpriteController] to manage playback details such as frame layout,
/// timing, direction, and looping. The sprite sheet must be a grid of frames
/// arranged in rows and columns.
class AnimationSheet {
  /// Number of horizontal frames in the sprite sheet.
  final int columns;

  /// Number of vertical frames in the sprite sheet.
  final int rows;

  /// Duration of each frame in the animation.
  ///
  /// Controls the playback speed of the animation.
  final Duration frameDuration;

  /// Whether the animation should repeat after reaching the end.
  final bool isLooping;

  /// Whether frames are arranged horizontally or vertically.
  ///
  /// Affects how frame coordinates are calculated.
  final Axis axis;

  /// The source image containing all animation frames.
  ///
  /// Must be a fully loaded [Image] instance.
  final Image image;

  /// The direction in which the animation should play.
  final AnimationDirection direction;

  /// Creates an [AnimationSheet] for sprite animations using a sprite sheet image.
  ///
  /// You must specify either [frameWidth] or [columns], and [frameHeight] or [rows].
  /// The constructor will infer the missing value using the image dimensions.
  ///
  /// Example:
  /// ```dart
  /// AnimationSheet(
  ///   image: spriteSheetImage,
  ///   frameWidth: 64,
  ///   frameHeight: 64,
  ///   frameDuration: Duration(milliseconds: 100),
  ///   direction: AnimationDirection.pingPong,
  /// )
  /// ```
  ///
  /// Throws an [AssertionError] if neither [frameHeight] nor [rows] is provided,
  /// or neither [frameWidth] nor [columns].
  AnimationSheet({
    required this.image,
    double? frameHeight,
    double? frameWidth,
    int? rows,
    int? columns,
    this.frameDuration = Durations.short2,
    this.isLooping = true,
    this.axis = Axis.horizontal,
    this.direction = AnimationDirection.forward,
  })  : assert(frameHeight != null || rows != null, 'Either frameHeight or rows must be provided.'),
        assert(frameWidth != null || columns != null, 'Either frameWidth or columns must be provided.'),
        columns = columns ?? (image.width ~/ (frameWidth ?? 1)),
        rows = rows ?? (image.height ~/ (frameHeight ?? 1));

  /// The width of a single frame in the sprite sheet.
  ///
  /// Assumes that the sprite sheet is evenly divided into columns, where each
  /// column represents a single frame.
  double get width => image.width / columns;

  /// The height of a single frame in the sprite sheet.
  ///
  /// Assumes that the sprite sheet is evenly divided into [rows] horizontal strips.
  double get height => image.height / rows;

  /// Total number of frames in the animation.
  ///
  /// It's calculated as the product of the number of columns and rows.
  int get totalFrames => columns * rows;

  /// Whether this animation is considered reversed (reverse or reversePingPong).
  bool get isReversed => direction == AnimationDirection.reverse || direction == AnimationDirection.reversePingPong;
}
