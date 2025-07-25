import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/models/payment_method.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;
  final String? walletBalance;

  const PaymentMethodCard({
    super.key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
    this.walletBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected ? paymentMethod.color : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: paymentMethod.isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:
                isSelected
                    ? paymentMethod.color.withOpacity(0.1)
                    : Colors.white,
          ),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(child: _buildContent()),
              if (isSelected) _buildSelectedIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: paymentMethod.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(paymentMethod.icon, color: paymentMethod.color, size: 24),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          paymentMethod.name,
          style: AppTextStyle.paragraph1(
            isSelected ? paymentMethod.color : AppColor.blackText,
          ).copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          paymentMethod.description,
          style: AppTextStyle.subtext1(AppColor.grey),
        ),
        if (paymentMethod.type == PaymentMethodType.wallet &&
            walletBalance != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: paymentMethod.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Balance: $walletBalance',
              style: AppTextStyle.subtext1(
                paymentMethod.color,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
        if (!paymentMethod.isEnabled) ...[
          const SizedBox(height: 4),
          Text('Coming Soon', style: AppTextStyle.subtext1(Colors.orange)),
        ],
      ],
    );
  }

  Widget _buildSelectedIndicator() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: paymentMethod.color,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, color: Colors.white, size: 16),
    );
  }
}
