import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/models/payment_method.dart';
import 'package:sepesha_app/provider/payment_provider.dart';
import 'package:sepesha_app/widgets/payment_method_card.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Methods',
          style: AppTextStyle.heading2(AppColor.blackText),
        ),
        backgroundColor: AppColor.white,
        elevation: 1,
        iconTheme: IconThemeData(color: AppColor.blackText),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingIndicator();
          }

          return Column(
            children: [
              if (provider.errorMessage != null) _buildErrorMessage(provider),
              if (provider.selectedPaymentMethod?.type ==
                  PaymentMethodType.wallet)
                _buildWalletBalanceSection(provider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.availablePaymentMethods.length,
                  itemBuilder: (context, index) {
                    final paymentMethod =
                        provider.availablePaymentMethods[index];
                    final isSelected =
                        provider.selectedPaymentMethod?.id == paymentMethod.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PaymentMethodCard(
                        paymentMethod: paymentMethod,
                        isSelected: isSelected,
                        walletBalance:
                            paymentMethod.type == PaymentMethodType.wallet
                                ? provider.getFormattedWalletBalance()
                                : null,
                        onTap:
                            () => _onPaymentMethodSelected(
                              paymentMethod,
                              provider,
                            ),
                      ),
                    );
                  },
                ),
              ),
              _buildBottomSection(provider),
            ],
          );
        },
      ),
    );
  }

  void _onPaymentMethodSelected(
    PaymentMethod method,
    PaymentProvider provider,
  ) async {
    try {
      await provider.selectPaymentMethod(method);
      if (mounted && provider.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment method updated to ${method.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update payment method'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildWalletBalanceSection(PaymentProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: AppColor.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Balance',
                  style: AppTextStyle.paragraph1(AppColor.blackText),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.getFormattedWalletBalance(),
                  style: AppTextStyle.heading3(AppColor.primary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showWalletBalanceDialog(provider),
            icon: Icon(Icons.info_outline, color: AppColor.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(PaymentProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: AppTextStyle.paragraph1(Colors.red),
            ),
          ),
          IconButton(
            onPressed: provider.clearError,
            icon: Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColor.primary),
          const SizedBox(height: 16),
          Text(
            'Loading payment methods...',
            style: AppTextStyle.paragraph1(AppColor.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(PaymentProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (provider.hasSelectedPaymentMethod)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    provider.selectedPaymentMethod!.icon,
                    color: AppColor.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Selected: ${provider.selectedPaymentMethodName}',
                    style: AppTextStyle.paragraph1(AppColor.primary),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  provider.hasSelectedPaymentMethod
                      ? () => Navigator.of(context).pop()
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Done',
                style: AppTextStyle.paragraph1(AppColor.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWalletBalanceDialog(PaymentProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Wallet Balance Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.walletBalance != null) ...[
                  Text(
                    'TZS Balance: ${provider.getFormattedWalletBalance('TZS')}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'USD Balance: ${provider.getFormattedWalletBalance('USD')}',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.isWalletPaymentAvailable
                        ? 'Your wallet is ready for payments'
                        : 'Add funds to your wallet to use this payment method',
                    style: TextStyle(
                      color:
                          provider.isWalletPaymentAvailable
                              ? Colors.green
                              : Colors.orange,
                    ),
                  ),
                ] else
                  Text('Unable to load wallet balance'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
              if (provider.walletBalance != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    provider.refreshWalletBalance();
                  },
                  child: Text('Refresh'),
                ),
            ],
          ),
    );
  }
}
