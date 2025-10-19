# 🎮 Multiplayer Architecture - Squart Web Edition

Detaljna arhitektura za web multiplayer funkcionalnost.

**Datum:** Oktobar 2025  
**Status:** 🚧 Planning Phase

---

## 🏗️ System Architecture

### High-Level Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter Web   │    │   Node.js API    │    │   Database      │
│   (Frontend)    │◄──►│   (Backend)      │◄──►│   (MongoDB)     │
│                 │    │                  │    │                 │
│ • Game UI       │    │ • WebSocket      │    │ • Game Rooms   │
│ • Real-time     │    │ • REST API       │    │ • User Data     │
│ • State Mgmt    │    │ • Authentication │    │ • Game History │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PWA Cache     │    │   Redis Cache    │    │   File Storage  │
│   (Offline)     │    │   (Sessions)     │    │   (Assets)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🔧 Backend Architecture

### 1. Node.js + Express Server

```javascript
// server.js
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.FRONTEND_URL,
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/rooms', require('./routes/rooms'));
app.use('/api/games', require('./routes/games'));

// Socket.io connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);
  
  // Game room events
  socket.on('join-room', handleJoinRoom);
  socket.on('leave-room', handleLeaveRoom);
  socket.on('make-move', handleMakeMove);
  socket.on('disconnect', handleDisconnect);
});
```

### 2. WebSocket Event System

```javascript
// Socket Events
const SocketEvents = {
  // Room Management
  JOIN_ROOM: 'join-room',
  LEAVE_ROOM: 'leave-room',
  ROOM_UPDATED: 'room-updated',
  
  // Game Events
  MAKE_MOVE: 'make-move',
  GAME_STATE_UPDATE: 'game-state-update',
  GAME_END: 'game-end',
  
  // Player Events
  PLAYER_READY: 'player-ready',
  PLAYER_DISCONNECTED: 'player-disconnected',
  
  // Chat Events
  SEND_MESSAGE: 'send-message',
  MESSAGE_RECEIVED: 'message-received'
};
```

### 3. Database Schema

```javascript
// Game Room Schema
const GameRoomSchema = {
  roomId: {
    type: String,
    unique: true,
    required: true
  },
  players: [{
    userId: String,
    username: String,
    socketId: String,
    color: String, // 'blue' or 'red'
    isReady: Boolean,
    isOnline: Boolean,
    joinedAt: Date
  }],
  gameState: {
    board: Array, // 2D array representing game board
    currentPlayer: String, // 'blue' or 'red'
    timer: Number, // seconds remaining
    gameSettings: {
      boardSize: Number,
      timeLimit: Number,
      hintsEnabled: Boolean
    },
    moves: [{
      player: String,
      position: {row: Number, col: Number},
      timestamp: Date
    }]
  },
  status: {
    type: String,
    enum: ['waiting', 'playing', 'finished', 'abandoned'],
    default: 'waiting'
  },
  createdAt: Date,
  updatedAt: Date,
  finishedAt: Date
};

// User Schema
const UserSchema = {
  userId: String,
  username: String,
  email: String,
  stats: {
    gamesPlayed: Number,
    gamesWon: Number,
    winRate: Number,
    averageGameTime: Number,
    favoriteBoardSize: Number
  },
  preferences: {
    theme: String,
    soundEnabled: Boolean,
    notificationsEnabled: Boolean
  },
  createdAt: Date,
  lastActiveAt: Date
};
```

---

## 🎮 Frontend Architecture

### 1. Multiplayer State Management

```dart
// lib/providers/multiplayer_provider.dart
class MultiplayerProvider extends ChangeNotifier {
  Socket? _socket;
  String? _currentRoomId;
  List<Player> _players = [];
  GameRoom? _currentRoom;
  bool _isConnected = false;
  
  // Connection Management
  Future<void> connect() async {
    _socket = io('ws://localhost:3000');
    _setupSocketListeners();
  }
  
  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket = null;
  }
  
  // Room Management
  Future<void> createRoom(GameSettings settings) async {
    _socket?.emit('create-room', {
      'settings': settings.toJson(),
      'userId': _currentUserId
    });
  }
  
  Future<void> joinRoom(String roomId) async {
    _socket?.emit('join-room', {
      'roomId': roomId,
      'userId': _currentUserId
    });
  }
  
  // Game Actions
  void makeMove(int row, int col) {
    if (_currentRoom?.gameState.currentPlayer == _myColor) {
      _socket?.emit('make-move', {
        'roomId': _currentRoomId,
        'position': {'row': row, 'col': col},
        'player': _myColor
      });
    }
  }
}
```

### 2. Real-time Game Sync

