import { NUTRITION_DATABASE } from '../data/nutritionData.js';

export function getAllNutrition(req, res) {
  const foods = Object.keys(NUTRITION_DATABASE).map((key) => {
    const item = NUTRITION_DATABASE[key];
    return {
      id: key,
      displayName: item.displayName,
      caloriesPer100g: item.caloriesPer100g,
      proteinPer100g: item.proteinPer100g,
      carbsPer100g: item.carbsPer100g,
      fatPer100g: item.fatPer100g,
      dataType: item.dataType,
      sourceUrl: item.sourceUrl,
      note: item.note
    };
  });

  res.json({
    success: true,
    count: foods.length,
    foods
  });
}
