import 'package:flutter/material.dart';

class UserImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const UserImage({
    super.key,
    required this.imagePath,
    this.width = 100,
    this.height = 100,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  bool _isNetworkImage(String path) => path.startsWith('http');
  bool _isAssetPath(String path) => path.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = _isNetworkImage(imagePath);
    final String resolvedPath = isNetwork
        ? imagePath
        : (_isAssetPath(imagePath)
        ? imagePath
        : 'assets/images/user/$imagePath');

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: isNetwork
          ? Image.network(
        resolvedPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) {
          return _defaultImage();
        },
      )
          : Image.asset(
        resolvedPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) {
          return _defaultImage();
        },
      ),
    );
  }

  Widget _defaultImage() {
    return Image.asset(
      'assets/images/default/default_profile.jpg',
      width: width,
      height: height,
      fit: fit,
    );
  }
}
