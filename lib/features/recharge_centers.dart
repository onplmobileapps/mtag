import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class RechargeCenter {
  final String name;
  final LatLng location;
  final String timing;
  final String information;

  RechargeCenter(this.name, this.location, this.timing, this.information);

  static final Map<String, LatLng> cities = {
    'Islamabad': const LatLng(33.6844, 73.0479),
    'Karachi': const LatLng(24.984362758794767, 67.22035480754474),
    'Hyderabad': const LatLng(25.369756757942742, 68.21567818242164),
    'Peshawar': const LatLng(34.03039708462152, 71.66326084028518),
    'Swat': const LatLng(34.63046755761476, 72.031054036588),
    'Abbottabad': const LatLng(34.097700671625326, 73.16850922716046),
    'Mansehra': const LatLng(34.3301, 73.1996),
    'Mianwali': const LatLng(32.890437448342944, 71.55341896256714),
    'Bhera': const LatLng(32.455369501857994, 72.88520196004258),
    'Lahore': const LatLng(31.556942890173637, 74.24293983040823),
    'Sialkot': const LatLng(32.46647220553786, 74.39397918838688),
    'Khanewal': const LatLng(30.328147, 71.849320),
    'Faisalabad': const LatLng(31.529431504602208, 73.06667709551853),
    'Uch Sharif': const LatLng(29.24691748539767, 71.03776706881527),
    'Rohri': const LatLng(27.663561, 68.932347),
    'Multan': const LatLng(29.994101, 71.387735),
    'Murree': const LatLng(33.778690, 73.255337),
  };
  static final Map<String, List<RechargeCenter>> allCenters = {
    'Islamabad': [
      RechargeCenter(
        'ETO',
        LatLng(33.67492, 73.0538588),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Gulberg Green',
        dmsToLatLng("33°36'14.9\"N 73°09'43.2\"E"),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        '26 No M-Tag Center',
        dmsToLatLng("33°36'34\"N 72°54'02\"E"),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'F-9 Park',
        LatLng(33.7056, 73.0189),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Faizabad',
        LatLng(33.673050, 73.080521),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'Gandum Godam',
        dmsToLatLng("33°38'03.0\"N 73°01'31.7\"E"),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Police Checkpost 9th Avenue',
        LatLng(33.6596, 73.0441),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Rawat',
        dmsToLatLng("33°31'13.9\"N 73°10'36.9\"E"),
        '9 AM - 9 PM',
        "Test Information",
      ),
    ],
    'Karachi': [
      RechargeCenter(
        'Karachi North',
        const LatLng(24.984362758794767, 67.22035480754474),
        '24 Hours',
        "Test Information",
      ),
    ],
    'Hyderabad': [
      RechargeCenter(
        'Hyderabad South',
        const LatLng(25.369756757942742, 68.21567818242164),
        '24 Hours',
        "Test Information",
      ),
    ],
    'Peshawar': [
      RechargeCenter(
        'Peshawar MTP South',
        const LatLng(34.03039708462152, 71.66326084028518),
        '24 Hours',
        "",
      ),
      RechargeCenter(
        'K Sher Khan MTP (South)',
        dmsToLatLng("34°04'33.1\"N 72°12'37.2\"E"),
        '24 Hours',
        "",
      ),
    ],
    'Swat': [
      RechargeCenter(
        "Maba Dheri / Swat (North)",
        LatLng(34.63046755761476, 72.031054036588),
        "24 Hours",
        "",
      ),
    ],
    'Abbottabad': [
      RechargeCenter(
        "Havelian",
        LatLng(34.097700671625326, 73.16850922716046),
        "24 Hours",
        "",
      ),
      RechargeCenter(
        "Malpur",
        dmsToLatLng("33°43'52.9\"N 73°08'52.9\"E"),
        "24 Hours",
        "",
      ),
    ],
    'Mansehra': [
      RechargeCenter(
        "Mansehra Svc Area North",
        LatLng(34.276458754635584, 73.21919607728485),
        "24 Hours",
        "",
      ),
      RechargeCenter(
        "Mansehra Svc Area South",
        LatLng(33.7297, 73.0784),
        "24 Hours",
        "",
      ),
    ],
    'Mianwali': [
      RechargeCenter(
        "Daud Khel",
        LatLng(32.890437448342944, 71.55341896256714),
        "7 AM -7 PM",
        "",
      ),
    ],
    'Bhera': [
      RechargeCenter(
        "Bhera Service Area North",
        LatLng(32.455369501857994, 72.88520196004258),
        "24 Hours",
        "",
      ),
      RechargeCenter(
        "Bhera Service Area South",
        LatLng(32.453800409812516, 72.88877116753743),
        "24 Hours",
        "",
      ),
    ],
    'Lahore': [
      RechargeCenter(
        "Ravi Drive Thru",
        LatLng(31.556942890173637, 74.24293983040823),
        "24 Hours",
        "",
      ),
      RechargeCenter(
        "Ravi SFU Entry",
        LatLng(31.557397246034093, 74.24134328156109),
        "24 Hours",
        "",
      ),
      RechargeCenter(
        "Ravi SFU Exit",
        LatLng(31.557417294809696, 74.24144262286782),
        "24 Hours",
        "",
      ),
      RechargeCenter(
        "Adda Plot",
        LatLng(31.608217832048275, 74.3005018315312),
        "8 AM - 8 PM",
        "",
      ),
      RechargeCenter(
        "Nawaz Sharif",
        LatLng(31.464179991379087, 74.4337395322497),
        "24 Hours",
        "",
      ),
      RechargeCenter(
        "Gutwala MTP South",
        LatLng(31.4988, 73.2384),
        "24 Hours",
        "",
      ),
      RechargeCenter(
        "Kala Shah Kaku Entry",
        dmsToLatLng("31°41'49.4\"N 74°16'09.7\"E"),
        "24 Hours",
        "",
      ),
      RechargeCenter(
        "Mominpura MTP North",
        dmsToLatLng("31°38'45.2\"N 74°10'34.7\"E"),
        "24 Hours",
        "",
      ),
    ],
    'Sialkot': [
      RechargeCenter(
        "Sambrial (LSM)",
        LatLng(32.46647220553786, 74.39397918838688),
        "24 Hours",
        "",
      ),
      RechargeCenter(
        "Kala Shah Kaku (LSM)",
        dmsToLatLng("31°43'41.6\"N 74°18'51.2\"E"),
        "24 Hours",
        "",
      ),
    ],
    'Khanewal': [
      RechargeCenter(
        "Khanewal M4",
        LatLng(30.328147, 71.849320),
        "24 Hours",
        "",
      ),
    ],
    'Faisalabad': [
      RechargeCenter(
        'Faisalabad M4',
        const LatLng(31.529431504602208, 73.06667709551853),
        '24 Hours',
        "",
      ),
      RechargeCenter(
        'SahiyanWala Svc Area North M4',
        const LatLng(31.69252826939195, 73.23437371092342),
        '24 Hours',
        "",
      ),
      RechargeCenter(
        'SahiyanWala Svc Area South M4',
        const LatLng(31.692750280023205, 73.23326936767734),
        '24 Hours',
        "",
      ),
      RechargeCenter(
        'JaraanWala Svc Area North M3',
        const LatLng(31.160465203704554, 73.29828851576679),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'JaraanWala SVC Area South M3',
        const LatLng(31.16090564105646, 73.29504221318815),
        '24 Hours',
        "",
      ),
    ],
    'Uch Sharif': [
      RechargeCenter(
        "Uch Sharif",
        LatLng(29.24691748539767, 71.03776706881527),
        "8 AM - 8 PM",
        "",
      ),
    ],
    'Rohri': [
      RechargeCenter("Rohri M5", LatLng(27.663561, 68.932347), "24 Hours", ""),
    ],
    'Multan': [
      RechargeCenter(
        'ShujaAbad Svc Area North M5',
        dmsToLatLng("29°59'40.1\"N 71°02'18.1\"E"),
        '24 Hours',
        "",
      ),
      RechargeCenter(
        'Shujabad Svc Area South M5',
        dmsToLatLng("29°59'43.6\"N 71°23'15.9\"E"),
        '24 Hours',
        "",
      ),
    ],
    'Murree': [
      RechargeCenter(
        'Phulgaran',
        const LatLng(33.778690, 73.255337),
        '24 Hours',
        "",
      ),
      RechargeCenter(
        'Tulip (Murree Road)',
        dmsToLatLng("33°40'23.7\"N 73°04'49.6\"E"),
        '24 Hours',
        "",
      ),
    ],
  };

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

LatLng dmsToLatLng(String dms) {
  try {
    final parts = dms.trim().split(RegExp(r'\s+'));
    if (parts.length != 2) return const LatLng(0, 0);

    double convert(String dmsPart) {
      int degIndex = dmsPart.indexOf('°');
      int minIndex = dmsPart.indexOf('\'');
      int secIndex = dmsPart.indexOf('"');

      if (degIndex == -1 || minIndex == -1) return 0.0;

      double deg = double.tryParse(dmsPart.substring(0, degIndex)) ?? 0.0;
      double min =
          double.tryParse(dmsPart.substring(degIndex + 1, minIndex)) ?? 0.0;
      double sec = 0.0;
      if (secIndex != -1) {
        sec = double.tryParse(dmsPart.substring(minIndex + 1, secIndex)) ?? 0.0;
      } else {
        // Handle cases like 33°36'N
        sec = 0.0;
        secIndex = minIndex; // Adjusted for dir parsing
      }

      String dir = dmsPart.substring(dmsPart.length - 1);

      double decimal = deg + (min / 60) + (sec / 3600);
      if (dir == 'S' || dir == 'W') decimal = -decimal;

      return decimal;
    }

    final lat = convert(parts[0]);
    final lng = convert(parts[1]);

    if (lat.isFinite && lng.isFinite) {
      return LatLng(lat, lng);
    }
    return const LatLng(0, 0);
  } catch (e) {
    debugPrint('Error parsing DMS: $dms - $e');
    return const LatLng(0, 0);
  }
}
