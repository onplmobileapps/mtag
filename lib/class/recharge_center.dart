import 'package:latlong2/latlong.dart';

class RechargeCenter {
  final String name;
  final LatLng location;
  final String timing;
  final String information;

  RechargeCenter(this.name, this.location, this.timing, this.information);

  static final Map<String, LatLng> cities = {
    'Islamabad': const LatLng(33.6844, 73.0479),
    'Rawalpindi': const LatLng(33.5651, 73.0169),
    'Lahore': const LatLng(31.5204, 74.3587),
    'Karachi': const LatLng(24.8607, 67.0011),
    'Faisalabad': const LatLng(31.4504, 73.1350),
    'Multan': const LatLng(30.1575, 71.5249),
    'Peshawar': const LatLng(34.0151, 71.5249),
    'Quetta': const LatLng(30.1798, 66.9750),
  };
  static final Map<String, List<RechargeCenter>> allCenters = {
    'Islamabad': [
      RechargeCenter(
        'Fatima Jinnah',
        dmsToLatLng("33°41'45\"N 73°00'56\"E"),
        '9 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'I-8 Kachnar',
        dmsToLatLng("33°40'34\"N 73°04'34\"E"),
        '8 AM - 10 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Gulburg Green',
        dmsToLatLng("33°36'14.9\"N 73°09'43.2\"E"),
        '9 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'F-7-Islamabad',
        const LatLng(33.726009, 73.058243),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'I-11-Islamabad',
        const LatLng(33.640163, 73.025085),
        '8 AM - 11 AM',
        "Test Information",
      ),
      RechargeCenter(
        'Tarlai CFC',
        dmsToLatLng("33°38'47\"N 73°09'44\"E"),
        '8 AM - 4 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Lake View Park',
        dmsToLatLng("33°42'56\"N 73°07'58\"E"),
        '8 AM - 4 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Islamabad Club',
        dmsToLatLng("33°42'19\"N 73°06'22\"E"),
        '8 AM - 4 PM',
        "Test Information",
      ),
      RechargeCenter(
        'ETO Islamabad',
        LatLng(33.67492, 73.0538588),
        '8 AM - 4 PM',
        "Test Information",
      ),
      RechargeCenter(
        '26 No Chungi',
        dmsToLatLng("33°36'34\"N 72°54'02\"E"),
        '8 AM - 4 PM',
        "Test Information",
      ),
    ],
    'Rawalpindi': [
      RechargeCenter(
        'Saddar Cantt',
        const LatLng(33.5965, 73.0473),
        '9 AM - 10 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Bahria Town Phase 8',
        const LatLng(33.5272, 73.1116),
        '10 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Committee Chowk',
        const LatLng(33.5965, 73.0473),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'Satellite Town',
        const LatLng(33.6167, 73.0786),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Faizabad',
        const LatLng(33.6142, 73.1011),
        '8 AM - 10 PM',
        "Test Information",
      ),
      RechargeCenter(
        '6th Road',
        const LatLng(33.6269, 73.0807),
        '9 AM - 11 PM',
        "Test Information",
      ),
    ],
    'Lahore': [
      RechargeCenter(
        'Gulberg III - Liberty',
        const LatLng(31.5204, 74.3587),
        '9 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'DHA Phase 5',
        const LatLng(31.4697, 74.4085),
        '10 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Johar Town',
        const LatLng(31.4697, 74.2728),
        '9 AM - 10 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Model Town Link Road',
        const LatLng(31.4825, 74.3205),
        '8 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Thokar Niaz Baig',
        const LatLng(31.4567, 74.2289),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'Canal Bank - Shadman',
        const LatLng(31.5138, 74.3436),
        '9 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Mall Road',
        const LatLng(31.5546, 74.3371),
        '9 AM - 9 PM',
        "Test Information",
      ),
    ],
    'Karachi': [
      RechargeCenter(
        'Clifton - Sea View',
        const LatLng(24.8138, 67.0299),
        '9 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Saddar - Empress Market',
        const LatLng(24.8607, 67.0011),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'Gulshan-e-Iqbal',
        const LatLng(24.9211, 67.0877),
        '9 AM - 10 PM',
        "Test Information",
      ),
      RechargeCenter(
        'DHA Phase 8',
        const LatLng(24.7945, 67.0654),
        '10 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'North Nazimabad',
        const LatLng(24.9293, 67.0363),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Shahrah-e-Faisal',
        const LatLng(24.8674, 67.0589),
        '8 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Korangi Road',
        const LatLng(24.8378, 67.0872),
        '9 AM - 10 PM',
        "Test Information",
      ),
    ],
    'Faisalabad': [
      RechargeCenter(
        'D-Ground',
        const LatLng(31.4504, 73.1350),
        '9 AM - 10 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Kohinoor City',
        const LatLng(31.3926, 73.0862),
        '10 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Peoples Colony',
        const LatLng(31.4158, 73.0927),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Clock Tower',
        const LatLng(31.4181, 73.0794),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'Satiana Road',
        const LatLng(31.4012, 73.1098),
        '9 AM - 10 PM',
        "Test Information",
      ),
    ],
    'Multan': [
      RechargeCenter(
        'Cantonment',
        const LatLng(30.1575, 71.5249),
        '9 AM - 10 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Gulgasht Colony',
        const LatLng(30.1978, 71.4714),
        '10 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Boson Road',
        const LatLng(30.1921, 71.4678),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Vehari Chowk',
        const LatLng(30.1812, 71.4923),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'Chowk Kumharanwala',
        const LatLng(30.2067, 71.4798),
        '9 AM - 10 PM',
        "Test Information",
      ),
    ],
    'Peshawar': [
      RechargeCenter(
        'Saddar Cantt',
        const LatLng(34.0151, 71.5249),
        '9 AM - 10 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Hayatabad Phase 3',
        const LatLng(33.9719, 71.3848),
        '10 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'University Road',
        const LatLng(34.0114, 71.4689),
        '9 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Ring Road',
        const LatLng(33.9989, 71.4567),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'GT Road',
        const LatLng(34.0089, 71.5623),
        '8 AM - 10 PM',
        "Test Information",
      ),
    ],
    'Quetta': [
      RechargeCenter(
        'Jinnah Road',
        const LatLng(30.1798, 66.9750),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Satellite Town',
        const LatLng(30.2163, 67.0246),
        '10 AM - 10 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Sariab Road',
        const LatLng(30.1867, 67.0134),
        '9 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Brewery Road',
        const LatLng(30.1923, 67.0089),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'Alamdar Road',
        const LatLng(30.1987, 67.0356),
        '9 AM - 10 PM',
        "Test Information",
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
  final parts = dms.split(' ');
  if (parts.length != 2) throw FormatException('Invalid DMS format');

  double convert(String dmsPart) {
    int degIndex = dmsPart.indexOf('°');
    int minIndex = dmsPart.indexOf('\'');
    int secIndex = dmsPart.indexOf('"');

    double deg = double.parse(dmsPart.substring(0, degIndex));
    double min = double.parse(dmsPart.substring(degIndex + 1, minIndex));
    double sec = double.parse(dmsPart.substring(minIndex + 1, secIndex));
    String dir = dmsPart.substring(secIndex + 1);

    double decimal = deg + (min / 60) + (sec / 3600);
    if (dir == 'S' || dir == 'W') decimal = -decimal;

    return decimal;
  }

  return LatLng(convert(parts[0]), convert(parts[1]));
}