```dart
// lib/services/game_sync_service.dart
class GameSyncService {
  final MultiplayerProvider _multiplayerProvider;
  
  GameSyncService(this._multiplayerProvider) {
    _setupSocketListeners();
  }
  
  void _setupSocketListeners() {
    _multiplayerProvider.socket?.on('game-state-update', (data) {
      _handleGameStateUpdate(data);
    });
    
    _multiplayerProvider.socket?.on('player-move', (data) {
      _handlePlayerMove(data);
    });
    
    _multiplayerProvider.socket?.on('game-end', (data) {
      _handleGameEnd(data);
    });
  }
  
  void _handleGameStateUpdate(Map<String, dynamic data) {
    final gameState = GameState.fromJson(data['gameState']);
    final currentPlayer = data['currentPlayer'];
    final timer = data['timer'];
    
    // Update local game state
    _multiplayerProvider.updateGameState(gameState);
    _multiplayerProvider.updateCurrentPlayer(currentPlayer);
    _multiplayerProvider.updateTimer(timer);
  }
}
```

### 3. Room Management UI

```dart
// lib/screens/multiplayer_lobby_screen.dart
class MultiplayerLobbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MultiplayerProvider>(
      builder: (context, multiplayer, child) {
        return Scaffold(
          body: Column(
            children: [
              // Connection Status
              ConnectionStatusWidget(),
              
              // Room List
              Expanded(
                child: ListView.builder(
                  itemCount: multiplayer.availableRooms.length,
                  itemBuilder: (context, index) {
                    final room = multiplayer.availableRooms[index];
                    return RoomCard(
                      room: room,
                      onJoin: () => multiplayer.joinRoom(room.roomId),
                    );
                  },
                ),
              ),
              
              // Action Buttons
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _showCreateRoomDialog(context),
                    child: Text('Create Room'),
                  ),
                  ElevatedButton(
                    onPressed: () => multiplayer.findQuickMatch(),
                    child: Text('Quick Match'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 🔄 Real-time Communication Flow

### 1. Game Start Flow

```
1. Player A creates room
   ├── Frontend: CreateRoomRequest
   ├── Backend: Create room in DB
   ├── Backend: Emit 'room-created'
   └── Frontend: Navigate to room screen

2. Player B joins room
   ├── Frontend: JoinRoomRequest(roomId)
   ├── Backend: Add player to room
   ├── Backend: Emit 'room-updated' to all players
   └── Frontend: Update room UI

3. Both players ready
   ├── Frontend: PlayerReadyRequest
   ├── Backend: Check if all players ready
   ├── Backend: Start game, emit 'game-started'
   └── Frontend: Navigate to game screen
```

### 2. Move Synchronization

```
1. Player makes move
   ├── Frontend: MakeMoveRequest(position)
   ├── Backend: Validate move
   ├── Backend: Update game state
   ├── Backend: Emit 'game-state-update' to all players
   └── Frontend: Update board UI

2. Move validation
   ├── Backend: Check if move is valid
   ├── Backend: Check if it's player's turn
   ├── Backend: Update board state
   └── Backend: Switch current player
```

### 3. Disconnection Handling

```
1. Player disconnects
   ├── Backend: Detect disconnection
   ├── Backend: Mark player as offline
   ├── Backend: Emit 'player-disconnected'
   └── Frontend: Show reconnection UI

2. Reconnection
   ├── Frontend: Attempt reconnection
   ├── Backend: Validate session
   ├── Backend: Restore game state
   └── Frontend: Resume game
```

---

## 🛡️ Security & Authentication

### 1. JWT Authentication

```javascript
// auth middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.sendStatus(401);
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};
```

### 2. Rate Limiting

```javascript
// Rate limiting for API endpoints
const rateLimit = require('express-rate-limit');

const gameLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many game requests from this IP'
});

app.use('/api/games', gameLimiter);
```

### 3. Input Validation

```javascript
// Move validation
const validateMove = (move, gameState) => {
  // Check if it's player's turn
  if (move.player !== gameState.currentPlayer) {
    return { valid: false, error: 'Not your turn' };
  }
  
  // Check if position is valid
  if (!isValidPosition(move.position, gameState.board)) {
    return { valid: false, error: 'Invalid position' };
  }
  
  // Check if move is legal
  if (!isLegalMove(move, gameState.board)) {
    return { valid: false, error: 'Illegal move' };
  }
  
  return { valid: true };
};
```

---

## 📊 Performance Optimization

### 1. Connection Pooling

```javascript
// Redis connection pool
const redis = require('redis');
const client = redis.createClient({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT,
  password: process.env.REDIS_PASSWORD,
  retry_strategy: (options) => {
    if (options.error && options.error.code === 'ECONNREFUSED') {
      return new Error('Redis server refused connection');
    }
    if (options.total_retry_time > 1000 * 60 * 60) {
      return new Error('Retry time exhausted');
    }
    if (options.attempt > 10) {
      return undefined;
    }
    return Math.min(options.attempt * 100, 3000);
  }
});
```

### 2. Message Batching

```javascript
// Batch multiple moves for efficiency
const batchMoves = (moves) => {
  return moves.reduce((batched, move) => {
    const key = `${move.roomId}-${move.player}`;
    if (!batched[key]) {
      batched[key] = [];
    }
    batched[key].push(move);
    return batched;
  }, {});
};
```

### 3. Frontend Optimization

```dart
// Debounced move updates
class DebouncedMoveHandler {
  Timer? _debounceTimer;
  
