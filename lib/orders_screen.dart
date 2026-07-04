import 'package:flutter/material.dart';
import 'home_screen.dart'; // استيراد شاشة الهوم للربط

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // مؤشر شريط التنقل (1 يعني شاشة الأوردرز)
  final int _currentIndex = 1;

  final List<String> _categories = [
    'All',
    'Pending',
    'Preparing',
    'Ready',
    'Delivered',
  ];
  int _selectedCategoryIndex = 0;

  final List<Map<String, String>> _allOrders = [
    {
      'table': 'Table 5',
      'items': 'Pizza x2, Cola',
      'status': 'Preparing',
      'price': '\$40',
      'time': '12 May 2024 • 10:30 AM',
    },
    {
      'table': 'Table 2',
      'items': 'Burger, Fries',
      'status': 'Ready',
      'price': '\$25',
      'time': '12 May 2024 • 10:15 AM',
    },
    {
      'table': 'Table 8',
      'items': 'Pasta, Water',
      'status': 'Delivered',
      'price': '\$18',
      'time': '12 May 2024 • 09:50 AM',
    },
    {
      'table': 'Table 3',
      'items': 'Sandwich, Juice',
      'status': 'Pending',
      'price': '\$20',
      'time': '12 May 2024 • 09:30 AM',
    },
  ];

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

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // شريط الفئات الأفقي
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
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
                          _categories[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // قائمة الطلبات الكاملة باستخدام ListView.builder للشاشة المستقلة
              Expanded(
                child: ListView.builder(
                  itemCount: _allOrders.length,
                  itemBuilder: (context, index) {
                    final order = _allOrders[index];
                    if (_selectedCategoryIndex != 0 &&
                        order['status'] !=
                            _categories[_selectedCategoryIndex]) {
                      return const SizedBox.shrink();
                    }
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
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order['table']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        order['items']!,
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
                                    color: _getStatusColor(order['status']!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order['status']!,
                                    style: TextStyle(
                                      color: _getStatusTextColor(
                                        order['status']!,
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
                                      order['price']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      order['time']!,
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
                                      onPressed: () {},
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
                ),
              ),
            ],
          ),
        ),
      ),

      // هنا الربط التفاعلي للرجوع للهوم سكرين
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
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
