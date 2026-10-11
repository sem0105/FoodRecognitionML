import multer from 'multer';

export function errorHandler(err, req, res, next) {
  let statusCode = err.statusCode || res.statusCode || 500;
  let message = err.message || 'An unexpected server error occurred.';

  if (err instanceof multer.MulterError) {
    statusCode = 400;
    if (err.code === 'LIMIT_FILE_SIZE') {
      const maxMb = process.env.MAX_FILE_SIZE_MB || '10';
      message = `Image file size is too large. Maximum limit is ${maxMb}MB.`;
    } else {
      message = `File upload error: ${err.message}`;
    }
  }

  if (statusCode === 500) {
    console.error('[SERVER ERROR]:', err);
  }

  res.status(statusCode).json({
    success: false,
    error: message
  });
}
