import 'dart:convert';                   // for decoding json formatted text
import 'package:http/http.dart' as http; // for making the http request

/*
    Notes: The OpenFoodFacts APIv2 is used for the endpoint
*/
Future<Map<String, dynamic>?> ingredientsAndNutrimentsFromBarcode(
  String barcode,
) async {
  /*
      URL Construction:
        The base url for OpenFoodFacts is the inital url.
        The barcode and query parameters are attached to the final url.
  */
  final Uri uri = Uri.parse(
    'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
  ).replace(queryParameters: {'fields': 'code,ingredients_text,nutriments'});

  /*
      HTTP Response Handling:
        Null will be returned in the case that the foodscan server does not respond or information pertaining to the food item is not found.
  */
  final response = await http.get(
    uri,
    headers: {'User-Agent': 'FoodScan/1.0 (20omarr04@gmail.com)'},
  );

  if (response.statusCode != 200) {
    // Bad response from server
    return null;
  }
  final Map<String, dynamic> json = jsonDecode(response.body);
  if (json['status'] != 1) {
    // Product not found
    return null;
  }
  final product = json['product'] as Map<String, dynamic>;
  final ingredients = product['ingredients_text'];
  //final nutriments = product['nutriments'] as Map<String, dynamic>?;

  return {
    'ingredients': ingredients,
    //'nutriments': nutriments,
  };
}
