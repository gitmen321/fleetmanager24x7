// import 'dart:convert';

// import 'package:fleet_manager_driver_app/utils/color.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // import 'package:get/get_core/src/get_main.dart';

// import '../controller/home_controller.dart';
// import '../controller/login_controller.dart';
// import '../widget/nav_drawer.dart';
// import 'home_screen.dart';

// class MainScreen extends StatelessWidget {
//    MainScreen({super.key});
//   final HomeController homeController = Get.put(HomeController());
//   final LoginController loginController = Get.put(LoginController());



//    @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//           appBar: AppBar(
//             toolbarHeight: 60,
//             leading: Builder(
//               builder: (context) => GestureDetector(
//                 child: Container(
//                   margin: EdgeInsets.only(left: 25,top: 15),
//                   child: Icon (Icons.menu_rounded, color: greenlight, size: 40.0,),
//                 ),
//                 onTap: () {
//                   Scaffold.of(context).openDrawer();
//                 },
//               ),
//             ),
//             backgroundColor: secondary,
//               actions: [
//                 Padding(
//                   padding: const EdgeInsets.only(top:10,right: 30),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child:
//                     loginController.user!.profileImg != null
//                         ? Image.memory(base64Decode(loginController.user!.profileImg!))
//                     // Image.asset(loginController.user!.profileImg!,)
//                         : const Icon(Icons.person, color: greenlight, size: 40.0,),
//                   ),
//                 ),
//               ],
//             ),
//           body:const HomeScreen(),
//       drawer: NavDrawer(),
//     );
//   }
// }
import 'dart:convert';
import 'package:fleet_manager_driver_app/utils/color.dart';
import 'package:fleet_manager_driver_app/view/attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/home_controller.dart';
import '../controller/login_controller.dart';
import '../widget/nav_drawer.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final HomeController homeController = Get.put(HomeController());
  final LoginController loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    _checkAttendanceDialog();
  }

  Future<void> _checkAttendanceDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastShownTimestamp = prefs.getInt('attendanceDialogShownTime');
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Check if 24 hours (86,400,000 milliseconds) have passed
    if (lastShownTimestamp == null || (currentTime - lastShownTimestamp) > 86400000) {
      _showAttendanceDialog();
      // Save the current timestamp
      prefs.setInt('attendanceDialogShownTime', currentTime);
    }
  }

  void _showAttendanceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text('Attendance',style: GoogleFonts.lato(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),),
          content:  Text('Make sure to mark your attendance for today.', style: GoogleFonts.lato(
                color: Colors.black, fontSize: 16, ),),
          actions: [
            TextButton(
              onPressed: () {
                
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const AttendanceScreen())); 

              },
              child: const Text('Mark Attendance',style: TextStyle(color: primary, fontWeight: FontWeight.w600 ) ,),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog if already marked
                Navigator.of(context).pop();
              },
              child:  const Text('Already Marked',style: TextStyle(color: primary, fontWeight: FontWeight.w600),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        leading: Builder(
          builder: (context) => GestureDetector(
            child: Container(
              margin: const EdgeInsets.only(left: 25, top: 15),
              child: const Icon(Icons.menu_rounded, color: greenlight, size: 40.0),
            ),
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        backgroundColor: secondary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: loginController.user!.profileImg != null
                  ? Image.memory(base64Decode(loginController.user!.profileImg!))
                  : const Icon(Icons.person, color: greenlight, size: 40.0),
            ),
          ),
        ],
      ),
      body: const HomeScreen(),
      drawer: NavDrawer(),
    );
  }
}
