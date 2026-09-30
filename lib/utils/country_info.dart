import 'dart:convert';

import 'package:fyrestream/services/db/fyrestream_db_service.dart';
import 'package:http/http.dart';

Future<String> getCountry() async {
  String countryCode = "IN";
  try {
    final response = await get(Uri.parse('http://ip-api.com/json'));
    if (response.statusCode == 200) {
      Map data = jsonDecode(utf8.decode(response.bodyBytes));
      countryCode = data['countryCode'];
      await FyreStreamDBService.putSettingStr('locationCode', countryCode);
    }
  } catch (err) {
    FyreStreamDBService.getSettingStr('locationCode').then((value) {
      if (value != null) {
        countryCode = value;
      } else {
        countryCode = "IN";
      }
    });
  }
  return countryCode;
}