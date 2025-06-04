import 'package:flutter/material.dart';

class DraggableSheet extends StatelessWidget {
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final Widget child;
  final bool fitToContent;

  const DraggableSheet({
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
    required this.child,
    this.fitToContent = false,
  });

  @override
  Widget build(BuildContext context) {
    if (fitToContent) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          elevation: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: child,
        ),
      );
    }
    final snapSizes = [minChildSize, initialChildSize, maxChildSize]..sort();

    return Positioned.fill(
      bottom: 0,
      child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        snap: true,
        snapSizes: snapSizes,
        builder: (context, scrollController) {
          return Material(
            elevation: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
