import 'package:fleet_manager_driver_app/service/database.dart';
import 'package:fleet_manager_driver_app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mongo_dart/mongo_dart.dart';

class RegistrationController extends GetxController {
  // TextEditingController for the name input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController driverIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable variables to manage state
  var driverName = ''.obs;
  var mobileNumber = ''.obs;
  var driverId = ''.obs;
  var driverPassword = ''.obs;
  var licenseNumber = ''.obs;
  var expiryDate = ''.obs;

  // Checkbox state
  var isTermsAccepted = false.obs;

  // Validation error for name
  var nameError = ''.obs;
  var mobileError = ''.obs; //  for the mobile number
  var driverIdError = ''.obs; // To hold validation error for ID
  var passwordError = ''.obs; // To hold validation error for password

  var isPasswordHidden = true.obs; // To toggle password visibility

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Validation for License Details
  bool validateLicenseDetails() {
    if (licenseNumber.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your license number.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (expiryDate.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select your license expiry date.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

// Save Driver Details to MongoDB
  Future<void> saveDriverDetails() async {
    try {
      // Ensure MongoDB is connected before proceeding
      if (MongoDB.driversCollection == null) {
        throw Exception("MongoDB driversCollection is not initialized");
      }

      // Log values for debugging
      print("Driver ID: ${driverIdController.text}");
      print("Password: ${passwordController.text}");
      print("Name: ${nameController.text}");
      print("Mobile: ${mobileController.text}");
      print("License Number: ${licenseNumber.value}");
      print("Expiry Date: ${expiryDate.value}");

      // Validate all fields explicitly
      if (driverIdController.text.trim().isEmpty) {
        throw Exception("Driver ID is missing");
      }
      if (passwordController.text.trim().isEmpty) {
        throw Exception("Password is missing");
      }
      if (nameController.text.trim().isEmpty) {
        throw Exception("Driver Name is missing");
      }
      if (mobileController.text.trim().isEmpty) {
        throw Exception("Mobile Number is missing");
      }
      if (licenseNumber.value.isEmpty) {
        throw Exception("License Number is missing");
      }
      if (expiryDate.value.isEmpty) {
        throw Exception("Expiry Date is missing");
      }

      // Prepare the data
      final data = {
        "driverId": driverIdController.text.trim(),
        "driverPassword": passwordController.text.trim(),
        "driverName": nameController.text.trim(),
        "mobileNumber": mobileController.text.trim(),
        "driverLicenceNumber": licenseNumber.value,
        "driverLicenceExpiryDate": DateTime.parse(expiryDate.value),
        "trips": [],
      };

      // Insert data into MongoDB
      await MongoDB.driversCollection.insertOne(data);

      print("Driver details saved successfully: $data");

      // Navigate to login screen
      Get.offAllNamed('/login');
    } catch (e) {
      print("Failed to save driver details: $e");

      Get.snackbar(
        "Error",
        "Failed to create driver account. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<String> generateDriverId() async {
    final lastDriver = await MongoDB.driversCollection
        .find(where.sortBy('driverId', descending: true).limit(1))
        .toList();

    if (lastDriver.isEmpty) {
      return 'DR001';
    }

    final lastId = lastDriver[0]['driverId']; // e.g., "DR003"
    final newId = int.parse(lastId.substring(2)) + 1;
    return 'DR${newId.toString().padLeft(3, '0')}';
  }

  void validateDriverIdAndPassword() {
    if (driverIdController.text.trim().isEmpty) {
      driverIdError.value = "Please generate your ID";
    } else {
      driverIdError.value = ""; // Clear error
    }

    if (passwordController.text.trim().isEmpty) {
      passwordError.value = "Please enter a password";
    } else if (passwordController.text.trim().length < 6) {
      passwordError.value = "Password must be at least 6 characters";
    } else {
      passwordError.value = ""; // Clear error
    }
  }

  // Validate the name input
  void validateName() {
    // Ensure controller and its text value are valid
    if (nameController.text.trim().isEmpty) {
      nameError.value = "Please enter your name";
    } else {
      nameError.value = ""; // Clear error if valid
      driverName.value = nameController.text.trim(); // Update driverName
    }
  }

  void validateMobileNumber() {
    if (mobileController.text.trim().isEmpty) {
      mobileError.value = "Please enter your mobile number";
    } else if (mobileController.text.trim().length < 8) {
      mobileError.value = "Mobile number must be at least 8 digits";
    } else {
      mobileError.value = ""; // Clear the error if input is valid
    }
  }

  // Clean up resources when the controller is removed
  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    driverIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Setters for other fields

  void setMobileNumber(String value) {
    mobileController.text = value;
  }

  void setDriverId(String id) {
    driverIdController.text = id;
  }

  void setDriverPassword(String password) {
    passwordController.text = password;
  }

  void setLicenseNumber(String license) {
    licenseNumber.value = license;
  }

  void setExpiryDate(String date) {
    print("Setting Expiry Date: $date"); // Debug log
    expiryDate.value = date;
  }

  // Collect all registration data as a map
  Map<String, dynamic> getRegistrationData() {
    return {
      "driverName": driverName.value,
      "mobileNumber": mobileNumber.value,
      "driverId": driverId.value,
      "driverPassword": driverPassword.value,
      "licenseNumber": licenseNumber.value,
      "expiryDate": expiryDate.value,
    };
  }
}
