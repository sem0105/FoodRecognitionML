class TopPredictionItem {
  final String food;
  final double confidence;

  TopPredictionItem({
    required this.food,
    required this.confidence,
  });

  factory TopPredictionItem.fromJson(Map<String, dynamic> json) {
    return TopPredictionItem(
      food: json['food'] ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food': food,
      'confidence': confidence,
    };
  }
}

class PredictionInfo {
  final String food;
  final String displayName;
  final double confidence;
  final List<TopPredictionItem> topPredictions;

  PredictionInfo({
    required this.food,
    required this.displayName,
    required this.confidence,
    required this.topPredictions,
  });

  factory PredictionInfo.fromJson(Map<String, dynamic> json) {
    var rawList = json['top_predictions'] as List? ?? [];
    List<TopPredictionItem> tops = rawList
        .map((item) => TopPredictionItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return PredictionInfo(
      food: json['food'] ?? 'Unknown',
      displayName: json['displayName'] ?? json['food'] ?? 'Unknown Food',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      topPredictions: tops,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food': food,
      'displayName': displayName,
      'confidence': confidence,
      'top_predictions': topPredictions.map((e) => e.toJson()).toList(),
    };
  }
}

class NutritionPer100g {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String dataType;
  final String sourceUrl;

  NutritionPer100g({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.dataType = 'estimated_recipe_value',
    this.sourceUrl = '',
  });

  factory NutritionPer100g.fromJson(Map<String, dynamic> json) {
    return NutritionPer100g(
      calories: (json['calories'] as num?)?.toDouble() ??
          (json['calories_per_100g'] as num?)?.toDouble() ??
          0.0,
      protein: (json['protein'] as num?)?.toDouble() ??
          (json['protein_per_100g'] as num?)?.toDouble() ??
          0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ??
          (json['carbs_per_100g'] as num?)?.toDouble() ??
          0.0,
      fat: (json['fat'] as num?)?.toDouble() ??
          (json['fat_per_100g'] as num?)?.toDouble() ??
          0.0,
      dataType: json['dataType'] ?? json['data_type'] ?? 'estimated_recipe_value',
      sourceUrl: json['sourceUrl'] ?? json['source_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'dataType': dataType,
      'sourceUrl': sourceUrl,
    };
  }
}

class NutritionInfo {
  final double portionGrams;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  final double estimatedCalories;
  final double estimatedProtein;
  final double estimatedCarbs;
  final double estimatedFat;

  final bool available;
  final String dataType;
  final String sourceUrl;
  final String note;

  NutritionInfo({
    required this.portionGrams,
    required this.caloriesPer100g,
    this.proteinPer100g = 0.0,
    this.carbsPer100g = 0.0,
    this.fatPer100g = 0.0,
    required this.estimatedCalories,
    this.estimatedProtein = 0.0,
    this.estimatedCarbs = 0.0,
    this.estimatedFat = 0.0,
    required this.available,
    this.dataType = 'estimated_recipe_value',
    this.sourceUrl = '',
    required this.note,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    final portion = (json['portion_grams'] as num?)?.toDouble() ??
        (json['portionGrams'] as num?)?.toDouble() ??
        100.0;
    final cal100 = (json['calories_per_100g'] as num?)?.toDouble() ??
        (json['caloriesPer100g'] as num?)?.toDouble() ??
        0.0;
    final prot100 = (json['protein_per_100g'] as num?)?.toDouble() ??
        (json['proteinPer100g'] as num?)?.toDouble() ??
        0.0;
    final carb100 = (json['carbs_per_100g'] as num?)?.toDouble() ??
        (json['carbsPer100g'] as num?)?.toDouble() ??
        0.0;
    final fat100 = (json['fat_per_100g'] as num?)?.toDouble() ??
        (json['fatPer100g'] as num?)?.toDouble() ??
        0.0;

    // Estimated totals: take explicitly provided fields, or calculate from portion
    final estCal = (json['estimated_calories'] as num?)?.toDouble() ??
        (json['calories'] as num?)?.toDouble() ??
        ((cal100 * portion) / 100.0);
    final estProt = (json['estimated_protein'] as num?)?.toDouble() ??
        (json['protein'] as num?)?.toDouble() ??
        ((prot100 * portion) / 100.0);
    final estCarb = (json['estimated_carbs'] as num?)?.toDouble() ??
        (json['carbs'] as num?)?.toDouble() ??
        ((carb100 * portion) / 100.0);
    final estFat = (json['estimated_fat'] as num?)?.toDouble() ??
        (json['fat'] as num?)?.toDouble() ??
        ((fat100 * portion) / 100.0);

    return NutritionInfo(
      portionGrams: portion,
      caloriesPer100g: cal100,
      proteinPer100g: prot100,
      carbsPer100g: carb100,
      fatPer100g: fat100,
      estimatedCalories: double.parse(estCal.toStringAsFixed(1)),
      estimatedProtein: double.parse(estProt.toStringAsFixed(1)),
      estimatedCarbs: double.parse(estCarb.toStringAsFixed(1)),
      estimatedFat: double.parse(estFat.toStringAsFixed(1)),
      available: json['available'] ?? true,
      dataType: json['dataType'] ?? json['data_type'] ?? 'estimated_recipe_value',
      sourceUrl: json['sourceUrl'] ?? json['source_url'] ?? '',
      note: json['note'] ?? 'Estimated value based on typical recipe.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portion_grams': portionGrams,
      'calories_per_100g': caloriesPer100g,
      'protein_per_100g': proteinPer100g,
      'carbs_per_100g': carbsPer100g,
      'fat_per_100g': fatPer100g,
      'estimated_calories': estimatedCalories,
      'estimated_protein': estimatedProtein,
      'estimated_carbs': estimatedCarbs,
      'estimated_fat': estimatedFat,
      'available': available,
      'dataType': dataType,
      'sourceUrl': sourceUrl,
      'note': note,
    };
  }
}

class PredictionResponse {
  final bool success;
  final String? foodName;
  final double? confidence;
  final double? portionGrams;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final NutritionPer100g? nutritionPer100g;
  final List<TopPredictionItem> topPredictions;
  final PredictionInfo? prediction;
  final NutritionInfo? nutrition;
  final String? error;

