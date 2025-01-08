import 'package:fleet_manager_driver_app/utils/color.dart';
import 'package:fleet_manager_driver_app/view/registrations/name_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/login_controller.dart';
import '../widget/toaster_message.dart';
import 'main_screen.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final LoginController controller = Get.put(LoginController());
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final RxBool _obscureText = true.obs;
  RxBool isLoader = false.obs;
  RxDouble progress = 0.0.obs; // Progress value for the loading indicator

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: logingrey,
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    primary.withOpacity(0.3),
                    BlendMode.srcOver,
                  ),
                  child: Image.asset('assets/image/intro3.jpeg'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo/fleet_manager.png',
                    height: 120,
                    width: 120,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: secondary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, -3),
                    ),
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(3, 0),
                    ),
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(-3, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 15),
                      const Center(
                          child: Text(
                        'Sign In',
                        style: TextStyle(
                            color: primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      )),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                          controller: usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Username',
                            contentPadding: const EdgeInsets.only(left: 25),
                            labelStyle: const TextStyle(
                                color: primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: primary,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextFormField(
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            obscureText: _obscureText.value,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              contentPadding: const EdgeInsets.only(left: 25),
                              labelStyle: const TextStyle(
                                  color: primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: primary,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: primary,
                                  width: 1.5,
                                ),
                              ),
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        return isLoader.value
                            ? Column(
                                children: [
                                  const SizedBox(height: 10),

                                  // Linear progress bar for showing the loading progress
                                  Obx(() => Padding(
                                        padding: const EdgeInsets.only(
                                            left: 70, right: 70, bottom: 18),
                                        child: LinearProgressIndicator(
                                          value: progress.value,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          minHeight: 20,
                                          backgroundColor: Colors.grey.shade300,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(primary),
                                        ),
                                        
                                      ),
                                      ),
                                  // const SizedBox(height: 10),

                                  // Showing percentage text for the loading
                                  Obx(() => Text(
                                        '${(progress.value * 100).toInt()}%',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      ),
                                ],
                              )
                            : SizedBox(
                                width: 40,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        elevation: WidgetStateProperty.all(5),
                                        backgroundColor:
                                            WidgetStateProperty.all(primary),
                                      ),
                                      onPressed: () async {

                                        // Reset the loading state and progress
                                        isLoader.value = true;
                                        progress.value = 0.0;

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'This may take a moment...',
                                              
                                              style: GoogleFonts.lato(
                                                  color: secondary,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        );

                                        // Start login process and pass progress observable
                                        bool isUser = await controller.login(
                                            usernameController,
                                            passwordController,
                                            progress);

                                        // If login fails, show toast and stop the loader
                                        if (!isUser) {
                                          createToastTop(
                                              'Invalid username or password');
                                          isLoader.value = false;
                                          return;
                                        }
                                        

                                        // After login, navigate to MainScreen without delay
                                        if (controller.user!.pin != null) {
                                          Get.offAll(() => MainScreen());
                                        } else {
                                          usernameController.clear();
                                          passwordController.clear();
                                          controller.showSetPinOverLay();
                                        }

                                        // Reset loading state
                                        isLoader.value = false;
                                      },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                      }),
                      // const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Haven't registered yet?", style: TextStyle(
                            color: Color.fromARGB(172, 0, 0, 0)
                          ),),
                          TextButton(onPressed: (){
                            Get.toNamed('/name');
                            // Get.offAll(() => NameScreen());
                          },
                           child: const Text('Register',style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primary
                           ),),)
                        ],
                      ),
                      const SizedBox(height: 10,)


                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
