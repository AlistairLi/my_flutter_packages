# inapp_purchase_wrapper

A comprehensive wrapper for Flutter's in_app_purchase plugin that simplifies cross-platform (
Android/iOS) in-app purchases with unified APIs for product purchasing, verification, and order
management.

## Features

- Cross-platform Support: Unified API for both Android and iOS in-app purchases
- Automatic Platform Detection: Handles Google Play and App Store automatically
- Simple Purchase Flow: Easy product purchasing with startPurchase method
- Purchase Verification: Built-in purchase validation and verification
- Order Management: Local storage and management of order data
- Purchase Restoration: Support for restoring previous purchases
- Event Listeners: Complete payment callback handling (pending, success, canceled, error)
- Custom Logging: Configurable logging for purchase events
- Error Handling: Comprehensive error management and reporting

## Installation

Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  inapp_purchase_wrapper: ^1.0.2
```

Then run:

``` bash
flutter pub get
```

## Usage

Please check the example.

## License

The project is under the MIT license.