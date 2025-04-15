import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../model/bill_model.dart';

class BillController extends GetxController {
  // Reactive variables
  RxDouble totalBill = 0.0.obs;
  RxInt splitCount = 1.obs;
  RxDouble tipPercentage = 15.0.obs;
  RxDouble discount = 0.0.obs;
  RxDouble tax = 0.0.obs;
  RxBool roundUp = false.obs;
  RxList<Bill> billHistory = <Bill>[].obs;
  RxBool showGraph = false.obs;
  final RxList<Map<String, dynamic>> savedTemplates =
      <Map<String, dynamic>>[].obs;

  // Storage keys
  final String _billsKey = 'saved_bills';
  final String _templatesKey = 'saved_templates';

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadBills();
    await _loadTemplates();
  }

  // ================= Storage Methods ================= //

  Future<void> _loadBills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final billsJson = prefs.getString(_billsKey);
      if (billsJson != null && billsJson.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(billsJson);
        billHistory.value = jsonList.map((json) => Bill.fromMap(json)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bills: ${e.toString()}');
    }
  }

  Future<void> _loadTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString(_templatesKey);
      if (templatesJson != null && templatesJson.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(templatesJson);
        savedTemplates.value = List<Map<String, dynamic>>.from(jsonList);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load templates: ${e.toString()}');
    }
  }

  Future<void> _saveBills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _billsKey,
        jsonEncode(billHistory.map((b) => b.toMap()).toList()),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save bills: ${e.toString()}');
    }
  }

  Future<void> _saveTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_templatesKey, jsonEncode(savedTemplates));
    } catch (e) {
      Get.snackbar('Error', 'Failed to save templates: ${e.toString()}');
    }
  }

  // ================= Core Functionality ================= //

  void toggleGraphView() => showGraph.value = !showGraph.value;

  // Calculation getters
  double get taxAmount => (totalBill.value * tax.value) / 100;
  double get subtotal => totalBill.value + taxAmount;
  double get tipAmount => (subtotal * tipPercentage.value) / 100;
  double get discountedAmount =>
      (subtotal - discount.value).clamp(0, double.infinity);
  double get totalWithTip => discountedAmount + tipAmount;
  double get perPersonAmount {
    if (splitCount.value <= 0) return totalWithTip;
    double amount = totalWithTip / splitCount.value;
    return roundUp.value ? amount.ceilToDouble() : amount;
  }

  Color get dynamicColor {
    if (totalWithTip == 0) return Colors.blueAccent;
    final hue = (totalWithTip * 3) % 360;
    return HSLColor.fromAHSL(1, hue, 0.7, 0.6).toColor();
  }

  // ================= Bill Management ================= //

  Future<void> saveBill() async {
    if (totalWithTip <= 0) return;

    final newBill = Bill(
      id: DateTime.now().toIso8601String(),
      total: totalWithTip,
      split: splitCount.value,
      date: DateTime.now(),
      tipPercentage: tipPercentage.value,
      discount: discount.value,
      tax: tax.value,
      roundUp: roundUp.value,
    );

    billHistory.add(newBill);
    await _saveBills();
    Get.snackbar(
      backgroundColor: Colors.deepPurple,
      'Bill Saved',
      'Your bill has been saved successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> deleteBill(String id) async {
    billHistory.removeWhere((bill) => bill.id == id);
    await _saveBills();
  }

  void loadBill(Bill bill) {
    totalBill.value =
        bill.total -
        (bill.total * bill.tipPercentage / 100) +
        bill.discount -
        (bill.total * bill.tax / 100);
    splitCount.value = bill.split;
    tipPercentage.value = bill.tipPercentage;
    discount.value = bill.discount;
    tax.value = bill.tax;
    roundUp.value = bill.roundUp;
  }

  // ================= Template Management ================= //

  Future<void> saveCurrentAsTemplate(String templateName) async {
    savedTemplates.add({
      'name': templateName,
      'total': totalBill.value,
      'tip': tipPercentage.value,
      'split': splitCount.value,
      'tax': tax.value,
      'created': DateTime.now().toIso8601String(),
    });
    await _saveTemplates();
  }

  void applyTemplate(int index) {
    final template = savedTemplates[index];
    totalBill.value = template['total'] ?? 0.0;
    tipPercentage.value = template['tip'] ?? 15.0;
    splitCount.value = template['split'] ?? 1;
    tax.value = template['tax'] ?? 0.0;
  }

  Future<void> deleteTemplate(int index) async {
    savedTemplates.removeAt(index);
    await _saveTemplates();
  }

  // ================= Utility Methods ================= //

  void clearCurrentBill() {
    totalBill.value = 0.0;
    splitCount.value = 1;
    tipPercentage.value = 15.0;
    discount.value = 0.0;
    tax.value = 0.0;
    roundUp.value = false;
  }

  Future<void> resetAll() async {
    clearCurrentBill();
    billHistory.clear();
    savedTemplates.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_billsKey);
    await prefs.remove(_templatesKey);
  }

  String generateReceiptText() {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return '''
    🍽️ Bill Split Receipt
    -------------------
    Subtotal: ${formatter.format(subtotal)}
    Tax (${tax.value}%): ${formatter.format(taxAmount)}
    Tip (${tipPercentage.value}%): ${formatter.format(tipAmount)}
    Discount: ${formatter.format(discount.value)}
    -------------------
    Total: ${formatter.format(totalWithTip)}
    Split: ${splitCount.value} ${splitCount.value > 1 ? 'people' : 'person'}
    -------------------
    Each pays: ${formatter.format(perPersonAmount)}
    ${roundUp.value ? '(Rounded up from ${(totalWithTip / splitCount.value).toStringAsFixed(2)})' : ''}
    '''.trim();
  }

  // ================= Input Handlers ================= //

  void updateTotalBill(String value) {
    final parsed = double.tryParse(value) ?? 0.0;
    totalBill.value = parsed < 0 ? 0.0 : parsed;
  }

  void updateSplitCount(String value) {
    final parsed = int.tryParse(value) ?? 1;
    splitCount.value = parsed < 1 ? 1 : parsed;
  }

  void updateTipPercentage(String value) {
    final parsed = double.tryParse(value) ?? 15.0;
    tipPercentage.value = parsed.clamp(0, 100).toDouble();
  }

  void updateDiscount(String value) {
    final parsed = double.tryParse(value) ?? 0.0;
    discount.value = parsed < 0 ? 0.0 : parsed;
  }

  void updateTax(String value) {
    final parsed = double.tryParse(value) ?? 0.0;
    tax.value = parsed.clamp(0, 100).toDouble();
  }

  void toggleRoundUp(bool value) => roundUp.value = value;
}