  PredictionResponse({
    required this.success,
    this.foodName,
    this.confidence,
    this.portionGrams,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.nutritionPer100g,
    this.topPredictions = const [],
    this.prediction,
    this.nutrition,
    this.error,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] == true) {
      // Parse top-level or nested prediction info
      PredictionInfo? pred;
      if (json['prediction'] != null) {
        pred = PredictionInfo.fromJson(json['prediction']);
      }

      // Parse topPredictions list
      List<TopPredictionItem> tops = [];
      if (json['topPredictions'] is List) {
        tops = (json['topPredictions'] as List)
            .map((item) => TopPredictionItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (pred != null && pred.topPredictions.isNotEmpty) {
        tops = pred.topPredictions;
      }

      // Parse nutritionPer100g
      NutritionPer100g? nPer100;
      if (json['nutritionPer100g'] != null) {
        nPer100 = NutritionPer100g.fromJson(json['nutritionPer100g']);
      }

      // Parse nutrition object
      NutritionInfo? nut;
      if (json['nutrition'] != null) {
        nut = NutritionInfo.fromJson(json['nutrition']);
      } else if (nPer100 != null || json['calories'] != null) {
        // Construct from top-level fields
        final portion = (json['portionGrams'] as num?)?.toDouble() ?? 100.0;
        nut = NutritionInfo(
          portionGrams: portion,
          caloriesPer100g: nPer100?.calories ?? 0.0,
          proteinPer100g: nPer100?.protein ?? 0.0,
          carbsPer100g: nPer100?.carbs ?? 0.0,
          fatPer100g: nPer100?.fat ?? 0.0,
          estimatedCalories: (json['calories'] as num?)?.toDouble() ?? 0.0,
          estimatedProtein: (json['protein'] as num?)?.toDouble() ?? 0.0,
          estimatedCarbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
          estimatedFat: (json['fat'] as num?)?.toDouble() ?? 0.0,
          available: true,
          dataType: nPer100?.dataType ?? 'estimated_recipe_value',
          sourceUrl: nPer100?.sourceUrl ?? '',
          note: 'Estimated reference nutritional values.',
        );
      }

      final fName = json['foodName'] ?? pred?.displayName ?? pred?.food;
      final conf = (json['confidence'] as num?)?.toDouble() ?? pred?.confidence ?? 0.0;
      final pGrams = (json['portionGrams'] as num?)?.toDouble() ?? nut?.portionGrams ?? 100.0;
      final cal = (json['calories'] as num?)?.toDouble() ?? nut?.estimatedCalories ?? 0.0;
      final prot = (json['protein'] as num?)?.toDouble() ?? nut?.estimatedProtein ?? 0.0;
      final carb = (json['carbs'] as num?)?.toDouble() ?? nut?.estimatedCarbs ?? 0.0;
      final f = (json['fat'] as num?)?.toDouble() ?? nut?.estimatedFat ?? 0.0;

      return PredictionResponse(
        success: true,
        foodName: fName,
        confidence: conf,
        portionGrams: pGrams,
        calories: cal,
        protein: prot,
        carbs: carb,
        fat: f,
        nutritionPer100g: nPer100 ??
            (nut != null
                ? NutritionPer100g(
                    calories: nut.caloriesPer100g,
                    protein: nut.proteinPer100g,
                    carbs: nut.carbsPer100g,
                    fat: nut.fatPer100g,
                    dataType: nut.dataType,
                    sourceUrl: nut.sourceUrl,
                  )
                : null),
        topPredictions: tops,
        prediction: pred ??
            (fName != null
                ? PredictionInfo(
                    food: fName,
                    displayName: fName,
                    confidence: conf,
                    topPredictions: tops,
                  )
                : null),
        nutrition: nut,
      );
    } else {
      return PredictionResponse(
        success: false,
        error: json['error'] ?? 'Prediction failed.',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'foodName': foodName,
      'confidence': confidence,
      'portionGrams': portionGrams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'nutritionPer100g': nutritionPer100g?.toJson(),
      'topPredictions': topPredictions.map((e) => e.toJson()).toList(),
      'prediction': prediction?.toJson(),
      'nutrition': nutrition?.toJson(),
      'error': error,
    };
  }
}
