import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart' as coding;

class LocationService {
  static Future<String> getCurrentLocation() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    // 1. Check if GPS hardware is turned on
    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return "GPS Disabled";

    // 2. Request Permissions
    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) return "Permission Denied";
    }

    if (permission == geo.LocationPermission.deniedForever) {
      return "Enable in Settings";
    }

    // 3. Get coordinates and convert to Area Name
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high
      );

      List<coding.Placemark> placemarks = await coding.placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        coding.Placemark place = placemarks[0];
        String area = (place.subLocality != null && place.subLocality!.isNotEmpty)
            ? place.subLocality!
            : (place.locality ?? "Chennai");

        return "$area, Chennai";
      }

      return "Chennai, India";
    } catch (e) {
      return "Chennai, India";
    }
  }
}