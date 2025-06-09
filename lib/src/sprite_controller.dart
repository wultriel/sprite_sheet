import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sprite_sheet/sprite_sheet.dart';

/// A controller that manages sprite animations from a sprite sheet.
///
/// The [SpriteController] is responsible for managing frame updates,
/// playback state (play, pause, stop), animation direction, looping,
/// and flip transformations. It drives the visual behavior of [SpriteSheet].
///
/// You can use any enum or object as a key to identify individual animations.
///
/// ### Example
/// ```dart
/// final controller = SpriteController<MyAnimationState>({
///   MyAnimationState.idle: AnimationSheet(...),
///   MyAnimationState.run: AnimationSheet(...),
/// });
///
/// controller.play(animation: MyAnimationState.run);
/// controller.isFlippedX = true;
/// ```
///
/// See also:
/// - [SpriteSheet], which renders the current frame.
/// - [AnimationSheet], which defines the layout and timing of a sprite sheet.
/// - [AnimationDirection], for supported playback modes.
class SpriteController<T> extends ChangeNotifier {
  /// The map of available animations keyed by an identifier [T].
  ///
  /// Each animation must be an instance of [AnimationSheet] that defines its grid,
  /// playback speed, and looping behavior.
  ///
  /// This map must not be empty.
  final Map<T, AnimationSheet> animations;

  Timer? _ticker;
  Offset _currentFrame = Offset.zero;
  T? _currentAnimation;

  bool _isPlaying = false;
  bool _isFlippedX = false;
  bool _isFlippedY = false;

  bool _isReversing = false;

  final Queue<T> _queue = Queue<T>();

  /// Creates a [SpriteController] with the provided [animations].
  /// The [animations] map should contain the animations keyed by their type [T].
  /// Each animation should be an instance of [AnimationSheet].
  ///
  /// The [T] type parameter allows for flexibility in the type of animations used.
  /// Example:
  /// ```dart
  /// final controller = SpriteController<MyAnimationType>({
  ///   MyAnimationType.walk: AnimationSheet(...),
  ///   MyAnimationType.run: AnimationSheet(...),
  /// });
  /// ```
  ///
  /// Throws an assertion error if the map is empty.
  SpriteController(this.animations)
      : assert(animations.isNotEmpty, 'Animations map cannot be empty.');

  /// The animation key currently playing.
  T? get currentAnimation => _currentAnimation;

  /// Returns the current frame of the animation as an [Offset].
  ///
  /// The [dx] value is the column (X), and [dy] is the row (Y).
  Offset get offsetFrame => _currentFrame;

  int get frame {
    return (_currentFrame.dx +
            _currentFrame.dy * ((currentAnimationSheet?.columns ?? 1)))
        .toInt();
  }

  /// Whether the animation is actively playing.
  bool get isPlaying => _isPlaying;

  /// Whether the sprite is flipped horizontally.
  bool get isFlippedX => _isFlippedX;

  /// Whether the sprite is flipped vertically.
  bool get isFlippedY => _isFlippedY;

  /// Updates the horizontal flip state of the sprite.
  set isFlippedX(bool value) {
    if (_isFlippedX != value) {
      _isFlippedX = value;
      notifyListeners();
    }
  }

  /// Updates the vertical flip state of the sprite.
  set isFlippedY(bool value) {
    if (_isFlippedY != value) {
      _isFlippedY = value;
      notifyListeners();
    }
  }

  /// The animation sheet for the currently active animation.
  AnimationSheet? get currentAnimationSheet {
    if (_currentAnimation == null) return null;
    return animations[_currentAnimation];
  }

  /// Starts playing the specified [animation], or resumes the current one if not provided.
  ///
  /// If the animation has reverse or ping-pong direction, the controller handles it accordingly.
  /// Automatically resets the frame to the start of the animation unless the same animation is resumed or looped.
  void play({T? animation}) {
    /// Set current animation sheet to play if new animation is provided
    /// and it exists in the animations map.
    if (animation != null &&
        _currentAnimation != animation &&
        animations.containsKey(animation)) {
      _currentAnimation = animation;
      _currentFrame = Offset.zero;
    }
    final currentAnimationSheet = this.currentAnimationSheet;

    /// If no animation is set, return early.
    if (currentAnimationSheet == null) {
      assert(currentAnimationSheet == null, 'No animation is set to play.');
      return;
    }

    /// Stop any existing ticker before starting a new one.
    if (_ticker?.isActive ?? false) {
      _ticker?.cancel();
    }

    /// Start a new ticker with the frame duration of the current animation sheet.
    _ticker = Timer.periodic(
      currentAnimationSheet.frameDuration,
      _updateAnimation,
    );

    if (currentAnimationSheet.direction == AnimationDirection.reverse ||
        currentAnimationSheet.direction == AnimationDirection.reversePingPong) {
      _isReversing = true;
      _currentFrame = Offset(
        currentAnimationSheet.columns - 1,
        currentAnimationSheet.rows - 1,
      );
    } else {
      _isReversing = false;
    }

    _isPlaying = true;
    notifyListeners();
  }

