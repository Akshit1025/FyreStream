import 'dart:convert';
import 'dart:developer';
import 'package:fyrestream/routes_and_consts/global_str_consts.dart';
import 'package:fyrestream/services/db/fyrestream_db_service.dart';
import 'package:http/http.dart';

Future<String> getCountry() async {
  String countryCode = "IN";
  await FyreStreamDBService.getSettingBool(GlobalStrConsts.autoGetCountry)
      .then((value) async {
    if (value != null && value == true) {
      try {
        final response = await get(Uri.parse('http://ip-api.com/json'));
        if (response.statusCode == 200) {
          Map data = jsonDecode(utf8.decode(response.bodyBytes));
          countryCode = data['countryCode'];
          await FyreStreamDBService.putSettingStr(
              GlobalStrConsts.countryCode, countryCode);
        }
      } catch (err) {
        await FyreStreamDBService.getSettingStr(GlobalStrConsts.countryCode)
            .then((value) {
          if (value != null) {
            countryCode = value;
          } else {
            countryCode = "IN";
          }
        });
      }
    } else {
      await FyreStreamDBService.getSettingStr(GlobalStrConsts.countryCode)
          .then((value) {
        if (value != null) {
          countryCode = value;
        } else {
          countryCode = "IN";
        }
      });
    }
  });
  log("Country Code: $countryCode");
  return countryCode;
}