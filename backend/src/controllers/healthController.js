import { checkFlaskHealth } from '../services/flaskService.js';

export async function getHealth(req, res, next) {
  try {
    const flaskHealth = await checkFlaskHealth();
    
    const isHealthy = flaskHealth.available;
    const statusCode = isHealthy ? 200 : 503;

    res.status(statusCode).json({
      success: isHealthy,
      backend: 'ok',
      flask: isHealthy ? 'ok' : 'unreachable',
      flaskDetails: flaskHealth.available ? flaskHealth.data : { error: flaskHealth.error }
    });
  } catch (error) {
    next(error);
  }
}
