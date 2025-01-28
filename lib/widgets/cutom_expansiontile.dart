import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyCustomExpansionTile extends StatefulWidget {
  final String title;
  final String? subtitle;

  final bool initiallyExpanded;
  final List<Widget>? children;
  final Function(bool)? onExpansionChanged;
  ExpansionTileController? controller;
  MyCustomExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onExpansionChanged,
    this.controller,
    this.children,
    this.initiallyExpanded = false,
  });

  @override
  State<MyCustomExpansionTile> createState() => _MyCustomExpansionTileState();
}

class _MyCustomExpansionTileState extends State<MyCustomExpansionTile> {
  @override
  void initState() {
    super.initState();
    widget.controller = ExpansionTileController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(widget.title), Text(widget.subtitle ?? '')],
        ),
        onExpansionChanged: widget.onExpansionChanged,
        controller: widget.controller,
        initiallyExpanded: widget.initiallyExpanded,
        children: widget.children ?? []);
  }
}
