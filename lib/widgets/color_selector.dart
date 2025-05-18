import 'package:calendar_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final List<Map<String, String>> colorOptions;
  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  const ColorSelector({
    super.key,
    required this.colorOptions,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colorOptions.map((color) {
        final isSelected = selectedColor == color['value'];
        return GestureDetector(
          onTap: () => onColorSelected(color['value']!),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(int.parse(color['value']!.substring(1), radix: 16) +
                  0xFF000000),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppTheme.backgroundColor, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(int.parse(color['value']!.substring(1),
                                    radix: 16) +
                                0xFF000000)
                            .withValues(alpha: 0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
          ),
        );
      }).toList(),
    );
  }
}
