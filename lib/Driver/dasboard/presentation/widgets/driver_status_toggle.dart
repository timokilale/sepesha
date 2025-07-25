import 'package:flutter/material.dart';
import 'package:action_slider/action_slider.dart';

class DriverStatusToggle extends StatefulWidget {
  final bool initialStatus;
  final Future<bool> Function(bool) onStatusChanged;

  const DriverStatusToggle({
    super.key,
    this.initialStatus = false,
    required this.onStatusChanged,
  });

  @override
  State<DriverStatusToggle> createState() => _DriverStatusToggleState();
}

class _DriverStatusToggleState extends State<DriverStatusToggle> {
  late bool _isOnline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ActionSlider.standard(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 60,
        backgroundColor: _isOnline ? Colors.green.withOpacity(0.2) : Colors.red,
        toggleColor: _isOnline ? Colors.green : Colors.red,
        icon:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Icon(
                  _isOnline ? Icons.directions_car : Icons.car_crash,
                  color: Colors.white,
                ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.1),
              Text(
                _isOnline ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                _isOnline ? 'Accepting rides' : 'Not available',
                style: TextStyle(
                  fontSize: 14,
                  color: _isOnline ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        action: (controller) async {
          setState(() => _isLoading = true);
          controller.loading();

          try {
            final success = await widget.onStatusChanged(!_isOnline);

            if (success) {
              setState(() => _isOnline = !_isOnline);
              controller.success();
              await Future.delayed(const Duration(seconds: 01));
              controller.reset(); // Reset to allow toggling again
            } else {
              controller.reset();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isOnline ? 'Failed to go offline' : 'Failed to go online',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } catch (e) {
            controller.reset();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Network error'),
                backgroundColor: Colors.red,
              ),
            );
          } finally {
            setState(() => _isLoading = false);
          }
        },
      ),
    );
  }
}
