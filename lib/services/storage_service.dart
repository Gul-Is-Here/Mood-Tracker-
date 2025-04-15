import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/bill_model.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;
  final String _billsKey = 'saved_bills';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveBill(Bill bill) async {
    try {
      final bills = getBills();
      bills.add(bill);
      await _prefs.setString(_billsKey, jsonEncode(bills.map((b) => b.toMap()).toList()));
    } catch (e) {
      Get.snackbar('Error', 'Failed to save bill: ${e.toString()}');
    }
  }

  List<Bill> getBills() {
    try {
      final data = _prefs.getString(_billsKey);
      if (data == null || data.isEmpty) return [];
      
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => Bill.fromMap(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bills: ${e.toString()}');
      return [];
    }
  }

  Future<void> deleteBill(String id) async {
    try {
      final bills = getBills();
      bills.removeWhere((bill) => bill.id == id);
      await _prefs.setString(_billsKey, jsonEncode(bills.map((b) => b.toMap()).toList()));
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete bill: ${e.toString()}');
    }
  }

  Future<void> clearAllBills() async {
    await _prefs.remove(_billsKey);
  }
}