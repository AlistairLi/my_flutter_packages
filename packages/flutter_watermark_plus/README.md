# Flutter Watermark Plus

A Flutter package that provides watermark functionality for images and widgets with customizable properties.

## Features

- **Cross-platform support**: Works on both Android and iOS
- **Widget-based watermarks**: Add watermarks to any Flutter widget
- **Image-based watermarks**: Apply watermarks directly to images
- **Customizable properties**: Text style, rotation, opacity, positioning, and spacing
- **Consistent behavior**: Shared drawing logic ensures consistent results across different use cases

## Architecture

The package has been refactored to eliminate code duplication and improve maintainability:

### Core Components

- **`Config`**: Configuration class for watermark properties
- **`TextWatermarkWidget`**: Widget for adding watermarks to Flutter widgets
- **`CanvasWatermarkEngine`**: Engine for applying watermarks to images
- **`WatermarkPainterUtil`**: Shared utility for drawing watermark patterns
- **`WatermarkProcessor`**: High-level processor for image watermark operations

### Code Refactoring Benefits

1. **Eliminated Duplication**: The watermark drawing logic was duplicated between `watermark_widget.dart` and `canvas_watermark_engine.dart`. Now both use the shared `WatermarkPainterUtil`.

2. **Consistent Behavior**: Both widget-based and image-based watermarks now use the same drawing logic, ensuring consistent results.

3. **Better Maintainability**: Changes to watermark drawing logic only need to be made in one place.

4. **Clear Separation**: Each component has a single responsibility:
   - `Config`: Configuration management
   - `TextWatermarkWidget`: Widget rendering
   - `CanvasWatermarkEngine`: Image processing
   - `WatermarkPainterUtil`: Drawing logic
   - `WatermarkProcessor`: High-level operations

## Configuration Options

- **`textStyle`**: Text appearance (color, font size, weight, etc.)
- **`rotationAngle`**: Rotation in radians
- **`horizontalInterval`**: Horizontal spacing between watermarks
- **`verticalInterval`**: Vertical spacing between watermarks
- **`offset`**: Position offset from top-left corner
- **`backgroundColor`**: Background color of watermark area
- **`textAlign`**: Text alignment
- **`textDirection`**: Text direction (LTR/RTL)
- **`locale`**: Locale for text rendering

## Examples

See the `example/` folder for complete demonstrations:
- `flutter_watermark_plus_example.dart`: Widget-based watermark examples
- `watermark_processor_example.dart`: Image processing watermark examples
