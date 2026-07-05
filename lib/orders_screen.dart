import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturnt_app/controllers/orders_controller.dart';
import 'package:resturnt_app/add_order_screen.dart';
import 'package:resturnt_app/home_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // حقن الكنترولر بشكل دائم في الذاكرة
    final OrdersController controller = Get.put(
      OrdersController(),
      permanent: true,
    );

    Color _getStatusColor(String status) {
      switch (status) {
        case 'Preparing':
          return Colors.orange.shade100;
        case 'Ready':
          return Colors.green.shade100;
        case 'Delivered':
          return Colors.blue.shade100;
        case 'Pending':
          return Colors.amber.shade100;
        default:
          return Colors.grey.shade100;
      }
    }

    Color _getStatusTextColor(String status) {
      switch (status) {
        case 'Preparing':
          return Colors.orange.shade800;
        case 'Ready':
          return Colors.green.shade800;
        case 'Delivered':
          return Colors.blue.shade800;
        case 'Pending':
          return Colors.amber.shade900;
        default:
          return Colors.grey.shade800;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.sort, color: Colors.black, size: 28),
          onPressed: () {},
        ),
        title: const Center(
          child: Text(
            'Orders',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // --- شريط الفئات التفاعلي (تم إزالة الـ Obx المسبب للشاشة الحمراء هان) ---
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    // نستخدم الـ Obx فقط على النص والخلفية اللي بتتغير قيمتهم داخل الـ Item نفسه
                    return Obx(() {
                      bool isSelected =
                          controller.selectedCategoryIndex.value == index;
                      return GestureDetector(
                        onTap: () => controller.changeCategory(index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xff0F964A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Text(
                            controller.categories[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // --- قائمة الطلبات المحمية تماماً ---
              Obx(() {
                if (controller.allOrders.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text('No orders found')),
                  );
                }

                var filteredOrders = controller.allOrders.where((order) {
                  if (controller.selectedCategoryIndex.value == 0) return true;
                  return order['status'] ==
                      controller.categories[controller
                          .selectedCategoryIndex
                          .value];
                }).toList();

                if (filteredOrders.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text('No orders found in this category'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order['table'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        order['items'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      order['status'] ?? 'Pending',
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order['status'] ?? 'Pending',
                                    style: TextStyle(
                                      color: _getStatusTextColor(
                                        order['status'] ?? 'Pending',
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      order['price'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      order['time'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () {},
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(width: 14),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          controller.allOrders.remove(order),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: (index) {
          if (index == 2) {
            Get.to(() => const AddOrderScreen());
          } else {
            controller.changePage(index);
            if (index == 0) Get.offAll(() => const HomeScreen());
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff0F964A),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xff0F964A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
