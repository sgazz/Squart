// Simple Backend Server for Testing (without database)
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const server = http.createServer(app);

// CORS configuration
const corsOptions = {
  origin: 'http://localhost:8080',
  methods: ['GET', 'POST'],
  credentials: true
};

// Socket.io configuration
const io = socketIo(server, {
  cors: corsOptions,
  transports: ['websocket', 'polling']
});

// Middleware
app.use(helmet());
app.use(cors(corsOptions));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: '1.0.0'
  });
});

// Simple auth endpoint
app.post('/api/auth/guest', (req, res) => {
  const { username } = req.body;
  
  if (!username || username.trim().length === 0) {
    return res.status(400).json({
      success: false,
      message: 'Username is required'
    });
  }
  
  res.json({
    success: true,
    user: {
      userId: 'guest_' + Date.now(),
      username: username.trim()
    },
    token: 'mock_token_' + Date.now()
  });
});

// Simple rooms endpoint
app.get('/api/rooms/public', (req, res) => {
  res.json({
    success: true,
    rooms: [
      {
        roomId: 'demo_room_1',
        roomName: 'Demo Room 1',
        players: 1,
        maxPlayers: 2,
        gameSettings: {
          boardSize: 7,
          timeLimit: 0,
          hintsEnabled: true
        },
        createdAt: new Date().toISOString()
      }
    ]
  });
});

// Socket.io connection handling
io.on('connection', (socket) => {
  console.log('🔌 User connected:', socket.id);
  
  socket.on('disconnect', () => {
    console.log('🔌 User disconnected:', socket.id);
  });
  
  // Echo back any message for testing
  socket.onAny((eventName, ...args) => {
    console.log(`📡 Received event: ${eventName}`, args);
    socket.emit(eventName + '_response', { 
      message: 'Echo: ' + eventName,
      timestamp: new Date().toISOString()
    });
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Start server
const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`🚀 Simple Backend Server running on port ${PORT}`);
  console.log(`🌐 Health check: http://localhost:${PORT}/health`);
  console.log(`📡 Socket.io ready for connections`);
});

module.exports = { app, server, io };
