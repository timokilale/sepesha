import 'package:flutter/material.dart';
import 'package:sepesha_app/screens/dashboard/widgets/dotted-line_painter.dart';

class Divider extends StatelessWidget {
  const Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18),
      child: CustomPaint(
        size: const Size(2, 20),
        painter: DottedLinePainter(color: Colors.grey[400]!),
      ),
    );
  }
}
