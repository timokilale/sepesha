import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/global_variables.dart';
import 'package:sepesha_app/Utilities/secret_variables.dart';
import 'package:sepesha_app/models/direction_model.dart';
import 'package:sepesha_app/models/predicted_places.dart';
import 'package:sepesha_app/screens/info_handler/app_info.dart';
import 'package:sepesha_app/services/request_assistance.dart';

class PlacesSearchScreen extends StatefulWidget {
  const PlacesSearchScreen({super.key});

  @override
  State<PlacesSearchScreen> createState() => _PlacesSearchScreenState();
}

class _PlacesSearchScreenState extends State<PlacesSearchScreen> {
  List<PredictedPlaces> _predictedPlaces = [];
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  findPlaceAutoCompleteSearch(String inputText) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (inputText.isEmpty) {
      if (mounted) {
        setState(() {
          _predictedPlaces = [];
        });
      }
      return;
    }

    // Add debounce for better performance
    _debounceTimer = Timer(const Duration(milliseconds: 150), () async {
      if (inputText.length >= 2) {
        String placeAutoCompleteUrl =
            'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:TZ';

        var responseAutoCompleteSearch = await RequestAssistance.receiveRequest(
          placeAutoCompleteUrl,
        );

        if (responseAutoCompleteSearch ==
            'Error occured. Failed to receive request.') {
          return;
        }
        if (responseAutoCompleteSearch["status"] == "OK") {
          var placePredictions = responseAutoCompleteSearch["predictions"];
          var predictedPlacesList =
              (placePredictions as List)
                  .map((e) => PredictedPlaces.fromJson(e))
                  .toList();
          if (mounted) {
            setState(() {
              _predictedPlaces = predictedPlacesList;
            });
          }
        }
      } else if (inputText.length == 1) {
        // Clear predictions if only 1 character
        if (mounted) {
          setState(() {
            _predictedPlaces = [];
          });
        }
      }
    });
  }

  getPlaceDirectionDetailes(String? placeId, context) async {
    String placesDirectionDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';

    var responseApi = await RequestAssistance.receiveRequest(
      placesDirectionDetailsUrl,
    );
    print(responseApi);

    if (responseApi == 'Error occured. Failed to receive request.') {
      return;
    }
    if (responseApi["status"] == "OK") {
      DirectionModel directionModel = DirectionModel();
      directionModel.locationName = responseApi["result"]["name"];
      directionModel.locationId = placeId;
      directionModel.locationLatitude =
          responseApi["result"]["geometry"]["location"]["lat"];
      directionModel.locationLongitude =
          responseApi["result"]["geometry"]["location"]["lng"];

      setState(() {
        UserdropOffAddress = directionModel.locationName!;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Ride'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Where are you going?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              _pickupController,
              'Pickup location',
              Icons.my_location,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _destinationController,
              'Destination',
              Icons.location_on,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Simulate search or navigation logic
                debugPrint(
                  'Searching ride from ${_pickupController.text} to ${_destinationController.text}',
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Find Ride'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: _predictedPlaces.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_predictedPlaces[index].mainText!),
                    subtitle: Text(_predictedPlaces[index].secondaryText!),
                    onTap: () {
                      //
                      getPlaceDirectionDetailes(
                        _predictedPlaces[index].placeId,
                        context,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        findPlaceAutoCompleteSearch(value);
      },
    );
  }
}
