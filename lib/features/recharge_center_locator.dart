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

  for (final centers in RechargeCenter.allCenters.values) {
    for (final center in centers) {
      final bool isOpen = center.isOpenNow;
      final markerIcon = isOpen 
          ? 'assets/location_on.png' 
          : 'assets/location_off.png';

      newMarkers.add(
        Marker(
          point: center.location,
          width: 150,  // Increased for info window
          height: 120, // Increased for info window + marker
          child: GestureDetector(
            onTap: () => _showRechargeDetails(center),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info Window (always visible)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        center.name,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        isOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          fontSize: 9,
                          color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Marker Icon
                Image.asset(markerIcon, width: 62, height: 62),
              ],
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

    final target = RechargeCenter.cities[city]!;
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
                options: MapOptions(backgroundColor: ColorScheme.of(context).surface,
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
              cities: RechargeCenter.cities.keys.toList(),
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

      barrierColor: Colors.black.withAlpha(80),
      enableDrag: true,useSafeArea: true,showDragHandle: true,scrollControlDisabledMaxHeightRatio: MediaQuery.devicePixelRatioOf(context),
      builder: (ctx) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(ctx),
          child: DraggableScrollableSheet(expand: false,
            initialChildSize: .6,
            minChildSize: 0.5,
            maxChildSize: .8,
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
