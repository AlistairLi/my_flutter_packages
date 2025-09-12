# svga_wrapper

A wrapper based on svgaplayer_3 that extends SVGASimpleImage with memory buffer support for SVGA animations.

## Getting started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  svga_wrapper: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:svga_wrapper/svga_wrapper.dart';

// From assets
SVGASimpleImageEx
(
assetsName: 'assets/animations/example.svga',
)

// From network URL
SVGASimpleImageEx(
resUrl: 'https://example.com/animation.svga',
)

// From memory buffer
SVGASimpleImageEx(
buffer: uint8ListData,
)
```

## Dependencies

This package depends on:

- `svgaplayer_3`: The underlying SVGA player implementation

## License

This project is licensed under the MIT License - see the LICENSE file for details.
