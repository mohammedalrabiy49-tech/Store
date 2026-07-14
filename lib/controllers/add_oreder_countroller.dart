import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddOrderController extends GetxController {
  final tableController = TextEditingController();
  final nameController = TextEditingController();

  var selectedStatus = 'Pending'.obs;

  var items = <Map<String, dynamic>>[
    {'name': 'Pizza', 'quantity': 2, 'price': 15.0},
    {'name': 'Cola', 'quantity': 1, 'price': 5.0},
  ].obs;

  double get totalPrice {
    double total = 0.0;
    for (var item in items) {
      total += (item['quantity'] as int) * (item['price'] as double);
    }
    return total;
  }

  void incrementQuantity(int index) {
    items[index]['quantity']++;
    items.refresh();
  }

  void decrementQuantity(int index) {
    if (items[index]['quantity'] > 1) {
      items[index]['quantity']--;
      items.refresh();
    }
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  void addNewItem() {
    items.add({'name': 'New Item', 'quantity': 1, 'price': 10.0});
  }

  Future<void> saveOrder() async {
    if (tableController.text.isEmpty) {
      Get.snackbar(
        'Error',
        '  Please enter the table number  ',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      Map<String, dynamic> orderData = {
        'tableNumber': tableController.text,
        'customerName': nameController.text.isEmpty
            ? 'Guest'
            : nameController.text,
        'items': items.toList(),
        'status': selectedStatus.value,
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      Get.back();
      Get.snackbar(
        'The order has been saved successfully',
        '!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save the request : $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    tableController.dispose();
    nameController.dispose();
    super.onClose();
  }
}
