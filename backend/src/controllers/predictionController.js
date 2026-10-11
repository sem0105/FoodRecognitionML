import { predictFoodImage } from '../services/flaskService.js';
import { getNutritionInfo } from '../data/nutritionData.js';
import { cleanupFile } from '../middleware/uploadMiddleware.js';

export async function predictFood(req, res, next) {
  if (!req.file) {
    return res.status(400).json({
      success: false,
      error: 'No image file provided. Please upload an image using the form-data key "image".'
    });
  }

  const filePath = req.file.path;

  try {
    // Validate portion_grams
    let portionGrams = 100;
    if (req.body && req.body.portion_grams !== undefined) {
      const parsed = parseFloat(req.body.portion_grams);
      if (isNaN(parsed) || parsed <= 0 || parsed > 5000) {
        const error = new Error('Invalid portion_grams. Portion weight must be a positive number between 1 and 5000 grams.');
        error.statusCode = 400;
        throw error;
      }
      portionGrams = parsed;
    }

    // Forward image to Flask ML service
    const flaskResult = await predictFoodImage(filePath, req.file.originalname, req.file.mimetype);

    if (!flaskResult || !flaskResult.success) {
      const error = new Error(flaskResult?.error || 'ML prediction service returned an unexpected response format.');
      error.statusCode = 500;
      throw error;
    }

    const predictedFood = flaskResult.predicted_food;
    const confidence = flaskResult.confidence;
    const topPredictions = flaskResult.top_predictions || [];

    // Get nutrition details
    const nutritionInfo = getNutritionInfo(predictedFood);
    const caloriesPer100g = nutritionInfo.caloriesPer100g;
    const proteinPer100g = nutritionInfo.proteinPer100g;
    const carbsPer100g = nutritionInfo.carbsPer100g;
    const fatPer100g = nutritionInfo.fatPer100g;

    // Calculate unrounded totals first to avoid accumulated rounding errors
    const rawCalories = (caloriesPer100g * portionGrams) / 100;
    const rawProtein = (proteinPer100g * portionGrams) / 100;
    const rawCarbs = (carbsPer100g * portionGrams) / 100;
    const rawFat = (fatPer100g * portionGrams) / 100;

    // Round displayed nutrient totals to one decimal place
    const calories = Math.round(rawCalories * 10) / 10;
    const protein = Math.round(rawProtein * 10) / 10;
    const carbs = Math.round(rawCarbs * 10) / 10;
    const fat = Math.round(rawFat * 10) / 10;

    const nutritionPer100g = {
      calories: caloriesPer100g,
      protein: proteinPer100g,
      carbs: carbsPer100g,
      fat: fatPer100g,
      dataType: nutritionInfo.dataType,
      sourceUrl: nutritionInfo.sourceUrl
    };

    res.json({
      success: true,
      foodName: nutritionInfo.displayName || predictedFood,
      confidence,
      portionGrams,
      calories,
      protein,
      carbs,
      fat,
      nutritionPer100g,
      topPredictions,
      // Backward-compatible fields for existing clients
      prediction: {
        food: predictedFood,
        displayName: nutritionInfo.displayName,
        confidence,
        top_predictions: topPredictions
      },
      nutrition: {
        portion_grams: portionGrams,
        calories_per_100g: caloriesPer100g,
        protein_per_100g: proteinPer100g,
        carbs_per_100g: carbsPer100g,
        fat_per_100g: fatPer100g,
        estimated_calories: calories,
        estimated_protein: protein,
        estimated_carbs: carbs,
        estimated_fat: fat,
        available: nutritionInfo.available,
        dataType: nutritionInfo.dataType,
        sourceUrl: nutritionInfo.sourceUrl,
        note: nutritionInfo.note
      }
    });

  } catch (error) {
    next(error);
  } finally {
    // Always clean up temp file
    cleanupFile(filePath);
  }
}
