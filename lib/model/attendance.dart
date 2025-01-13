

import 'package:intl/intl.dart';

class Attendance {
  final String userId;
  final String driverId;     // Added driver ID
  // final String driverUsername;  // Added driver username
  final List<AttendanceRecord> attendanceRecords;  // To store multiple attendance records

  Attendance({
    required this.userId,
    required this.driverId,
    // required this.driverUsername,
    required this.attendanceRecords,
  });

  // Convert a Dart object to a JSON-like map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'driverId': driverId,
      // 'driverUsername': driverUsername,
      'attendanceRecords': attendanceRecords.map((record) => record.toMap()).toList(),
    };
  }

  // Convert JSON-like map to a Dart object
  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      userId: map['userId'] as String,
      driverId: map['driverId'] as String,
      // driverUsername: map['driverUsername'] as String,
      attendanceRecords: List<AttendanceRecord>.from(
        map['attendanceRecords'].map((record) => AttendanceRecord.fromMap(record)),
      ),
    );
  }
}


class AttendanceRecord {
  final DateTime checkInDate;
  final String checkInTime;
  final DateTime? checkOutDate;
  final String? checkOutTime;
  final double overtime; // Overtime in hours, default is 0.

  AttendanceRecord({
    required this.checkInDate,
    required this.checkInTime,
    this.checkOutDate,
    this.checkOutTime,
    this.overtime = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'checkInDate': DateFormat('yyyy-MM-dd').format(checkInDate), // Store only date
      'checkInTime': checkInTime,
      'checkOutDate': checkOutDate != null ? DateFormat('yyyy-MM-dd').format(checkOutDate!) : null, // Store only date
      'checkOutTime': checkOutTime,
      'overtime': overtime,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      checkInDate: DateTime.parse(map['checkInDate']),
      checkInTime: map['checkInTime'],
      checkOutDate: map['checkOutDate'] != null ? DateTime.parse(map['checkOutDate']) : null,
      checkOutTime: map['checkOutTime'],
      overtime: (map['overtime'] ?? 0.0).toDouble(),
    );
  }
}


