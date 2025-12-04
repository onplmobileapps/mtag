import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 150);

  String _selectedCity = 'Islamabad';
  bool _isDropdownOpen = false;
  List<String> _filteredCities = [];
  final double _dropdownHeight = 400;

  final ValueNotifier<double> _zoomNotifier = ValueNotifier<double>(12.5);
  final ValueNotifier<LatLng> _centerNotifier = ValueNotifier<LatLng>(
    const LatLng(33.6844, 73.0479),
  );

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
        '8 AM - 10 PM',
        "Test Information",
      ),
      RechargeCenter(
        'F-11 Markaz',
        const LatLng(33.6789, 72.9999),
        '9 AM - 9 PM',
        "Test Information",
      ),
      RechargeCenter(
        'Zero Point - G-7',
        const LatLng(33.6992, 73.0625),
        '24 Hours',
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

  late final List<Marker> _cachedMarkers = _getAllMarkers();

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

    _filteredCities = _cities.keys.toList();

    _fabController.forward();
    _headerController.forward();

    _centerNotifier.value = _cities[_selectedCity]!;
    _zoomNotifier.value = 12.5;
  }

  @override
  void dispose() {
    _fabController.dispose();
    _headerController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    _zoomNotifier.dispose();
    _centerNotifier.dispose();
    super.dispose();
  }

  Future<void> _openInGoogleMaps(LatLng latLng) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
    }
  }

  Future<void> _onCityChanged(String city) async {
    if (city == _selectedCity && _isDropdownOpen) {
      _toggleDropdown();
      return;
    }

    setState(() {
      _selectedCity = city;
      _isDropdownOpen = false;
      _searchTextController.clear();
      _filteredCities = _cities.keys.toList();
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
    final targetZoom = 12.5;

    controller.addListener(() {
      final t = curve.value;
      final easedT = t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;

      final lat =
          startCenter.latitude +
          (target.latitude - startCenter.latitude) * easedT;
      final lng =
          startCenter.longitude +
          (target.longitude - startCenter.longitude) * easedT;
      final zoom = startZoom + (targetZoom - startZoom) * easedT;

      _mapController.move(LatLng(lat, lng), zoom);

      _centerNotifier.value = LatLng(lat, lng);
      _zoomNotifier.value = zoom;
    });

    await controller.forward();
    controller.dispose();
  }

  List<Marker> _getAllMarkers() {
    final markers = <Marker>[];

    for (final entry in _allCenters.entries) {
      for (final center in entry.value) {
        markers.add(
          Marker(
            point: center.location,
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => _showRechargeDetails(center),
              child: Material(
                elevation: 4,
                shape: const CircleBorder(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade50, Colors.white],
                    ),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset('assets/location.png'),
                ),
              ),
            ),
          ),
        );
      }
    }
    return markers;
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
      if (!_isDropdownOpen) {
        _searchTextController.clear();
        _filteredCities = _cities.keys.toList();
      } else {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _searchFocusNode.requestFocus();
          }
        });
      }
    });
  }

  void _filterCities(String query) {
    _searchDebouncer.run(() {
      if (mounted) {
        setState(() {
          _filteredCities = _cities.keys
              .where((city) => city.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      }
    });
  }

  void _animateZoom(double delta) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final currentZoom = _mapController.camera.zoom;
    final zoomAnim = Tween<double>(
      begin: currentZoom,
      end: currentZoom + delta,
    );

    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      final zoom = zoomAnim.evaluate(curve);
      _mapController.move(_mapController.camera.center, zoom);
      _zoomNotifier.value = zoom;
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
                  onPositionChanged: (position, hasGesture) {
                    if (!hasGesture) return;
                    _centerNotifier.value = position.center;
                    _zoomNotifier.value = position.zoom;
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                    userAgentPackageName: 'com.playdev.mtagapp',
                    tileProvider: NetworkTileProvider(),
                    maxZoom: 19.0,
                  ),
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius:
                          60,
                      size: const Size(45, 45),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(30),
                      markers: _cachedMarkers,
                      builder: (context, markers) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.blue.shade800,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
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
                        );
                      },
                      spiderfyCircleRadius: 60,
                      spiderfySpiralDistanceMultiplier: 2,
                      showPolygon: false,
                      disableClusteringAtZoom: 15,
                      zoomToBoundsOnClick: true,
                    ),
                  ),
                ],
              );
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withAlpha(125), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _headerController,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(
                      _isDropdownOpen ? 20 : 20,
                    ),
                    shadowColor: Colors.black.withAlpha(39),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(105),
                        borderRadius: BorderRadius.circular(
                          _isDropdownOpen ? 20 : 20,
                        ),
                        border: Border.all(
                          color: Colors.white.withAlpha(105),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          _isDropdownOpen ? 20 : 20,
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Column(
                            children: [
                              // Selected City Display
                              GestureDetector(
                                onTap: _toggleDropdown,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue.shade500,
                                              Colors.blue.shade700,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.location_city,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedCity,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      RotationTransition(
                                        turns: Tween<double>(begin: 0, end: 0.5)
                                            .animate(
                                              CurvedAnimation(
                                                parent: _headerController,
                                                curve: Curves.easeInOut,
                                              ),
                                            ),
                                        child: Icon(
                                          Icons.arrow_drop_down_rounded,
                                          color: Colors.blue.shade700,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (_isDropdownOpen) ...[
                                Divider(
                                  height: 1,
                                  color: Colors.grey.shade200,
                                  indent: 16,
                                  endIndent: 16,
                                ),

                                // Search Field
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(12),
                                    child: TextField(
                                      controller: _searchTextController,
                                      focusNode: _searchFocusNode,
                                      decoration: InputDecoration(
                                        hintText: 'Search city...',
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                        suffixIcon:
                                            _searchTextController
                                                .text
                                                .isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  _searchTextController.clear();
                                                  _filterCities('');
                                                },
                                              )
                                            : null,
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                      ),
                                      onChanged: _filterCities,
                                    ),
                                  ),
                                ),

                                Container(
                                  constraints: BoxConstraints(
                                    maxHeight: _dropdownHeight - 130,
                                  ),
                                  child: NotificationListener<ScrollNotification>(
                                    onNotification: (notification) {
                                      return true;
                                    },
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _filteredCities.length,
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      itemBuilder: (context, index) {
                                        final city = _filteredCities[index];
                                        return Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => _onCityChanged(city),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 4,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _selectedCity == city
                                                    ? Colors.blue.shade50
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: _selectedCity == city
                                                    ? Border.all(
                                                        color: Colors
                                                            .blue
                                                            .shade300,
                                                        width: 1.5,
                                                      )
                                                    : null,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    color: _selectedCity == city
                                                        ? Colors.blue.shade700
                                                        : Colors.grey.shade600,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      city,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            _selectedCity ==
                                                                city
                                                            ? Colors
                                                                  .blue
                                                                  .shade800
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                  if (_selectedCity == city)
                                                    Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color:
                                                          Colors.blue.shade700,
                                                      size: 20,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                  _buildFabButton(
                    Icons.add_rounded,
                    () => _animateZoom(1),
                    gradient: true,
                  ),
                  const SizedBox(height: 8),
                  _buildFabButton(
                    Icons.remove_rounded,
                    () => _animateZoom(-1),
                    gradient: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabButton(
    IconData icon,
    VoidCallback onTap, {
    bool gradient = false,
  }) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withAlpha(50),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: Colors.blue.withAlpha(50),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: gradient
                ? LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                  )
                : null,
            color: gradient ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: gradient ? null : Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(
            icon,
            color: gradient ? Colors.white : Colors.grey.shade700,
            size: 22,
          ),
        ),
      ),
    );
  }

  void _showRechargeDetails(RechargeCenter center) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        snap: true,
        snapSizes: const [0.4, 0.6, 0.8],
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ListView(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildCenterHeader(center),
              const SizedBox(height: 24),
              _buildInfoRow(
                Icons.access_time_rounded,
                'Operating Hours',
                center.timing,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.info_outlined,
                'Information',
                center.information,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _openInGoogleMaps(center.location),
                icon: const Icon(
                  Icons.directions_rounded,
                  size: 22,
                  color: Colors.white,
                ),
                label: const Text(
                  'Open in Google Maps',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterHeader(RechargeCenter center) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade800],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withAlpha(80),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.store_mall_directory_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                center.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'M-Tag Recharge Point',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RechargeCenter {
  final String name;
  final LatLng location;
  final String timing;

  final String information;

  RechargeCenter(this.name, this.location, this.timing, this.information);
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
