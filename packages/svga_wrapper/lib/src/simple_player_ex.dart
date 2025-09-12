import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:svgaplayer_3/svgaplayer_flutter.dart';

class SVGASimpleImageEx extends StatefulWidget {
  final String? resUrl;
  final String? assetsName;
  final Uint8List? buffer;

  const SVGASimpleImageEx({
    super.key,
    this.resUrl,
    this.assetsName,
    this.buffer,
  });

  @override
  State<StatefulWidget> createState() {
    return _SVGASimpleImageExState();
  }
}

class _SVGASimpleImageExState extends State<SVGASimpleImageEx>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    _tryDecodeSvga();
  }

  @override
  void didUpdateWidget(covariant SVGASimpleImageEx oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resUrl != widget.resUrl ||
        oldWidget.assetsName != widget.assetsName) {
      _tryDecodeSvga();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (animationController == null) {
      return Container();
    }
    return SVGAImage(animationController!);
  }

  @override
  void dispose() {
    animationController?.dispose();
    animationController = null;
    super.dispose();
  }

  void _tryDecodeSvga() {
    Future<MovieEntity> decode;
    if (widget.resUrl != null) {
      decode = SVGAParser.shared.decodeFromURL(widget.resUrl!);
    } else if (widget.assetsName != null) {
      decode = SVGAParser.shared.decodeFromAssets(widget.assetsName!);
    } else if (widget.buffer != null) {
      decode = SVGAParser.shared.decodeFromBuffer(widget.buffer!);
    } else {
      return;
    }
    decode.then((videoItem) {
      if (mounted && animationController != null) {
        animationController!
          ..videoItem = videoItem
          ..repeat();
      } else {
        videoItem.dispose();
      }
    }).catchError((e, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        stack: stack,
        library: 'svga library',
        informationCollector: () => [
          if (widget.resUrl != null) StringProperty('resUrl', widget.resUrl),
          if (widget.assetsName != null)
            StringProperty('assetsName', widget.assetsName),
        ],
      ));
    });
  }
}
