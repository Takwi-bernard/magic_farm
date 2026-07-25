import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {

  final String title;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return ChoiceChip(

      label: Text(title),

      selected: selected,

      onSelected: (_) => onTap(),

      selectedColor: AppColors.primary,

    );

  }
}