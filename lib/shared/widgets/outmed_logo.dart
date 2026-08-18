import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_assets.dart';
import 'package:outmed/shared/widgets/app_asset_image.dart';

class OutMedLogo extends StatelessWidget {
  const OutMedLogo({this.height = 44, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return AppAssetImage(
      AppAssets.logo,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
