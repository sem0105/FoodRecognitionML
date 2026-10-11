import dotenv from 'dotenv';
import app from './app.js';

dotenv.config();

const PORT = process.env.PORT || 5000;
const FLASK_URL = process.env.FLASK_API_URL || 'http://127.0.0.1:8000';

app.listen(PORT, '0.0.0.0', () => {
  console.log(`==================================================`);
  console.log(`Node.js Express Backend is running on port ${PORT}`);
  console.log(`Configured Upstream Flask API: ${FLASK_URL}`);
  console.log(`Health endpoint: http://0.0.0.0:${PORT}/api/health`);
  console.log(`Nutrition endpoint: http://0.0.0.0:${PORT}/api/nutrition`);
  console.log(`Predict endpoint: http://0.0.0.0:${PORT}/api/predict`);
  console.log(`==================================================`);
});

