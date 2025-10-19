// Socket.io Service for Real-time Communication
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const GameRoom = require('../models/GameRoom');
const { getRedisClient } = require('../config/redis');

// Socket events
const SocketEvents = {
  // Connection
  CONNECTION: 'connection',
  DISCONNECT: 'disconnect',
  
  // Room Management
  JOIN_ROOM: 'join-room',
  LEAVE_ROOM: 'leave-room',
  CREATE_ROOM: 'create-room',
  ROOM_CREATED: 'room-created',
  ROOM_UPDATED: 'room-updated',
  ROOM_JOINED: 'room-joined',
  ROOM_LEFT: 'room-left',
  
  // Game Events
  PLAYER_READY: 'player-ready',
  GAME_START: 'game-start',
  GAME_STARTED: 'game-started',
  MAKE_MOVE: 'make-move',
  MOVE_MADE: 'move-made',
  GAME_END: 'game-end',
  GAME_ENDED: 'game-ended',
  
  // Player Events
  PLAYER_DISCONNECTED: 'player-disconnected',
  PLAYER_RECONNECTED: 'player-reconnected',
  
  // Chat Events
  SEND_MESSAGE: 'send-message',
  MESSAGE_RECEIVED: 'message-received',
  
  // Error Events
  ERROR: 'error',
  INVALID_MOVE: 'invalid-move',
  GAME_ERROR: 'game-error'
};

// Socket middleware for authentication
const authenticateSocket = (socket, next) => {
  try {
    const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return next(new Error('Authentication token required'));
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.userId = decoded.userId;
    socket.username = decoded.username;
    next();
  } catch (error) {
    next(new Error('Invalid authentication token'));
  }
};

// Setup socket handlers
const setupSocketHandlers = (io) => {
  // Apply authentication middleware
  io.use(authenticateSocket);
  
  io.on(SocketEvents.CONNECTION, (socket) => {
    console.log(`🔌 User connected: ${socket.username} (${socket.id})`);
    
    // Store user session in Redis
    storeUserSession(socket);
    
    // Room management events
    socket.on(SocketEvents.CREATE_ROOM, handleCreateRoom(socket));
    socket.on(SocketEvents.JOIN_ROOM, handleJoinRoom(socket));
    socket.on(SocketEvents.LEAVE_ROOM, handleLeaveRoom(socket));
    
    // Game events
    socket.on(SocketEvents.PLAYER_READY, handlePlayerReady(socket));
    socket.on(SocketEvents.MAKE_MOVE, handleMakeMove(socket));
    
    // Chat events
    socket.on(SocketEvents.SEND_MESSAGE, handleSendMessage(socket));
    
    // Disconnect handling
    socket.on(SocketEvents.DISCONNECT, handleDisconnect(socket));
  });
};

// Store user session in Redis
const storeUserSession = async (socket) => {
  try {
    const redisClient = getRedisClient();
    if (redisClient) {
      const sessionData = {
        userId: socket.userId,
        username: socket.username,
        socketId: socket.id,
        connectedAt: new Date().toISOString()
      };
      
      await redisClient.setEx(
        `user:${socket.userId}`,
        3600, // 1 hour expiry
        JSON.stringify(sessionData)
      );
    }
  } catch (error) {
    console.error('Failed to store user session:', error);
  }
};

// Create room handler
const handleCreateRoom = (socket) => async (data) => {
  try {
    const { roomName, isPublic, password, gameSettings } = data;
    
    const roomId = uuidv4().substring(0, 8);
    
    const room = new GameRoom({
      roomId,
      roomName: roomName || 'Squart Game',
      isPublic: isPublic !== false,
      password,
      players: [{
        userId: socket.userId,
        username: socket.username,
        socketId: socket.id,
        color: 'blue', // Creator is always blue
        isReady: false,
        isOnline: true
      }],
      gameState: {
        gameSettings: {
          boardSize: gameSettings?.boardSize || 7,
          timeLimit: gameSettings?.timeLimit || 0,
          hintsEnabled: gameSettings?.hintsEnabled !== false
        }
      }
    });
    
    await room.save();
    
    // Join socket room
    socket.join(roomId);
    
    // Emit room created event
    socket.emit(SocketEvents.ROOM_CREATED, {
      roomId,
      room: room.toObject()
    });
    
    console.log(`🏠 Room created: ${roomId} by ${socket.username}`);
    
  } catch (error) {
    console.error('Create room error:', error);
    socket.emit(SocketEvents.ERROR, {
      message: 'Failed to create room',
      error: error.message
    });
  }
};

// Join room handler
const handleJoinRoom = (socket) => async (data) => {
  try {
    const { roomId, password } = data;
    
    const room = await GameRoom.findByRoomId(roomId);
    if (!room) {
      return socket.emit(SocketEvents.ERROR, {
        message: 'Room not found'
      });
    }
    
    if (room.status !== 'waiting') {
      return socket.emit(SocketEvents.ERROR, {
        message: 'Room is not available'
      });
    }
    
    if (room.players.length >= room.maxPlayers) {
      return socket.emit(SocketEvents.ERROR, {
        message: 'Room is full'
      });
    }
    
    if (room.password && room.password !== password) {
      return socket.emit(SocketEvents.ERROR, {
        message: 'Invalid password'
      });
    }
    
    // Add player to room
    room.addPlayer({
      userId: socket.userId,
      username: socket.username,
      socketId: socket.id,
      color: 'red', // Second player is always red
      isReady: false,
      isOnline: true
    });
    
    await room.save();
    
    // Join socket room
    socket.join(roomId);
    
    // Emit to all players in room
    socket.to(roomId).emit(SocketEvents.ROOM_UPDATED, {
      room: room.toObject()
    });
    
    socket.emit(SocketEvents.ROOM_JOINED, {
      room: room.toObject()
    });
    
    console.log(`🚪 User ${socket.username} joined room ${roomId}`);
    
  } catch (error) {
    console.error('Join room error:', error);
    socket.emit(SocketEvents.ERROR, {
      message: 'Failed to join room',
      error: error.message
    });
  }
};

