import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';
import 'package:sepesha_app/models/booking.dart';
import 'package:sepesha_app/provider/customer_history_provider.dart';
import 'package:sepesha_app/screens/dashboard/dashboard.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:sepesha_app/services/ride_services.dart';
import 'package:sepesha_app/widgets/smart_driver_rating.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride History',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: RidesScreen(),
    );
  }
}

class RidesScreen extends StatefulWidget {
  @override
  _RidesScreenState createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  String _calculateTripDuration(double distanceKm) {
    if (distanceKm <= 0) return 'Unknown';
    final timeInHours = distanceKm / 30.0; // 30 km/h average city speed
    final timeInMinutes = (timeInHours * 60).round();
    return '$timeInMinutes minutes';
  }

  Future<String> _calculateArrivalTime(
    String? driverId,
    double pickupLat,
    double pickupLng,
  ) async {
    if (driverId == null) return 'Driver not assigned';

    try {
      final token = await Preferences.instance.apiToken;
      if (token == null) return 'Location unavailable';

      // Get driver's current location from the API
      final url = Uri.parse(
        '${dotenv.env['BASE_URL']}/driver-location?driver_id=$driverId',
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] && data['data'] != null) {
          final locationData = data['data'];
          final driverLat = (locationData['latitude'] as num?)?.toDouble();
          final driverLng = (locationData['longitude'] as num?)?.toDouble();
          final driverSpeed =
              (locationData['speed'] as num?)?.toDouble() ?? 0.0;

          if (driverLat != null && driverLng != null) {
            // Calculate distance between driver and pickup location
            final distance = _calculateDistance(
              driverLat,
              driverLng,
              pickupLat,
              pickupLng,
            );

            // Use driver's current speed or average city speed (30 km/h)
            final speed = driverSpeed > 5.0 ? driverSpeed : 30.0;
            final timeInHours = distance / speed;
            final timeInMinutes = (timeInHours * 60).round();

            if (timeInMinutes < 1) {
              return 'Arriving now';
            } else if (timeInMinutes == 1) {
              return 'Arrives in 1 minute';
            } else {
              return 'Arrives in $timeInMinutes minutes';
            }
          }
        }
      }

