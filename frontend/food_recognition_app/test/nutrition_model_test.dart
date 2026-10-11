import 'package:flutter_test/flutter_test.dart';
import 'package:food_recognition_app/models/prediction_result.dart';

void main() {
  group('PredictionResult & NutritionInfo tests', () {
    test('Calculates and deserializes nutrition correctly for biryani 250g', () {
      final jsonResponse = {
        'success': true,
        'foodName': 'Biryani',
        'confidence': 96.4,
        'portionGrams': 250.0,
        'calories': 375.0,
        'protein': 13.8,
        'carbs': 55.0,
        'fat': 10.5,
        'nutritionPer100g': {
          'calories': 150.0,
          'protein': 5.5,
          'carbs': 22.0,
          'fat': 4.2,
          'dataType': 'estimated_recipe_value',
          'sourceUrl': 'https://mynutrients.fun/indian-food-database/'
        },
        'topPredictions': [
          {'food': 'biryani', 'confidence': 96.4},
          {'food': 'dal', 'confidence': 2.1}
        ]
      };

      final response = PredictionResponse.fromJson(jsonResponse);

      expect(response.success, isTrue);
      expect(response.foodName, 'Biryani');
      expect(response.confidence, 96.4);
      expect(response.portionGrams, 250.0);
      expect(response.calories, 375.0);
      expect(response.protein, 13.8);
      expect(response.carbs, 55.0);
      expect(response.fat, 10.5);
      expect(response.nutritionPer100g?.calories, 150.0);
      expect(response.topPredictions.length, 2);
    });

    test('Handles missing optional nutrition fields safely', () {
      final jsonResponse = {
        'success': true,
        'prediction': {
          'food': 'dal',
          'displayName': 'Dal',
          'confidence': 88.0,
          'top_predictions': []
        }
      };

      final response = PredictionResponse.fromJson(jsonResponse);

      expect(response.success, isTrue);
      expect(response.foodName, 'Dal');
      expect(response.calories, 0.0);
      expect(response.protein, 0.0);
      expect(response.carbs, 0.0);
      expect(response.fat, 0.0);
    });
  });
}
