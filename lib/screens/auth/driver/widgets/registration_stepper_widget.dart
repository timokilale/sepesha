import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';


class RegistrationStepperWidget extends StatelessWidget {
  final int currentStep;
  final Function(int)? onStepTapped;

  const RegistrationStepperWidget({
    super.key,
    required this.currentStep,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStep(0, 'Personal', currentStep),
          _buildLine(currentStep > 0),
          _buildStep(1, 'Vehicle', currentStep),
          _buildLine(currentStep > 1),
          _buildStep(2, 'Documents', currentStep),
        ],
      ),
    );
  }

  Widget _buildStep(int stepIndex, String label, int currentStep) {
    final isActive = stepIndex == currentStep;
    final isCompleted = stepIndex < currentStep;

    return GestureDetector(
      onTap: () => onStepTapped?.call(stepIndex),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  isActive
                      ? AppColor.primary
                      : isCompleted
                      ? Colors.green
                      : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColor.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? Colors.green : Colors.grey[300],
      ),
    );
  }
}
