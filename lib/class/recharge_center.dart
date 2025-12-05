import 'package:latlong2/latlong.dart';

class RechargeCenter {
  final String name;
  final LatLng location;
  final String timing;
  final String information;

  RechargeCenter(this.name, this.location, this.timing, this.information);

  bool get isOpenNow {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (timing.trim() == '24 Hours') return true;

    final match = RegExp(
      r'(\d{1,2})\s*(AM|PM)\s*-\s*(\d{1,2})\s*(AM|PM)',
      caseSensitive: false,
    ).firstMatch(timing);
    if (match == null) return false;

    int to24(String h, String p) {
      int hour = int.parse(h);
      if (p.toUpperCase() == 'PM' && hour != 12) hour += 12;
      if (p.toUpperCase() == 'AM' && hour == 12) hour = 0;
      return hour;
    }

    final openHour = to24(match.group(1)!, match.group(2)!);
    var closeHour = to24(match.group(3)!, match.group(4)!);

    var openTime = today.add(Duration(hours: openHour));
    var closeTime = today.add(Duration(hours: closeHour));

    if (closeHour <= openHour) {
      closeTime = closeTime.add(const Duration(days: 1));
    }

    return now.isAfter(openTime) && now.isBefore(closeTime);
  }
}