      return 'Calculating arrival...';
    } catch (e) {
      print('Error calculating arrival time: $e');
      return 'Location unavailable';
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  void initState() {
    super.initState();
    // Load ride history when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerHistoryProvider>().loadRideHistory();
    });
  }

  Widget _buildArrivalTime(Booking booking) {
    return FutureBuilder<String>(
      future: _calculateArrivalTime(
        booking.driverId,
        booking.pickupLatitude,
        booking.pickupLongitude,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Calculating...');
        }
        return Text(snapshot.data ?? 'Unknown');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'Active',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Completed',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Canceled',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: Colors.red),
                  insets: EdgeInsets.symmetric(horizontal: 24),
                ),
                indicatorSize: TabBarIndicatorSize.label,
                labelPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Active Rides Tab
                  Consumer<CustomerHistoryProvider>(
                    builder: (context, historyProvider, child) {
                      if (historyProvider.isLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (historyProvider.activeRides.isEmpty) {
                        return Center(child: Text('No active rides'));
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: historyProvider.activeRides.length,
                        itemBuilder: (context, index) {
                          final booking = historyProvider.activeRides[index];
                          return FutureBuilder<String>(
                            future: _calculateArrivalTime(
                              booking.driverId,
                              booking.pickupLatitude,
                              booking.pickupLongitude,
                            ),
                            builder: (context, arrivalSnapshot) {
                              return ActiveRideCard(
                                driverName:
                                    booking.driverName ?? 'Unknown Driver',
                                driverId: booking.driverId ?? '',
                                arrivalTime:
                                    arrivalSnapshot.data ?? 'Calculating...',
                                cost:
                                    'TZS ${booking.fare?.toStringAsFixed(2) ?? '0.00'}',
                                dateTime: booking.createdAt.toString(),
                                startLocation: booking.pickupLocation,
                                endLocation: booking.deliveryLocation,
                                tripDuration: _calculateTripDuration(
                                  booking.distanceKm,
                                ),
                                rating: booking.driverRating ?? 0.0,
                                carModel:
                                    '${booking.vehicleMake ?? ''} ${booking.vehicleModel ?? ''}',
                                plateNumber: booking.vehiclePlateNumber ?? '',
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  // Completed Rides Tab
                  Consumer<CustomerHistoryProvider>(
                    builder: (context, historyProvider, child) {
                      if (historyProvider.isLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (historyProvider.completedRides.isEmpty) {
                        return Center(child: Text('No completed rides'));
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: historyProvider.completedRides.length,
                        itemBuilder: (context, index) {
                          final booking = historyProvider.completedRides[index];
                          return CompletedRideCard(
                            driverName: booking.driverName ?? 'Unknown Driver',
                            phone: booking.driverPhone ?? 'N/A',
                            cost:
                                'TZS ${booking.fare?.toStringAsFixed(2) ?? '0.00'}',
                            dateTime: booking.createdAt.toString(),
                            startLocation: booking.pickupLocation,
                            endLocation: booking.deliveryLocation,
                            tripDuration:
                                '13 minutes', // Calculate from booking data
                            rating: 4.8, // Get from driver rating
                            carModel:
                                '${booking.vehicleMake ?? ''} ${booking.vehicleModel ?? ''}',
                          );
                        },
                      );
                    },
                  ),
                  // Canceled Rides Tab
                  Consumer<CustomerHistoryProvider>(
                    builder: (context, historyProvider, child) {
                      if (historyProvider.isLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (historyProvider.canceledRides.isEmpty) {
                        return Center(child: Text('No canceled rides'));
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: historyProvider.canceledRides.length,
                        itemBuilder: (context, index) {
                          final booking = historyProvider.canceledRides[index];
                          return CanceledRideCard(
                            driverName: booking.driverName ?? 'Unknown Driver',
                            phone: booking.driverPhone ?? 'N/A',
                            cost:
                                'TZS ${booking.fare?.toStringAsFixed(2) ?? '0.00'}',
                            dateTime: booking.createdAt.toString(),
                            startLocation: booking.pickupLocation,
                            endLocation: booking.deliveryLocation,
                            tripDuration:
                                '13 minutes', // Calculate from booking data
                            rating: 4.8, // Get from driver rating
                            carModel:
                                '${booking.vehicleMake ?? ''} ${booking.vehicleModel ?? ''}',
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveRideCard extends StatelessWidget {
  final String driverName;
  final String? driverId;
  final String arrivalTime;
  final String cost;
  final String dateTime;
  final String startLocation;
  final String endLocation;
  final String tripDuration;
  final double rating;
  final String carModel;
  final String plateNumber;

  const ActiveRideCard({
    super.key,
    required this.driverName,
    this.driverId,
    required this.arrivalTime,
    required this.cost,
    required this.dateTime,
    required this.startLocation,
    required this.endLocation,
    required this.tripDuration,
    required this.rating,
    required this.carModel,
    required this.plateNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(Icons.person, size: 30, color: Colors.red),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        arrivalTime,
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              carModel,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[200]),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COST',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      cost,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'DATE',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      dateTime,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLocationRow(startLocation),
            SizedBox(height: 8),
            _buildLocationRow(endLocation),
            SizedBox(height: 8),
            Text(
              'Estimated trip time: $tripDuration',
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            // Container(
            //   height: 180,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: Colors.grey[200]!),
            //   ),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(12),
            //     child: FlutterMap(
            //       options: MapOptions(
            //         center: latlong.LatLng(51.5, -0.09),
            //         zoom: 13.0,
            //         interactiveFlags: InteractiveFlag.none,
            //       ),
            //       layers: [
            //         TileLayerOptions(
            //           urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            //           subdomains: ['a', 'b', 'c'],
            //         ),
            //         PolylineLayerOptions(
            //           polylines: [
            //             Polyline(
            //               points: [
            //                 latlong.LatLng(51.5, -0.09),
            //                 latlong.LatLng(51.51, -0.1),
            //               ],
            //               strokeWidth: 4.0,
            //               color: Colors.red,
            //             ),
            //           ],
            //         ),
            //         MarkerLayerOptions(
            //           markers: [
            //             Marker(
            //               width: 40.0,
            //               height: 40.0,
            //               point: latlong.LatLng(51.5, -0.09),
            //               builder: (ctx) => Container(
            //                 child: Icon(
            //                   Icons.location_on,
            //                   color: Colors.red,
            //                   size: 40.0,
            //                 ),
            //               ),
            //             ),
            //             Marker(
            //               width: 40.0,
            //               height: 40.0,
            //               point: latlong.LatLng(51.51, -0.1),
            //               builder: (ctx) => Container(
            //                 child: Icon(
            //                   Icons.location_on,
            //                   color: Colors.red,
            //                   size: 40.0,
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Contact Driver'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Cancel Ride'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String location) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, color: Colors.red, size: 20),
        SizedBox(width: 8),
        Expanded(child: Text(location, style: TextStyle(fontSize: 14))),
      ],
    );
  }
}

class CompletedRideCard extends StatelessWidget {
  final String driverName;
  final String phone;
  final String cost;
  final String dateTime;
  final String startLocation;
  final String endLocation;
  final String tripDuration;
  final double rating;
  final String carModel;

  const CompletedRideCard({
    super.key,
    required this.driverName,
    required this.phone,
    required this.cost,
    required this.dateTime,
    required this.startLocation,
    required this.endLocation,
    required this.tripDuration,
    required this.rating,
    required this.carModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(Icons.person, size: 30, color: Colors.green),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        phone,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          SmartDriverRating(
                            driverId:
                                'driver_id_here', // Add driverId parameter to ActiveRideCard
                            iconSize: 16.0,
                            fallbackRating: rating,
                          ),
                          SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              carModel,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[200]),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COST',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      cost,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'DATE',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      dateTime,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLocationRow(startLocation),
            SizedBox(height: 8),
            _buildLocationRow(endLocation),
            SizedBox(height: 8),
            Text(
              'Trip duration: $tripDuration',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Rate This Ride'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String location) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, color: Colors.red, size: 20),
        SizedBox(width: 8),
        Expanded(child: Text(location, style: TextStyle(fontSize: 14))),
      ],
    );
  }
}

class CanceledRideCard extends StatelessWidget {
  final String driverName;
  final String phone;
  final String cost;
  final String dateTime;
  final String startLocation;
  final String endLocation;
  final String tripDuration;
  final double rating;
  final String carModel;

  const CanceledRideCard({
    super.key,
    required this.driverName,
    required this.phone,
    required this.cost,
    required this.dateTime,
    required this.startLocation,
    required this.endLocation,
    required this.tripDuration,
    required this.rating,
    required this.carModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        phone,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          SmartDriverRating(
                            driverId:
                                'driver_id_here', // Add driverId parameter to ActiveRideCard
                            iconSize: 16.0,
                            fallbackRating: rating,
                          ),
                          SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              carModel,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    'Canceled',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[200]),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COST',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      cost,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'DATE',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      dateTime,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLocationRow(startLocation),
            SizedBox(height: 8),
            _buildLocationRow(endLocation),
            SizedBox(height: 8),
            Text(
              'Estimated trip time: $tripDuration',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Book Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String location) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, color: Colors.red, size: 20),
        SizedBox(width: 8),
        Expanded(child: Text(location, style: TextStyle(fontSize: 14))),
      ],
    );
  }
}
