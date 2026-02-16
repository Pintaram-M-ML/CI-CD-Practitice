# 🏗️ Task Manager - 3-Container Architecture

## Overview

This application follows a **microservices architecture** with three separate Docker containers, each handling a specific responsibility.

## Container Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Network                        │
│                  (taskmanager-network)                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────┐                                   │
│  │   FRONTEND       │                                   │
│  │   Container      │                                   │
│  │                  │                                   │
│  │   Nginx:alpine   │                                   │
│  │   Port: 8080     │                                   │
│  │                  │                                   │
│  │   Serves:        │                                   │
│  │   - HTML/CSS/JS  │                                   │
│  │   - Static files │                                   │
│  │                  │                                   │
│  │   Proxies:       │                                   │
│  │   /api/* → :3000 │                                   │
│  └────────┬─────────┘                                   │
│           │                                              │
│           │ HTTP Proxy                                   │
│           ▼                                              │
│  ┌──────────────────┐       ┌──────────────────┐       │
│  │   BACKEND        │       │   DATABASE       │       │
│  │   Container      │◄──────│   Container      │       │
│  │                  │  SQL  │                  │       │
│  │   Node:18-alpine │       │   Postgres:15    │       │
│  │   Port: 3000     │       │   Port: 5432     │       │
│  │                  │       │                  │       │
│  │   Provides:      │       │   Stores:        │       │
│  │   - REST API     │       │   - Tasks data   │       │
│  │   - /api/tasks   │       │   - Persistent   │       │
│  │   - /api/health  │       │     volume       │       │
│  └──────────────────┘       └──────────────────┘       │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Container Details

### 1. Frontend Container (taskmanager-frontend)

**Image**: `nginx:alpine`  
**Port**: `8080:80`  
**Purpose**: Serve static frontend files and proxy API requests

**Responsibilities**:
- Serve HTML, CSS, and JavaScript files
- Handle client-side routing
- Proxy `/api/*` requests to backend container
- Provide reverse proxy functionality

**Files**:
- `frontend/src/index.html` - Main HTML file
- `frontend/src/styles/styles.css` - Stylesheet
- `docker/nginx.conf` - Nginx configuration

**Configuration**:
```nginx
location / {
    root /usr/share/nginx/html;
    try_files $uri $uri/ /index.html;
}

location /api/ {
    proxy_pass http://backend:3000;
}
```

### 2. Backend Container (taskmanager-backend)

**Image**: `node:18-alpine` (custom build)  
**Port**: `3000:3000`  
**Purpose**: REST API server

**Responsibilities**:
- Handle API requests
- Business logic processing
- Database communication
- Data validation

**API Endpoints**:
- `GET /api/tasks` - Get all tasks
- `GET /api/tasks/:id` - Get single task
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task
- `GET /api/health` - Health check

**Files**:
- `backend/src/server.js` - Express server
- `backend/src/config.js` - Configuration
- `backend/src/database.js` - DB connection
- `backend/src/routes/tasks.js` - API routes

### 3. Database Container (taskmanager-db)

**Image**: `postgres:15-alpine`  
**Port**: `5432:5432`  
**Purpose**: Data persistence

**Responsibilities**:
- Store task data
- Handle SQL queries
- Data persistence via Docker volume
- Database initialization

**Schema**:
```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    text VARCHAR(500) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Files**:
- `database/init.sql` - Schema and seed data

**Volume**:
- `postgres_data` - Persistent data storage

## Communication Flow

### User Request Flow

1. **User accesses** `http://localhost:8080`
   - Nginx serves `index.html` from frontend container

2. **Frontend loads** and makes API call to `/api/tasks`
   - Nginx proxies request to `http://backend:3000/api/tasks`

3. **Backend receives** API request
   - Validates request
   - Queries PostgreSQL database

4. **Database returns** data
   - Backend formats response
   - Returns JSON to frontend

5. **Frontend renders** tasks
   - Updates UI with data

### Container Dependencies

```
frontend → backend → database
```

- Frontend depends on backend (for API)
- Backend depends on database (health check)
- Database is independent

## Network Configuration

All containers are connected via a custom bridge network: `taskmanager-network`

**Benefits**:
- Containers can communicate using service names
- Isolated from other Docker networks
- Built-in DNS resolution

## Volume Mounts

### Development Volumes (Hot Reload)
- `./backend/src → /app/src` - Backend source code
- `./frontend/src → /usr/share/nginx/html` - Frontend files

### Persistent Volumes
- `postgres_data` - Database data persistence

## Environment Variables

Backend container uses:
- `DB_HOST=db` - Database hostname
- `DB_PORT=5432` - Database port
- `DB_NAME=taskmanager` - Database name
- `DB_USER=postgres` - Database user
- `DB_PASSWORD=postgres` - Database password
- `PORT=3000` - Backend server port

## Health Checks

### Database Health Check
```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]
  interval: 10s
  timeout: 5s
  retries: 5
```

Backend waits for database to be healthy before starting.

## Advantages of 3-Container Architecture

1. **Separation of Concerns**
   - Each container has a single responsibility
   - Easier to maintain and debug

2. **Scalability**
   - Can scale each service independently
   - Frontend can be scaled separately from backend

3. **Technology Independence**
   - Each container can use different technology
   - Easy to swap out components

4. **Development Flexibility**
   - Can develop/test each service independently
   - Hot reload for frontend and backend

5. **Production Ready**
   - Follows microservices best practices
   - Easy to deploy to cloud platforms

## Deployment

### Start All Containers
```bash
docker-compose up -d
```

### View Logs
```bash
docker-compose logs -f
```

### Stop All Containers
```bash
docker-compose down
```

### Rebuild Containers
```bash
docker-compose up -d --build
```

## Monitoring

Check container status:
```bash
docker-compose ps
```

Expected output:
```
NAME                   STATUS              PORTS
taskmanager-frontend   Up                  0.0.0.0:8080->80/tcp
taskmanager-backend    Up                  0.0.0.0:3000->3000/tcp
taskmanager-db         Up (healthy)        0.0.0.0:5432->5432/tcp
```
