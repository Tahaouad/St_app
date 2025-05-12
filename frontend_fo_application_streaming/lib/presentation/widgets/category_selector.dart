import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/core/constants/colors.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => onCategorySelected(index),
              style: TextButton.styleFrom(
                backgroundColor:
                    isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.3),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
