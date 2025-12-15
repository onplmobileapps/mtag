import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StationSearchDialog extends StatefulWidget {
  final RxList<String> items;
  final String? selectedItem;
  final String title;
  final String hintText;
  final IconData? leadingIcon;
  final Widget? Function(String)? trailingIconBuilder;

  const StationSearchDialog({
    super.key,
    required this.items,
    required this.title,
    required this.hintText,
    this.selectedItem,
    this.leadingIcon,
    this.trailingIconBuilder,
  });

  @override
  State<StationSearchDialog> createState() => _StationSearchDialogState();
}

class _StationSearchDialogState extends State<StationSearchDialog> {
  late List<String> _filteredItems;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) => setState(() {
        _filteredItems = widget.items
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDarkMode ? Colors.redAccent : Theme.of(context).primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 500,
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterItems,
                  cursorColor: borderColor,
                  style: TextStyle(color: borderColor),
                  decoration: InputDecoration(contentPadding: .zero,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(color: borderColor, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: borderColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(padding: .zero,
                  shrinkWrap: true,
                  itemCount: _filteredItems.length,
                  itemBuilder: (_, index) {
                    final item = _filteredItems[index];
                    return ListTile(minVerticalPadding: 0,
                      title: Text(
                        item,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                      leading: widget.leadingIcon != null
                          ? Icon(
                              widget.leadingIcon,
                              color: 
                                 Colors.grey
                                  
                            )
                          : null,
                      trailing: widget.trailingIconBuilder != null
                          ? widget.trailingIconBuilder!(item)
                          : null,
                      onTap: () => Navigator.pop(context, item),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: borderColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
