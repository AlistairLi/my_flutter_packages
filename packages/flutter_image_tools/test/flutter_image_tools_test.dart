import 'package:flutter_image_tools/flutter_image_tools.dart';
import 'package:test/test.dart';

void main() {
  group('图像处理工具测试', () {
    test('智能压缩器测试', () {
      final compressor = SmartCompressor();
      expect(compressor, isNotNull);
    });

    test('批量处理器测试', () {
      final batchProcessor = BatchProcessor();
      expect(batchProcessor, isNotNull);
    });

    test('压缩选项测试', () {
      final options = CompressionOptions(
        targetSize: FileSize.compressThreshold,
        quality: 80,
        format: 'jpeg',
      );
      expect(options.targetSize, equals(FileSize.compressThreshold));
      expect(options.quality, equals(80));
      expect(options.format, equals('jpeg'));
    });

    test('缩放选项测试', () {
      final options = ResizeOptions(
        targetWidth: 800,
        targetHeight: 600,
        maintainAspectRatio: true,
        fitMode: 'contain',
      );
      expect(options.targetWidth, equals(800));
      expect(options.targetHeight, equals(600));
      expect(options.maintainAspectRatio, isTrue);
    });

    test('文件大小常量测试', () {
      // 基础单位测试
      expect(FileSize.oneKB, equals(1024));
      expect(FileSize.oneMB, equals(1024 * 1024));
      expect(FileSize.oneGB, equals(1024 * 1024 * 1024));

      // 常用大小测试
      expect(FileSize.smallImage, equals(100 * 1024));
      expect(FileSize.mediumImage, equals(500 * 1024));
      expect(FileSize.largeImage, equals(1 * 1024 * 1024));
      expect(FileSize.extraLargeImage, equals(5 * 1024 * 1024));
      expect(FileSize.hugeImage, equals(10 * 1024 * 1024));

      // 压缩阈值测试
      expect(FileSize.compressThreshold, equals(1 * 1024 * 1024));
      expect(FileSize.maxUploadSize, equals(10 * 1024 * 1024));
      expect(FileSize.avatarSize, equals(200 * 1024));
      expect(FileSize.thumbnailSize, equals(50 * 1024));

      // 格式转换阈值测试
      expect(FileSize.webpThreshold, equals(500 * 1024));
      expect(FileSize.pngThreshold, equals(2 * 1024 * 1024));
    });

    test('头像压缩选项测试', () {
      final avatarOptions = CompressionOptions(
        targetSize: FileSize.avatarSize,
        quality: 80,
        format: 'jpeg',
      );
      expect(avatarOptions.targetSize, equals(FileSize.avatarSize));
      expect(avatarOptions.quality, equals(80));
    });

    test('缩略图压缩选项测试', () {
      final thumbnailOptions = CompressionOptions(
        targetSize: FileSize.thumbnailSize,
        quality: 70,
        format: 'jpeg',
      );
      expect(thumbnailOptions.targetSize, equals(FileSize.thumbnailSize));
      expect(thumbnailOptions.quality, equals(70));
    });
  });
}
