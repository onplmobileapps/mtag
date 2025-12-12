import 'package:flutter/material.dart';

class CustomKeyboardActions extends StatefulWidget {
  final Widget child;
  final List<FocusNode> focusNodes;

  const CustomKeyboardActions({
    super.key,
    required this.child,
    required this.focusNodes,
  });

  @override
  State<CustomKeyboardActions> createState() => _CustomKeyboardActionsState();
}

class _CustomKeyboardActionsState extends State<CustomKeyboardActions>
    with WidgetsBindingObserver {
  final ValueNotifier<bool> _isKeyboardVisible = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    for (var node in widget.focusNodes) {
      node.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    final anyFocused = widget.focusNodes.any((node) => node.hasFocus);
    if (!anyFocused) {
      _isKeyboardVisible.value = false;
    }
  }

  @override
  void didChangeMetrics() {
    final bottomInset = View.of(context).viewInsets.bottom;

    if (bottomInset == 0) {
      _isKeyboardVisible.value = false;
    } else {
      final anyFocused = widget.focusNodes.any((node) => node.hasFocus);
      _isKeyboardVisible.value = anyFocused;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (var node in widget.focusNodes) {
      node.removeListener(_onFocusChange);
    }
    _isKeyboardVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          widget.child,

          ValueListenableBuilder<bool>(
            valueListenable: _isKeyboardVisible,
            builder: (context, visible, _) {
              if (!visible) return const SizedBox.shrink();

              return Positioned(
                bottom: bottomInset,
                left: 0,
                right: 0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  offset: visible ? Offset.zero : const Offset(0, 1),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                   
                      padding: const EdgeInsets.only(right: 12,top: 4,bottom: 4),
                      decoration: BoxDecoration(borderRadius: .circular(4),
                        color: ColorScheme.of(context).surface,
                        border: Border(
                          top: BorderSide(
                            color: Colors.black.withValues(alpha: 0.08),
                            width: 0.6,
                          ),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              "Done",
                              style: TextTheme.of(context).bodyLarge
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