// Leave room handler
const handleLeaveRoom = (socket) => async (data) => {
  try {
    const { roomId } = data;
    
    const room = await GameRoom.findByRoomId(roomId);
    if (!room) return;
    
    // Remove player from room
    room.removePlayer(socket.userId);
    
    if (room.players.length === 0) {
      // Delete empty room
      await GameRoom.findByIdAndDelete(room._id);
    } else {
      await room.save();
      
      // Emit to remaining players
      socket.to(roomId).emit(SocketEvents.ROOM_UPDATED, {
        room: room.toObject()
      });
    }
    
    // Leave socket room
    socket.leave(roomId);
    
    socket.emit(SocketEvents.ROOM_LEFT, {
      roomId
    });
    
    console.log(`🚪 User ${socket.username} left room ${roomId}`);
    
  } catch (error) {
    console.error('Leave room error:', error);
    socket.emit(SocketEvents.ERROR, {
      message: 'Failed to leave room',
      error: error.message
    });
  }
};

// Player ready handler
const handlePlayerReady = (socket) => async (data) => {
  try {
    const { roomId, ready } = data;
    
    const room = await GameRoom.findByRoomId(roomId);
    if (!room) return;
    
    const player = room.getPlayer(socket.userId);
    if (!player) return;
    
    // Set player ready status
    room.setPlayerReady(socket.userId, ready);
    await room.save();
    
    // Emit to all players in room
    socket.to(roomId).emit(SocketEvents.ROOM_UPDATED, {
      room: room.toObject()
    });
    
    socket.emit(SocketEvents.ROOM_UPDATED, {
      room: room.toObject()
    });
    
    // Check if game can start
    if (room.canStartGame()) {
      // Start game
      room.startGame();
      await room.save();
      
      // Emit game started event
      io.to(roomId).emit(SocketEvents.GAME_STARTED, {
        room: room.toObject()
      });
      
      console.log(`🎮 Game started in room ${roomId}`);
    }
    
  } catch (error) {
    console.error('Player ready error:', error);
    socket.emit(SocketEvents.ERROR, {
      message: 'Failed to set ready status',
      error: error.message
    });
  }
};

// Make move handler
const handleMakeMove = (socket) => async (data) => {
  try {
    const { roomId, row, col } = data;
    
    const room = await GameRoom.findByRoomId(roomId);
    if (!room) return;
    
    const player = room.getPlayer(socket.userId);
    if (!player) return;
    
    // Make move
    room.makeMove(player.color, row, col);
    await room.save();
    
    // Emit move to all players
    io.to(roomId).emit(SocketEvents.MOVE_MADE, {
      room: room.toObject(),
      move: {
        player: player.color,
        position: { row, col },
        timestamp: new Date()
      }
    });
    
    // Check if game ended
    if (room.gameState.gameEnded) {
      io.to(roomId).emit(SocketEvents.GAME_ENDED, {
        room: room.toObject(),
        winner: room.gameState.winner,
        endReason: room.gameState.endReason
      });
      
      console.log(`🏆 Game ended in room ${roomId}, winner: ${room.gameState.winner}`);
    }
    
  } catch (error) {
    console.error('Make move error:', error);
    socket.emit(SocketEvents.INVALID_MOVE, {
      message: error.message
    });
  }
};

// Send message handler
const handleSendMessage = (socket) => async (data) => {
  try {
    const { roomId, message } = data;
    
    if (!message || message.trim().length === 0) return;
    
    const room = await GameRoom.findByRoomId(roomId);
    if (!room) return;
    
    const player = room.getPlayer(socket.userId);
    if (!player) return;
    
    const messageData = {
      id: uuidv4(),
      player: player.username,
      message: message.trim(),
      timestamp: new Date()
    };
    
    // Emit message to all players in room
    io.to(roomId).emit(SocketEvents.MESSAGE_RECEIVED, messageData);
    
  } catch (error) {
    console.error('Send message error:', error);
    socket.emit(SocketEvents.ERROR, {
      message: 'Failed to send message',
      error: error.message
    });
  }
};

// Disconnect handler
const handleDisconnect = (socket) => async () => {
  try {
    console.log(`🔌 User disconnected: ${socket.username} (${socket.id})`);
    
    // Find rooms where user is playing
    const rooms = await GameRoom.find({
      'players.userId': socket.userId,
      status: { $in: ['waiting', 'playing'] }
    });
    
    for (const room of rooms) {
      const player = room.getPlayer(socket.userId);
      if (player) {
        player.isOnline = false;
        
        if (room.status === 'playing') {
          // End game if player disconnects during play
          room.status = 'abandoned';
          room.gameState.gameEnded = true;
          room.gameState.winner = player.color === 'blue' ? 'red' : 'blue';
          room.gameState.endReason = 'disconnect';
        }
        
        await room.save();
        
        // Emit to other players
        socket.to(room.roomId).emit(SocketEvents.PLAYER_DISCONNECTED, {
          player: player.username,
          room: room.toObject()
        });
      }
    }
    
    // Remove user session from Redis
    const redisClient = getRedisClient();
    if (redisClient) {
      await redisClient.del(`user:${socket.userId}`);
    }
    
  } catch (error) {
    console.error('Disconnect handling error:', error);
  }
};

module.exports = {
  setupSocketHandlers,
  SocketEvents
};
