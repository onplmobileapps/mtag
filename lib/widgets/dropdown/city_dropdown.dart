import 'dart:async';
import 'package:flutter/material.dart';

class CityDropdown extends StatefulWidget {
  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String> onCitySelected;
  final String placeholder;
  final double? maxDropdownHeight;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  const CityDropdown({
    super.key,
    required this.cities,
    required this.onCitySelected,
    this.selectedCity,
    this.placeholder = "Select City",
    this.maxDropdownHeight,
    this.padding,
    this.enabled = true,
  });

  @override
  State<CityDropdown> createState() => _CityDropdownState();
}

class _CityDropdownState extends State<CityDropdown>
    with SingleTickerProviderStateMixin {
  bool _isDropdownOpen = false;
  late String? _selectedCity;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late List<String> _filteredCities;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  late AnimationController _arrowController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.selectedCity;
    _filteredCities = widget.cities;
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(CityDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCity != widget.selectedCity) {
      _selectedCity = widget.selectedCity;
    }
    if (oldWidget.cities != widget.cities) {
      _filteredCities = widget.cities;
    }
  }

  @override
  void dispose() {
    _closeDropdown();
    _arrowController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() => _isDropdownOpen = true);
    _arrowController.forward();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(
      const Duration(milliseconds: 50),
          () {
        if (mounted && _searchFocusNode.canRequestFocus) {
          _searchFocusNode.requestFocus();
        }
      },
    );
  }

  void _closeDropdown() {
    if (!_isDropdownOpen) return;

    setState(() => _isDropdownOpen = false);
    _arrowController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.clear();
    _filteredCities = widget.cities;
    _searchFocusNode.unfocus();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      setState(() {
        if (query.isEmpty) {
          _filteredCities = widget.cities;
        } else {
          _filteredCities = widget.cities
              .where((city) => city.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      });
      _overlayEntry?.markNeedsBuild();
    });
  }

  void _onCitySelected(String city) {
    _selectedCity = city;
    _closeDropdown();
    widget.onCitySelected(city);
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;
    final position = renderBox.localToGlobal(Offset.zero);

    final availableSpaceBelow = screenHeight - position.dy - size.height;
    final availableSpaceAbove = position.dy;
    final maxHeight = widget.maxDropdownHeight ??
        MediaQuery.of(context).size.height * 0.4;

    final showAbove = availableSpaceBelow < 200 && availableSpaceAbove > availableSpaceBelow;
    final actualMaxHeight = showAbove
        ? (availableSpaceAbove - 16).clamp(150.0, maxHeight)
        : (availableSpaceBelow - 16).clamp(150.0, maxHeight);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, showAbove ? -actualMaxHeight - 8 : size.height + 8),
                child: Material(
                  color: Colors.transparent,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: actualMaxHeight,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Search field
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: _onSearchChanged,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  hintText: 'Search cities',
                                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      size: 20,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                      : null,
                                  suffixIconConstraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  isDense: true,
                                ),
                              ),
                            ),
                            // Cities list
                            Flexible(
                              child: _filteredCities.isEmpty
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    'No cities found',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              )
                                  : ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _filteredCities.length,
                                itemBuilder: (context, index) {
                                  final city = _filteredCities[index];
                                  final isSelected = city == _selectedCity;

                                  return InkWell(
                                    onTap: () => _onCitySelected(city),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
                                            : Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              city,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: isSelected
                                                    ? Theme.of(context).colorScheme.primary
                                                    : Theme.of(context).colorScheme.onSurface,
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              size: 20,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: Container(
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isDropdownOpen
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: _isDropdownOpen ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: _isDropdownOpen
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedCity ?? widget.placeholder,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _selectedCity != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_arrowController),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: _isDropdownOpen
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}