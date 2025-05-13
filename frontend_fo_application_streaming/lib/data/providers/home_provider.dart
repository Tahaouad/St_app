import 'package:flutter/material.dart';
import 'package:frontend_fo_application_streaming/presentation/widgets/custom_drawer.dart';

class HomeProvider extends ChangeNotifier {
  int _selectedCategoryIndex = 0;
  bool _isAppBarExpanded = true;

  int get selectedCategoryIndex => _selectedCategoryIndex;
  bool get isAppBarExpanded => _isAppBarExpanded;

  void setSelectedCategory(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  void setAppBarExpanded(bool expanded) {
    _isAppBarExpanded = expanded;
    notifyListeners();
  }

  // Category names
  static const List<String> categories = [
    'Pour vous',
    'Films',
    'Séries',
    'Populaire',
  ];
}
