import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_oreder_countroller.dart';

class AddOrderScreen extends StatelessWidget {
  const AddOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddOrderController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add New Order',
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            _buildTextField(
              controller: controller.tableController,
              label: 'Table Number',
              hint: '10',
              icon: Icons.table_restaurant_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            _buildTextField(
              controller: controller.nameController,
              label: 'Customer Name (Optional)',
              hint: 'John Doe',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 25),

            const Text(
              'Items',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            Obx(
              () => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  double itemTotal = item['quantity'] * item['price'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                                onPressed: () =>
                                    controller.decrementQuantity(index),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                              ),
                              Text(
                                '${item['quantity']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                                onPressed: () =>
                                    controller.incrementQuantity(index),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        // السعر الإجمالي للصنف
                        Text(
                          '\$${itemTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () => controller.removeItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            OutlinedButton.icon(
              onPressed: () => controller.addNewItem(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Item'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2EC4B6),
                side: const BorderSide(color: Color(0xFF2EC4B6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // قسم Status
            const Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedStatus.value,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black54,
                    ),
                    items:
                        <String>[
                          'Pending',
                          'Preparing',
                          'Ready',
                          'Completed',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: value == 'Pending'
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedStatus.value = newValue;
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // قسم السعر الإجمالي الإجمالي
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '\$${controller.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // زر الحفظ النهائي للطلب
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.saveOrder(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF0F9F59,
                  ), // اللون الأخضر في تصميمك
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Order',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            suffixIcon: Icon(icon, color: Colors.black54),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2EC4B6)),
            ),
          ),
        ),
      ],
    );
  }
}
