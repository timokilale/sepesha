// import '../screens/dashboard/home_screen.dart';
//
// class MapService{
//   MapService._();
//
//   static final MapService _instance = MapService._();
//   static MapService get instance => _instance;
//
//
//   Future<void> findPlaceAutoCompleteSearch(String inputText) async {
//     if (inputText.length > 1) {
//       String url =
//           'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:TZ';
//       var response = await RequestAssistance.receiveRequest(url);
//
//       if (response == 'Error occurred. Failed to receive request.') {
//         return;
//       }
//
//       if (response["status"] == "OK") {
//         setState(() {
//           _placePredictions = response["predictions"];
//         });
//       }
//     } else {
//       setState(() {
//         _placePredictions = [];
//       });
//     }
//   }
//
//
// }