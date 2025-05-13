import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/category_selector.dart';

class ContentCategoryTab extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  const ContentCategoryTab({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: CategorySelector(
        categories: categories,
        selectedIndex: selectedIndex,
        onCategorySelected: onCategorySelected,
      ),
    );
  }
}
