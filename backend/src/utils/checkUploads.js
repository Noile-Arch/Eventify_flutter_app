const fs = require('fs');
const path = require('path');

const checkUploadsDirectory = () => {
  const uploadsPath = path.join(__dirname, '../../public/uploads');
  
  try {
    if (!fs.existsSync(uploadsPath)) {
      console.log('Creating uploads directory...');
      fs.mkdirSync(uploadsPath, { recursive: true });
      console.log('Uploads directory created at:', uploadsPath);
    } else {
      console.log('Uploads directory exists at:', uploadsPath);
      // List contents of uploads directory
      const files = fs.readdirSync(uploadsPath);
      console.log('Files in uploads directory:', files);
    }
  } catch (error) {
    console.error('Error checking/creating uploads directory:', error);
  }
};

checkUploadsDirectory(); 