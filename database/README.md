# Database - Task Manager Schema

PostgreSQL database schema and initialization scripts for the Task Manager application.

## Schema

### Tasks Table

```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    text VARCHAR(500) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Indexes

- `idx_tasks_created_at` - Index on `created_at` for faster sorting

## Initialization

The `init.sql` script is automatically executed when the PostgreSQL container starts for the first time. It:

1. Creates the tasks table
2. Creates necessary indexes
3. Inserts sample data

## Sample Data

The initialization script includes 3 sample tasks to help users get started.

## Migrations

For future schema changes, consider using a migration tool like:
- [node-pg-migrate](https://github.com/salsita/node-pg-migrate)
- [Knex.js](http://knexjs.org/)
- [Sequelize](https://sequelize.org/)

## Backup and Restore

### Backup
```bash
docker exec taskmanager-db pg_dump -U postgres taskmanager > backup.sql
```

### Restore
```bash
docker exec -i taskmanager-db psql -U postgres taskmanager < backup.sql
```

## Accessing the Database

### Via Docker
```bash
docker exec -it taskmanager-db psql -U postgres -d taskmanager
```

### Via Local Client
```bash
psql -h localhost -p 5432 -U postgres -d taskmanager
```

## Performance Considerations

- The `created_at` column is indexed for faster sorting
- Consider adding indexes on frequently queried columns
- For large datasets, implement pagination in the API

