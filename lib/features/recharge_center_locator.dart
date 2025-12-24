import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';


import 'package:url_launcher/url_launcher.dart';

import 'recharge_centers.dart';
import 'widget/city_dropdown.dart';



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

  static const LatLng _pakistanCenter = LatLng(30.3753, 69.3451);
  static const double _pakistanZoom = 5.0;

  final ValueNotifier<double> _zoomNotifier = ValueNotifier<double>(
    _pakistanZoom,
  );
  final ValueNotifier<LatLng> _centerNotifier = ValueNotifier<LatLng>(
    _pakistanCenter,
  );

  late List<Marker> _markers = [];
  Timer? _updateTimer;
  Timer? _markerRebuildTimer;
  final ValueNotifier<int> _markerVersion = ValueNotifier<int>(0);

  bool _isInitialized = false;
  bool _isAnimating = false;

  final Map<String, Widget> _markerWidgetCache = {};

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fabController.forward();
        _headerController.forward();
      }
    });

    _buildMarkersAsync();

    _updateTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _buildMarkersAsync(),
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _markerRebuildTimer?.cancel();
    _markerVersion.dispose();
    _fabController.dispose();
    _headerController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    _zoomNotifier.dispose();
    _centerNotifier.dispose();
    _markerWidgetCache.clear();
    super.dispose();
  }

  Future<void> _buildMarkersAsync() async {
    final markers = await _computeMarkers();
    if (mounted) {
      setState(() {
        _markers = markers;
        _isInitialized = true;
      });
      _markerVersion.value++;
    }
  }

  Future<List<Marker>> _computeMarkers() async {
    final List<Marker> newMarkers = [];

    await Future.microtask(() {
      for (final centers in RechargeCenter.allCenters.values) {
        for (final center in centers) {
          final bool isOpen = center.isOpenNow;
          final String cacheKey = '${center.name}_$isOpen';

          newMarkers.add(
            Marker(
              point: center.location,
              width: 120,
              height: 124,
              alignment: Alignment.topCenter,
              child: _buildMarkerWidget(center, isOpen, cacheKey),
            ),
          );
        }
      }
    });

    return newMarkers;
  }

  Widget _buildMarkerWidget(
    RechargeCenter center,
    bool isOpen,
    String cacheKey,
  ) {
    return GestureDetector(
      onTap: () => _showRechargeDetails(center),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 130, // MUST match Marker height
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          mainAxisSize: MainAxisSize.max, // ✅ FIX
          children: [
            // label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
              margin: const EdgeInsets.only(bottom: 1),
              decoration: BoxDecoration(
                color: ColorScheme.of(context).surface,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(maxWidth: 120),
              child: Column(mainAxisAlignment: .center,crossAxisAlignment: .center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    center.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextTheme.of(
                      context,
                    ).displaySmall?.copyWith( fontSize: 9),
                  ),

                  _statusChip(isOpen),
                ],
              ),
            ),

            // ✅ absorbs extra space
            Image.asset(
              isOpen ? 'assets/location_on.png' : 'assets/location_off.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w600,
          color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
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
    if (_isAnimating) return;

    setState(() {
      _searchTextController.clear();
      _isAnimating = true;
    });

    final target = RechargeCenter.cities[city]!;
    const targetZoom = 13.0;

    final controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    final curve = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    final startCenter = _mapController.camera.center;
    final startZoom = _mapController.camera.zoom;

    controller.addListener(() {
      if (!mounted) return;

      final t = curve.value;
      final lat =
          startCenter.latitude + (target.latitude - startCenter.latitude) * t;
      final lng =
          startCenter.longitude +
          (target.longitude - startCenter.longitude) * t;
      final zoom = startZoom + (targetZoom - startZoom) * t;

      _mapController.move(LatLng(lat, lng), zoom);
      _centerNotifier.value = LatLng(lat, lng);
      _zoomNotifier.value = zoom;
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _isAnimating = false);
        controller.dispose();
      }
    });

    await controller.forward();
  }

  void _animateZoom(double delta) {
    if (_isAnimating) return;

    final controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    final currentZoom = _mapController.camera.zoom;
    final targetZoom = (currentZoom + delta).clamp(5.0, 18.0);

    final anim = Tween<double>(
      begin: currentZoom,
      end: targetZoom,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    controller.addListener(() {
      if (!mounted) return;
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
          RepaintBoundary(
            child: ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, child) {
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    initialCenter: _pakistanCenter,
                    initialZoom: _pakistanZoom,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      enableMultiFingerGestureRace: true,
                    ),
                    onPositionChanged: (pos, hasGesture) {
                      if (!hasGesture || _isAnimating) return;

                      _markerRebuildTimer?.cancel();
                      _markerRebuildTimer = Timer(
                        const Duration(milliseconds: 50),
                        () {
                          if (mounted) {
                            _centerNotifier.value = pos.center;
                            _zoomNotifier.value = pos.zoom;
                          }
                        },
                      );
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                      userAgentPackageName: 'com.playdev.mtagapp',
                      tileProvider: NetworkTileProvider(),
                      maxNativeZoom: 18,
                      maxZoom: 18,
                      keepBuffer: 2,
                    ),
                    if (_isInitialized)
                      ValueListenableBuilder<int>(
                        valueListenable: _markerVersion,
                        builder: (_, version, _) {
                          return MarkerClusterLayerWidget(
                            options: MarkerClusterLayerOptions(
                              maxClusterRadius: 80,
                              size: const Size(50, 50),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(40),
                              markers: _markers,
                              polygonOptions: const PolygonOptions(
                                borderColor: Colors.transparent,
                                color: Colors.transparent,
                                borderStrokeWidth: 0,
                              ),
                              builder: (context, markers) {
                                final count = markers.length;
                                final size = count > 100
                                    ? 60.0
                                    : count > 50
                                    ? 55.0
                                    : 50.0;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue.shade500,
                                        Colors.blue.shade700,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      count > 999 ? '999+' : '$count',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: count > 99 ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              spiderfyCircleRadius: 80,
                              spiderfySpiralDistanceMultiplier: 3,
                              circleSpiralSwitchover: 12,
                              showPolygon: false,
                              disableClusteringAtZoom: 16,
                              zoomToBoundsOnClick: true,
                              centerMarkerOnClick: true,
                              rotate: true,
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: SlideTransition(
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
              child: FadeTransition(
                opacity: _headerController,
                child: CityDropdown(
                  cities: RechargeCenter.cities.keys.toList(),
                  onCitySelected: _onCityChanged,
                  placeholder: "Select City",
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 100,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _fabController,
                curve: Curves.easeOutBack,
              ),
              child: ZoomControl(
                onPlus: () => _animateZoom(1),
                onMinus: () => _animateZoom(-1),
              ),
            ),
          ),

          if (!_isInitialized)
            Positioned.fill(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
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
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(128),
      useSafeArea: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: RechargeCenterBottomSheet(
              center: center,
              onOpenMap: () => _openInGoogleMaps(center.location),
            ),
          ),
        );
      },
    );
  }
}
