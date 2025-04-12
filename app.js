const express = require('express');
require('dotenv').config();
const { initializeDatabase } = require('./models');
const file_route = require('./routes/fileRoute');
const { trackApiMetrics } = require('./utils/cloudwatch_metrics');
const logger = require('./utils/logs');

const app = express();

// Add middleware to parse JSON and form data
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(trackApiMetrics);

app.use((req, res, next) => {
  if ((req.method === 'GET' && req.path === '/healthz') || (req.method === "GET" && req.path === "/cicd")) {
    const hasContent = Object.keys(req.query).length > 0
      || req.headers['content-length'] > 0
      || req.headers['transfer-encoding'];

    if (hasContent) {
      setHeaders(res);
      logger.warn(
        "Health check request with content body or query parameters"
      );
      return res.status(400).end();
    }
  }
  next();
});

let HealthCheck = null;

function setHeaders(res) {
  res.header('Cache-Control', 'no-cache, no-store, must-revalidate');
  res.header('Pragma', 'no-cache');
  res.header('X-Content-Type-Options', 'nosniff');
}

app.get('/healthz', async (req, res) => {
  try {
    if (!HealthCheck) {
      throw new Error('Database not connected');
    }
    await HealthCheck.create({});
    setHeaders(res);
    logger.info("Health check passed");
    res.status(200).end();
  } catch (error) {
    setHeaders(res);
    logger.error("Health check failed", {
      message: error.message,
      stack: error.stack,
    });
    res.status(503).end();
  }
});

app.get('/cicd', async (req, res) => {
  try {
    if (!HealthCheck) {
      throw new Error('Database not connected');
    }
    await HealthCheck.create({});
    setHeaders(res);
    logger.info("CI/CD check passed");
    res.status(200).end();
  } catch (error) {
    setHeaders(res);
    logger.error("CI/CD check failed", {
      message: error.message,
      stack: error.stack,
    });
    res.status(503).end();
  }
});

app.all("/cicd", (req, res) => {
  logger.warn(`Method not allowed on CICD check endpoint: ${req.method}`);
  setHeaders(res);
  res.status(405).end();
});

app.all('/healthz', (req, res) => {
  setHeaders(res);
  logger.warn("Health check request with invalid method");
  res.status(405).end();
});

app.use('/', file_route)

app.all('*', (req, res) => {
  setHeaders(res);
  logger.warn("Request for undefined route");
  res.status(404).end();
});

const PORT = process.env.PORT || 8080;

// Initializing the Server
async function startServer() {
  try {
    const models = await initializeDatabase();
    HealthCheck = models.HealthCheck;
    logger.info("Database connection successful");
    global.db = models;
  } catch (error) {
    logger.error("Database connection failed", {
      message: error.message,
      stack: error.stack,
    });
  } finally {
    app.listen(PORT, () => logger.info(`Server running on port ${PORT}`));
  }
}

startServer();

module.exports = app;