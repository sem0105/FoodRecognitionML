import { Router } from 'express';
import { getHealth } from '../controllers/healthController.js';
import { getAllNutrition } from '../controllers/nutritionController.js';
import { predictFood } from '../controllers/predictionController.js';
import { uploadSingleImage } from '../middleware/uploadMiddleware.js';

const router = Router();

// GET /api/health
router.get('/health', getHealth);

// GET /api/nutrition
router.get('/nutrition', getAllNutrition);

// POST /api/predict
router.post('/predict', uploadSingleImage, predictFood);

export default router;
