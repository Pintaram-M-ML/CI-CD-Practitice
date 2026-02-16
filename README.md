# 📝 Task Manager - Full Stack Application

A modern, full-stack task management application built with Node.js, Express, PostgreSQL, and vanilla JavaScript.

## 🚀 Features

- ✅ Create, read, update, and delete tasks
- ✅ Mark tasks as complete/incomplete
- ✅ Real-time statistics (total, completed, pending)
- ✅ Beautiful, responsive UI with smooth animations
- ✅ RESTful API backend
- ✅ PostgreSQL database for data persistence
- ✅ Docker containerization for easy deployment

## 🏗️ Architecture

This application uses a **3-container microservices architecture**:

1. **Frontend Container** (Nginx) - Serves static files and proxies API requests
2. **Backend Container** (Node.js/Express) - REST API server
3. **Database Container** (PostgreSQL) - Data persistence

## 🛠️ Tech Stack

### Frontend
- HTML5
- CSS3 (with animations and gradients)
- Vanilla JavaScript (ES6+)
- Nginx (web server)

### Backend
- Node.js
- Express.js
- PostgreSQL
- pg (node-postgres)

### DevOps
- Docker
- Docker Compose
- Nginx reverse proxy

## 📋 Prerequisites

- Docker and Docker Compose installed on your system
- OR Node.js (v18+) and PostgreSQL (if running without Docker)

## 🐳 Quick Start with Docker (Recommended)

1. **Clone or navigate to the project directory**

2. **Start the application**
   ```bash
   docker-compose up -d
   ```

3. **Access the application**
   - **Frontend**: http://localhost:8080 (Nginx)
   - **Backend API**: http://localhost:3000 (Express)
   - **Database**: localhost:5432 (PostgreSQL)

4. **Stop the application**
   ```bash
   docker-compose down
   ```

5. **Stop and remove all data**
   ```bash
   docker-compose down -v
   ```

## 💻 Running Locally (Without Docker)

### 1. Install Dependencies
```bash
npm install
```

### 2. Set up PostgreSQL Database
Create a database named `taskmanager` and run the initialization script:
```bash
psql -U postgres -d taskmanager -f init.sql
```

### 3. Configure Environment Variables
Copy `.env.example` to `.env` and update the values:
```bash
cp .env.example .env
```

Edit `.env` with your local database credentials.

### 4. Start the Server
```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

### 5. Access the Application
Open your browser to http://localhost:3000

## 📡 API Endpoints

### Tasks

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/tasks` | Get all tasks |
| GET | `/api/tasks/:id` | Get a single task |
| POST | `/api/tasks` | Create a new task |
| PUT | `/api/tasks/:id` | Update a task |
| DELETE | `/api/tasks/:id` | Delete a task |

### Health Check

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Check API health status |

### Example API Requests

**Create a task:**
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"text": "Buy groceries"}'
```

**Get all tasks:**
```bash
curl http://localhost:3000/api/tasks
```

**Update a task:**
```bash
curl -X PUT http://localhost:3000/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'
```

**Delete a task:**
```bash
curl -X DELETE http://localhost:3000/api/tasks/1
```

## 📁 Project Structure

```
.
├── backend/                    # Backend application
│   ├── src/                    # Source code
│   │   ├── server.js           # Express server entry point
│   │   ├── config.js           # Configuration management
│   │   ├── database.js         # Database connection pool
│   │   └── routes/             # API routes
│   │       └── tasks.js        # Tasks API endpoints
│   ├── config/                 # Configuration files
│   │   ├── .env                # Environment variables
│   │   └── .env.example        # Example environment variables
│   └── package.json            # Node.js dependencies
│
├── frontend/                   # Frontend application
│   └── src/                    # Source code
│       ├── index.html          # Main HTML file
│       ├── styles/             # CSS files
│       │   └── styles.css      # Main stylesheet
│       └── scripts/            # JavaScript files (future)
│
├── database/                   # Database files
│   └── init.sql                # Database initialization script
│
├── docker/                     # Docker configuration
│   ├── Dockerfile.backend      # Backend Dockerfile
│   ├── Dockerfile.nginx        # Nginx Dockerfile (optional)
│   ├── docker-compose.yml      # Docker Compose configuration
│   └── .dockerignore           # Docker ignore file
│
├── docker-compose.yml          # Root Docker Compose file
├── .gitignore                  # Git ignore file
└── README.md                   # This file
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Backend server port | 3000 |
| DB_HOST | PostgreSQL host | db |
| DB_PORT | PostgreSQL port | 5432 |
| DB_NAME | Database name | taskmanager |
| DB_USER | Database user | postgres |
| DB_PASSWORD | Database password | postgres |

## 🎨 Features in Detail

### Frontend
- Modern gradient background
- Responsive card-based layout
- Smooth animations and transitions
- Shake animation for validation
- Real-time statistics updates
- Error handling with user feedback

### Backend
- RESTful API design
- Input validation
- Error handling
- CORS enabled
- Database connection pooling

### Database
- Indexed queries for performance
- Timestamps for created/updated tracking
- Sample data on initialization

## 🚢 Deployment

The application is containerized and ready for deployment to any Docker-compatible platform:

- Docker Swarm
- Kubernetes
- AWS ECS
- Google Cloud Run
- Azure Container Instances
- DigitalOcean App Platform

## 📝 License

ISC

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

