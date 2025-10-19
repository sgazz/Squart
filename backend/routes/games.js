// Game Management Routes
const express = require('express');
const GameRoom = require('../models/GameRoom');

const router = express.Router();

// Get game by room ID
router.get('/:roomId', async (req, res) => {
  try {
    const { roomId } = req.params;
    const room = await GameRoom.findByRoomId(roomId);
    
    if (!room) {
      return res.status(404).json({
        success: false,
        message: 'Game not found'
      });
    }
    
    res.json({
      success: true,
      game: {
        roomId: room.roomId,
        status: room.status,
        gameState: room.gameState,
        players: room.players.map(p => ({
          userId: p.userId,
          username: p.username,
          color: p.color,
          isReady: p.isReady,
          isOnline: p.isOnline
        }))
      }
    });
  } catch (error) {
    console.error('Get game error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get game',
      error: error.message
    });
  }
});

// Make move
router.post('/:roomId/move', async (req, res) => {
  try {
    const { roomId } = req.params;
    const { row, col } = req.body;
    
    const room = await GameRoom.findByRoomId(roomId);
    if (!room) {
      return res.status(404).json({
        success: false,
        message: 'Game not found'
      });
    }
    
    if (room.status !== 'playing') {
      return res.status(400).json({
        success: false,
        message: 'Game is not in progress'
      });
    }
    
    const player = room.getPlayer(req.user.userId);
    if (!player) {
      return res.status(400).json({
        success: false,
        message: 'Player not in game'
      });
    }
    
    // Make move
    room.makeMove(player.color, row, col);
    await room.save();
    
    res.json({
      success: true,
      game: {
        roomId: room.roomId,
        status: room.status,
        gameState: room.gameState,
        players: room.players.map(p => ({
          userId: p.userId,
          username: p.username,
          color: p.color,
          isReady: p.isReady,
          isOnline: p.isOnline
        }))
      }
    });
  } catch (error) {
    console.error('Make move error:', error);
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
});

// Get game history
router.get('/:roomId/history', async (req, res) => {
  try {
    const { roomId } = req.params;
    const room = await GameRoom.findByRoomId(roomId);
    
    if (!room) {
      return res.status(404).json({
        success: false,
        message: 'Game not found'
      });
    }
    
    res.json({
      success: true,
      history: {
        moves: room.gameState.moves,
        gameSettings: room.gameState.gameSettings,
        startedAt: room.createdAt,
        endedAt: room.finishedAt,
        winner: room.gameState.winner,
        endReason: room.gameState.endReason
      }
    });
  } catch (error) {
    console.error('Get game history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get game history',
      error: error.message
    });
  }
});

// Get valid moves for current player
router.get('/:roomId/valid-moves', async (req, res) => {
  try {
    const { roomId } = req.params;
    const room = await GameRoom.findByRoomId(roomId);
    
    if (!room) {
      return res.status(404).json({
        success: false,
        message: 'Game not found'
      });
    }
    
    if (room.status !== 'playing') {
      return res.status(400).json({
        success: false,
        message: 'Game is not in progress'
      });
    }
    
    const player = room.getPlayer(req.user.userId);
    if (!player) {
      return res.status(400).json({
        success: false,
        message: 'Player not in game'
      });
    }
    
    const validMoves = [];
    const board = room.gameState.board;
    const size = board.length;
    
    for (let row = 0; row < size; row++) {
      for (let col = 0; col < size; col++) {
        if (board[row][col] === 'empty') {
          if (room.isValidMove(player.color, row, col)) {
            validMoves.push({ row, col });
          }
        }
      }
    }
    
    res.json({
      success: true,
      validMoves,
      currentPlayer: room.gameState.currentPlayer
    });
  } catch (error) {
    console.error('Get valid moves error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get valid moves',
      error: error.message
    });
  }
});

module.exports = router;
