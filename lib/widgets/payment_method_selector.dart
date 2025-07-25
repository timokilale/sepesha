import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/models/payment_method.dart';
import 'package:sepesha_app/provider/payment_provider.dart';
import 'package:sepesha_app/screens/payment_methods_screen.dart';

class PaymentMethodSelector extends StatelessWidget {
  final VoidCallback? onChanged;
  final bool showBalance;

  const PaymentMethodSelector({
    super.key,
    this.onChanged,
    this.showBalance = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _navigateToPaymentMethods(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildIcon(provider),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSelectedMethod(provider)),
                  Icon(Icons.arrow_forward_ios, color: AppColor.grey, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(PaymentProvider provider) {
    final selectedMethod = provider.selectedPaymentMethod;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            selectedMethod?.color.withOpacity(0.2) ??
            AppColor.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        selectedMethod?.icon ?? Icons.payment,
        color: selectedMethod?.color ?? AppColor.grey,
        size: 20,
      ),
    );
  }

  Widget _buildSelectedMethod(PaymentProvider provider) {
    final selectedMethod = provider.selectedPaymentMethod;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: AppTextStyle.subtext1(AppColor.grey)),
        const SizedBox(height: 2),
        Text(
          selectedMethod?.name ?? 'Select Payment Method',
          style: AppTextStyle.paragraph1(AppColor.blackText),
        ),
        if (showBalance &&
            selectedMethod?.type == PaymentMethodType.wallet &&
            provider.walletBalance != null) ...[
          const SizedBox(height: 4),
          Text(
            'Balance: ${provider.getFormattedWalletBalance()}',
            style: AppTextStyle.subtext1(selectedMethod!.color),
          ),
        ],
      ],
    );
  }

  void _navigateToPaymentMethods(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ChangeNotifierProvider.value(
              value: Provider.of<PaymentProvider>(context, listen: false),
              child: const PaymentMethodsScreen(),
            ),
      ),
    );

    // Call onChanged callback if provided
    if (result != null && onChanged != null) {
      onChanged!();
    }
  }
}
