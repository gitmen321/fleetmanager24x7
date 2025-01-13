import 'package:fleet_manager_driver_app/model/attendance.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'constants.dart';
import 'global.dart';

class MongoDB {
  static late Db db;
  static late DbCollection driversCollection;

  static Future<Map<String, dynamic>> connect() async {
    try {
      db = await Db.create(MONGO_URL);
      await db.open();
      driversCollection = db.collection('drivers');
      // Initialize collections
      collection_drivers = db.collection(COLLECTION_DRIVERS);
      collection_temp_vehicles = db.collection(COLLECTION_TEMPVEHICLES);
      collection_trips = db.collection(COLLECTION_TRIPS);
      collection_vehicles = db.collection(COLLECTION_VEHICLES);
      collection_scratch = db.collection(COLLECTION_SCRATCHS);
      collection_workshop = db.collection(COLLECTION_WORKSHOPS);
      collection_issues = db.collection(COLLECTION_ISSUES);
      collection_charts = db.collection(COLLECTION_CHARTS);
      collection_attendance = db.collection('attendance');

      print('Connected to MongoDB');

      // Return the db and drivers collection
      return {
        'db': db,
        'collection_drivers': collection_drivers,
      };
    } catch (e) {
      print('Failed to connect to MongoDB: $e');

      // Optionally, you can return null or handle offline cases here
      return {
        'db': null,
        'collection_drivers': null,
      };
    }
  }
}

void monitorDriverTrips(String driverId) async {
//   final db = Db('mongodb://localhost:27017/fleet_manager'); // Your connection string
//  await db.open();
//   final collection = db.collection('drivers');

  // Use a change stream to monitor updates
  var pipeline = [
    {
      '\$match': {'operationType': 'update', 'fullDocument.driverId': driverId}
    }
  ];

  final changeStream = MongoDB.driversCollection.watch(pipeline);

  await for (var change in changeStream) {
    print('Change detected: ${change}');
    // Notify the driver app using Socket.IO or update the local state.
  }
}



Future<void> tripStatus(String tripNumber, String newStatus) async {
  try {
    if (db!.isConnected) {
      var result = await collection_trips?.updateOne(
        where.eq('tripNumber', tripNumber),
        modify.set('tripStatus', newStatus),
      );

      if (result!.isAcknowledged) {
        print("Trip status updated successfully for trip: $tripNumber");
      } else {
        print("Failed to update trip status for trip: $tripNumber");
      }
    } else {
      print("Database is not connected.");
    }
  } catch (e) {
    print("Error updating trip status: $e");
  }
}

Future<void> updateVehicleStatus(String vehicleNumber, String newStatus) async {
  try {
    if (db!.isConnected) {
      var result = await collection_vehicles?.updateOne(
        where.eq('vehicleNumber', vehicleNumber),
        modify.set('vehicleStatus', newStatus),
      );

      if (result!.isAcknowledged) {
        print(
            "Vehicle status updated successfully for vehicle: $vehicleNumber");
      } else {
        print("Failed to update vehicle status for vehicle: $vehicleNumber");
      }
    } else {
      print("Database is not connected.");
    }
  } catch (e) {
    print("Error updating vehicle status: $e");
  }
}

Future<void> updateTempVehicleReading(vehicleNumber, odometerReading) async {
  final query = where.eq('vehicleNumber', vehicleNumber);
  final update = modify.set(
    'odometerReading',
    odometerReading,
  );
  await collection_temp_vehicles?.updateOne(query, update);
}

Future<void> updateVehicleReading(vehicleNumber, odometerReading) async {
  final query = where.eq('vehicleNumber', vehicleNumber);
  final update = modify.set('odometerReading', int.parse(odometerReading));
  await collection_vehicles?.updateOne(query, update);
}

Future<void> updateKeyCustody(vehicleNumber, keyCustody) async {
  final query = where.eq('vehicleNumber', vehicleNumber);
  final update = modify.set('keyCustody', keyCustody);
  await collection_vehicles?.updateOne(query, update);
}

Future<void> updateLocation(vehicleNumber, latitude, longitude) async {
  final query = where.eq('vehicleNumber', vehicleNumber);
  final update = modify.set('vehicleLocation', {
    'latitude': latitude,
    'longitude': longitude,
  });
  await collection_vehicles?.updateOne(query, update);
}

Future<void> updateTripBegin(
    tripNumber, odometerReading, fuelReading, image) async {
  final query = where.eq('tripNumber', tripNumber);
  final update = modify
      .set(
        'odometerStart',
        int.parse(odometerReading),
      )
      .set('fuelStart', int.parse(fuelReading))
      .set(
        'odometerStartImage',
        image,
      );
  await collection_trips?.updateOne(query, update);
}

