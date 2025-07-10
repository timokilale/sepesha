import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

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

class RidesScreen extends StatelessWidget {
  const RidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Rides',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
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
                  // Active Rides
                  ListView(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    children: [
                      ActiveRideCard(
                        driverName: 'David Jones',
                        arrivalTime: 'Arrives in 3 minutes',
                        cost: 'TZS 72.86',
                        dateTime: 'Dec 13, 2024 18:50 A.M.',
                        startLocation: 'Airport',
                        endLocation: 'Market',
                        tripDuration: '13 minutes',
                        rating: 4.8,
                        carModel: 'Toyota Prius',
                        plateNumber: 'T 123 ABC',
                      ),
                    ],
                  ),

                  // Completed Rides
                  ListView(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    children: [
                      CompletedRideCard(
                        driverName: 'James Roth',
                        phone: '(209) 555-0104',
                        cost: 'TZS 44.87',
                        dateTime: '07/05/2016',
                        startLocation: 'San Francisco Gas Station',
                        endLocation: 'Fairmont San Francisco',
                        tripDuration: '13 minutes',
                        rating: 4.5,
                        carModel: 'Honda Civic',
                      ),
                      CompletedRideCard(
                        driverName: 'David Bloom',
                        phone: '(201) 555-0124',
                        cost: 'TZS 32.30',
                        dateTime: '28/10/2016',
                        startLocation: 'Pier 39',
                        endLocation: 'Giants',
                        tripDuration: '25 minutes',
                        rating: 4.7,
                        carModel: 'Toyota Camry',
                      ),
                    ],
                  ),

                  // Canceled Rides
                  ListView(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    children: [
                      CanceledRideCard(
                        driverName: 'Marvin McKinney',
                        phone: '(239) 555-0108',
                        cost: 'TZS 56.80',
                        dateTime: '07/05/2016',
                        startLocation: 'Downtown',
                        endLocation: 'Shopping Mall',
                        tripDuration: '15 minutes',
                        rating: 4.3,
                        carModel: 'Nissan Altima',
                      ),
                      CanceledRideCard(
                        driverName: 'Arlene McCoy',
                        phone: '(270) 555-0117',
                        cost: 'TZS 36.70',
                        dateTime: '28/10/2016',
                        startLocation: 'University',
                        endLocation: 'Train Station',
                        tripDuration: '20 minutes',
                        rating: 4.1,
                        carModel: 'Hyundai Elantra',
                      ),
                    ],
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
  final String arrivalTime;
  final String cost;
  final String dateTime;
  final String startLocation;
  final String endLocation;
  final String tripDuration;
  final double rating;
  final String carModel;
  final String plateNumber;

  const ActiveRideCard({super.key, 
    required this.driverName,
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

  const CompletedRideCard({super.key, 
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

  const CanceledRideCard({super.key, 
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
