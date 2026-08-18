import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssetImage extends StatelessWidget {
  const AppAssetImage(
    this.asset, {
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.bytes,
    super.key,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    if (bytes != null) {
      return Image.memory(
        bytes!,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
      );
    }
    if (asset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(asset, width: width, height: height, fit: fit);
    }
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }
}
