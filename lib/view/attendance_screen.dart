import 'dart:async';
import 'package:fleet_manager_driver_app/service/database.dart';
import 'package:fleet_manager_driver_app/service/global.dart';
import 'package:fleet_manager_driver_app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isCheckedIn = false;
  String buttonText = "Check In";
  String checkinTime = '';
  String currentDate = DateFormat('dd - MMMM - yyyy').format(DateTime.now());
  String currentTime = DateFormat('hh:mm a').format(DateTime.now());
  DateTime? checkInDateTime; // Track when the user checked in
  Timer? _timer;
  double percentage = 0.0; // Progress of the 12-hour period

  @override
  void initState() {
    super.initState();
    _loadCheckInStatus();
  }

  Future<void> _loadCheckInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? storedIsCheckedIn = prefs.getBool('isCheckedIn');
    String? storedCheckInTime = prefs.getString('checkInDateTime');

    if (storedIsCheckedIn != null && storedCheckInTime != null) {
      setState(() {
        isCheckedIn = storedIsCheckedIn;
        checkInDateTime = DateTime.parse(storedCheckInTime);
        buttonText = isCheckedIn ? "Check Out" : "Check In";
        checkinTime =
            "Checked-in at ${DateFormat('hh:mm a').format(checkInDateTime!)}";
        if (isCheckedIn) {
          startTimer();
        }
      });
    }
  }

  Future<void> _saveCheckInStatus(
      bool isCheckedIn, DateTime? checkInDateTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCheckedIn', isCheckedIn);
    if (checkInDateTime != null) {
      await prefs.setString(
          'checkInDateTime', checkInDateTime.toIso8601String());
    }
  }

  Future<void> _clearCheckInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isCheckedIn');
    await prefs.remove('checkInDateTime');
  }

  void _onCheckInOutPressed() async {
    final userId = loggedInUserId;
    final driverId = loggedInDriverId;
    final now = DateTime.now();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasCompletedFirstCheckInToday =
        prefs.getBool('hasCompletedFirstCheckInToday') ?? false;

    if (isCheckedIn) {
      final elapsed = now.difference(checkInDateTime!).inMinutes;

      // Restrict checkout if required time not met
      if (!hasCompletedFirstCheckInToday && elapsed < 3 * 60) {
        _showToast("You can only check out after completing 3 Hours.");//for testing
        return;
      }

      // Checkout allowed
      setState(() {
        isCheckedIn = false;
        buttonText = "Check In";
        _timer?.cancel();
        percentage = 0.0;
      });

      await prefs.setBool('hasCompletedFirstCheckInToday', true);
      await _clearCheckInStatus();

      await checkOutAttendance(userId);

      _showToast("Checked out successfully.");
    } else {
      // Check-In logic
      setState(() {
        isCheckedIn = true;
        buttonText = "Check Out";
        checkInDateTime = now;
        checkinTime = "Checked-in at ${DateFormat('hh:mm a').format(now)}";
        startTimer();
      });

      await _saveCheckInStatus(isCheckedIn, checkInDateTime);
      await checkInAttendance(userId, driverId);

      _showToast("Checked in successfully.");
    }
  }

//  void _onCheckInOutPressed() async {
//   final userId = loggedInUserId;
//   final driverId = loggedInDriverId;

//   // Get the current date and time
//   final now = DateTime.now();
//   final today = DateFormat('yyyy-MM-dd').format(now);

//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? lastCheckInDate = prefs.getString('lastCheckInDate');
//   bool? hasCompletedFirstCheckInToday = prefs.getBool('hasCompletedFirstCheckInToday') ?? false;

//   if (isCheckedIn) {
//     // If the user is already checked in, calculate elapsed time
//     final elapsed = now.difference(checkInDateTime!).inMinutes;

//     // Restrict checkout only for the first check-in of the day
//     if (!hasCompletedFirstCheckInToday && elapsed < 1) {
//       _showToast("You can only check out after completing 12 Hours");
//       return;
//     }

//     // Allow checkout
//     setState(() {
//       isCheckedIn = false;
//       buttonText = "Check In";
//       _timer?.cancel(); // Stop the timer
//       percentage = 0.0; // Reset progress
//     });

//     // Update the flag for first check-in completion
//     if (!hasCompletedFirstCheckInToday) {
//       await prefs.setBool('hasCompletedFirstCheckInToday', true);
//     }

//     // Clear the check-in status locally
//     await _clearCheckInStatus();

//     // Call the MongoDB checkout function
//     await checkOutAttendance(userId);

//     _showToast("Checked out successfully.");
//   } else {
//     // Check-in logic
//     if (lastCheckInDate != null && lastCheckInDate == today) {
//       // Allow subsequent check-ins and checkouts without restriction
//       _showToast("You can check in again for today.");
//     }

//     // Proceed with check-in
//     setState(() {
//       isCheckedIn = true;
//       buttonText = "Check Out";
//       checkInDateTime = now;
//       checkinTime = "Checked-in at ${DateFormat('hh:mm a').format(now)}";
//       startTimer();
//     });

//     // Save the check-in status and time locally
//     await _saveCheckInStatus(isCheckedIn, checkInDateTime);
//     await prefs.setString('lastCheckInDate', today);

//     // Call the MongoDB check-in function
//     await checkInAttendance(userId, driverId);

//     _showToast("Checked in successfully.");
//   }
// }

  void startTimer() {
    const oneMinute = Duration(minutes: 1);
    _timer = Timer.periodic(oneMinute, (Timer timer) {
      setState(() {
        calculateProgress();
      });
    });
  }

  void calculateProgress() {
    if (checkInDateTime != null) {
      final now = DateTime.now();
      final elapsed = now
          .difference(checkInDateTime!)
          .inMinutes; // Elapsed minutes since check-in

      // For testing: change 12 * 60 (720 minutes for 12 hours) to a smaller value

      
      const totalMinutes = 3 * 60; // 3 hours in minutes for testing


      setState(() {
        percentage = elapsed / totalMinutes;
        if (percentage >= 1.0) {
          percentage =
              1.0; // Cap at 100% once 12 minutes have passed (for testing)
          _timer?.cancel(); // Stop the timer when the period is over
        }
      });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: Text(
          "Attendance",
          style: GoogleFonts.lato(
              color: secondary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: primary,
      ),
      backgroundColor: secondary,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, color: Colors.black, size: 18),
                const SizedBox(width: 10),
                Text(
                  currentDate,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 40),
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 13.0,
              percent: percentage, // Dynamic percentage
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentTime,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  const Text("Today",
                      style: TextStyle(fontSize: 16, color: Colors.white54)),
                ],
              ),
              progressColor: primary,
            ),
            const SizedBox(height: 15),
            // Check-in time display
            Text(
              checkinTime,
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // Check In/Out Button
            ElevatedButton(
              onPressed: _onCheckInOutPressed,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: primary, // Button background color
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }
}
