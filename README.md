# 🕹️ SpriteSheet — Pixel-perfect sprite animation toolkit for Flutter

**SpriteSheet** is a powerful and flexible toolkit for managing sprite-based animations in Flutter. Designed for pixel art, and interactive experiences and simple games. It helps you render animations from sprite sheets with full control over playback, frame progression, hot swapping and more.

## ✨ Features

- 🎞️ Frame-by-frame animation from sprite sheets
- 🔁 Multiple playback modes: forward, reverse, ping-pong, reverse-ping-pong
- ⏱️ Customizable frame duration and looping
- 🌀 Optional glow effects with static or dynamic color support
- 🎨 Flip sprites along X and Y axes
- 🔧 Controller API for play/pause/stop and runtime updates
- ✅ Fully documented and easy to integrate
 
## 🛠️ Usage

1. Define your animation
```dart
final runAnimation = AnimationSheet(
	image: await loadImage('assets/character_run.png'),
	columns: 6,
	rows: 1,
	frameDuration: Duration(milliseconds: 80),
	isLooping: true,
	direction: AnimationDirection.forward,
);
```

2. Initialize the controller
```dart
final controller = SpriteController<MyAnimationType>({
	MyAnimationType.run: runAnimation,
});
```
3. Use it in your widget
```dart
SpriteSheet(
	controller: controller,
	glow: SpriteGlow.color(
		color: Colors.cyanAccent,
		blurX: 10,
		thicknessX: 10,
	),
)
```
## 🎮 Demos

Here are some pixel art demos built using this package:

| 🏃‍♂️ Run Animation | 🔥 Queuing animations | 🌈 Dynamic Glow|
|--|--|--|
> Check out the /example folder for runnable demo code.

## 🔍 Classes Overview
|Class| Description
|--|--
|`SpriteController<T>`|Controls sprite playback, direction, frame updates, and flip states
|`SpriteSheet`|Widget for rendering sprites using a controller and animation sheet
|`AnimationSheet`|Describes a sprite sheet's layout, timing, and playback configuration
|`SpriteGlow`|Adds a glow around the sprite, either static or frame-dependent
|`GlowColorDelegate`|Base class for customizing glow color logic

## 🧠 Why use SpriteSheet?
 - Clean API for animation control
 - Simple and sufficient logic for sprite animation
 - Ideal for pixel-art projects and simple game mechanics
 - Built for extensibility and customization
 - Production-ready and lightweight

## 📄 License

MIT License. Use freely in personal and commercial projects.


## 👨‍💻 Contributions
Got ideas? Found a bug? PRs and issues are welcome!
