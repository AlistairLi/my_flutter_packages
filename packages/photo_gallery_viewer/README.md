# Photo Gallery Viewer

A powerful and customizable Flutter package for displaying photo galleries with support for carousel sliding, zooming, and various indicator styles. Perfect for image viewers, banners, and photo browsing experiences.

## Features

- 🖼️ **Multi-image Support**: Display multiple images with smooth carousel sliding
- 🔍 **Zoom & Pan**: Support for image zooming and panning gestures
- 📱 **Flexible Layout**: Customizable width, height, and fit options
- 🎯 **Multiple Indicators**: Dots and number indicators with customizable styles
- 🔄 **Infinite Scroll**: Optional infinite scrolling for seamless browsing
- 🎨 **Customizable Styling**: Custom borders, indicators, and placeholder widgets
- 📱 **Responsive Design**: Works on both mobile and web platforms
- �� **High Performance**: Optimized for smooth scrolling and image loading

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  photo_gallery_viewer: ^1.0.0
```

## Usages

### Banner View
```dart
class BannerViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PhotoGalleryViewer<String>(
      dataList: bannerImages,
      imageUrlBuilder: (item) => item,
      height: 200,
      fit: BoxFit.cover,
      scale: 1.0,
      indicatorType: IndicatorType.dots,
      borderRadius: BorderRadius.circular(12),
      infiniteScroll: true,
    );
  }
}
```

### Full Page Gallery
```dart
class GalleryViewPageExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: PhotoGalleryViewer<String>(
        dataList: galleryImages,
        imageUrlBuilder: (item) => item,
        initialIndex: 0,
        enableZoom: true,
        isPage: true,
        indicatorType: IndicatorType.number,
        indicatorAlignment: Alignment.topCenter,
      ),
    );
  }
}
```

## Dependencies

This package depends on:
- `photo_view: ^0.15.0` - For image viewing and zooming
- `carousel_slider: ^5.1.1` - For carousel functionality
- `dots_indicator: ^4.0.1` - For page indicators

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.