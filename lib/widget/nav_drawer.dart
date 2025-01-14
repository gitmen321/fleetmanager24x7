import 'package:fleet_manager_driver_app/view/attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../controller/login_controller.dart';
import '../utils/color.dart';

// ignore: must_be_immutable
class NavDrawer extends StatelessWidget {
  NavDrawer({Key? key}) : super(key: key);
  final HomeController homeController = Get.find();
  LoginController loginController = Get.put(LoginController());


  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primary, Colors.black], // replace with your desired colors
          ),
        ),
        child: Drawer(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                      margin: const EdgeInsets.only(top: 110),
                      child: Image.asset('assets/logo/fleet_manager.png', height: 130)),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                         /* Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 2)),
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: user != null ? AssetImage(user.profileImg) : null,
                            ),
                          ),*/

                          const Text(
                            'Name',
                            style: TextStyle(color: greenlight),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            loginController.user!.name,
                            style: const TextStyle(fontSize:18, color: Colors.white70, fontWeight: FontWeight.w600),
                          ),
                          const Divider(
                            thickness: 1.5,
                            color: Colors.grey,
                            height: 10,
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'Phone',
                            style: TextStyle(color: greenlight),
                          ),
                          const SizedBox(height: 5),
                           Text(
                             loginController.user?.mobile !=null ?loginController.user!.mobile.toString():'',
                            style: const TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w600),
                          ),
                          const Divider(
                            thickness: 1.5,
                            color: Colors.grey,
                            height: 10,
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            'Location',
                            style: TextStyle(color: greenlight),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            loginController.user!.location ?? '',
                            style: const TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w600),
                          ),
                          const Divider(
                            thickness: 1.5,
                            color: Colors.grey,
                            height: 10,
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            'DL Number',
                            style: TextStyle(color: greenlight),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            loginController.user?.dlNumber!=null ? loginController.user!.dlNumber:'',
                            style: const TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w600),
                          ),
                          const Divider(
                            thickness: 1.5,
                            color: Colors.grey,
                            height: 10,
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            'DL Expire Date',
                            style: TextStyle(color: greenlight),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            loginController.user?.dlExpiry != null ? DateFormat('dd/MM/yy').format(loginController.user!.dlExpiry):"",
                            style: const TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w600),
                          ),
                          const Divider(
                            thickness: 1.5,
                            color: Colors.grey,
                            height: 10,
                          ),
                          const SizedBox(height: 25),
                          Column(
                            children: [
                               Padding(
                                 padding: const EdgeInsets.symmetric(horizontal: 16),
                                 child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white54,
                                        minimumSize: const Size(double.maxFinite, 40)
                                      ),
                                      onPressed: (){
                                        navigator?.push(MaterialPageRoute(builder: (context)=>const AttendanceScreen()));
                                      },
                                      child: const Text('ATTENDANCE',style: TextStyle(color: secondary),)
                                    ),
                               ),
                              const SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(Colors.white54),
                                    ),
                                    onPressed: (){
                                      homeController.changePin();
                                    },
                                    child: const Text('CHANGE PIN',style: TextStyle(color: secondary),)
                                  ),
                              
                                  ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all(Colors.white54),
                                      ),
                                      onPressed: (){
                                        homeController.logout();
                                      },
                                      child: const Text('LOGOUT',style: TextStyle(color: secondary),)),
                              
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    side: const BorderSide(color: Colors.white54),
                                    minimumSize: const Size(double.maxFinite, 35),
                                  ),
                                  onPressed: () {
                                    homeController.deleteAccount();
                                  },
                                  child: const Text(
                                    'DELETE ACCOUNT',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 270,
                right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () {
                      homeController.editProfile();
                    },
                  ),
              ),
            ],
          ),
        ),
      );
  }
  }
