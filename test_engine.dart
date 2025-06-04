// // Flutter example for WebSocket connection
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/io.dart';
// import 'dart:convert';

// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class RealTimeService {
//   final String socketUrl = 'wss://socket.example.com';
//   WebSocketChannel? _channel;
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

//   // Stream controllers for different event types
//   final StreamController<Map<String, dynamic>> _bookingStatusController = 
//       StreamController<Map<String, dynamic>>.broadcast();
//   final StreamController<Map<String, dynamic>> _driverLocationController = 
//       StreamController<Map<String, dynamic>>.broadcast();
//   final StreamController<Map<String, dynamic>> _messageController = 
//       StreamController<Map<String, dynamic>>.broadcast();

//   // Expose streams for UI to listen to
//   Stream<Map<String, dynamic>> get bookingStatusStream => _bookingStatusController.stream;
//   Stream<Map<String, dynamic>> get driverLocationStream => _driverLocationController.stream;
//   Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

//   // Connection status
//   bool _isConnected = false;
//   bool get isConnected => _isConnected;

//   // Connect to WebSocket server
//   Future<bool> connect() async {
//     try {
//       // Get user ID and token for authentication
//       final userId = await _secureStorage.read(key: 'uid');
//       final token = await _secureStorage.read(key: 'access_token');

//       if (userId == null || token == null) {
//         return false;
//       }

//       // Connect to WebSocket with authentication
//       _channel = IOWebSocketChannel.connect(
//         Uri.parse('$socketUrl?user_id=$userId&token=$token'),
//       );

//       // Listen for messages
//       _channel!.stream.listen(
//         (dynamic message) {
//           _handleMessage(message);
//         },
//         onError: (error) {
//           print('WebSocket error: $error');
//           _isConnected = false;
//         },
//         onDone: () {
//           print('WebSocket connection closed');
//           _isConnected = false;
//         },
//       );

//       _isConnected = true;
//       return true;
//     } catch (e) {
//       print('Error connecting to WebSocket: $e');
//       _isConnected = false;
//       return false;
//     }
//   }

//   // Handle incoming WebSocket messages
//   void _handleMessage(dynamic message) {
//     try {
//       final data = jsonDecode(message);

//       // Route message to appropriate stream based on event type
//       switch (data['event']) {
//         case 'booking_status_changed':
//           _bookingStatusController.add(data['booking']);
//           break;
//         case 'driver_location_updated':
//           _driverLocationController.add(data['location']);
//           break;
//         case 'new_message':
//           _messageController.add(data['message']);
//           break;
//         default:
//           print('Unknown event type: ${data['event']}');
//       }
//     } catch (e) {
//       print('Error handling WebSocket message: $e');
//     }
//   }

//   // Send message to WebSocket server
//   Future<bool> sendMessage(Map<String, dynamic> data) async {
//     if (!_isConnected || _channel == null) {
//       return false;
//     }

//     try {
//       _channel!.sink.add(jsonEncode(data));
//       return true;
//     } catch (e) {
//       print('Error sending WebSocket message: $e');
//       return false;
//     }
//   }

//   // Update driver location
//   Future<bool> updateDriverLocation(double latitude, double longitude) {
//     return sendMessage({
//       'event': 'update_driver_location',
//       'location': {
//         'latitude': latitude,
//         'longitude': longitude,
//       }
//     });
//   }

//   // Close WebSocket connection
//   void disconnect() {
//     _channel?.sink.close();
//     _isConnected = false;
//   }

//   // Dispose resources
//   void dispose() {
//     _bookingStatusController.close();
//     _driverLocationController.close();
//     _messageController.close();
//     disconnect();
//   }
// }

// // Example usage in a Flutter app - Real-time ride tracking screen
// class RideTrackingScreen extends StatefulWidget {
//   final String bookingId;
//   final Map<String, dynamic> initialBookingData;

//   const RideTrackingScreen({
//     Key? key,
//     required this.bookingId,
//     required this.initialBookingData,
//   }) : super(key: key);

//   @override
//   _RideTrackingScreenState createState() => _RideTrackingScreenState();
// }

// class _RideTrackingScreenState extends State<RideTrackingScreen> {
//   final RealTimeService _realTimeService = RealTimeService();
//   GoogleMapController? _mapController;

//   // Ride data
//   Map<String, dynamic> _bookingData = {};
//   String _rideStatus = 'pending';

//   // Driver location
//   LatLng _driverLocation = LatLng(-6.776012, 39.178326); // Default location (Dar es Salaam)
//   Set<Marker> _markers = {};

//   // Connection status
//   bool _isConnected = false;
//   String _connectionMessage = 'Connecting...';

//   @override
//   void initState() {
//     super.initState();
//     _bookingData = widget.initialBookingData;
//     _rideStatus = _bookingData['status'] ?? 'pending';

//     // Initialize driver location if available
//     if (_bookingData['driver_location'] != null) {
//       _driverLocation = LatLng(
//         _bookingData['driver_location']['latitude'],
//         _bookingData['driver_location']['longitude'],
//       );
//     }

//     // Connect to WebSocket and set up listeners
//     _initializeRealTimeConnection();
//   }

//   Future<void> _initializeRealTimeConnection() async {
//     // Connect to WebSocket
//     final connected = await _realTimeService.connect();

//     setState(() {
//       _isConnected = connected;
//       _connectionMessage = connected 
//           ? 'Connected to real-time updates' 
//           : 'Failed to connect. Tap to retry.';
//     });