  void handleMove(Move move) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      _processMove(move);
    });
  }
}
```

---

## 🧪 Testing Strategy

### 1. Unit Tests

```dart
// test/multiplayer_provider_test.dart
void main() {
  group('MultiplayerProvider', () {
    test('should connect to server', () async {
      final provider = MultiplayerProvider();
      await provider.connect();
      expect(provider.isConnected, true);
    });
    
    test('should create room', () async {
      final provider = MultiplayerProvider();
      await provider.connect();
      await provider.createRoom(GameSettings());
      expect(provider.currentRoom, isNotNull);
    });
  });
}
```

### 2. Integration Tests

```javascript
// test/integration/game-flow.test.js
describe('Game Flow Integration', () => {
  test('should complete full multiplayer game', async () => {
    // Create two socket connections
    const player1 = io('http://localhost:3000');
    const player2 = io('http://localhost:3000');
    
    // Player 1 creates room
    player1.emit('create-room', { settings: defaultSettings });
    
    // Player 2 joins room
    player2.emit('join-room', { roomId: 'test-room' });
    
    // Both players ready
    player1.emit('player-ready');
    player2.emit('player-ready');
    
    // Play game
    player1.emit('make-move', { position: { row: 0, col: 0 } });
    player2.emit('make-move', { position: { row: 1, col: 1 } });
    
    // Verify game end
    // ... assertions
  });
});
```

### 3. Load Testing

```javascript
// test/load/concurrent-games.test.js
const loadTest = require('loadtest');

describe('Concurrent Games Load Test', () => {
  test('should handle 100 concurrent games', (done) => {
    const options = {
      url: 'http://localhost:3000',
      maxRequests: 100,
      concurrency: 10,
      requestsPerSecond: 50
    };
    
    loadTest.loadTest(options, (error, result) => {
      expect(result.totalRequests).toBe(100);
      expect(result.meanLatency).toBeLessThan(1000);
      done();
    });
  });
});
```

---

## 🚀 Deployment Architecture

### 1. Production Environment

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Firebase      │    │   Heroku        │    │   MongoDB       │
│   Hosting       │◄──►│   Backend       │◄──►│   Atlas         │
│   (Frontend)    │    │   (API)         │    │   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CDN           │    │   Redis Cloud   │    │   File Storage  │
│   (Assets)      │    │   (Sessions)     │    │   (Images)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 2. Environment Variables

```bash
# Backend (.env)
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb+srv://...
REDIS_URL=redis://...
JWT_SECRET=your-secret-key
FRONTEND_URL=https://squart.game

# Frontend (Firebase)
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=squart.game
FIREBASE_PROJECT_ID=squart-game
```

### 3. CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm install
        
      - name: Run tests
        run: npm test
        
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3
        with:
          heroku_api_key: ${{secrets.HEROKU_API_KEY}}
          heroku_app_name: "squart-backend"
          
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
          projectId: squart-game
```

---

## 📈 Monitoring & Analytics

### 1. Real-time Monitoring

```javascript
// Monitoring middleware
const monitorSocketConnections = (io) => {
  io.on('connection', (socket) => {
    console.log(`User connected: ${socket.id}`);
    
    socket.on('disconnect', () => {
      console.log(`User disconnected: ${socket.id}`);
    });
  });
};
```

### 2. Performance Metrics

```javascript
// Performance tracking
const trackGamePerformance = (gameId, startTime, endTime) => {
  const duration = endTime - startTime;
  console.log(`Game ${gameId} completed in ${duration}ms`);
  
  // Send to analytics service
  analytics.track('game_completed', {
    gameId,
    duration,
    timestamp: new Date()
  });
};
```

### 3. Error Tracking

```javascript
// Error handling
const handleSocketError = (socket, error) => {
  console.error(`Socket error for ${socket.id}:`, error);
  
  // Send error to monitoring service
  errorTracker.captureException(error, {
    socketId: socket.id,
    timestamp: new Date()
  });
};
```

---

**Napravljeno:** Multiplayer Architecture Plan  
**Datum:** Oktobar 2025  
**Status:** Ready for Implementation 🚀
