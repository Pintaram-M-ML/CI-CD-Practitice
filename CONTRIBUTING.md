# Contributing to Task Manager

Thank you for your interest in contributing to the Task Manager project!

## Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/yourusername/task-manager.git
   cd task-manager
   ```

2. **Install dependencies**
   ```bash
   make install
   ```

3. **Start the development environment**
   ```bash
   make up
   ```

## Project Structure

Please familiarize yourself with the project structure:

- `backend/` - Node.js/Express API
- `frontend/` - HTML/CSS/JavaScript UI
- `database/` - PostgreSQL schema and migrations
- `docker/` - Docker configuration files

## Making Changes

1. **Create a new branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation as needed

3. **Test your changes**
   ```bash
   make test-api
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**

## Code Style

### Backend (JavaScript/Node.js)
- Use 2 spaces for indentation
- Use semicolons
- Use meaningful variable names
- Add JSDoc comments for functions

### Frontend (HTML/CSS/JavaScript)
- Use 4 spaces for indentation in HTML
- Use 2 spaces for indentation in CSS
- Follow BEM naming convention for CSS classes
- Keep JavaScript modular and well-commented

### Database
- Use snake_case for table and column names
- Add comments to complex queries
- Create indexes for frequently queried columns

## Adding New Features

### Backend API Endpoint
1. Create route handler in `backend/src/routes/`
2. Register route in `backend/src/server.js`
3. Update API documentation in README

### Frontend Feature
1. Add HTML structure in `frontend/src/index.html`
2. Add styles in `frontend/src/styles/`
3. Add JavaScript logic (inline or in separate file)

### Database Changes
1. Create migration script in `database/`
2. Update `init.sql` if needed
3. Document schema changes in `database/README.md`

## Testing

- Test all API endpoints manually
- Verify frontend functionality in multiple browsers
- Check responsive design on different screen sizes
- Ensure Docker containers build and run correctly

## Documentation

- Update README.md for user-facing changes
- Update component READMEs for technical changes
- Add inline code comments for complex logic
- Update API documentation for new endpoints

## Questions?

Feel free to open an issue for any questions or concerns!

