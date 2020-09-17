
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

class WolframApi {

  static const String APP_ID = 'GEG2E7-E2WGL33E9J';
  static const String WOLFRAM_INPUT_URL = 'https://api.wolframalpha.com/v2/query?input=';

  /// вернет либо результат вычисления выражения, либо null
  static Future<double> evaluateExpression(String mathExpression) async {
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
  /// делает плот запрос к вольфраму и возвращет url картинки с функцией
  /// если она есть, или null
  static Future<String> plotAFunction({
      String expression, 
      double fromX, 
      double toX
    }) async {
    var url = '${WOLFRAM_INPUT_URL}plot+$expression+from+x=$fromX+to+$toX&format=image,plaintext&output=JSON&appid=$APP_ID';
    var response = await get(url);
    if (response.statusCode == 200) {
      try {
        Map json = jsonDecode(response.body);
        if (json.containsKey('queryresult')) {
          if (json['queryresult'].containsKey('pods')) {
            List pods = json['queryresult']['pods'];
            var imagePod = pods.firstWhere((p) => p['title'] == 'Plot', orElse: () => null);
            if (imagePod != null) {
              List subpods = imagePod['subpods'];
              if (subpods.isNotEmpty) {
                var imageUrl = subpods[0]['img']['src'];
                //print(imageUrl);
                return imageUrl;
              }
            }
          }
        }
      } catch (e) {
        debugPrint(e);
      }
    }
    return null;
  }

}