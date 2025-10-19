// Room Management Routes
const express = require('express');
const { v4: uuidv4 } = require('uuid');
const GameRoom = require('../models/GameRoom');
const { getRedisClient } = require('../config/redis');

const router = express.Router();

// Get public rooms
router.get('/public', async (req, res) => {
  try {
    const rooms = await GameRoom.findPublicRooms();
    res.json({
      success: true,
      rooms: rooms.map(room => ({
        roomId: room.roomId,
        roomName: room.roomName,
        players: room.players.length,
        maxPlayers: room.maxPlayers,
        gameSettings: room.gameState.gameSettings,
        createdAt: room.createdAt
      }))
    });
  } catch (error) {
    console.error('Get public rooms error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get public rooms',
      error: error.message
    });
  }
});

// Get room by ID
router.get('/:roomId', async (req, res) => {
  try {
    const { roomId } = req.params;
    const room = await GameRoom.findByRoomId(roomId);
    
    if (!room) {
      return res.status(404).json({
        success: false,
        message: 'Room not found'
      });
    }
    
    res.json({
      success: true,
      room: room.toObject()
    });
  } catch (error) {
    console.error('Get room error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get room',
      error: error.message
    });
  }
});

// Create room
router.post('/create', async (req, res) => {
  try {
    const { roomName, isPublic, password, gameSettings } = req.body;
    
    const roomId = uuidv4().substring(0, 8);
    
    const room = new GameRoom({
      roomId,
      roomName: roomName || 'Squart Game',
      isPublic: isPublic !== false,
      password,
      players: [{
        userId: req.user.userId,
        username: req.user.username,
        socketId: req.user.socketId || 'api',
        color: 'blue',
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
    
    res.json({
      success: true,
      room: room.toObject()
    });
  } catch (error) {
    console.error('Create room error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create room',
      error: error.message
    });
  }
});

// Join room
router.post('/:roomId/join', async (req, res) => {
  try {
    const { roomId } = req.params;
    const { password } = req.body;
    
    const room = await GameRoom.findByRoomId(roomId);
    if (!room) {
      return res.status(404).json({
        success: false,
        message: 'Room not found'
      });
    }
    
    if (room.status !== 'waiting') {
      return res.status(400).json({
        success: false,
        message: 'Room is not available'
      });
    }
    
    if (room.players.length >= room.maxPlayers) {
      return res.status(400).json({
        success: false,
        message: 'Room is full'
      });
    }
    
    if (room.password && room.password !== password) {
      return res.status(400).json({
        success: false,
        message: 'Invalid password'
      });
    }
    
    // Check if user is already in room
    if (room.players.some(p => p.userId === req.user.userId)) {
      return res.status(400).json({
        success: false,
        message: 'Already in room'
      });
    }
    
    // Add player to room
    room.addPlayer({
      userId: req.user.userId,
      username: req.user.username,
      socketId: req.user.socketId || 'api',
      color: 'red',
      isReady: false,
      isOnline: true
    });
    
    await room.save();
    
    res.json({
      success: true,
      room: room.toObject()
    });
  } catch (error) {
    console.error('Join room error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to join room',
      error: error.message
    });
  }
});

// Leave room
router.post('/:roomId/leave', async (req, res) => {
  try {
    const { roomId } = req.params;
    
    const room = await GameRoom.findByRoomId(roomId);
    if (!room) {
      return res.status(404).json({
        success: false,
        message: 'Room not found'
      });
    }
    
    // Remove player from room
    room.removePlayer(req.user.userId);
    
    if (room.players.length === 0) {
      // Delete empty room
      await GameRoom.findByIdAndDelete(room._id);
    } else {
      await room.save();
    }
    
    res.json({
      success: true,
      message: 'Left room successfully'
    });
  } catch (error) {
    console.error('Leave room error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to leave room',
      error: error.message
    });
  }
});

// Set player ready status
router.post('/:roomId/ready', async (req, res) => {
  try {
    const { roomId } = req.params;
    const { ready } = req.body;
    
    const room = await GameRoom.findByRoomId(roomId);
    if (!room) {
      return res.status(404).json({
        success: false,
        message: 'Room not found'
      });
    }
    
    const player = room.getPlayer(req.user.userId);
    if (!player) {
      return res.status(400).json({
        success: false,
        message: 'Player not in room'
      });
    }
    
    // Set player ready status
    room.setPlayerReady(req.user.userId, ready);
    await room.save();
    
    res.json({
      success: true,
      room: room.toObject()
    });
  } catch (error) {
    console.error('Set ready error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to set ready status',
      error: error.message
    });
  }
});

// Get active rooms count
router.get('/stats/active', async (req, res) => {
  try {
    const activeRooms = await GameRoom.findActiveRooms();
    const waitingRooms = activeRooms.filter(room => room.status === 'waiting');
    const playingRooms = activeRooms.filter(room => room.status === 'playing');
    
    res.json({
      success: true,
      stats: {
        totalActive: activeRooms.length,
        waiting: waitingRooms.length,
        playing: playingRooms.length,
        totalPlayers: activeRooms.reduce((sum, room) => sum + room.players.length, 0)
      }
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get stats',
      error: error.message
    });
  }
});

module.exports = router;
