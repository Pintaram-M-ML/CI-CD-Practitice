# Backend - Task Manager API

This is the backend API for the Task Manager application built with Node.js, Express, and PostgreSQL.

## Structure

```
backend/
├── src/
│   ├── server.js       # Main application entry point
│   ├── config.js       # Configuration management
│   ├── database.js     # Database connection pool
│   └── routes/         # API route handlers
│       └── tasks.js    # Task-related endpoints
├── config/
│   ├── .env            # Environment variables (not in git)
│   └── .env.example    # Example environment variables
└── package.json        # Dependencies and scripts
```

## API Endpoints

### Tasks

- `GET /api/tasks` - Get all tasks
- `GET /api/tasks/:id` - Get a specific task
- `POST /api/tasks` - Create a new task
- `PUT /api/tasks/:id` - Update a task
- `DELETE /api/tasks/:id` - Delete a task

### Health Check

- `GET /api/health` - Check API health status

## Running Locally

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up environment variables:
   ```bash
   cp config/.env.example config/.env
   # Edit config/.env with your database credentials
   ```

3. Start the server:
   ```bash
   npm start
   ```

   For development with auto-reload:
   ```bash
   npm run dev
   ```

## Environment Variables

See `config/.env.example` for all available configuration options.

## Database

The application uses PostgreSQL. Make sure you have a PostgreSQL instance running and update the connection details in `config/.env`.

