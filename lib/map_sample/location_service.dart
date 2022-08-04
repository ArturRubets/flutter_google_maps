import 'dart:convert' as convert;

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static const _key = 'AIzaSyCuaykOmoXu0BSY0H1XH8EUu5JN0J0QnIY';

  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await _getPlaceId(input);
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_key';
    final response = await http.get(Uri.parse(url));
    final json = convert.jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['result'] as Map<String, dynamic>;
    return results;
  }

  Future<Map<String, dynamic>> getDirections(
    String origin,
    String destination,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?destination=$destination&origin=$origin&key=$_key';
    final response = await http.get(Uri.parse(url));
    final json = convert.jsonDecode(response.body) as Map;
    final routes = json['routes'] as List;
    final route = routes[0] as Map;

    final bounds = route['bounds'] as Map;
    final boundsNortheast = bounds['northeast'] as Map;
    final boundsSouthwest = bounds['southwest'] as Map;

    final legs = route['legs'] as List;
    final leg = legs[0] as Map;

    final startLocation = leg['start_location'] as Map;
    final endLocation = leg['end_location'] as Map;

    final overviewPolyline = route['overview_polyline'] as Map;
    final points = overviewPolyline['points'] as String;
    final polyline = PolylinePoints().decodePolyline(points);

    final results = {
      'boundsNortheast': boundsNortheast,
      'boundsSouthwest': boundsSouthwest,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'polyline': polyline,
    };
    return results;
  }

  Future<String> _getPlaceId(String input) async {
    final url = '''
https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$_key''';
    final response = await http.get(Uri.parse(url));
    final json = convert.jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List;
    final candidate = candidates[0] as Map<String, dynamic>;
    final placeId = candidate['place_id'] as String;
    return placeId;
  }
}
