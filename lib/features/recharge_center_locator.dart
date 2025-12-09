import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import 'package:latlong2/latlong.dart';
import 'package:mtag_flutterapp/widgets/dropdown/city_dropdown.dart';
import 'package:mtag_flutterapp/widgets/zoom_control.dart';
import 'package:url_launcher/url_launcher.dart';

import '../class/recharge_center.dart';
import '../widgets/bottomsheet/recharge_center_bottomsheet.dart';


class RechargeMapScreen extends StatefulWidget {
  const RechargeMapScreen({super.key});

  @override
  State<RechargeMapScreen> createState() => _RechargeMapScreenState();
}

class _RechargeMapScreenState extends State<RechargeMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _fabController;
  late AnimationController _headerController;
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final ValueNotifier<double> _zoomNotifier = ValueNotifier<double>(12.5);
  final ValueNotifier<LatLng> _centerNotifier = ValueNotifier<LatLng>(
    const LatLng(33.6844, 73.0479),
  );

  late List<Marker> _markers;
  Timer? _timer;
  final ValueNotifier<bool> _markersNeedUpdate = ValueNotifier<bool>(true);

  final Map<String, LatLng> _cities = {
    'Islamabad': const LatLng(33.6844, 73.0479),
    'Rawalpindi': const LatLng(33.5651, 73.0169),
    'Lahore': const LatLng(31.5204, 74.3587),
    'Karachi': const LatLng(24.984362758794767,67.22035480754474),
    'Faisalabad': const LatLng(31.529431504602208,73.06667709551853),
    'Multan': const LatLng(30.1575, 71.5249),
    'Peshawar': const LatLng(34.03039708462152, 71.66326084028518),
    'Shujabad':const LatLng(29.994101,71.387735),
    'Quetta': const LatLng(30.1798, 66.9750),
    'Hyderabad':const LatLng(25.369756757942742,68.21567818242164, )
  };

  final Map<String, List<RechargeCenter>> _allCenters = {
    'Islamabad': [ 
RechargeCenter(
'Fatima Jinnah',
const LatLng(33.69583333333333, 73.01555555555555),
'24 Hours',
"M-Tag Recharge Center",
),
RechargeCenter(
'I-8 Kachnar',
const LatLng(33.67611111111111, 73.0761111111111),
'8 AM - 11 AM',
"M-Tag Recharge Center",
),
RechargeCenter(
'Gulburg Green',
const LatLng(33.60413888888889, 73.162),
'8 AM - 4 PM',
"M-Tag Recharge Center",
),
      RechargeCenter(
'26 No Chungi',
const LatLng(33.3634, 72.5402),
'8 AM - 4 PM',
"M-Tag Recharge Center",
),
RechargeCenter(
'I 11',
const LatLng(33.640163, 73.025085),
'9 AM - 11 PM',
"M-Tag Recharge Center",
),
RechargeCenter(
'Tarlai CFC',
const LatLng(33.646388888888886, 73.16222222222223),
'8 AM - 10 PM',
"M-Tag Recharge Center",
),
RechargeCenter(
'Lake view Park',
const LatLng(33.71555555555556, 73.13277777777778),
'9 AM - 11 PM',
"M-Tag Recharge Center",
),
RechargeCenter(
'Islamabad Club',
const LatLng(33.70527777777778, 73.1061111111111),
'24 Hours',
"M-Tag Recharge Center",
),
RechargeCenter(
'ETO Islamabad',
const LatLng(33.67492, 73.0538588),
'8 AM - 11 AM',
"M-Tag Recharge Center",
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
        const LatLng(31.529431504602208,73.06667709551853),
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
        'Zahir pir',
        const LatLng(28.84695137286077,70.50889644821397),
        '9 AM - 10 PM',
        "M-Tag Recharge Center",
      ),
      RechargeCenter(
        'Uch Sharif',
        const LatLng(29.24691748539767,71.03776706881527),
        '10 AM - 11 PM',
        "M-Tag Recharge Center",
      ),
      RechargeCenter(
        'ShujaAbad Svc Area North',
        const LatLng(29.994101,71.387735),
        '9 AM - 9 PM',
        "M-Tag Recharge Center",
      ),
      RechargeCenter(
        'Shujabad Svc Area South',
        const LatLng(29.994101,71.387735),
        '24 Hours',
        "M-Tag Recharge Center",
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

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fabController.forward();
    _headerController.forward();
    _zoomNotifier.value = 12.5;

    _updateMarkers();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateMarkers(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _markersNeedUpdate.dispose();
    _fabController.dispose();
    _headerController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    _zoomNotifier.dispose();
    _centerNotifier.dispose();
    super.dispose();
  }

  void _updateMarkers() {
    final List<Marker> newMarkers = [];

    for (final centers in _allCenters.values) {
      for (final center in centers) {
        final bool isOpen = center.isOpenNow;

        newMarkers.add(
          Marker(
            point: center.location,
            width: 100,
            height: 100,
            child: GestureDetector(
              onTap: () => _showRechargeDetails(center),
              child: Image.asset(
                isOpen ? 'assets/location_on.png' : 'assets/location_off.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
        );
      }
    }

    setState(() => _markers = newMarkers);
    _markersNeedUpdate.value = !_markersNeedUpdate.value;
  }

  Future<void> _openInGoogleMaps(LatLng latLng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onCityChanged(String city) async {
    setState(() {
      _searchTextController.clear();
    });

    final target = _cities[city]!;
    final controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    final curve = CurvedAnimation(
      parent: controller,
      curve: Curves.fastEaseInToSlowEaseOut,
    );
    final startCenter = _mapController.camera.center;
    final startZoom = _mapController.camera.zoom;

    controller.addListener(() {
      final t = curve.value;
      final easedT = t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
      final lat =
          startCenter.latitude +
          (target.latitude - startCenter.latitude) * easedT;
      final lng =
          startCenter.longitude +
          (target.longitude - startCenter.longitude) * easedT;
      final zoom = startZoom + (12.5 - startZoom) * easedT;
      _mapController.move(LatLng(lat, lng), zoom);
      _centerNotifier.value = LatLng(lat, lng);
      _zoomNotifier.value = zoom;
    });

    await controller.forward();
    controller.dispose();
  }

  void _animateZoom(double delta) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    final currentZoom = _mapController.camera.zoom;
    final anim = Tween<double>(
      begin: currentZoom,
      end: currentZoom + delta,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    controller.addListener(() {
      _mapController.move(_mapController.camera.center, anim.value);
      _zoomNotifier.value = anim.value;
    });
    controller.forward().then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _zoomNotifier,
            builder: (context, zoom, child) {
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _centerNotifier.value,
                  initialZoom: zoom,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  onPositionChanged: (pos, _) {
                    _centerNotifier.value = pos.center;
                    _zoomNotifier.value = pos.zoom;
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                    userAgentPackageName: 'com.playdev.mtagapp',
                    tileProvider: NetworkTileProvider(),
                  ),

                  ValueListenableBuilder<bool>(
                    valueListenable: _markersNeedUpdate,
                    builder: (_, _, _) {
                      return MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                          maxClusterRadius: 60,
                          size: const Size(45, 45),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(30),
                          markers: _markers,
                          builder: (context, markers) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade600,
                                  Colors.blue.shade800,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withAlpha(125),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${markers.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          spiderfyCircleRadius: 60,
                          spiderfySpiralDistanceMultiplier: 2,
                          showPolygon: false,
                          disableClusteringAtZoom: 15,
                          zoomToBoundsOnClick: true,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),

          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: CityDropdown(
              cities: _cities.keys.toList(),
              onCitySelected: _onCityChanged,
              placeholder: "Select City",
            ),
          ),

          Positioned(
            right: 16,
            bottom: 100,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _fabController,
                curve: Curves.elasticOut,
              ),
              child: Column(
                children: [
                  ZoomControl(
                    onPlus: () => _animateZoom(1),
                    onMinus: () => _animateZoom(-1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRechargeDetails(RechargeCenter center) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(80),
      enableDrag: true,
      builder: (ctx) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(ctx),
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.8,
            snap: true,
            builder: (context, controller) {
              return GestureDetector(
                onTap: () {},
                child: RechargeCenterBottomSheet(
                  center: center,
                  onOpenMap: () => _openInGoogleMaps(center.location),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
