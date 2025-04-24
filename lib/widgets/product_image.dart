import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imagePath,
    this.width = 100,
    this.height = 100,
    this.borderRadius,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imagePath.startsWith('http');
    final isDefault = imagePath.contains('default_product.png');
    final String localPath = 'assets/images/default/default_product.png';

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: isNetworkImage
          ? Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.asset(
          localPath,
          width: width,
          height: height,
          fit: fit,
        ),
      )
          : Image.asset(
        isDefault ? localPath : 'assets/images/products/$imagePath',
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.asset(
          localPath,
          width: width,
          height: height,
          fit: fit,
        ),
      ),
    );
  }
}
