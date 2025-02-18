import 'package:shared_preferences/shared_preferences.dart';

class ExampleStorage {
  // Stocker les données
  Future<void> storeData(int tapCount, int cuddlesPerClick, int upgradePrice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tapCount', tapCount);
    await prefs.setInt('cuddlesPerClick', cuddlesPerClick);
    await prefs.setInt('upgradePrice', upgradePrice);
  }

  // Charger les données
  Future<Map<String, int>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'tapCount': prefs.getInt('tapCount') ?? 0,
      'cuddlesPerClick': prefs.getInt('cuddlesPerClick') ?? 1,
      'upgradePrice': prefs.getInt('upgradePrice') ?? 10,
    };
  }

  // Réinitialiser les données
  Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tapCount', 0);
    await prefs.setInt('cuddlesPerClick', 1);
    await prefs.setInt('upgradePrice', 10);
  }
}