  /// Pauses the current animation at the current frame.
  void pause() {
    _isPlaying = false;
    _ticker?.cancel();
    notifyListeners();
  }

  /// Stops the animation and resets the frame to the beginning.
  void stop() {
    _isPlaying = false;
    _currentFrame = currentAnimationSheet?.isReversed == true
        ? Offset((currentAnimationSheet?.columns ?? 1) - 1,
            (currentAnimationSheet?.rows ?? 1) - 1)
        : Offset.zero;
    _ticker?.cancel();
    _ticker = null;

    notifyListeners();
  }

  void addToQueue(T animation) {
    _queue.add(animation);
  }

  void seek(Offset frameOffset) {
    final columns = currentAnimationSheet?.columns ?? 1;
    final rows = currentAnimationSheet?.rows ?? 1;

    var dx = frameOffset.dx % columns;
    var dy = frameOffset.dy % rows;

    _currentFrame = Offset(dx, dy);
  }

  void seekFrame(int index) {
    final columns = currentAnimationSheet?.columns ?? 1;

    final dx = index % columns;
    final dy = index ~/ columns;

    _currentFrame = Offset(dx.toDouble(), dy.toDouble());
  }

  /// Called internally by a timer to update the animation frame.
  ///
  /// Depending on the animation direction, it will increment, decrement,
  /// or ping-pong between frames. Looped animations repeat automatically.
  void _updateAnimation(Timer timer) {
    if (!isPlaying || currentAnimationSheet == null) {
      timer.cancel();
      return;
    }

    final columns = currentAnimationSheet!.columns;
    final rows = currentAnimationSheet!.rows;

    switch (currentAnimationSheet!.direction) {
      case AnimationDirection.forward:
        _incrementFrame(columns, rows);
        break;
      case AnimationDirection.reverse:
        _decrementFrame(columns, rows);
        break;
      case AnimationDirection.pingPong:
        _pingPongFrame(columns, rows);
        break;
      case AnimationDirection.reversePingPong:
        _reversePingPongFrame(columns, rows);
        break;
    }

    notifyListeners();
  }

  void _incrementFrame(int columns, int rows, {bool checkQueue = true}) {
    _currentFrame = Offset(
      (_currentFrame.dx + 1) % columns,
      _currentFrame.dy,
    );

    if (_currentFrame.dx == 0) {
      _currentFrame = Offset(0, _currentFrame.dy + 1);
    }

    if (_currentFrame.dy >= rows) {
      if (checkQueue && _checkNextInQueue()) {
        return;
      }
      if (currentAnimationSheet!.isLooping) {
        _currentFrame = Offset.zero;
      } else {
        stop();
      }
    }
  }

  void _decrementFrame(int columns, int rows, {bool checkQueue = true}) {
    if (_currentFrame.dx == 0 && _currentFrame.dy == 0) {
      if (checkQueue && _checkNextInQueue()) {
        return;
      }
      if (currentAnimationSheet!.isLooping) {
        _currentFrame = Offset(columns - 1, rows - 1);
      } else {
        stop();
        return;
      }
    } else {
      _currentFrame = Offset(
        (_currentFrame.dx - 1 + columns) % columns,
        _currentFrame.dy,
      );

      if (_currentFrame.dx == columns - 1) {
        _currentFrame = Offset(columns - 1, _currentFrame.dy - 1);
      }
    }
  }

  void _pingPongFrame(int columns, int rows) {
    if (_isReversing) {
      _decrementFrame(columns, rows, checkQueue: false);
      if (_currentFrame.dx == 0 && _currentFrame.dy == 0) {
        _isReversing = false;
        if (_checkNextInQueue()) {
          return;
        }
      }
    } else {
      _incrementFrame(columns, rows, checkQueue: false);
      if (_currentFrame.dx == columns - 1 && _currentFrame.dy == rows - 1) {
        _isReversing = true;
      }
    }
  }

  void _reversePingPongFrame(int columns, int rows) {
    if (_isReversing) {
      _incrementFrame(columns, rows, checkQueue: false);
      if (_currentFrame.dx == columns - 1 && _currentFrame.dy == rows - 1) {
        _isReversing = false;
        if (_checkNextInQueue()) {
          return;
        }
      }
    } else {
      _decrementFrame(columns, rows, checkQueue: false);
      if (_currentFrame.dx == 0 && _currentFrame.dy == 0) {
        _isReversing = true;
      }
    }
  }

  bool _checkNextInQueue() {
    if (_queue.isNotEmpty) {
      final next = _queue.removeFirst();
      play(animation: next);
      return true;
    }

    return false;
  }
}
