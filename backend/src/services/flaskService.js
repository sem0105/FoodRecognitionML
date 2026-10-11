import axios from 'axios';
import FormData from 'form-data';
import fs from 'fs';

const getFlaskUrl = () => process.env.FLASK_API_URL || 'http://127.0.0.1:8000';

/**
 * Checks health of the upstream Flask ML service.
 * @returns {Promise<{available: boolean, details: any}>}
 */
export async function checkFlaskHealth() {
  try {
    const response = await axios.get(`${getFlaskUrl()}/health`, {
      timeout: 3000
    });
    return {
      available: true,
      data: response.data
    };
  } catch (error) {
    return {
      available: false,
      error: error.message
    };
  }
}

/**
 * Forwards an uploaded image to Flask /predict endpoint.
 * @param {string} filePath Local path to the uploaded image
 * @param {string} originalName Original filename
 * @param {string} mimeType Mime type
 * @returns {Promise<any>}
 */
export async function predictFoodImage(filePath, originalName, mimeType) {
  const form = new FormData();
  form.append('image', fs.createReadStream(filePath), {
    filename: originalName,
    contentType: mimeType
  });

  try {
    const response = await axios.post(`${getFlaskUrl()}/predict`, form, {
      headers: {
        ...form.getHeaders()
      },
      timeout: 15000
    });

    return response.data;
  } catch (error) {
    if (error.code === 'ECONNREFUSED' || error.code === 'ENOTFOUND') {
      const err = new Error('Flask ML prediction service is currently offline or unreachable.');
      err.statusCode = 503;
      throw err;
    }
    if (error.code === 'ECONNABORTED') {
      const err = new Error('Prediction request to ML service timed out.');
      err.statusCode = 504;
      throw err;
    }
    if (error.response) {
      const message = error.response.data?.error || 'ML service returned an error during prediction.';
      const err = new Error(message);
      err.statusCode = error.response.status || 500;
      throw err;
    }
    throw error;
  }
}
