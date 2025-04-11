import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';

class AvatarStack extends StatelessWidget {
  final int count;
  final Color backgroundColor;
  final double size;
  final double spacing;

  const AvatarStack({
    Key? key,
    required this.count,
    this.backgroundColor = AppTheme.primaryColor,
    this.size = 32,
    this.spacing = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Padding(
          padding: EdgeInsets.only(right: index == count - 1 ? 0 : spacing),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: backgroundColor,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: size / 2,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
