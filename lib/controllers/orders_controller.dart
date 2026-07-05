import 'package:get/get.dart';

class OrdersController extends GetxController {
  var currentIndex = 1.obs;
  var selectedCategoryIndex = 0.obs;

  final List<String> categories = [
    'All',
    'Pending',
    'Preparing',
    'Ready',
    'Delivered',
  ];

  var allOrders = <Map<String, String>>[
    {
      'table': 'Table 5',
      'items': 'Pizza x2, Cola x1',
      'status': 'Preparing',
      'price': '\$40',
      'time': '12 May 2026 • 10:30 AM',
    },
  ].obs;

  var selectedStatus = 'Pending'.obs;

  var currentOrderItems = <Map<String, dynamic>>[
    {'name': 'Pizza', 'quantity': 2, 'price': 15.0},
    {'name': 'Cola', 'quantity': 1, 'price': 5.0},
  ].obs;

  double get totalPrice {
    double total = 0.0;
    for (var item in currentOrderItems) {
      total += (item['price'] * item['quantity']);
    }
    return total;
  }

  void incrementItem(int index) {
    var item = currentOrderItems[index];
    item['quantity']++;
    currentOrderItems[index] = item;
  }

  // تقليل الكمية (-)
  void decrementItem(int index) {
    var item = currentOrderItems[index];
    if (item['quantity'] > 1) {
      item['quantity']--;
      currentOrderItems[index] = item;
    }
  }

  void removeItem(int index) {
    currentOrderItems.removeAt(index);
  }

  void addNewItemPlaceholder() {
    currentOrderItems.add({'name': 'New Item', 'quantity': 1, 'price': 10.0});
  }

  void saveFinalOrder(String tableNumber, String customerName) {
    if (tableNumber.isEmpty || currentOrderItems.isEmpty) return;

    String itemsSummary = currentOrderItems
        .map((item) => "${item['name']} x${item['quantity']}")
        .join(', ');

    allOrders.insert(0, {
      'table': 'Table $tableNumber',
      'items': itemsSummary,
      'status': selectedStatus.value,
      'price': '\$${totalPrice.toStringAsFixed(0)}',
      'time': 'Just now',
    });

    currentOrderItems.value = [
      {'name': 'Pizza', 'quantity': 2, 'price': 15.0},
      {'name': 'Cola', 'quantity': 1, 'price': 5.0},
    ];
  }

  void changeCategory(int index) => selectedCategoryIndex.value = index;
  void changePage(int index) => currentIndex.value = index;
}
