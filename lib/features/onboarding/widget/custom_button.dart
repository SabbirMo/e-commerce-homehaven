import 'package:flutter/material.dart';
import 'package:home_haven/core/assets/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.width,
    this.height,
    required this.onTap,
  });

  final String text;
  final double? width;
  final double? height;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? size.width,
        height: height ?? size.height*.07,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.liner,
              AppColors.gradient,
            ],
          ),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.neutral10,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
