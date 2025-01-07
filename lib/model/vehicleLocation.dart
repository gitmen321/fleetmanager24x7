// class VehicleLocation {
//   final double latitude;
//   final double longitude;

//   VehicleLocation({required this.latitude, required this.longitude});

//   factory VehicleLocation.fromMap(Map<String, dynamic> map) {
//     return VehicleLocation(
//       latitude: map['latitude'],
//       longitude: map['longitude'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'latitude': latitude,
//       'longitude': longitude,
//     };
//   }
// }

class VehicleLocation {
  final double? latitude; // Make latitude nullable
  final double? longitude; // Make longitude nullable

  VehicleLocation({required this.latitude, required this.longitude});

  factory VehicleLocation.fromMap(Map<String, dynamic> map) {
    return VehicleLocation(
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
