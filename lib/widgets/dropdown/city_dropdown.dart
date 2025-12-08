import 'dart:async';
import 'package:flutter/material.dart';

class CityDropdown extends StatefulWidget {
  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String> onCitySelected;
  final String placeholder;

  const CityDropdown({
    super.key,
    required this.cities,
    required this.onCitySelected,
    this.selectedCity,
    this.placeholder = "Select City",
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

  late AnimationController _arrowController;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.selectedCity;
    _filteredCities = widget.cities;
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
      if (_isDropdownOpen) {
        _arrowController.forward();
        Future.delayed(
          const Duration(milliseconds: 50),
          () => _searchFocusNode.requestFocus(),
        );
      } else {
        _arrowController.reverse();
        _searchController.clear();
        _filteredCities = widget.cities;
      }
    });
  }

  void _onCitySelected(String city) {
    setState(() {
      _selectedCity = city;
      _isDropdownOpen = false;
      _arrowController.reverse();
      _searchController.clear();
      _filteredCities = widget.cities;
    });
    widget.onCitySelected(city);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedCity ?? widget.placeholder,
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedCity != null
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_arrowController),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_isDropdownOpen)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(padding: .zero,
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
                      vertical: 12,
                    ),
                    color: isSelected ? Colors.blue.shade50 : null,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            city,
                            style: TextStyle(
                              fontSize: 15,
                              color: isSelected
                                  ? Colors.blue.shade800
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (isSelected) Icon(Icons.check, color: Colors.blue),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
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
}
