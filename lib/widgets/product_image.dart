import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Color placeholderColor;
  final IconData placeholderIcon;

  const ProductImage({
    super.key,
    required this.imagePath,
    this.width = 100,
    this.height = 100,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholderColor = Colors.grey,
    this.placeholderIcon = Icons.shopping_bag,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    try {
      // Verifica si es una imagen de red o local
      if (imagePath.startsWith('http')) {
        return Image.network(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } else {
        return Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      }
    } catch (e) {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: placeholderColor.withOpacity(0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Icon(
        placeholderIcon,
        size: width * 0.4,
        color: placeholderColor.withOpacity(0.6),
      ),
    );
  }
}