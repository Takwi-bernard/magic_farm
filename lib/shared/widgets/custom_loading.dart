import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class CustomLoading extends StatelessWidget {
  final String message;

  const CustomLoading({
    super.key,
    this.message = "Please wait...",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          Text(message),
        ],
      ),
    );
  }
}