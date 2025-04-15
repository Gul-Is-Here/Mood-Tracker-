import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/bill_controller.dart';
import '../views/history_view.dart';

class HomeScreen extends StatelessWidget {
  final BillController _controller = Get.put(BillController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Obx(
          () => Text(
            'BILL SPLITR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: _controller.dynamicColor.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'View history', // Accessibility
            onPressed: () => Get.to(() => HistoryView()),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            tooltip: 'Template options', // Accessibility
            onSelected: (value) => _handleTemplateSelection(value, context),
            itemBuilder: (context) => _buildTemplateMenuItems(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildInputCard(),
              const SizedBox(height: 30),
              _buildResultsCard(),
              const SizedBox(height: 30),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // === Widget Building Methods === //

  Widget _buildInputCard() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[50],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(10, 10),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 20,
              offset: Offset(-10, -10),
            ),
          ],
          border: Border.all(
            color: _controller.dynamicColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              _buildInputField(
                "Total Bill (\$)",
                _controller.updateTotalBill,
                Icons.receipt,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                "Tip Percentage (%)",
                _controller.updateTipPercentage,
                Icons.thumb_up,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                "Discount (\$)",
                _controller.updateDiscount,
                Icons.discount,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                "Split Among",
                _controller.updateSplitCount,
                Icons.people,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Obx(
      () => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _controller.dynamicColor.withOpacity(0.7),
                  _controller.dynamicColor.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildResultRow("Tip Amount:", _controller.tipAmount),
                Divider(color: Colors.white.withOpacity(0.5)),
                _buildResultRow(
                  "After Discount:",
                  _controller.discountedAmount,
                ),
                Divider(color: Colors.white.withOpacity(0.5)),
                _buildResultRow("Total + Tip:", _controller.totalWithTip),
                const SizedBox(height: 20),
                _buildEachPaysSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildShareButton(context),
        _buildSaveButton(),
        _buildResetButton(),
      ],
    );
  }

  // === Component Widgets === //

  Widget _buildInputField(
    String label,
    Function(String) onChanged,
    IconData icon,
  ) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      style: TextStyle(color: Colors.grey[800], fontSize: 16),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }

  Widget _buildResultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "\$${value.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEachPaysSection() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Each Pays:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "\$${_controller.perPersonAmount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'share',
      onPressed: () => _shareReceipt(context),
      backgroundColor: Colors.deepPurple,
      tooltip: 'Share receipt', // Accessibility
      child: const Icon(Icons.share, color: Colors.white),
    );
  }

  Widget _buildSaveButton() {
    return FloatingActionButton.extended(
      heroTag: 'save',
      onPressed: _controller.saveBill,
      icon: const Icon(Icons.save, color: Colors.white),
      label: const Text(
        "SAVE",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.deepPurple,
      elevation: 5,
      tooltip: 'Save current bill', // Accessibility
    );
  }

  Widget _buildResetButton() {
    return FloatingActionButton(
      heroTag: 'reset',
      onPressed: _controller.clearCurrentBill,
      backgroundColor: Colors.deepPurple,
      tooltip: 'Reset inputs', // Accessibility
      child: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  // === Helper Methods === //

  List<PopupMenuEntry<String>> _buildTemplateMenuItems() {
    return [
      const PopupMenuItem(
        value: 'save',
        child: Text('Save Current as Template'),
      ),
      const PopupMenuDivider(),
      ..._controller.savedTemplates.asMap().entries.map(
        (entry) => PopupMenuItem(
          value: entry.key.toString(),
          child: Text(entry.value['name']),
        ),
      ),
    ];
  }

  void _handleTemplateSelection(String value, BuildContext context) {
    if (value == 'save') {
      _showSaveTemplateDialog(context);
    } else {
      _controller.applyTemplate(int.parse(value));
    }
  }

  Future<void> _showSaveTemplateDialog(BuildContext context) async {
    final textController = TextEditingController();
    final result = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Save as Template"),
            content: TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: "Template Name",
                hintText: "e.g. Roommates Dinner",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (textController.text.trim().isNotEmpty) {
                    Get.back(result: textController.text);
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );

    if (result != null) {
      _controller.saveCurrentAsTemplate(result);
      Get.snackbar(
        "Template Saved",
        "$result was saved",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.deepPurple,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _shareReceipt(BuildContext context) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        _controller.generateReceiptText(),
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      Get.snackbar(
        "Sharing Error",
        "Could not share receipt: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
