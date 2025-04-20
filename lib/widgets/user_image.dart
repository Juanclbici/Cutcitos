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
    final String finalPath = imagePath == 'default_profile.jpg'
        ? 'assets/images/default/default_profile.jpg'
        : 'assets/images/user/$imagePath';

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: Image.asset(
        finalPath,
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
