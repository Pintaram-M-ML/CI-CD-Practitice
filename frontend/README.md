# Frontend - Task Manager UI

This is the frontend user interface for the Task Manager application built with vanilla HTML, CSS, and JavaScript.

## Structure

```
frontend/
└── src/
    ├── index.html      # Main HTML file
    ├── styles/         # CSS stylesheets
    │   └── styles.css  # Main stylesheet
    └── scripts/        # JavaScript files (future expansion)
```

## Features

- Modern, responsive design
- Gradient backgrounds and smooth animations
- Real-time task statistics
- Interactive task management (add, complete, delete)
- Error handling with user feedback
- XSS protection with HTML escaping

## Styling

The application uses:
- CSS Grid and Flexbox for layout
- CSS animations for smooth transitions
- Gradient backgrounds for visual appeal
- Responsive design for mobile compatibility

## API Integration

The frontend communicates with the backend API using the Fetch API:
- `GET /api/tasks` - Fetch all tasks
- `POST /api/tasks` - Create a new task
- `PUT /api/tasks/:id` - Update task status
- `DELETE /api/tasks/:id` - Delete a task

## Development

The frontend is served as static files by the Express backend. Any changes to HTML, CSS, or JavaScript will be reflected immediately upon page refresh.

## Future Enhancements

- Separate JavaScript into modules
- Add task categories/tags
- Implement task search and filtering
- Add task due dates
- Implement user authentication

