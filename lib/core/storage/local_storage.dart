import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const favoritesBoxName = 'favorites';

  static Future<void> init() async {
    await Hive.openBox<Map>(favoritesBoxName);
  }

  static Box<Map> get favorites => Hive.box<Map>(favoritesBoxName);
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences override missing'),
);