Future<void> updateTripEnd(
    tripNumber, odometerReading, fuelReading, image) async {
  final query = where.eq('tripNumber', tripNumber);
  final update = modify
      .set(
        'odometerEnd',
        int.parse(odometerReading),
      )
      .set('fuelEnd', int.parse(fuelReading))
      .set(
        'odometerEndImage',
        image,
      );
  await collection_trips?.updateOne(query, update);
}

Future<void> updateTripStatus(driverUsername, status) async {
  final query = where.eq('driverId', driverUsername);
  final update = modify.set(
    'status',
    status,
  );
  await collection_drivers?.updateOne(query, update);
}

Future<void> updateTripStartTime(tripNumber) async {
  final query = where.eq('tripNumber', tripNumber);
  final update = modify.set(
    'tripStartTimeDriver',
    DateTime.now(),
  );
  await collection_trips?.updateOne(query, update);
}

Future<void> updateTripEndTime(tripNumber) async {
  final query = where.eq('tripNumber', tripNumber);
  final update = modify.set(
    'tripEndTimeDriver',
    DateTime.now(),
  );
  await collection_trips?.updateOne(query, update);
}

Future<void> updateChartData(id, totalHours, date) async {
  final query = where.eq('driverId', ObjectId.parse(id));
  final update = modify
      .set(
        'totalHours',
        totalHours,
      )
      .push(
        'date',
        date,
      );
  await collection_charts?.updateOne(query, update);
}

Future<void> reportIssue(
    String tripNumber,
    String vehicleNumber,
    String driverUsername,
    String issueType,
    String issueDetail,
    String issueImage) async {
  final newIssue = {
    'tripNumber': tripNumber,
    'vehicleNumber': vehicleNumber,
    'driverId': driverUsername,
    'issueType': issueType,
    'issueDetail': issueDetail,
    'issueImage': issueImage,
    'timestamp': DateTime.now()
  };

  await collection_issues?.insertOne(newIssue);
}
//new  functions added below

// Future<void> checkInAttendance(String userId, String driverId) async {
//   final currentDate = DateTime.now();
//   final checkInTime = DateFormat('hh:mm a').format(currentDate); // Store formatted time
//   final query = where.eq('userId', userId);

//   final attendanceRecord = await collection_attendance?.findOne(query);

//   if (attendanceRecord == null) {
//     // Create a new attendance record
//     final newAttendance = Attendance(
//       userId: userId,
//       driverId: driverId,
//       attendanceRecords: [
//         AttendanceRecord(
//           checkInDate: currentDate,
//           checkInTime: checkInTime
//         )
//       ],
//     ).toMap();

//     await collection_attendance?.insertOne(newAttendance);
//   } else {
//     // Add new check-in record
//     List<dynamic> records = attendanceRecord['attendanceRecords'];
//     records.add(AttendanceRecord(
//       checkInDate: currentDate,
//       checkInTime: checkInTime
//     ).toMap());

//     final update = modify.set('attendanceRecords', records);
//     await collection_attendance?.updateOne(query, update);
//   }
// }

// Future<void> checkOutAttendance(String userId) async {
//   final currentDate = DateTime.now();
//   final checkOutTime = DateFormat('hh:mm a').format(currentDate); // Store formatted time
//   final query = where.eq('userId', userId);

//   final attendanceRecord = await collection_attendance?.findOne(query);

//   if (attendanceRecord != null) {
//     List<dynamic> records = attendanceRecord['attendanceRecords'];

//     double totalHoursWorkedToday = 0.0;

//     for (var record in records) {
//       // Check if the record is for today's date
//       final checkInDate = DateTime.parse(record['checkInDate']);
//       if (checkInDate.year == currentDate.year &&
//           checkInDate.month == currentDate.month &&
//           checkInDate.day == currentDate.day) {

//         // If the record already has a checkout time, accumulate hours
//         if (record['checkOutTime'] != null) {
//           final checkInTime = DateFormat('hh:mm a').parse(record['checkInTime']);
//           final checkInDateTime = DateTime(checkInDate.year, checkInDate.month, checkInDate.day, checkInTime.hour, checkInTime.minute);
//           final checkOutTimeParsed = DateFormat('hh:mm a').parse(record['checkOutTime']);
//           final checkOutDateTime = DateTime(checkInDate.year, checkInDate.month, checkInDate.day, checkOutTimeParsed.hour, checkOutTimeParsed.minute);

//           totalHoursWorkedToday += checkOutDateTime.difference(checkInDateTime).inHours;
//         }
//         // If there is no checkout time yet (current record), calculate hours for this session
//         else {
//           final checkInTime = DateFormat('hh:mm a').parse(record['checkInTime']);
//           final checkInDateTime = DateTime(checkInDate.year, checkInDate.month, checkInDate.day, checkInTime.hour, checkInTime.minute);

