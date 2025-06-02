import 'package:flutter/material.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/Driver/wallet/data/wallet_repository.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: FutureBuilder<Driver>(
        future: WalletRepository().getDriverData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Failed to load wallet data'));
          }

          final driver = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Available Balance',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tsh ${driver.walletBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Handle withdraw
                              },
                              child: const Text('Withdraw'),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                // Handle add funds
                              },
                              child: const Text('Add Funds'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: const [
                      ListTile(
                        leading: Icon(Icons.arrow_upward, color: Colors.red),
                        title: Text('Withdrawal'),
                        subtitle: Text('Today, 10:30 AM'),
                        trailing: Text(
                          '-Tsh 200.00',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.arrow_downward,
                          color: Colors.green,
                        ),
                        title: Text('Ride Payment'),
                        subtitle: Text('Yesterday, 5:45 PM'),
                        trailing: Text(
                          '+Tsh 18.50',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
