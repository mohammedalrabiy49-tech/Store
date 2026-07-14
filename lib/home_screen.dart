import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'controllers/auth_controller.dart';
import 'add_order_screen.dart';

class OrderDetailsController extends GetxController {
  final String orderId;

  final tableController = TextEditingController();
  final nameController = TextEditingController();
  var selectedStatus = 'Pending'.obs;
  var itemsList = <Map<String, dynamic>>[].obs;

  OrderDetailsController({required this.orderId});

  double get totalPrice {
    double total = 0.0;
    for (var item in itemsList) {
      total += (item['quantity'] as int) * (item['price'] as double);
    }
    return total;
  }

  void prepareEditData(Map<String, dynamic> currentData) {
    tableController.text = (currentData['tableNumber'] ?? '')
        .toString()
        .replaceAll('Table ', '');
    nameController.text = currentData['customerName'] == 'Guest'
        ? ''
        : (currentData['customerName'] ?? '');
    selectedStatus.value = currentData['status'] ?? 'Pending';

    itemsList.value = [
      {'name': 'Pizza', 'quantity': 2, 'price': 15.0},
      {'name': 'Cola', 'quantity': 1, 'price': 5.0},
    ];
  }

  Future<void> updateStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': newStatus},
      );
      selectedStatus.value = newStatus;
      Get.snackbar(
        ' Success ',
        '  Order Status updated  $newStatus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error ',
        'Failed to update status  : $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
    }
  }

  Future<void> updateFullOrder(VoidCallback onUpdateSuccess) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {
          'tableNumber': 'Table ' + tableController.text,
          'customerName': nameController.text.isEmpty
              ? 'Guest'
              : nameController.text,
          'items': itemsList
              .map((item) => "${item['name']} x${item['quantity']}")
              .toList(), // حفظها كـ List لتناسب قاعدة بياناتك
          'totalPrice': '\$' + totalPrice.toStringAsFixed(0),
          'status': selectedStatus.value,
        },
      );
      onUpdateSuccess();
      Get.snackbar(
        'Sucssefuly',
        'The order data has been successfully updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Update failed : $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
    }
  }

  Future<void> deleteOrder(VoidCallback onDeleteSuccess) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();
      onDeleteSuccess();
      Get.snackbar(
        'Deleted ',
        ' Deletion successful   ',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        '  Failed to delete the Order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _ordersSubView = 'list';
  String _activeOrderId = '';
  Map<String, dynamic> _activeOrderData = {};

  String _parseItems(dynamic itemsData) {
    if (itemsData == null) return '';
    if (itemsData is String) return itemsData;
    if (itemsData is List) {
      return itemsData.join(', ');
    }
    return itemsData.toString();
  }

  String _parsePrice(dynamic priceData) {
    if (priceData == null) return '\$0';
    return priceData.toString();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController _authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    Widget getBodyWidget() {
      switch (_currentIndex) {
        case 0:
          return _buildDashboard(context, _authController);
        case 1:
          return _buildOrdersTabNavigator();
        case 3:
          return _buildProfileView(_authController);
        default:
          return _buildDashboard(context, _authController);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: (_currentIndex == 0)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.sort, color: Colors.black, size: 30),
                onPressed: () {},
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  tooltip: 'Logout',
                  onPressed: () => _authController.signOut(),
                ),
              ],
            )
          : null,
      body: getBodyWidget(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Get.to(() => const AddOrderScreen());
          } else {
            setState(() {
              _currentIndex = index;
              if (index == 1) {
                _ordersSubView = 'list';
              }
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff0F964A),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40, color: Color(0xff0F964A)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, AuthController auth) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Good Morning,',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 5),
              const Text(' Mohammed👋', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 25),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snapshot) {
              int orderCount = snapshot.hasData
                  ? snapshot.data!.docs.length
                  : 0;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 2,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.mail_outline,
                        color: Colors.orange,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Orders',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$orderCount',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 1;
                          _ordersSubView = 'list';
                        });
                      },
                      child: const Text(
                        'View all',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 25),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickActionCard(
                Icons.add_circle_outline,
                'Add Order',
                const Color(0xff0F964A),
                -1,
              ),
              _buildQuickActionCard(
                Icons.assignment_outlined,
                'View Orders',
                Colors.orange,
                1,
              ),
              _buildQuickActionCard(
                Icons.person_outline,
                'Profile',
                Colors.blue,
                3,
              ),
            ],
          ),
          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                    _ordersSubView = 'list';
                  });
                },
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: Color(0xff0F964A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .limit(3)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs;
              if (docs.isEmpty)
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No recent orders'),
                );

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  String status = data['status'] ?? 'Pending';
                  Color statusColor = status == 'Pending'
                      ? Colors.orange
                      : status == 'Preparing'
                      ? Colors.blue
                      : Colors.green;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = 1;
                        _ordersSubView = 'details';
                        _activeOrderId = docs[index].id;
                        _activeOrderData = data;
                      });
                    },
                    child: _buildOrderItem(
                      data['tableNumber'] ?? 'Table',
                      _parseItems(data['items']),
                      status,
                      'Just now',
                      statusColor,
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    IconData icon,
    String title,
    Color color,
    int targetIndex,
  ) {
    return GestureDetector(
      onTap: () {
        if (targetIndex == -1) {
          Get.to(() => const AddOrderScreen());
        } else {
          setState(() {
            _currentIndex = targetIndex;
            if (targetIndex == 1) {
              _ordersSubView = 'list';
            }
          });
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.27,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(
    String table,
    String items,
    String status,
    String time,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.table_restaurant_outlined,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  table,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  items,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTabNavigator() {
    if (_ordersSubView == 'details') {
      return _buildOrderDetailsView(_activeOrderId);
    } else if (_ordersSubView == 'edit') {
      final editController = Get.put(
        OrderDetailsController(orderId: _activeOrderId),
        tag: _activeOrderId,
      );
      return _buildEditOrderView(editController);
    } else {
      return _buildOrdersListTab();
    }
  }

  String selectedFilter = 'All';
  final List<String> filters = [
    'All',
    'Pending',
    'Preparing',
    'Ready',
    'Delivered',
  ];

  Widget _buildOrdersListTab() {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.sort, color: Colors.black, size: 30),
            onPressed: () {},
          ),
          title: const Text(
            'Orders',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.filter_alt_outlined,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 10),
          ],
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemBuilder: (context, index) {
              bool isSelected = selectedFilter == filters[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilter = filters[index];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xff0F964A) : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: selectedFilter == 'All'
                ? FirebaseFirestore.instance
                      .collection('orders')
                      .orderBy('createdAt', descending: true)
                      .snapshots()
                : FirebaseFirestore.instance
                      .collection('orders')
                      .where('status', isEqualTo: selectedFilter)
                      .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No orders found',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              var docOrders = snapshot.data!.docs;

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: docOrders.length,
                itemBuilder: (context, index) {
                  var orderId = docOrders[index].id;
                  var orderData =
                      docOrders[index].data() as Map<String, dynamic>;

                  return _buildOrderCard(orderId, orderData);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(String id, Map<String, dynamic> order) {
    String status = order['status'] ?? 'Pending';
    Color statusColor = status == 'Pending'
        ? Colors.orange
        : status == 'Preparing'
        ? Colors.blue
        : Colors.green;

    final cardController = Get.put(
      OrderDetailsController(orderId: id),
      tag: id,
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _ordersSubView = 'details';
          _activeOrderId = id;
          _activeOrderData = order;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.04),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['tableNumber'] ?? 'Table',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _parseItems(order['items']),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                        _parsePrice(order['totalPrice']),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '12 May 2024',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 22,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        cardController.prepareEditData(order);
                        setState(() {
                          _ordersSubView = 'edit';
                          _activeOrderId = id;
                          _activeOrderData = order;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 22,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Confirm Deletion',
                          middleText:
                              '     Are you sure you want to permanently delete the request?    ',
                          textConfirm: ' yes , delete',
                          textCancel: 'to retreat',
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.redAccent,
                          onConfirm: () => cardController.deleteOrder(() {
                            Get.back();
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsView(String id) {
    final detailsController = Get.put(
      OrderDetailsController(orderId: id),
      tag: id,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            setState(() {
              _ordersSubView = 'list';
            });
          },
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) {
            return const Center(child: Text('الطلب غير موجود'));
          }

          var orderData = snapshot.data!.data() as Map<String, dynamic>;
          String status = orderData['status'] ?? 'Pending';
          Color statusColor = status == 'Pending'
              ? Colors.orange
              : status == 'Preparing'
              ? Colors.blue
              : Colors.green;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.table_restaurant, color: statusColor),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderData['tableNumber'] ?? 'Table',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '12 May 2024 - 10:30 AM',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Customer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.person_outline,
                    color: Colors.black54,
                  ),
                  title: Text(
                    orderData['customerName'] ?? 'Guest',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    '+1 555 123 4567',
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: CircleAvatar(
                    backgroundColor: const Color(0xFF0F964A).withOpacity(0.1),
                    child: const Icon(
                      Icons.phone,
                      color: Color(0xFF0F964A),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                const Text(
                  'Items',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _parseItems(orderData['items']),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Price',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _parsePrice(orderData['totalPrice']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                const Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: status,
                      isExpanded: true,
                      items:
                          <String>[
                            'Pending',
                            'Preparing',
                            'Ready',
                            'Delivered',
                          ].map((String val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(
                                val,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (newVal) {
                        if (newVal != null)
                          detailsController.updateStatus(newVal);
                      },
                    ),
                  ),
                ),
                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          detailsController.prepareEditData(orderData);
                          setState(() {
                            _ordersSubView = 'edit';
                          });
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF0F964A),
                        ),
                        label: const Text(
                          'Edit Order',
                          style: TextStyle(color: Color(0xFF0F964A)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0F964A)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.defaultDialog(
                            title: 'تأكيد الحذف',
                            middleText:
                                'هل أنت متأكد من رغبتك في حذف هذا الطلب نهائياً؟',
                            textConfirm: 'نعم، احذف',
                            textCancel: 'تراجع',
                            confirmTextColor: Colors.white,
                            buttonColor: Colors.redAccent,
                            onConfirm: () => detailsController.deleteOrder(() {
                              setState(() {
                                _ordersSubView = 'list';
                              });
                              Get.back();
                            }),
                          );
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        label: const Text(
                          'Delete Order',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditOrderView(OrderDetailsController editController) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            setState(() {
              _ordersSubView = 'details';
            });
          },
        ),
        title: const Text(
          'Edit Order',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Info',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildEditField(
              editController.tableController,
              'Table Number',
              Icons.table_restaurant_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            _buildEditField(
              editController.nameController,
              'Customer Name (Optional)',
              Icons.person_outline,
            ),
            const SizedBox(height: 25),

            const Text(
              'Items',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            Obx(
              () => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: editController.itemsList.length,
                itemBuilder: (context, index) {
                  var item = editController.itemsList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'x${item['quantity']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '\$${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: editController.selectedStatus.value,
                    isExpanded: true,
                    items:
                        <String>[
                          'Pending',
                          'Preparing',
                          'Ready',
                          'Delivered',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null)
                        editController.selectedStatus.value = newValue;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Obx(
                    () => Text(
                      '\$${editController.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => editController.updateFullOrder(() {
                  setState(() {
                    _ordersSubView = 'list';
                  });
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F964A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(
    TextEditingController textCtrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: textCtrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildProfileView(AuthController auth) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFE5E7EB),
                      child: Icon(
                        Icons.person,
                        size: 45,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mohammed Alrabiy',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'aboalrabiy@gmail.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileMenuItem(
                      icon: Icons.person_outline,
                      title: 'Account Information',
                      onTap: () {},
                    ),
                    _buildProfileDivider(),
                    _buildProfileMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () {},
                    ),
                    _buildProfileDivider(),
                    _buildProfileMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    _buildProfileDivider(),
                    _buildProfileMenuItem(
                      icon: Icons.info_outline,
                      title: 'About Us',
                      onTap: () {},
                    ),
                    _buildProfileDivider(),
                    _buildProfileMenuItem(
                      icon: Icons.logout_outlined,
                      title: 'Logout',
                      textColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () => auth.signOut(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF374151),
    Color iconColor = const Color(0xFF6B7280),
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: textColor == Colors.red
            ? Colors.red.withOpacity(0.5)
            : const Color(0xFF9CA3AF),
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 4.0,
      ),
    );
  }

  Widget _buildProfileDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF3F4F6),
      indent: 20,
      endIndent: 20,
    );
  }
}
