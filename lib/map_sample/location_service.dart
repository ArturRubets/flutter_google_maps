import 'dart:convert' as convert;

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
