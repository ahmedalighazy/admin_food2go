import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? sharedPreferences;

  // Initialize SharedPreferences
  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    log('✅ CacheHelper initialized');
  }

  // Save primitive data
  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    try {
      if (value is String) {
        return await sharedPreferences!.setString(key, value);
      } else if (value is int) {
        return await sharedPreferences!.setInt(key, value);
      } else if (value is bool) {
        return await sharedPreferences!.setBool(key, value);
      } else if (value is double) {
        return await sharedPreferences!.setDouble(key, value);
      }
      return false;
    } catch (e) {
      log('❌ Error saving data for key $key: $e');
      return false;
    }
  }

  // Save model as JSON
  static Future<bool> saveModel<T>({
    required String key,
    required T model,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    try {
      final jsonMap = toJson(model);
      final jsonString = jsonEncode(jsonMap);
      return await sharedPreferences!.setString(key, jsonString);
    } catch (e) {
      log('❌ Error saving model for key $key: $e');
      return false;
    }
  }

  // Get primitive data - Returns the actual type
  static dynamic getData({required String key}) {
    try {
      return sharedPreferences!.get(key);
    } catch (e) {
      log('❌ Error getting data for key $key: $e');
      return null;
    }
  }

  // Get String data specifically
  static String? getString({required String key}) {
    try {
      return sharedPreferences!.getString(key);
    } catch (e) {
      log('❌ Error getting string for key $key: $e');
      return null;
    }
  }

  // Get model from JSON
  static T? getModel<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    try {
      final jsonString = sharedPreferences!.getString(key);
      if (jsonString == null) return null;

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      log('❌ Cache deserialization error for key $key: $e');
      sharedPreferences!.remove(key);
      return null;
    }
  }

  // Remove specific data
  static Future<bool> removeData({required String key}) async {
    try {
      return await sharedPreferences!.remove(key);
    } catch (e) {
      log('❌ Error removing data for key $key: $e');
      return false;
    }
  }

  // Clear all data
  static Future<bool> clearAllData() async {
    try {
      return await sharedPreferences!.clear();
    } catch (e) {
      log('❌ Error clearing all data: $e');
      return false;
    }
  }

  // Check if key exists
  static bool containsKey({required String key}) {
    try {
      return sharedPreferences!.containsKey(key);
    } catch (e) {
      log('❌ Error checking key existence for $key: $e');
      return false;
    }
  }
}