//     if (connected) {
//       // Listen for booking status updates
//       _realTimeService.bookingStatusStream.listen((bookingData) {
//         setState(() {
//           _bookingData = bookingData;
//           _rideStatus = bookingData['status'] ?? _rideStatus;
//         });
//       });

//       // Listen for driver location updates
//       _realTimeService.driverLocationStream.listen((locationData) {
//         final newLocation = LatLng(
//           locationData['latitude'],
//           locationData['longitude'],
//         );

//         setState(() {
//           _driverLocation = newLocation;
//           _updateMarkers();
//         });

//         // Move camera to follow driver
//         _mapController?.animateCamera(
//           CameraUpdate.newLatLng(_driverLocation),
//         );
//       });
//     }
//   }

//   void _updateMarkers() {
//     _markers = {
//       Marker(
//         markerId: MarkerId('driver'),
//         position: _driverLocation,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         infoWindow: InfoWindow(title: 'Driver'),
//       ),

//       // Add pickup marker
//       if (_bookingData['pickup_latitude'] != null && _bookingData['pickup_longitude'] != null)
//         Marker(
//           markerId: MarkerId('pickup'),
//           position: LatLng(
//             _bookingData['pickup_latitude'],
//             _bookingData['pickup_longitude'],
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//           infoWindow: InfoWindow(title: 'Pickup'),
//         ),

//       // Add destination marker
//       if (_bookingData['delivery_latitude'] != null && _bookingData['delivery_longitude'] != null)
//         Marker(
//           markerId: MarkerId('destination'),
//           position: LatLng(
//             _bookingData['delivery_latitude'],
//             _bookingData['delivery_longitude'],
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//           infoWindow: InfoWindow(title: 'Destination'),
//         ),
//     };
//   }

//   @override
//   void dispose() {
//     _realTimeService.dispose();
//     _mapController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Track Your Ride'),
//         actions: [
//           // Connection status indicator
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Icon(
//               _isConnected ? Icons.wifi : Icons.wifi_off,
//               color: _isConnected ? Colors.green : Colors.red,
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Status bar
//           Container(
//             color: _getStatusColor(),
//             padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             child: Row(
//               children: [
//                 Icon(
//                   _getStatusIcon(),
//                   color: Colors.white,
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   _getStatusText(),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Connection message if not connected
//           if (!_isConnected)
//             GestureDetector(
//               onTap: _initializeRealTimeConnection,
//               child: Container(
//                 color: Colors.red[100],
//                 padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 child: Row(
//                   children: [
//                     Icon(Icons.refresh, color: Colors.red),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         _connectionMessage,
//                         style: TextStyle(color: Colors.red[800]),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//           // Map view
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: _driverLocation,
//                 zoom: 15,
//               ),
//               markers: _markers,
//               onMapCreated: (controller) {
//                 _mapController = controller;
//                 _updateMarkers();
//               },
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//               mapToolbarEnabled: false,
//               compassEnabled: true,
//             ),
//           ),

//           // Ride info panel
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 5,
//                   offset: Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Driver info
//                 if (_bookingData['driver'] != null) ...[
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 20,
//                         backgroundImage: _bookingData['driver']['profile_photo'] != null
//                           ? NetworkImage(_bookingData['driver']['profile_photo'])
//                           : null,
//                         child: _bookingData['driver']['profile_photo'] == null
//                           ? Icon(Icons.person)
//                           : null,
//                       ),
//                       SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '${_bookingData['driver']['name'] ?? 'Driver'}',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           if (_bookingData['vehicle'] != null)
//                             Text(
//                               '${_bookingData['vehicle']['make'] ?? ''} ${_bookingData['vehicle']['model'] ?? ''} - ${_bookingData['vehicle']['plate_number'] ?? ''}',
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 14,
//                               ),
//                             ),
//                         ],
//                       ),
//                       Spacer(),
//                       IconButton(
//                         icon: Icon(Icons.phone, color: Colors.green),
//                         onPressed: () {
//                           // In a real app, launch phone call to driver
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Calling driver...')),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                   Divider(),
//                 ],

//                 // ETA and distance
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildInfoItem(
//                       icon: Icons.access_time,
//                       label: 'ETA',
//                       value: '10 min', // In a real app, calculate from API data
//                     ),
//                     _buildInfoItem(
//                       icon: Icons.straighten,
//                       label: 'Distance',
//                       value: '${_bookingData['distance_km'] ?? 0} km',
//                     ),
//                     _buildInfoItem(
//                       icon: Icons.attach_money,
//                       label: 'Fare',
//                       value: 'TZS ${_bookingData['amount'] ?? 0}',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method to build info items
//   Widget _buildInfoItem({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.grey[700]),
//         SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[600],
//             fontSize: 12,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper methods for status display
//   IconData _getStatusIcon() {
//     switch (_rideStatus) {
//       case 'pending':
//         return Icons.access_time;
//       case 'assigned':
//         return Icons.directions_car;
//       case 'intransit':
//         return Icons.navigation;
//       case 'completed':
//         return Icons.check_circle;
//       default:
//         return Icons.info;
//     }
//   }

//   String _getStatusText() {
//     switch (_rideStatus) {
//       case 'pending':
//         return 'Waiting for driver';
//       case 'assigned':
//         return 'Driver is on the way';
//       case 'intransit':
//         return 'On the way to destination';
//       case 'completed':
//         return 'Ride completed';
//       default:
//         return 'Unknown status';
//     }
//   }

//   Color _getStatusColor() {
//     switch (_rideStatus) {
//       case 'pending':
//         return Colors.orange;
//       case 'assigned':
//         return Colors.blue;
//       case 'intransit':
//         return Colors.purple;
//       case 'completed':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
// }