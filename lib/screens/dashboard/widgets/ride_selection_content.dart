import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/components/home/sheet_handle.dart';
import 'package:sepesha_app/models/ride_option.dart';
import 'package:sepesha_app/provider/ride_provider.dart';
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

  List<RideOption> get twoWheelerOptions => [
    RideOption(
      'Bodaboda',
      'TZS ${totalFair(BestPrice: 3000, vehicleMultiplier: 1.0, pricePerKilometer: 400)}',
      Icons.motorcycle,
      'Total weight < 150kg',
      Colors.blue,
      '2 Wheeler',
    ),
    RideOption(
      'Bajaji',
      'TZS ${totalFair(BestPrice: 5000, vehicleMultiplier: 1.4, pricePerKilometer: 700)}',
      Icons.motorcycle,
      'Total weight < 1300kg',
      Colors.green,
      '2 Wheeler',
    ),
    RideOption(
      'Guta',
      'TZS ${totalFair(BestPrice: 7000, vehicleMultiplier: 1.6, pricePerKilometer: 900)}',
      Icons.motorcycle,
      'Total weight < 1300kg',
      Colors.green,
      '2 Wheeler',
    ),
  ];

  List<RideOption> get fourWheelerOptions => [
    RideOption(
      'Carry',
      'TZS ${totalFair(BestPrice: 10500, vehicleMultiplier: 1.9, pricePerKilometer: 1400)}',
      Icons.directions_car,
      'Total weight < 1,000kg',
      Colors.orange,
      '4 Wheeler',
    ),
    RideOption(
      'Townace ',
      'TZS ${totalFair(BestPrice: 12000, vehicleMultiplier: 2.1, pricePerKilometer: 1600)}',
      Icons.directions_car,
      'Total weight < 1,500kg',
      Colors.purple,
      '4 Wheeler',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: SheetHandle()),
          const SizedBox(height: 16),
          const Text(
            'Choose Your Ride',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
          _buildDiscountSection(context),
        ],
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
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFilterChip('2 Wheeler', Icons.motorcycle),
            _buildFilterChip('4 Wheeler', Icons.directions_car),
          ],
        ),
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
        onTap: () => provider.selectRideType(option.name!),
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
        ContinueButton(
          isLoading: false,
          text: "Continue",
          onPressed: () => provider.startSearching(),
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
}
