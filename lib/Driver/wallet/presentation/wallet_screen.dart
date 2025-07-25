import 'package:flutter/material.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/Driver/wallet/data/wallet_repository.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/models/payment_method.dart';
import 'package:sepesha_app/provider/payment_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh wallet balance when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentProvider>(
        context,
        listen: false,
      ).refreshWalletBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<PaymentProvider>(
                context,
                listen: false,
              ).refreshWalletBalance();
            },
          ),
        ],
      ),*/
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildWalletBalanceCard(provider),
                const SizedBox(height: 20),
                _buildPaymentMethodCard(provider),
                const SizedBox(height: 20),
                _buildActionButtons(provider),
                const SizedBox(height: 20),
                _buildTransactionHistory(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWalletBalanceCard(PaymentProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Balance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.getFormattedWalletBalance('TZS'),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'USD: ${provider.getFormattedWalletBalance('USD')}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    provider.isWalletPaymentAvailable
                        ? Icons.check_circle
                        : Icons.warning,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.isWalletPaymentAvailable
                        ? 'Ready for payments'
                        : 'Add funds to use wallet',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentProvider provider) {
    final isWalletSelected =
        provider.selectedPaymentMethod?.type.name == 'wallet';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isWalletSelected
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: isWalletSelected ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isWalletSelected
                        ? 'Currently selected as preferred payment'
                        : 'Not selected as preferred payment',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Switch(
              value: isWalletSelected,
              onChanged: (value) async {
                if (value && provider.isWalletPaymentAvailable) {
                  // Set wallet as preferred payment method
                  final walletMethod = provider.getPaymentMethodByType(
                    PaymentMethodType.wallet,
                  );
                  if (walletMethod != null) {
                    await provider.selectPaymentMethod(walletMethod);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Wallet set as preferred payment method'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else if (!provider.isWalletPaymentAvailable) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add funds to your wallet first'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(PaymentProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showAddFundsDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Funds'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                provider.isWalletPaymentAvailable
                    ? () {
                      _showWithdrawDialog();
                    }
                    : null,
            icon: const Icon(Icons.remove),
            label: const Text('Withdraw'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _buildTransactionItem(
                  'Ride Payment',
                  'Today, 2:30 PM',
                  '+TZS 15,000',
                  Colors.green,
                  Icons.arrow_downward,
                ),
                _buildTransactionItem(
                  'Withdrawal',
                  'Yesterday, 10:15 AM',
                  '-TZS 50,000',
                  Colors.red,
                  Icons.arrow_upward,
                ),
                _buildTransactionItem(
                  'Ride Payment',
                  'Dec 10, 5:45 PM',
                  '+TZS 8,500',
                  Colors.green,
                  Icons.arrow_downward,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String subtitle,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showAddFundsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Funds'),
            content: const Text(
              'This feature will integrate with mobile money and card payments.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
  onPressed: () {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Funds feature coming soon! Backend integration required.'),
        backgroundColor: Colors.orange,
      ),
    );
  },
  child: const Text('Continue'),
),
            ],
          ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Withdraw Funds'),
            content: const Text(
              'Withdraw funds to your mobile money or bank account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
  onPressed: () {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Withdraw feature coming soon! Backend integration required.'),
        backgroundColor: Colors.orange,
      ),
    );
  },
  child: const Text('Continue'),
),
            ],
          ),
    );
  }
}
