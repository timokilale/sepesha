import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/components/home/sheet_handle.dart';
import 'package:sepesha_app/models/ride_option.dart';
import 'package:sepesha_app/provider/ride_provider.dart';
import 'package:sepesha_app/provider/payment_provider.dart';
import 'package:sepesha_app/widgets/payment_method_selector.dart';
import 'package:sepesha_app/services/session_manager.dart';

class RideSelectionContent extends StatelessWidget {
  final RideProvider provider;

  RideSelectionContent({super.key, required this.provider});

  // Add separate lists for 2 Wheeler and 4 Wheeler using the correct RideOption constructor (positional arguments)

  final distance = SessionManager.instance.distanceCovered;

  int totalFair({
    required int BestPrice,
    required double vehicleMultiplier,
    required int pricePerKilometer,
  }) {
    double newDistance = double.parse(distance.split(" ")[0]);

    final amount =
        BestPrice +
        (vehicleMultiplier * pricePerKilometer * newDistance).toInt();

    // Round to the nearest 500
    int roundedAmount = ((amount + 250) ~/ 500) * 500;
    return roundedAmount;
  }

  List<RideOption> get twoWheelerOptions {
    return provider.categories
        .where((cat) => _isTwoWheeler(cat['name']))
        .map(
          (cat) => RideOption(
            cat['name'],
            'TZS ${cat['base_price']}',
            Icons.motorcycle,
            cat['description'] ?? 'Capacity: ${cat['capacity']}',
            Colors.blue,
            '2 Wheeler',
            cat['id'],
          ),
        )
        .toList();
  }

  List<RideOption> get fourWheelerOptions {
    return provider.categories
        .where((cat) => _isFourWheeler(cat['name']))
        .map(
          (cat) => RideOption(
            cat['name'],
            'TZS ${cat['base_price']}',
            Icons.directions_car,
            cat['description'] ?? 'Capacity: ${cat['capacity']}',
            Colors.orange,
            '4 Wheeler',
            cat['id'],
          ),
        )
        .toList();
  }

  // Helper methods to categorize vehicles
  bool _isTwoWheeler(String name) {
    return ['Bodaboda', 'Bajaj'].contains(name);
  }

  bool _isFourWheeler(String name) {
    return ['Guta', 'Carry'].contains(name);
  }

  @override
  Widget build(BuildContext context) {
    if (provider.categoriesLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: SheetHandle()),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => provider.resetToInitialState(),
                  tooltip: 'Back to home',
                ),
                const Expanded(
                  child: Text(
                    'Choose Your Ride',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildVehicleTypeFilter(),
            const SizedBox(height: 16),
            ..._getFilteredOptions().map(
              (option) => _buildRideOptionCard(option, provider),
            ),
            // const SizedBox(height: 16),
            // _buildLuggageOption(),
            const SizedBox(height: 16),
            _buildPaymentMethodSection(provider),
            const SizedBox(height: 16),
            _buildDiscountSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFilterChip('2 Wheeler', Icons.motorcycle),
          _buildFilterChip('4 Wheeler', Icons.directions_car),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, IconData icon) {
    final isSelected = provider.filterType == type;
    return GestureDetector(
      onTap: () => provider.filterRideType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.red : Colors.grey),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.red : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideOptionCard(RideOption option, RideProvider provider) {
    final isSelected = provider.selectedRideType == option.name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap:
            () => provider.selectRideType(
              option.name!,
              categoryId: option.categoryId,
            ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? option.color!.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? option.color! : Colors.grey[200]!,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: option.color!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    _getVehicleImage(option.name!),
                    // width: 40,
                    // height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    // Row(
                    //   children: [
                    //     Icon(Icons.star, color: Colors.amber, size: 14),
                    //     const SizedBox(width: 4),
                    //     const SizedBox(width: 8),
                    //     Icon(Icons.people, color: Colors.grey[400], size: 14),
                    //     const SizedBox(width: 4),
                    //   ],
                    // ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    option.price!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getVehicleImage(String name) {
    switch (name.toLowerCase().trim()) {
      case 'bodaboda':
        return 'assets/images/bodaboda.png';
      case 'bajaji':
        return 'assets/images/bajaji.png';
      case 'guta':
        return 'assets/images/guta.png';
      case 'carry':
        return 'assets/images/carry.png';
      case 'townace':
      case 'townace ': // handle trailing space
        return 'assets/images/carry.png';
      default:
        return 'assets/images/bodaboda.png';
    }
  }

  Widget _buildLuggageOption() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.luggage, color: Colors.grey[600]),
              const SizedBox(width: 8),
              const Text(
                'Add Luggage Space',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Switch.adaptive(
            value: false,
            onChanged: (value) {},
            activeColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Have a promo code?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter promo code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ContinueButton(
                onPressed: () {},
                backgroundColor: AppColor.black,
                isLoading: false,
                text: 'Apply',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => provider.resetToInitialState(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColor.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ContinueButton(
                isLoading: false,
                text: "Continue",
                onPressed: () => provider.startSearching(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Add a method to get filtered options
  List<RideOption> _getFilteredOptions() {
    if (provider.filterType == '2 Wheeler') {
      return twoWheelerOptions;
    } else if (provider.filterType == '4 Wheeler') {
      return fourWheelerOptions;
    }
    return [];
  }

  Widget _buildPaymentMethodSection(RideProvider rideProvider) {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            PaymentMethodSelector(
              onChanged: () {
                // Update ride provider when payment method changes
                rideProvider.setPaymentProvider(paymentProvider);
              },
            ),
          ],
        );
      },
    );
  }
}
