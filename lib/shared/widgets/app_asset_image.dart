import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:outmed/core/constants/app_colors.dart';

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
    if (asset.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const FittedBox(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.medical_services_outlined,
              color: AppColors.muted,
            ),
          ),
        ),
      );
    }
    if (asset.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: asset,
        width: width,
        height: height,
        fit: fit,
        errorWidget: (context, url, error) =>
            Icon(Icons.image_not_supported_outlined, size: height),
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