//           totalHoursWorkedToday += currentDate.difference(checkInDateTime).inHours;

//           // Now update the record with the current checkout time and overtime calculation
//           record['checkOutDate'] = DateFormat('yyyy-MM-dd').format(currentDate); // Store only date
//           record['checkOutTime'] = checkOutTime; // Store formatted time
//         }
//       }
//     }

//     // Calculate overtime if total hours worked today exceed 12 hours
//     double overtime = 0.0;
//     if (totalHoursWorkedToday > 12) {
//       overtime = totalHoursWorkedToday - 12;//for testing purpose
//     }

//     // Set overtime in the last record
//     records.last['overtime'] = overtime;

//     // Update the attendance record in MongoDB
//     final update = modify.set('attendanceRecords', records);
//     await collection_attendance?.updateOne(query, update);
//   } else {
//     print("No attendance record found for check-out.");
//   }
// }

Future<void> checkInAttendance(String userId, String driverId) async {
  final currentDate = DateTime.now();
  final checkInTime = DateFormat('hh:mm a').format(currentDate);
  final query = where.eq('userId', userId);

  final attendanceRecord = await collection_attendance?.findOne(query);

  if (attendanceRecord == null) {
    // First check-in of the day
    final newAttendance = Attendance(
      userId: userId,
      driverId: driverId,
      attendanceRecords: [
        AttendanceRecord(
          checkInDate: currentDate,
          checkInTime: checkInTime,
        )
      ],
    ).toMap();
    await collection_attendance?.insertOne(newAttendance);
  } else {
    // Subsequent check-in: Only add to overtime, do not create a new record
    List<dynamic> records = attendanceRecord['attendanceRecords'];
    final lastRecord = records.last;

    final checkInDate = DateTime.parse(lastRecord['checkInDate']);
    if (checkInDate.year == currentDate.year &&
        checkInDate.month == currentDate.month &&
        checkInDate.day == currentDate.day) {
      // Same day: Check if overtime already exists and add to it
      double existingOvertime = lastRecord['overtime'] ?? 0.0;

      final lastCheckOutTime =
          DateFormat('hh:mm a').parse(lastRecord['checkOutTime']);
      final lastCheckOutDateTime = DateTime(
        checkInDate.year,
        checkInDate.month,
        checkInDate.day,
        lastCheckOutTime.hour,
        lastCheckOutTime.minute,
      );

      final elapsedTime =
          currentDate.difference(lastCheckOutDateTime).inMinutes / 60.0;
      lastRecord['overtime'] = existingOvertime + elapsedTime;

      // Update MongoDB record
      final update = modify.set('attendanceRecords', records);
      await collection_attendance?.updateOne(query, update);
    } else {
      // Add new record if it's a new day
      records.add(
        AttendanceRecord(
          checkInDate: currentDate,
          checkInTime: checkInTime,
        ).toMap(),
      );

      final update = modify.set('attendanceRecords', records);
      await collection_attendance?.updateOne(query, update);
    }
  }
}

Future<void> checkOutAttendance(String userId) async {
  final currentDate = DateTime.now();
  final checkOutTime = DateFormat('hh:mm a').format(currentDate);
  final query = where.eq('userId', userId);

  final attendanceRecord = await collection_attendance?.findOne(query);

  if (attendanceRecord != null) {
    List<dynamic> records = attendanceRecord['attendanceRecords'];

    double totalOvertime = 0.0;

    for (var record in records) {
      final checkInDate = DateTime.parse(record['checkInDate']);
      if (checkInDate.year == currentDate.year &&
          checkInDate.month == currentDate.month &&
          checkInDate.day == currentDate.day) {
        final checkInTime = DateFormat('hh:mm a').parse(record['checkInTime']);
        final checkInDateTime = DateTime(
          checkInDate.year,
          checkInDate.month,
          checkInDate.day,
          checkInTime.hour,
          checkInTime.minute,
        );

        final requiredTime = checkInDateTime
            .add(const Duration(hours: 3)); // 12 hours for production
        if (currentDate.isAfter(requiredTime)) {
          // User has completed the required time
          final elapsedTime =
              currentDate.difference(requiredTime).inMinutes / 60.0;
          totalOvertime += elapsedTime;

          // Update the existing record
          record['checkOutDate'] = DateFormat('yyyy-MM-dd').format(currentDate);
          record['checkOutTime'] = checkOutTime;
          record['overtime'] = totalOvertime;
        } else {
          print("Checkout is not allowed before required time.");
          return; // Prevent updating if required time not completed
        }
      }
    }

    // Update the record in MongoDB
    final update = modify.set('attendanceRecords', records);
    await collection_attendance?.updateOne(query, update);
  } else {
    print("No attendance record found for checkout.");
  }
}
