import 'package:fleet_manager_driver_app/controller/registration_controller.dart';
import 'package:fleet_manager_driver_app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MobileScreen extends StatelessWidget {
  final RegistrationController controller = Get.find<RegistrationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background color
      appBar: AppBar(
        elevation: 0, // Remove shadow
        backgroundColor: Colors.white, // Match background
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Get.back(); // Navigate back
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              "Mobile Number",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              "Enter your mobile number to continue.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            // Text Field with Validation
            Obx(() => TextField(
                  controller: controller.mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Enter your mobile number",
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    errorText: controller.mobileError.value.isEmpty
                        ? null
                        : controller.mobileError.value, // Show error message
                  ),
                  onChanged: (value) => controller.setMobileNumber(value),
                )),
            const SizedBox(height: 30),
            // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.validateMobileNumber(); // Validate input
                    if (controller.mobileError.value.isEmpty) {
                      Get.toNamed('/generate-id'); // Navigate if valid
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary, // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
