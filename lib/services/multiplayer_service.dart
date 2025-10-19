// Multiplayer Service for Real-time Communication
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class MultiplayerService {
  static final MultiplayerService _instance = MultiplayerService._internal();
  factory MultiplayerService() => _instance;
  MultiplayerService._internal();

  IO.Socket? _socket;
  String? _currentRoomId;
  String? _userId;
  String? _username;
  String? _token;
  bool _isConnected = false;
  
  // Connection status
  bool get isConnected => _isConnected;
  String? get currentRoomId => _currentRoomId;
  String? get userId => _userId;
  String? get username => _username;

  // Initialize multiplayer service
  Future<void> initialize() async {
    if (kIsWeb) {
      await _connectToServer();
    }
  }

  // Connect to backend server
  Future<void> _connectToServer() async {
    try {
      _socket = IO.io('http://localhost:3000', <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': false,
      });

      _setupSocketListeners();
      _socket!.connect();
    } catch (e) {
      print('Failed to connect to server: $e');
    }
  }

  // Setup socket event listeners
  void _setupSocketListeners() {
    _socket!.onConnect((_) {
      print('🔌 Connected to server');
      _isConnected = true;
    });

    _socket!.onDisconnect((_) {
      print('🔌 Disconnected from server');
      _isConnected = false;
    });

    _socket!.onError((error) {
      print('❌ Socket error: $error');
    });

    // Room events
    _socket!.on('room-created', _handleRoomCreated);
    _socket!.on('room-joined', _handleRoomJoined);
    _socket!.on('room-updated', _handleRoomUpdated);
    _socket!.on('room-left', _handleRoomLeft);

    // Game events
    _socket!.on('game-started', _handleGameStarted);
    _socket!.on('move-made', _handleMoveMade);
    _socket!.on('game-ended', _handleGameEnded);

    // Player events
    _socket!.on('player-disconnected', _handlePlayerDisconnected);
    _socket!.on('player-reconnected', _handlePlayerReconnected);

    // Chat events
    _socket!.on('message-received', _handleMessageReceived);

    // Error events
    _socket!.on('error', _handleError);
    _socket!.on('invalid-move', _handleInvalidMove);
  }

  // Guest login
  Future<bool> guestLogin(String username) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/guest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userId = data['user']['userId'];
        _username = data['user']['username'];
        _token = data['token'];
        
        // Update socket auth
        _socket!.emit('authenticate', {'token': _token});
        
        return true;
      }
      return false;
    } catch (e) {
      print('Guest login failed: $e');
      return false;
    }
  }

  // Create room
  Future<void> createRoom({
    String? roomName,
    bool isPublic = true,
    String? password,
    Map<String, dynamic>? gameSettings,
  }) async {
    if (_socket == null || !_isConnected) return;

    _socket!.emit('create-room', {
      'roomName': roomName,
      'isPublic': isPublic,
      'password': password,
      'gameSettings': gameSettings,
    });
  }

  // Join room
  Future<void> joinRoom(String roomId, {String? password}) async {
    if (_socket == null || !_isConnected) return;

    _socket!.emit('join-room', {
      'roomId': roomId,
      'password': password,
    });
  }

  // Leave room
  Future<void> leaveRoom() async {
    if (_socket == null || !_isConnected || _currentRoomId == null) return;

    _socket!.emit('leave-room', {'roomId': _currentRoomId});
    _currentRoomId = null;
  }

  // Set player ready status
  Future<void> setPlayerReady(bool ready) async {
    if (_socket == null || !_isConnected || _currentRoomId == null) return;

    _socket!.emit('player-ready', {
      'roomId': _currentRoomId,
      'ready': ready,
    });
  }

  // Make move
  Future<void> makeMove(int row, int col) async {
    if (_socket == null || !_isConnected || _currentRoomId == null) return;

    _socket!.emit('make-move', {
      'roomId': _currentRoomId,
      'row': row,
      'col': col,
    });
  }

  // Send chat message
  Future<void> sendMessage(String message) async {
    if (_socket == null || !_isConnected || _currentRoomId == null) return;

    _socket!.emit('send-message', {
      'roomId': _currentRoomId,
      'message': message,
    });
  }

  // Get public rooms
  Future<List<Map<String, dynamic>>> getPublicRooms() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/rooms/public'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['rooms']);
      }
      return [];
    } catch (e) {
      print('Failed to get public rooms: $e');
      return [];
    }
  }

  // Disconnect
  Future<void> disconnect() async {
    if (_currentRoomId != null) {
      await leaveRoom();
    }
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    _currentRoomId = null;
    _userId = null;
    _username = null;
    _token = null;
  }

  // Event handlers
  void _handleRoomCreated(dynamic data) {
    print('🏠 Room created: ${data['roomId']}');
    _currentRoomId = data['roomId'];
  }

  void _handleRoomJoined(dynamic data) {
    print('🚪 Joined room: ${data['room']['roomId']}');
    _currentRoomId = data['room']['roomId'];
  }

  void _handleRoomUpdated(dynamic data) {
    print('🔄 Room updated');
  }

  void _handleRoomLeft(dynamic data) {
    print('🚪 Left room: ${data['roomId']}');
    _currentRoomId = null;
  }

  void _handleGameStarted(dynamic data) {
    print('🎮 Game started');
  }

  void _handleMoveMade(dynamic data) {
    print('🎯 Move made: ${data['move']}');
  }

  void _handleGameEnded(dynamic data) {
    print('🏆 Game ended: ${data['winner']}');
  }

  void _handlePlayerDisconnected(dynamic data) {
    print('👤 Player disconnected: ${data['player']}');
  }

  void _handlePlayerReconnected(dynamic data) {
    print('👤 Player reconnected: ${data['player']}');
  }

  void _handleMessageReceived(dynamic data) {
    print('💬 Message: ${data['message']}');
  }

  void _handleError(dynamic data) {
    print('❌ Error: ${data['message']}');
  }

  void _handleInvalidMove(dynamic data) {
    print('❌ Invalid move: ${data['message']}');
  }
}
