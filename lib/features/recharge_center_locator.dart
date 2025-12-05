import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:mtag_flutterapp/widgets/dropdown/city_dropdown.dart';
import 'package:mtag_flutterapp/widgets/zoom_control.dart';
import 'package:url_launcher/url_launcher.dart';

import '../class/recharge_center.dart';
import '../widgets/bottomsheet/recharge_center_bottomsheet.dart';
import '../widgets/elevated_button.dart';

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
    'Karachi': const LatLng(24.8607, 67.0011),
    'Faisalabad': const LatLng(31.4504, 73.1350),
    'Multan': const LatLng(30.1575, 71.5249),
    'Peshawar': const LatLng(34.0151, 71.5249),
    'Quetta': const LatLng(30.1798, 66.9750),
  };

  final Map<String, List<RechargeCenter>> _allCenters = {
    'Islamabad': [
      RechargeCenter(
        'Blue Area - Jinnah Super',
        const LatLng(33.7181, 73.0776),
        '9 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'F-7 Markaz',
        const LatLng(33.7215, 73.0433),
        '8 AM - 10 PM',
        "Test Information",
      ),
      RechargeCenter(
        'F-10 Markaz',
        const LatLng(33.6955, 73.0128),
        '9 AM - 11 PM',
        "Test Information",
      ),
      RechargeCenter(
        'G-9 Markaz',
        const LatLng(33.6844, 73.0479),
        '24 Hours',
        "Test Information",
      ),
      RechargeCenter(
        'I-8 Markaz',
        const LatLng(33.6659, 73.0785),
        '8 AM - 11 AM',
        "Test Information",
      ),
      RechargeCenter(
        'F-11 Markaz',
        const LatLng(33.6789, 72.9999),
        '8 AM - 4 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Zero Point - G-7',
        const LatLng(33.6992, 73.0625),
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
