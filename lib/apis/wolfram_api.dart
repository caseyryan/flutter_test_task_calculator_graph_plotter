
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

class WolframApi {

  /// вернет либо результат вычисления выражения, либо null
  static Future<double> evaluateApression(String mathExpression) async {
    var preparedExpression = Uri.encodeComponent(mathExpression);
    var url = 'https://www.wolframalpha.com/n/v1/api/autocomplete/?i=$preparedExpression';
    var response = await get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json'
    });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json.containsKey('instantMath')) {
        var instantMath = json['instantMath'];
        String valToParse;
        if (instantMath != null) {
          String exactResult = instantMath['exactResult'];
          String approximateResult = json['instantMath']['approximateResult'];
          valToParse = approximateResult.isNotEmpty ? approximateResult : exactResult;
        } else {
          valToParse = mathExpression.trim();
        }
        return double.tryParse(valToParse);
      }
    }
    return null;
  }
}