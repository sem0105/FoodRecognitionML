import multer from 'multer';
import path from 'path';
import fs from 'fs';
import os from 'os';

// Temporary upload directory
const uploadDir = path.join(os.tmpdir(), 'food_app_uploads');

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `upload-${uniqueSuffix}${ext}`);
  }
});

const fileFilter = (req, file, cb) => {
  const mimetype = (file.mimetype || '').toLowerCase();
  const ext = (path.extname(file.originalname) || '').toLowerCase();

  const allowedExts = ['.jpg', '.jpeg', '.png', '.webp', '.heic', '.heif', '.jfif', '.bmp', '.pjpeg', '.pjp'];
  const allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/jpg',
    'image/webp',
    'image/heic',
    'image/heif',
    'image/jfif',
    'image/bmp',
    'application/octet-stream'
  ];

  if (mimetype.startsWith('image/') || allowedMimeTypes.includes(mimetype) || allowedExts.includes(ext)) {
    cb(null, true);
  } else {
    const error = new Error('Invalid file format. Only JPEG, PNG, WebP, and HEIC images are allowed.');
    error.statusCode = 400;
    cb(error, false);
  }
};


const maxMb = parseInt(process.env.MAX_FILE_SIZE_MB || '10', 10);

export const uploadSingleImage = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: maxMb * 1024 * 1024
  }
}).single('image');

/**
 * Safely removes a file from disk if it exists.
 * @param {string} filePath 
 */
export function cleanupFile(filePath) {
  if (filePath && fs.existsSync(filePath)) {
    fs.unlink(filePath, (err) => {
      if (err) console.error(`Failed to clean up temp file ${filePath}:`, err.message);
    });
  }
}
