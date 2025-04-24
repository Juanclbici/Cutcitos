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

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = imagePath.startsWith('http');
    final String localPath = imagePath == 'default_profile.jpg'
        ? 'assets/images/default/default_profile.jpg'
        : 'assets/images/user/$imagePath';

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: isNetworkImage
          ? Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) {
          return Image.asset(
            'assets/images/default/default_profile.jpg',
            width: width,
            height: height,
            fit: fit,
          );
        },
      )
          : Image.asset(
        localPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) {
          return Image.asset(
            'assets/images/default/default_profile.jpg',
            width: width,
            height: height,
            fit: fit,
          );
        },
      ),
    );
  }
}
