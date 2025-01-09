import 'package:fleet_manager_driver_app/view/registrations/generate_id_screen.dart';
import 'package:fleet_manager_driver_app/view/registrations/license_screen.dart';
import 'package:fleet_manager_driver_app/view/registrations/mobile_screen.dart';
import 'package:fleet_manager_driver_app/view/registrations/name_screen.dart';
import 'package:get/get.dart';

class RegistrationRoutes {
  static final routes = [
    GetPage(name: '/name', page: () => NameScreen()),
    GetPage(name: '/mobile', page: () => MobileScreen()),
    GetPage(name: '/generate-id', page: () => GenerateIdScreen()),
    GetPage(name: '/license', page: () => LicenseScreen()),
    // GetPage(name: '/expiry-date', page: () => ExpiryDateScreen()),
  ];
}
