// Multiplayer Provider for State Management
import 'package:flutter/foundation.dart';
import '../services/multiplayer_service.dart';

class MultiplayerProvider extends ChangeNotifier {
  final MultiplayerService _multiplayerService = MultiplayerService();
  
  // Connection state
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectionError;
  
  // User state
  String? _userId;
  String? _username;
  bool _isLoggedIn = false;
  
  // Room state
  String? _currentRoomId;
  Map<String, dynamic>? _currentRoom;
  List<Map<String, dynamic>> _publicRooms = [];
  bool _isLoadingRooms = false;
  
  // Game state
  bool _isGameStarted = false;
  bool _isPlayerReady = false;
  String? _currentPlayer;
  List<Map<String, dynamic>> _gameMoves = [];
  String? _gameWinner;
  String? _gameEndReason;
  
  // Chat state
  List<Map<String, dynamic>> _messages = [];
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectionError => _connectionError;
  
  String? get userId => _userId;
  String? get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  
  String? get currentRoomId => _currentRoomId;
  Map<String, dynamic>? get currentRoom => _currentRoom;
  List<Map<String, dynamic>> get publicRooms => _publicRooms;
  bool get isLoadingRooms => _isLoadingRooms;
  
  bool get isGameStarted => _isGameStarted;
  bool get isPlayerReady => _isPlayerReady;
  String? get currentPlayer => _currentPlayer;
  List<Map<String, dynamic>> get gameMoves => _gameMoves;
  String? get gameWinner => _gameWinner;
  String? get gameEndReason => _gameEndReason;
  
  List<Map<String, dynamic>> get messages => _messages;
  
  // Initialize multiplayer
  Future<void> initialize() async {
    if (kIsWeb) {
      _isConnecting = true;
      notifyListeners();
      
      try {
        // Add delay to ensure backend is ready
        await Future.delayed(Duration(seconds: 2));
        await _multiplayerService.initialize();
        _isConnected = _multiplayerService.isConnected;
        _connectionError = null;
      } catch (e) {
        _connectionError = e.toString();
        _isConnected = false;
      } finally {
        _isConnecting = false;
        notifyListeners();
      }
    }
  }
  
  // Guest login
  Future<bool> guestLogin(String username) async {
    if (!_isConnected) return false;
    
    try {
      final success = await _multiplayerService.guestLogin(username);
      if (success) {
        _userId = _multiplayerService.userId;
        _username = _multiplayerService.username;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _connectionError = e.toString();
      notifyListeners();
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
    if (!_isConnected || !_isLoggedIn) return;
    
    await _multiplayerService.createRoom(
      roomName: roomName,
      isPublic: isPublic,
      password: password,
      gameSettings: gameSettings,
    );
  }
  
  // Join room
  Future<void> joinRoom(String roomId, {String? password}) async {
    if (!_isConnected || !_isLoggedIn) return;
    
    await _multiplayerService.joinRoom(roomId, password: password);
  }
  
  // Leave room
  Future<void> leaveRoom() async {
    if (_currentRoomId != null) {
      await _multiplayerService.leaveRoom();
      _currentRoomId = null;
      _currentRoom = null;
      _isGameStarted = false;
      _isPlayerReady = false;
      _gameMoves.clear();
      _gameWinner = null;
      _gameEndReason = null;
      _messages.clear();
      notifyListeners();
    }
  }
  
  // Set player ready
  Future<void> setPlayerReady(bool ready) async {
    if (!_isConnected || !_isLoggedIn || _currentRoomId == null) return;
    
    await _multiplayerService.setPlayerReady(ready);
    _isPlayerReady = ready;
    notifyListeners();
  }
  
  // Make move
  Future<void> makeMove(int row, int col) async {
    if (!_isConnected || !_isLoggedIn || _currentRoomId == null || !_isGameStarted) return;
    
    await _multiplayerService.makeMove(row, col);
  }
  
  // Send message
  Future<void> sendMessage(String message) async {
    if (!_isConnected || !_isLoggedIn || _currentRoomId == null) return;
    
    await _multiplayerService.sendMessage(message);
  }
  
  // Get public rooms
  Future<void> loadPublicRooms() async {
    if (!_isConnected || !_isLoggedIn) return;
    
    _isLoadingRooms = true;
    notifyListeners();
    
    try {
      final rooms = await _multiplayerService.getPublicRooms();
      _publicRooms = rooms;
    } catch (e) {
      _connectionError = e.toString();
    } finally {
      _isLoadingRooms = false;
      notifyListeners();
    }
  }
  
  // Handle room created
  void handleRoomCreated(Map<String, dynamic> data) {
    _currentRoomId = data['roomId'];
    _currentRoom = data['room'];
    notifyListeners();
  }
  
  // Handle room joined
  void handleRoomJoined(Map<String, dynamic> data) {
    _currentRoomId = data['room']['roomId'];
    _currentRoom = data['room'];
    notifyListeners();
  }
  
  // Handle room updated
  void handleRoomUpdated(Map<String, dynamic> data) {
    _currentRoom = data['room'];
    notifyListeners();
  }
  
  // Handle room left
  void handleRoomLeft(Map<String, dynamic> data) {
    _currentRoomId = null;
    _currentRoom = null;
    _isGameStarted = false;
    _isPlayerReady = false;
    _gameMoves.clear();
    _gameWinner = null;
    _gameEndReason = null;
    _messages.clear();
    notifyListeners();
  }
  
  // Handle game started
  void handleGameStarted(Map<String, dynamic> data) {
    _isGameStarted = true;
    _currentPlayer = data['room']['gameState']['currentPlayer'];
    notifyListeners();
  }
  
  // Handle move made
  void handleMoveMade(Map<String, dynamic> data) {
    _currentRoom = data['room'];
    _currentPlayer = data['room']['gameState']['currentPlayer'];
    _gameMoves.add(data['move']);
    notifyListeners();
  }
  
  // Handle game ended
  void handleGameEnded(Map<String, dynamic> data) {
    _gameWinner = data['winner'];
    _gameEndReason = data['endReason'];
    _isGameStarted = false;
    notifyListeners();
  }
  
  // Handle player disconnected
  void handlePlayerDisconnected(Map<String, dynamic> data) {
    // Update room state if needed
    notifyListeners();
  }
  
  // Handle player reconnected
  void handlePlayerReconnected(Map<String, dynamic> data) {
    // Update room state if needed
    notifyListeners();
  }
  
  // Handle message received
  void handleMessageReceived(Map<String, dynamic> data) {
    _messages.add(data);
    notifyListeners();
  }
  
  // Handle error
  void handleError(Map<String, dynamic> data) {
    _connectionError = data['message'];
    notifyListeners();
  }
  
  // Handle invalid move
  void handleInvalidMove(Map<String, dynamic> data) {
    _connectionError = data['message'];
    notifyListeners();
  }
  
  // Disconnect
  Future<void> disconnect() async {
    await _multiplayerService.disconnect();
    _isConnected = false;
    _isLoggedIn = false;
    _userId = null;
    _username = null;
    _currentRoomId = null;
    _currentRoom = null;
    _publicRooms.clear();
    _isGameStarted = false;
    _isPlayerReady = false;
    _gameMoves.clear();
    _gameWinner = null;
    _gameEndReason = null;
    _messages.clear();
    _connectionError = null;
    notifyListeners();
  }
}
