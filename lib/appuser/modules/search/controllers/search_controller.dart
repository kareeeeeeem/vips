import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  // Text Controller
  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  // Observable variables
  var recentSearches =
      <String>['Pizza Hub', 'Burger King', 'McDonald\'s', 'KFC', 'Subway'].obs;

  var popularSearches =
      <String>[
        'Fast Food',
        'Italian Restaurant',
        'Chinese Food',
        'Pizza',
        'Burgers',
        'Sushi',
      ].obs;

  var filteredResults = <String>[].obs;
  var isSearching = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Écouter les changements dans le champ de recherche
    searchTextController.addListener(_onSearchChanged);

    // Auto-focus après l'initialisation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });
  }

  @override
  void onClose() {
    searchTextController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    final query = searchTextController.text.toLowerCase();
    searchQuery.value = query;

    if (query.isEmpty) {
      isSearching.value = false;
      filteredResults.clear();
    } else {
      isSearching.value = true;
      // Simuler des résultats de recherche
      final mockResults = [
        'Pizza Hub Milano',
        'Pizza Palace',
        'Burger Hub',
        'Food Hub Express',
        'Hub Restaurant',
      ];

      filteredResults.value =
          mockResults
              .where((item) => item.toLowerCase().contains(query))
              .toList();
    }
  }

  void removeRecentSearch(int index) {
    recentSearches.removeAt(index);
  }

  void clearAllRecent() {
    recentSearches.clear();
  }

  void addToRecent(String query) {
    // Supprimer si existe déjà
    recentSearches.remove(query);
    // Ajouter au début
    recentSearches.insert(0, query);
    // Limiter à 10 éléments
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }
  }

  void clearSearch() {
    searchTextController.clear();
    searchFocusNode.requestFocus();
  }

  void selectSearch(String searchTerm) {
    searchTextController.text = searchTerm;
    _onSearchChanged();
  }

  void onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      addToRecent(query);
    }
  }

  void openFilter() {
    // Logique pour ouvrir le filtre
    Get.bottomSheet(
      // Votre widget FilterSearch ici
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Text('Filter Search', style: TextStyle(fontSize: 18)),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void goBack() {
    Get.back();
  }

  void selectSearchResult(String result) {
    // Logique pour sélectionner un résultat de recherche
    addToRecent(result);
    // Naviguer vers la page de détails ou effectuer une autre action
    print('Selected: $result');
  }
}
