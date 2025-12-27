import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'recharge_centers.dart';
import 'widget/city_dropdown.dart';
import 'widget/recharge_center_bottom_sheet.dart';
import 'widget/zoom_controller.dart';

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

  List<Marker> _markers = [];
  Timer? _updateTimer;
  Timer? _markerRebuildTimer;
  final ValueNotifier<int> _markerVersion = ValueNotifier<int>(0);

  bool _isInitialized = false;
  bool _isAnimating = false;
  bool _isDisposed = false;

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
      if (mounted && !_isDisposed) {
        _fabController.forward();
        _headerController.forward();
      }
    });

    _buildMarkersAsync();

    _updateTimer = Timer.periodic(
      const Duration(minutes: 5),
          (_) {
        if (mounted && !_isDisposed) {
          _buildMarkersAsync();
        }
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
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
    if (_isDisposed || !mounted) return;

    try {
      final markers = await _computeMarkers();
      if (mounted && !_isDisposed) {
        setState(() {
          _markers = markers;
          _isInitialized = true;
        });
        _markerVersion.value++;
      }
    } catch (e) {
      debugPrint('Error building markers: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<List<Marker>> _computeMarkers() async {
    final List<Marker> newMarkers = [];

    try {
      await Future.microtask(() {
        for (final centers in RechargeCenter.allCenters.values) {
          for (final center in centers) {
            try {
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
            } catch (e) {
              debugPrint('Error creating marker for ${center.name}: $e');
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error in computeMarkers: $e');
    }

    return newMarkers;
  }

  Widget _buildMarkerWidget(
      RechargeCenter center,
      bool isOpen,
      String cacheKey,
      ) {
    try {
      return GestureDetector(
        onTap: () {
          if (mounted && !_isDisposed) {
            _showRechargeDetails(center);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 130,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                margin: const EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxWidth: 120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      center.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontSize: 9),
                    ),
                    _statusChip(isOpen),
                  ],
                ),
              ),
              Image.asset(
                isOpen ? 'assets/location_on.png' : 'assets/location_off.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.location_on,
                    size: 60,
                    color: isOpen ? Colors.green : Colors.red,
                  );
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error building marker widget: $e');
      return const SizedBox(
        width: 60,
        height: 60,
        child: Icon(Icons.location_on, color: Colors.blue),
      );
    }
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
    try {
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch Google Maps');
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps application'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching Google Maps: $e');
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening maps'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _onCityChanged(String city) async {
    if (_isAnimating || _isDisposed || !mounted) return;

    try {
      setState(() {
        _searchTextController.clear();
        _isAnimating = true;
      });

      final target = RechargeCenter.cities[city];
      if (target == null) {
        setState(() => _isAnimating = false);
        return;
      }

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
        if (!mounted || _isDisposed) return;

        try {
          final t = curve.value;
          final lat = startCenter.latitude +
              (target.latitude - startCenter.latitude) * t;
          final lng = startCenter.longitude +
              (target.longitude - startCenter.longitude) * t;
          final zoom = startZoom + (targetZoom - startZoom) * t;

          _mapController.move(LatLng(lat, lng), zoom);
          _centerNotifier.value = LatLng(lat, lng);
          _zoomNotifier.value = zoom;
        } catch (e) {
          debugPrint('Error during animation: $e');
        }
      });

      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted && !_isDisposed) {
          setState(() => _isAnimating = false);
          controller.dispose();
        }
      });

      await controller.forward();
    } catch (e) {
      debugPrint('Error changing city: $e');
      if (mounted && !_isDisposed) {
        setState(() => _isAnimating = false);
      }
    }
  }

  void _animateZoom(double delta) {
    if (_isAnimating || _isDisposed || !mounted) return;

    try {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this,
      );

      final currentZoom = _mapController.camera.zoom;
      final targetZoom = (currentZoom + delta).clamp(5.0, 18.0);

      final anim = Tween<double>(
        begin: currentZoom,
        end: targetZoom,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );

      controller.addListener(() {
        if (!mounted || _isDisposed) return;
        try {
          _mapController.move(_mapController.camera.center, anim.value);
          _zoomNotifier.value = anim.value;
        } catch (e) {
          debugPrint('Error during zoom animation: $e');
        }
      });

      controller.forward().then((_) {
        if (!_isDisposed) {
          controller.dispose();
        }
      });
    } catch (e) {
      debugPrint('Error animating zoom: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => result,
      child: Scaffold(
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
                        if (!hasGesture || _isAnimating || _isDisposed || !mounted) {
                          return;
                        }

                        try {
                          _markerRebuildTimer?.cancel();
                          _markerRebuildTimer = Timer(
                            const Duration(milliseconds: 50),
                                () {
                              if (mounted && !_isDisposed) {
                                final center = pos.center;
                                final posZoom = pos.zoom;
                                _centerNotifier.value = center;
                                _zoomNotifier.value = posZoom;
                                                            }
                            },
                          );
                        } catch (e) {
                          debugPrint('Error in onPositionChanged: $e');
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.playdev.mtagapp',
                        maxNativeZoom: 18,
                        maxZoom: 18,
                        keepBuffer: 2,
                        errorTileCallback: (tile, error, stackTrace) {
                          debugPrint('Tile load error: $error');
                        },
                      ),

                      if (_isInitialized && _markers.isNotEmpty)
                        ValueListenableBuilder<int>(
                          valueListenable: _markerVersion,
                          builder: (_, version, _) {
                            try {
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
                                    try {
                                      final count = markers.length;
                                      final size = count > 100
                                          ? 60.0
                                          : count > 50
                                          ? 55.0
                                          : 50.0;

                                      return AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 200),
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
                                    } catch (e) {
                                      debugPrint('Error building cluster: $e');
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      );
                                    }
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
                            } catch (e) {
                              debugPrint('Error creating cluster layer: $e');
                              return const SizedBox.shrink();
                            }
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
                position: Tween<Offset>(
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

            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(230),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withAlpha(50),
                  ),
                ),
                child: Text(
                  '© OpenStreetMap © CARTO',
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(155),
                  ),
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
      ),
    );
  }

  void _showRechargeDetails(RechargeCenter center) {
    if (_isDisposed || !mounted) return;

    try {
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
    } catch (e) {
      debugPrint('Error showing bottom sheet: $e');
    }
  }
}