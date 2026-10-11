/**
 * Nutrition dictionary for supported food classes.
 * Calorie and macronutrient values represent reference/estimated values per 100g.
 * References:
 * - https://mynutrients.fun/indian-food-database/
 * - https://suhri.in/nutrition/calories-in-indian-foods
 * - https://fdc.nal.usda.gov/
 */
export const NUTRITION_DATABASE = {
  biryani: {
    displayName: "Biryani",
    caloriesPer100g: 150,
    proteinPer100g: 5.5,
    carbsPer100g: 22.0,
    fatPer100g: 4.2,
    dataType: "estimated_recipe_value",
    sourceUrl: "https://mynutrients.fun/indian-food-database/",
    note: "Estimated value for spiced rice dish; varies by meat/vegetables and oil used."
  },
  cholebhature: {
    displayName: "Chole Bhature",
    caloriesPer100g: 197,
    proteinPer100g: 5.3,
    carbsPer100g: 25.0,
    fatPer100g: 8.0,
    dataType: "estimated_recipe_value",
    sourceUrl: "https://suhri.in/nutrition/calories-in-indian-foods",
    note: "Estimated value for spiced chickpea curry served with fried bhatura."
  },
  dabeli: {
    displayName: "Dabeli",
    caloriesPer100g: 233,
    proteinPer100g: 5.0,
    carbsPer100g: 36.7,
    fatPer100g: 7.5,
    dataType: "estimated_recipe_value",
    sourceUrl: "https://mynutrients.fun/indian-food-database/",
    note: "Estimated value for spiced potato bun filling with peanuts and chutney."
  },
  dal: {
    displayName: "Dal",
    caloriesPer100g: 109,
    proteinPer100g: 5.5,
    carbsPer100g: 16.0,
    fatPer100g: 3.0,
    dataType: "published_reference",
    sourceUrl: "https://fdc.nal.usda.gov/",
    note: "Cooked yellow/mixed lentil preparation with tempered spices."
  },
  dhokla: {
    displayName: "Dhokla",
    caloriesPer100g: 128,
    proteinPer100g: 5.6,
    carbsPer100g: 22.5,
    fatPer100g: 1.7,
    dataType: "estimated_recipe_value",
    sourceUrl: "https://mynutrients.fun/indian-food-database/",
    note: "Steamed fermented gram flour savoury cake with light tempering."
  },
  dosa: {
    displayName: "Dosa",
    caloriesPer100g: 165,
    proteinPer100g: 4.4,
    carbsPer100g: 31.3,
    fatPer100g: 3.1,
    dataType: "published_reference",
    sourceUrl: "https://fdc.nal.usda.gov/",
    note: "Fermented rice and black gram crepe cooked with light oil."
  },
  jalebi: {
    displayName: "Jalebi",
    caloriesPer100g: 380,
    proteinPer100g: 2.0,
    carbsPer100g: 75.0,
    fatPer100g: 10.0,
    dataType: "estimated_recipe_value",
    sourceUrl: "https://suhri.in/nutrition/calories-in-indian-foods",
    note: "Deep-fried refined flour spirals soaked in concentrated sugar syrup."
  },
  kathiroll: {
    displayName: "Kathi Roll",
    caloriesPer100g: 175,
    proteinPer100g: 6.0,
    carbsPer100g: 24.0,
    fatPer100g: 6.0,
    dataType: "estimated_recipe_value",
    sourceUrl: "https://mynutrients.fun/indian-food-database/",
    note: "Layered flatbread rolled with spiced stuffing and sauces."
  },
  kofta: {
    displayName: "Kofta",
    caloriesPer100g: 210,
    proteinPer100g: 7.0,
    carbsPer100g: 15.0,
    fatPer100g: 13.0,
    dataType: "estimated_recipe_value",
    sourceUrl: "https://mynutrients.fun/indian-food-database/",
    note: "Spiced vegetable/paneer dumplings simmered in seasoned curry."
  },
  naan: {
    displayName: "Naan",
    caloriesPer100g: 311,
    proteinPer100g: 11.1,
    carbsPer100g: 50.2,
    fatPer100g: 7.3,
    dataType: "published_reference",
    sourceUrl: "https://fdc.nal.usda.gov/",
    note: "Tandoor-baked leavened flatbread."
  },
  pakora: {
    displayName: "Pakora",
    caloriesPer100g: 250,
    proteinPer100g: 6.0,
    carbsPer100g: 25.0,
    fatPer100g: 14.0,
    dataType: "estimated_recipe_value",
    sourceUrl: "https://suhri.in/nutrition/calories-in-indian-foods",
    note: "Vegetable fritters battered with chickpea flour and deep-fried."
  },
  paneer: {
    displayName: "Paneer Dish",
    caloriesPer100g: 265,
    proteinPer100g: 18.0,
    carbsPer100g: 3.4,
    fatPer100g: 20.0,
    dataType: "published_reference",
    sourceUrl: "https://fdc.nal.usda.gov/",
    note: "Indian cottage cheese preparation."
  },
  panipuri: {
    displayName: "Pani Puri",
    caloriesPer100g: 110,
    proteinPer100g: 2.5,
    carbsPer100g: 21.7,
    fatPer100g: 1.7,
    dataType: "estimated_recipe_value",
    sourceUrl: "https://mynutrients.fun/indian-food-database/",
    note: "Crisp puris filled with spiced potato/sprout mixture and flavored water."
  },
  pavbhaji: {
    displayName: "Pav Bhaji",
    caloriesPer100g: 140,
    proteinPer100g: 3.4,
    carbsPer100g: 20.6,
    fatPer100g: 5.1,
    dataType: "estimated_recipe_value",
    sourceUrl: "https://suhri.in/nutrition/calories-in-indian-foods",
    note: "Mashed vegetable curry in tomato and butter gravy, served with pav."
  },
  vadapav: {
    displayName: "Vada Pav",
    caloriesPer100g: 193,
    proteinPer100g: 4.0,
    carbsPer100g: 28.0,
    fatPer100g: 7.3,
    dataType: "estimated_recipe_value",
    sourceUrl: "https://suhri.in/nutrition/calories-in-indian-foods",
    note: "Deep-fried spiced potato ball inside a sliced bread bun."
  }
};

/**
 * Safely looks up nutrition information for a given predicted food label.
 * @param {string} foodLabel 
 * @returns {object} Nutrition data object
 */
export function getNutritionInfo(foodLabel) {
  if (!foodLabel) {
    return {
      displayName: "Unknown Food",
      caloriesPer100g: 0,
      proteinPer100g: 0,
      carbsPer100g: 0,
      fatPer100g: 0,
      dataType: "estimated_recipe_value",
      sourceUrl: "",
      available: false,
      note: "No food class provided."
    };
  }

  const normalizedKey = foodLabel.trim().toLowerCase().replace(/[\s\-_]+/g, "");

  if (NUTRITION_DATABASE[normalizedKey]) {
    return {
      ...NUTRITION_DATABASE[normalizedKey],
      available: true
    };
  }

  return {
    displayName: foodLabel,
    caloriesPer100g: 0,
    proteinPer100g: 0,
    carbsPer100g: 0,
    fatPer100g: 0,
    dataType: "estimated_recipe_value",
    sourceUrl: "",
    available: false,
    note: "Nutrition data is unavailable for this food item."
  };
}
