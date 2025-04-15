import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bill_controller.dart';

class TipSlider extends StatelessWidget {
  final BillController controller;
  TipSlider({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      children: [
        Text("Tip: ${controller.tipPercentage.value}%"),
        Slider(
          value: controller.tipPercentage.value,
          min: 0,
          max: 30,
          divisions: 6,
          onChanged: (val) => controller.tipPercentage.value = val,
        ),
      ],
    ));
  }
}