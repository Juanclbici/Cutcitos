import 'package:flutter/material.dart';

class UserCover extends StatelessWidget {
  final String? imagePath;
  final double height;

  const UserCover({
    super.key,
    this.imagePath,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imagePath != null
                ? AssetImage('assets/images/user/$imagePath')
                : const AssetImage('assets/images/default/default_cover.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
