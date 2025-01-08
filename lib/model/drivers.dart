class Driver {
  String? id; // MongoDB ObjectId
  String driverId;
  String driverPassword;
  String driverName;
  String mobileNumber;
  String? location;
  String? driverPin;
  String driverLicenceNumber;
  List<dynamic> trips;
  DateTime driverLicenceExpiryDate;
  String? notesAboutDriver;
  String? driverPhoto;

  Driver({
    this.id,
    required this.driverId,
    required this.driverPassword,
    required this.driverName,
    required this.mobileNumber,
    this.location,
    this.driverPin,
    required this.driverLicenceNumber,
    this.trips = const [],
    required this.driverLicenceExpiryDate,
    this.notesAboutDriver,
    this.driverPhoto,
  });

  // Convert a Driver instance to a Map for MongoDB insertion
  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': {'\$oid': id},
      'driverId': driverId,
      'driverPassword': driverPassword,
      'driverName': driverName,
      'mobileNumber': mobileNumber,
      'location': location,
      'driverPin': driverPin,
      'driverLicenceNumber': driverLicenceNumber,
      'trips': trips,
      'driverLicenceExpiryDate': driverLicenceExpiryDate.toIso8601String(),
      'notesAboutDriver': notesAboutDriver,
      'driverPhoto': driverPhoto,
    };
  }

  // Create a Driver instance from a MongoDB document
  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['_id']?['\$oid'],
      driverId: map['driverId'],
      driverPassword: map['driverPassword'],
      driverName: map['driverName'],
      mobileNumber: map['mobileNumber'],
      location: map['location'],
      driverPin: map['driverPin'],
      driverLicenceNumber: map['driverLicenceNumber'],
      trips: List<dynamic>.from(map['trips'] ?? []),
      driverLicenceExpiryDate: DateTime.parse(map['driverLicenceExpiryDate']['\$date']),
      notesAboutDriver: map['notesAboutDriver'],
      driverPhoto: map['driverPhoto'],
    );
  }
}
