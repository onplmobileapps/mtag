import 'package:latlong2/latlong.dart';

class RechargeCenter {
  final String name;
  final LatLng location;
  final String timing;
  final String information;

  RechargeCenter(this.name, LatLng location, this.timing, this.information)
      : location = (location.latitude.isFinite && location.longitude.isFinite)
            ? location
            : const LatLng(30.3753, 69.3451);

  static final Map<String, LatLng> cities = {
    'Islamabad': const LatLng(33.6844, 73.0479),
    'Karachi': const LatLng(24.984362758794767,67.22035480754474),
    'Hyderabad': const LatLng(25.369756757942742,68.21567818242164),
    'Peshawar': const LatLng(34.03039708462152,71.66326084028518),
    'Swabi': const LatLng(34.04347989118024,72.41418227031748),
    'Swat': const LatLng(34.63046755761476,72.031054036588),
    'Abbottabad': const LatLng(34.097700671625326,73.16850922716046),
    'Mansehra': const LatLng(34.3301, 73.1996),
    'Mianwali': const LatLng(32.890437448342944,71.55341896256714),
    'Bhera': const LatLng(32.455369501857994,72.88520196004258),
    'Sheikhupura': const LatLng(31.7131, 73.9783),
    'Sial Morr': const LatLng(31.967397826742324,73.11229467470422),
    'Lahore': const LatLng(31.556942890173637,74.24293983040823),
    'Sialkot': const LatLng(32.46647220553786,74.39397918838688),
    'Khanewal': const LatLng(30.328147,71.849320),
    'Faisalabad': const LatLng(31.529431504602208,73.06667709551853),
    'Rahim Yar Khan': const LatLng(28.84695137286077,70.50889644821397),
    'Uch Sharif': const LatLng(29.24691748539767,71.03776706881527),
    'Rohri': const LatLng(27.663561,68.932347),
    'Multan': const LatLng(29.994101,71.387735),
    'Murree': const LatLng(33.778690,73.255337),
  };
  static final Map<String, List<RechargeCenter>> allCenters = {
    'Islamabad': [
      RechargeCenter(
        'Islamabad M1',
        LatLng(33.59779656249329,72.86474179630815),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'Islamabad M2',
        LatLng(33.5834262511135,72.87554699842836),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'ETO Islamabad',
        LatLng(33.67492 ,73.0538588),
        '9 AM - 5 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Fatima Jinnah Park',
        LatLng(33.695833, 73.015556),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Kachnar Park I-8',
        LatLng(33.676111, 73.076111),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Gulburg Green',
        LatLng(33.604139, 73.162),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Tarlai CFC',
        LatLng(33.646389, 73.162222),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Lake View Park',
        LatLng(33.715556, 73.132778),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Islamabad Club',
        LatLng(33.705278, 73.106111),
        '9 AM - 9 PM',
        "Test Information",
      ),

      RechargeCenter(
        '26 No Chungi',
        LatLng(33.609444, 72.900556),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'F7/3 Gol Market',
        LatLng(33.726009 , 73.058243),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Metro Cash & Carry I-11 DT-1',
        LatLng(33.640163 , 73.025085),
        '9 AM - 9 PM',
        "Test Information",
      ),
    ],
    'Karachi': [
      RechargeCenter(
        'Karachi',
        const LatLng(24.984362758794767,67.22035480754474),
        '24 Hours',
        "Test Information",
      ),

    ],
    'Hyderabad': [
      RechargeCenter(
        'Hyderabad',
        const LatLng(25.369756757942742,68.21567818242164),
        '24 Hours',
        "Test Information",
      ),

    ],
    'Peshawar': [
      RechargeCenter(
        'Peshawar',
        const LatLng(34.03039708462152,71.66326084028518),
        '24 Hours',
        "",
      ),

    ],
    'Swabi':[
      RechargeCenter("Swabi", LatLng(34.04347989118024,72.41418227031748), "24 Hours","")
    ],
    'Swat':[
      RechargeCenter("Maba Dheri", LatLng(34.63046755761476,72.031054036588), "24 Hours","")
    ],
    'Abbottabad':[
      RechargeCenter("Havelian", LatLng(34.097700671625326,73.16850922716046), "24 Hours","")
    ],
    'Mansehra':[
      RechargeCenter("Mansehra Svc Area North/South", LatLng(34.276458754635584,73.21919607728485), "24 Hours","")
    ],
    'Mianwali':[
      RechargeCenter("Daud Khel", LatLng(32.890437448342944,71.55341896256714), "7 AM -7 PM","")
    ],
    'Bhera':[
      RechargeCenter("Bhera Service Area North", LatLng(32.455369501857994,72.88520196004258), "24 Hours",""),
      RechargeCenter("Bhera Service Area South", LatLng(32.453800409812516,72.88877116753743), "24 Hours","")
    ],
    'Sheikhupura':[
      RechargeCenter("Sheikhupura", LatLng(31.745014559641177,74.00833399409476), "24 Hours","")
    ],
    'Sial Morr':[
      RechargeCenter("Sial Mor Service Area South", LatLng(31.967397826742324,73.11229467470422), "24 Hours","")
    ],
    'Lahore':[
      RechargeCenter("Ravi Drive Thru", LatLng(31.556942890173637,74.24293983040823), "24 Hours",""),
      RechargeCenter("Ravi Toll Plaza Entry", LatLng(31.557397246034093,74.24134328156109), "24 Hours",""),
      RechargeCenter("Ravi Toll Plaza Exit", LatLng(31.557417294809696,74.24144262286782), "24 Hours",""),
      RechargeCenter("Adda Plot", LatLng(31.608217832048275,74.3005018315312), "7 AM - 7 PM",""),
      RechargeCenter("Nawaz Sharif", LatLng(31.464179991379087,74.4337395322497), "24 Hours",""),
    ],
    'Sialkot':[
      RechargeCenter("Sambrial", LatLng(32.46647220553786,74.39397918838688), "24 Hours","")
    ],
    'Khanewal':[
      RechargeCenter("Khanewal", LatLng(30.328147,71.849320), "24 Hours","")
    ],
    'Faisalabad': [
      RechargeCenter(
        'Faisalabad',
        const LatLng(31.529431504602208,73.06667709551853),
        '24 Hours',
        "",
      ),
      RechargeCenter(
        'Sahianwala Service Area North',
        const LatLng(31.69252826939195,73.23437371092342),
        '24 Hours',
        "",
      ),
      RechargeCenter(
        'Sahianwala Service Area South',
        const LatLng(31.692750280023205,73.23326936767734),
        '24 Hours',
        "",
      ),
      RechargeCenter(
        'Jaranwala Service Area North',
        const LatLng(31.160465203704554,73.29828851576679),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'Jaranwala Service Area South',
        const LatLng(31.16090564105646,73.29504221318815),
        '24 Hours',
        "",
      ),
      RechargeCenter(
        'DT-1 Samundari',
        const LatLng(31.0408143315026,73.0273424961958),
        '24 Hours',
        "",
      ),
    ],
    'Rahim Yar Khan':[
      RechargeCenter("Zahir pir", LatLng(28.84695137286077,70.50889644821397), "24 Hours","")
    ],
    'Uch Sharif':[
      RechargeCenter("Uch Sharif", LatLng(29.24691748539767,71.03776706881527), "24 Hours","")
    ],
    'Rohri':[
      RechargeCenter("Uch Sharif", LatLng(27.663561,68.932347), "24 Hours","")
    ],
    'Multan': [
      RechargeCenter(
        'ShujaAbad Svc Area South/North',
        const LatLng(29.994101,71.387735),
        '24 Hours',
        "",
      ),

    ],
    'Murree': [
      RechargeCenter(
        'Phulgaran (Murree Exp)',
        const LatLng(33.778690,73.255337),
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
