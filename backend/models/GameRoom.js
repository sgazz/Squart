// Game Room Model
const mongoose = require('mongoose');

const playerSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true
  },
  username: {
    type: String,
    required: true,
    trim: true,
    maxlength: 20
  },
  socketId: {
    type: String,
    required: true
  },
  color: {
    type: String,
    enum: ['blue', 'red'],
    required: true
  },
  isReady: {
    type: Boolean,
    default: false
  },
  isOnline: {
    type: Boolean,
    default: true
  },
  joinedAt: {
    type: Date,
    default: Date.now
  }
});

const moveSchema = new mongoose.Schema({
  player: {
    type: String,
    enum: ['blue', 'red'],
    required: true
  },
  position: {
    row: { type: Number, required: true },
    col: { type: Number, required: true }
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

const gameStateSchema = new mongoose.Schema({
  board: {
    type: [[String]], // 2D array representing game board
    required: true
  },
  currentPlayer: {
    type: String,
    enum: ['blue', 'red'],
    required: true
  },
  timer: {
    type: Number,
    default: 0
  },
  gameSettings: {
    boardSize: {
      type: Number,
      required: true,
      min: 5,
      max: 20
    },
    timeLimit: {
      type: Number,
      default: 0 // 0 = no time limit
    },
    hintsEnabled: {
      type: Boolean,
      default: true
    }
  },
  moves: [moveSchema],
  gameStarted: {
    type: Boolean,
    default: false
  },
  gameEnded: {
    type: Boolean,
    default: false
  },
  winner: {
    type: String,
    enum: ['blue', 'red', 'draw', null],
    default: null
  },
  endReason: {
    type: String,
    enum: ['normal', 'timeout', 'disconnect', 'forfeit', null],
    default: null
  }
});

const gameRoomSchema = new mongoose.Schema({
  roomId: {
    type: String,
    unique: true,
    required: true,
    index: true
  },
  roomName: {
    type: String,
    trim: true,
    maxlength: 50,
    default: 'Squart Game'
  },
  isPublic: {
    type: Boolean,
    default: true
  },
  password: {
    type: String,
    trim: true,
    maxlength: 20
  },
  players: [playerSchema],
  gameState: gameStateSchema,
  status: {
    type: String,
    enum: ['waiting', 'playing', 'finished', 'abandoned'],
    default: 'waiting'
  },
  maxPlayers: {
    type: Number,
    default: 2,
    min: 2,
    max: 2
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  },
  finishedAt: {
    type: Date
  }
});

// Indexes for better performance
gameRoomSchema.index({ roomId: 1 });
gameRoomSchema.index({ status: 1 });
gameRoomSchema.index({ isPublic: 1 });
gameRoomSchema.index({ createdAt: -1 });

// Pre-save middleware
gameRoomSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// Instance methods
gameRoomSchema.methods.addPlayer = function(playerData) {
  if (this.players.length >= this.maxPlayers) {
    throw new Error('Room is full');
  }
  
  if (this.players.some(p => p.userId === playerData.userId)) {
    throw new Error('Player already in room');
  }
  
  this.players.push(playerData);
  return this;
};

gameRoomSchema.methods.removePlayer = function(userId) {
  this.players = this.players.filter(p => p.userId !== userId);
  return this;
};

gameRoomSchema.methods.getPlayer = function(userId) {
  return this.players.find(p => p.userId === userId);
};

gameRoomSchema.methods.isPlayerReady = function(userId) {
  const player = this.getPlayer(userId);
  return player ? player.isReady : false;
};

gameRoomSchema.methods.setPlayerReady = function(userId, ready) {
  const player = this.getPlayer(userId);
  if (player) {
    player.isReady = ready;
  }
  return this;
};

gameRoomSchema.methods.canStartGame = function() {
  return this.players.length === this.maxPlayers && 
         this.players.every(p => p.isReady);
};

gameRoomSchema.methods.startGame = function() {
  if (!this.canStartGame()) {
    throw new Error('Cannot start game - not all players ready');
  }
  
  this.status = 'playing';
  this.gameState.gameStarted = true;
  this.gameState.currentPlayer = 'blue'; // Blue always starts
  
  // Initialize board
  this.gameState.board = this.initializeBoard();
  
  return this;
};

gameRoomSchema.methods.initializeBoard = function() {
  const size = this.gameState.gameSettings.boardSize;
  const board = Array(size).fill(null).map(() => Array(size).fill('empty'));
  
  // Add black cells (17-19% of total cells)
  const totalCells = size * size;
  const blackCellCount = Math.floor(totalCells * (0.17 + Math.random() * 0.02));
  
  for (let i = 0; i < blackCellCount; i++) {
    const row = Math.floor(Math.random() * size);
    const col = Math.floor(Math.random() * size);
    board[row][col] = 'black';
  }
  
  return board;
};

gameRoomSchema.methods.makeMove = function(player, row, col) {
  if (this.status !== 'playing') {
    throw new Error('Game is not in progress');
  }
  
  if (this.gameState.currentPlayer !== player) {
    throw new Error('Not your turn');
  }
  
  if (this.gameState.board[row][col] !== 'empty') {
    throw new Error('Invalid move - cell not empty');
  }
  
  // Place token
  this.gameState.board[row][col] = player;
  
  // Add move to history
  this.gameState.moves.push({
    player,
    position: { row, col },
    timestamp: new Date()
  });
  
  // Switch players
  this.gameState.currentPlayer = player === 'blue' ? 'red' : 'blue';
  
  // Check for game end
  if (this.checkGameEnd()) {
    this.endGame();
  }
  
  return this;
};

gameRoomSchema.methods.checkGameEnd = function() {
  // Check if current player has valid moves
  const currentPlayer = this.gameState.currentPlayer;
  const hasValidMoves = this.hasValidMoves(currentPlayer);
  
  if (!hasValidMoves) {
    // Current player cannot move, other player wins
    this.gameState.winner = currentPlayer === 'blue' ? 'red' : 'blue';
    this.gameState.endReason = 'normal';
    return true;
  }
  
  return false;
};

gameRoomSchema.methods.hasValidMoves = function(player) {
  const board = this.gameState.board;
  const size = board.length;
  
  for (let row = 0; row < size; row++) {
    for (let col = 0; col < size; col++) {
      if (board[row][col] === 'empty') {
        // Check if this position is valid for the player
        if (this.isValidMove(player, row, col)) {
          return true;
        }
      }
    }
  }
  
  return false;
};

gameRoomSchema.methods.isValidMove = function(player, row, col) {
  const board = this.gameState.board;
  const size = board.length;
  
  if (player === 'blue') {
    // Blue plays horizontal (row, col) and (row, col+1)
    return col + 1 < size && 
           board[row][col] === 'empty' && 
           board[row][col + 1] === 'empty';
  } else {
    // Red plays vertical (row, col) and (row+1, col)
    return row + 1 < size && 
           board[row][col] === 'empty' && 
           board[row + 1][col] === 'empty';
  }
};

gameRoomSchema.methods.endGame = function() {
  this.status = 'finished';
  this.gameState.gameEnded = true;
  this.finishedAt = new Date();
  return this;
};

// Static methods
gameRoomSchema.statics.findByRoomId = function(roomId) {
  return this.findOne({ roomId });
};

gameRoomSchema.statics.findPublicRooms = function() {
  return this.find({ 
    isPublic: true, 
    status: 'waiting' 
  }).sort({ createdAt: -1 });
};

gameRoomSchema.statics.findActiveRooms = function() {
  return this.find({ 
    status: { $in: ['waiting', 'playing'] } 
  });
};

module.exports = mongoose.model('GameRoom', gameRoomSchema);
