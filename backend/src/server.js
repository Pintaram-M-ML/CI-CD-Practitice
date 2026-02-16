const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const config = require('./config');
const tasksRouter = require('./routes/tasks');

const app = express();
const PORT = config.server.port;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// API Routes
app.use('/api/tasks', tasksRouter);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: config.server.env
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT} in ${config.server.env} mode`);
});

