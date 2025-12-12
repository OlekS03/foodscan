import 'dart:convert'; // for decoding json formatted text
import 'package:http/http.dart' as http; // for making the http request

//Future<FoodItem?> ingredientsAndNutrimentsFromBarcode(String barcode) async {
Future<Map<String, dynamic>> ingredientsAndNutrimentsFromBarcode(
  String barcode,
) async {
  print("Inside ingredientsAndNutrimentsFromBarcode");
  /*
      Make call to first api
        if return is null, secondApi = true
        if name or ingredients field is missing, secondApi = true
      if secondApi = true
        make call to second api
          if return is null, unidentified food item warning
          else add values to ingredients.
  */

  //variables:
  var foodInfo = await openFoodFactsApiReturn(barcode);
  bool makeSecondApiCall = false;

  if (foodInfo['food_name'].isEmpty || foodInfo['ingredients'].isEmpty) {
    makeSecondApiCall = true;
  }

  if (makeSecondApiCall) {
    foodInfo = await usdaApiReturn(barcode);
    if (foodInfo['ingredients'] == null || foodInfo['food_name'] == null) {
      return {};
    }
  }
  return foodInfo;
}

Future<Map<String, dynamic>> openFoodFactsApiReturn(String barcode) async {
  var json = await apiSendAndRespond(
    'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
    {
      'fields':
          'product_name,code,ingredients_text,nutriments,allergens,allergens_tags,traces_tags,additives',
    },
    {'User-Agent': 'FoodScan/1.0 (20omarr04@gmail.com)'},
  );

  if (json == null) {
    return {};
  }
  // Product not found (SECOND PORTION TRIGGERED)
  if (json['status'] != 1) {
    return {};
  } else if (json['product'] == null || json['product'] is! Map) {
    return {};
  }
  final product = json['product'] as Map<String, dynamic>;

  final foodName = product['product_name'] as String? ?? 'Unknown Food';
  final ingredients = product['ingredients_text'];
  final nutriments = product['nutriments'] as Map<String, dynamic>?;
  var allergenTags = product['allergens_tags'] as List<dynamic>?;
  var traces = product['traces_tags'] as List<dynamic>?;
  final servingSize = product['serving_size'] as String?;
  final servingQuantity = product['serving_quantity'] as String?;

  //the following section of code cleans the allergen list from the subtitle (en: )
  List<String> cleanedAllergenTags = [];
  List<String> cleanedTraceTags = [];
  if (allergenTags != null) {
    cleanedAllergenTags = [];
    final iterableAllergenTags = allergenTags;

    for (final tag in iterableAllergenTags) {
      if (tag is String) {
        final parts = tag.split(':');
        cleanedAllergenTags.add(parts.length > 1 ? parts[1] : tag);
      }
    }
    allergenTags = cleanedAllergenTags;
  }

  if (traces != null) {
    cleanedTraceTags = [];
    final iterableTraceTags = traces;
    for (final tag in iterableTraceTags) {
      if (tag is String) {
        final parts = tag.split(':');
        cleanedTraceTags.add(parts.length > 1 ? parts[1] : tag);
      }
    }
    traces = cleanedTraceTags;
  }

  return {
    'food_name': foodName,
    'ingredients': ingredients,
    'nutriments': nutriments,
    'allergen_tags': cleanedAllergenTags,
    'traces': traces,
    'serving_size': servingSize,
    'serving_quantity': servingQuantity,
  };
}

Future<Map<String, dynamic>> usdaApiReturn(String barcode) async {
  //DO NOT PUBLSH THE API KEY ONTO THE MAIN BRANCH OF GITHUB!
  String apiKey = "Dummy API Key Here :)";
  //FoodItem newItem = FoodItem();

  var json = await apiSendAndRespond(
    'https://api.nal.usda.gov/fdc/v1/foods/search?query=$barcode&api_key=$apiKey',
    {},
    {},
  );
  if (json == null) {
    return {};
  }

  if (json['foods'] == null || json['foods'].isEmpty) {
    return {};
  }

  if (json["foods"].isEmpty) {
    return {};
  }
  final fdcId = json["foods"][0]["fdcId"];

  //json element was empty
  json = await apiSendAndRespond(
    "https://api.nal.usda.gov/fdc/v1/food/$fdcId?api_key=$apiKey",
    {},
    {},
  );
  if (json == null) {
    return {};
  }

  //extract ingredients, nutrients, and allergens from the usda database.
  var foodName = json['description'] as String;
  var ingredients = json['ingredients'] as String;
  var nutriments = json['labelNutrients'] as Map<String, dynamic>;

  var newNutriments = {};

  //in the following json code, we are collapsing the key value pair of the nutrient's value into simply the value
  nutriments.forEach((key, value) {
    if (value is Map && value.containsKey('value')) {
      newNutriments[key] = value['value'];
    } else {
      newNutriments[key] = value;
    }
  });

  return {
    'food_name': foodName,
    'ingredients': ingredients,
    'nutriments': nutriments,
  };
}

/*
    apiSendAndRespond:
    Sends a request to the API and returns the response.

    has string base, list vars, and list query parameters
*/
Future<Map<String, dynamic>?> apiSendAndRespond(
  String apiBase,
  Map<String, String> queryParams,
  Map<String, String> headers,
) async {
  //construct url
  Uri uri = Uri.parse(apiBase);

  if (queryParams.isNotEmpty) {
    uri = uri.replace(queryParameters: queryParams);
  }

  var apiResponse = await http.get(uri, headers: headers);

  if (apiResponse.statusCode != 200) {
    return null;
  } else if (apiResponse.body.isEmpty) {
    return null;
  }

  var response = jsonDecode(apiResponse.body) as Map<String, dynamic>?;
  return response;
}

List<String> allergensFromIngredients(
  String ingredients,
  List<String> allergens,
) {
  List<String> allergenList = [];
  // All allergens are iterated through, and if an allergen matches the list, it is added to the concurrent list of allergens
  for (final allergen in allergens) {
    if (ingredients.toLowerCase().contains(allergen.toLowerCase())) {
      allergenList.add(allergen);
    }
  }
  return allergenList;
}
