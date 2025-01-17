import 'dart:convert';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:fleet_manager_driver_app/utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/workShopMovement.dart';
import '../service/global.dart';
import '../view/login_screen.dart';
import '../view/main_screen.dart';
import '../widget/toaster_message.dart';
import 'login_controller.dart';

class HomeController extends GetxController {
  workshopMovement? workshop;
  LoginController loginController = Get.put(LoginController());
  // bool isLoading = false;
  final pinController1 = TextEditingController();
  final pinController2 = TextEditingController();
  final passwordController = TextEditingController();
  RxBool _obscureText1 = true.obs;
  RxBool _obscureText2 = true.obs;
  RxBool _obscureText = true.obs;
  RxBool _obscureText3 = false.obs;
  RxBool isinitloading = false.obs;
  List<FlSpot> spots = [];
  int? totalTripsThisYear;
  //bool obscureText3 = false;

  void refreshPage() {
    Get.off(MainScreen());
  }

  Rx<File?> _imageFile = Rx<File?>(null);
  final List<String> vehicleModels = ['SUV', 'MPV', 'SEDAN', 'LIMOUSINE'];

  Future<void> uploadTempVehicle(
      vehicleNumber, image, vehicleName, vechileType) async {
    await collection_temp_vehicles?.insert({
      'driverId': loginController.user?.id,
      'vehicleNumber': vehicleNumber,
      'vehiclePhoto': image,
      'vehicleName': vehicleName,
      'vechileType': vechileType,
      'odometerReading': '0',
      'fuelReading': '0',
      'odometerPhoto': '',
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _imageFile.value = File(image.path);
      update();
    }
  }

  Future<void> logout() async {
  // Access the existing LoginController instance
  LoginController loginController = Get.find<LoginController>();

  // Clear SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('userName');
  prefs.remove('password');
  prefs.remove('id');

  // Reset all state variables
  loginController.currentTrip = null; // Clear current trip
  loginController.trips.clear(); // Clear trips list
  loginController.vehicles.clear(); // Clear vehicles list
  loginController.user = null; // Reset user object
  loginController.isLoggedIn(false); // Set logged-in status to false

  // Navigate to the login screen
  Get.offAll(() => LoginScreen());
}




  // Future<void> logout() async {
  //   LoginController loginController = LoginController();

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.remove('userName');
  //   prefs.remove('password');
  //   prefs.remove('id');

  //   loginController.currentTrip = null; // Clear current trip
  //   loginController.trips.clear(); // Clear trips list
  //   loginController.vehicles.clear(); // Clear vehicles list
  //   loginController.user = null;
  //   loginController.isLoggedIn(false);

  //   //nkjn
  //   Get.offAll(() => LoginScreen());
  // }

  Future<void> changePin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('pin');
    Get.back();
    Get.dialog(
      AlertDialog(
        title: const Text('CHANGE PIN',
            style: TextStyle(
                color: primary, fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: secondary,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: greenlight.withOpacity(.1),
                ),
                child: Obx(() => TextFormField(
                      controller: passwordController,
                      obscureText: _obscureText.value,
                      decoration: InputDecoration(
                        counterText: "",
                        prefixIcon: const Icon(Icons.lock_outline),
                        prefixIconColor: primary,
                        border: InputBorder.none,
                        labelText: 'PASSWORD',
                        labelStyle: const TextStyle(
                            color: primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: primary,
                          ),
                          onPressed: () => _obscureText.toggle(),
                        ),
                      ),
                    )),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: greenlight.withOpacity(.1),
                ),
                child: Obx(() => TextFormField(
                      controller: pinController1,
                      obscureText: _obscureText1.value,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        counterText: "",
                        prefixIcon: const Icon(Icons.password),
                        prefixIconColor: primary,
                        border: InputBorder.none,
                        labelText: 'PIN',
                        labelStyle: const TextStyle(
                            color: primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText1.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: primary,
                          ),
                          onPressed: () => _obscureText1.toggle(),
                        ),
                      ),
                    )),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: greenlight.withOpacity(.1),
                ),
                child: Obx(
                  () => TextFormField(
                    controller: pinController2,
                    obscureText: _obscureText2.value,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      counterText: "",
                      prefixIcon: const Icon(Icons.password),
                      prefixIconColor: primary,
                      border: InputBorder.none,
                      labelText: 'CONFIRM PIN',
                      labelStyle: const TextStyle(
                          color: primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText2.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: primary,
                        ),
                        onPressed: () => _obscureText2.toggle(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.clear();
              pinController1.clear();
              pinController2.clear();
              Get.back();
            },
            child: Text(
              "CANCEL",
              style: GoogleFonts.lato(
                  fontSize: 15, color: primary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (loginController.user?.password == passwordController.text) {
                if (pinController1.text == pinController2.text) {
                  await collection_drivers?.update(
                    where.eq('_id', ObjectId.parse(loginController.user!.id)),
                    modify.set('driverPin', int.parse(pinController1.text)),
                  );
                  print('Pin set');
                  createToastTop('PIN Changed successfully');
                  passwordController.clear();
                  pinController1.clear();
                  pinController2.clear();
                  Get.back();
                } else {
                  pinController1.clear();
                  pinController2.clear();
                  print('Pin not match');
                  createToastTop('Pin not match');
                }
              } else {
                passwordController.clear();
                pinController1.clear();
                pinController2.clear();
                print('Password not match');
                createToastTop('Password not match');
              }
            },
            child: Text(
              "CONFIRM",
              style: GoogleFonts.lato(
                  fontSize: 15, color: primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> editProfile() async {
    TextEditingController mobileController = TextEditingController(
      text: loginController.user?.mobile != null
          ? loginController.user!.mobile.toString()
          : '',
    );
    TextEditingController locationController = TextEditingController(
      text: loginController.user?.location != null
          ? loginController.user!.location.toString()
          : '',
    );
    Get.back();
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile',
            style: TextStyle(
                color: primary, fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: secondary,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  await _pickImage();
                },
                child: Obx(
                  () => _imageFile.value != null
                      ? Image.file(_imageFile.value!)
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.transparent,
                          ),
                          child: loginController.user!.profileImg != null
                              ? Image.memory(base64Decode(
                                  loginController.user!.profileImg!))
                              : const Icon(
                                  Icons.person,
                                  color: greenlight,
                                  size: 50.0,
                                ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: greenlight.withOpacity(.1),
                  ),
                  child: TextFormField(
                    controller: mobileController,
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(
                      counterText: "",
                      prefixIcon: Icon(Icons.dialpad_outlined),
                      prefixIconColor: primary,
                      border: InputBorder.none,
                      labelText: 'Mobile Number',
                      labelStyle: TextStyle(
                          color: primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  )),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: greenlight.withOpacity(.1),
                ),
                child: TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    counterText: "",
                    prefixIcon: Icon(Icons.location_pin),
                    prefixIconColor: primary,
                    border: InputBorder.none,
                    labelText: 'Location',
                    labelStyle: TextStyle(
                        color: primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _imageFile = Rx<File?>(null);
              mobileController.clear();
              locationController.clear();
              Get.back();
            },
            child: Text(
              "CANCEL",
              style: GoogleFonts.lato(
                  fontSize: 15, color: primary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (mobileController.text != '' &&
                  locationController.text != '' &&
                  _imageFile.value != null) {
                try {
                  final Uint8List bytes = await _imageFile.value!.readAsBytes();
                  String base64Image = base64Encode(bytes);
                  loginController.user!.profileImg = base64Image;
                  loginController.user!.location = locationController.text;
                  loginController.user!.mobile = mobileController.text;
                  await collection_drivers?.update(
                    where.eq('_id', ObjectId.parse(loginController.user!.id)),
                    modify
                        .set('mobileNumber', mobileController.text)
                        .set('location', locationController.text)
                        .set('driverPhoto', base64Image),
                  );
                } catch (e) {
                  print(e);
                }
                print("Image uploaded.........................");
              } else {
                await collection_drivers?.update(
                  where.eq('_id', ObjectId.parse(loginController.user!.id)),
                  modify
                      .set('mobileNumber', mobileController.text)
                      .set('location', locationController.text),
                );
                print("Image not uploaded.........................");
              }
              _imageFile = Rx<File?>(null);
              mobileController.clear();
              locationController.clear();
              Get.back();
              refreshPage();
              refreshPage();
            },
            child: Text(
              "CONFIRM",
              style: GoogleFonts.lato(
                  fontSize: 15, color: primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteAccount() async {
    TextEditingController passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(
              color: primary, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: secondary,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Please enter your password to proceed.",
                style: TextStyle(
                    color: primary, fontSize: 15, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 10),
              Obx(() =>TextFormField(
                controller: passwordController,
                obscureText: _obscureText3.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                      color: primary, fontSize: 15, fontWeight: FontWeight.w600),
                  prefixIcon: const Icon(Icons.lock),
                  prefixIconColor: primary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText3.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: primary,
                    ),
                    onPressed: () {
                       _obscureText3.toggle();
                    },
                ),
              ),
                ))
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.clear();
              Get.back();
            },
            child: const Text(
              "CANCEL",
              style: TextStyle(
                  fontSize: 15, color: primary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text == loginController.user?.password) {
                // Password matches, show confirmation dialog
                Get.back(); // Close the password dialog
                Get.dialog(
                  AlertDialog(
                    title: const Text(
                      'Confirm Deletion',
                      style: TextStyle(
                          color: primary, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: secondary,
                    content: const Text(
                      "Are you sure you want to delete your account permanently?",
                      style: TextStyle(
                          color: primary, fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                              fontSize: 15,
                              color: primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Delete the account from the database
                          try {
                            await collection_drivers?.remove(
                              where.eq('_id', ObjectId.parse(loginController.user!.id)),
                            );
                            createToastTop("Account deleted successfully");
                          } catch (e) {
                            print("Error deleting account: $e");
                          }

                          // Log the user out and navigate to login screen
                          await logout();
                        },
                        child: const Text(
                          "CONFIRM",
                          style: TextStyle(
                              fontSize: 15,
                              color: primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Password incorrect, show snackbar
                Get.back();
                Get.snackbar(
                  "Error",
                  "Password incorrect",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text(
              "PROCEED",
              style: TextStyle(
                  fontSize: 15, color: primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }


}
