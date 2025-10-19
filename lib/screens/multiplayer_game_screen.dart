// Multiplayer Game Screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import '../widgets/pwa_status_widget.dart';

class MultiplayerGameScreen extends StatefulWidget {
  @override
  _MultiplayerGameScreenState createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
  
  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final multiplayer = Provider.of<MultiplayerProvider>(context, listen: false);
    await multiplayer.sendMessage(_messageController.text.trim());
    
    _messageController.clear();
    _scrollToBottom();
  }
  
  Future<void> _setPlayerReady(bool ready) async {
    final multiplayer = Provider.of<MultiplayerProvider>(context, listen: false);
    await multiplayer.setPlayerReady(ready);
  }
  
  Future<void> _makeMove(int row, int col) async {
    final multiplayer = Provider.of<MultiplayerProvider>(context, listen: false);
    await multiplayer.makeMove(row, col);
  }
  
  Future<void> _leaveRoom() async {
    final multiplayer = Provider.of<MultiplayerProvider>(context, listen: false);
    await multiplayer.leaveRoom();
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<MultiplayerProvider>(
            builder: (context, multiplayer, child) {
              if (multiplayer.currentRoom == null) {
                return _buildNoRoom();
              }
              
              return _buildGameContent(multiplayer);
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildNoRoom() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'No Room Found',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'You are not in any room',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back to Lobby'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameContent(MultiplayerProvider multiplayer) {
    final room = multiplayer.currentRoom!;
    final players = room['players'] as List<dynamic>;
    final gameState = room['gameState'] as Map<String, dynamic>;
    
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: _leaveRoom,
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  room['roomName'] ?? 'Squart Game',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              PWAStatusWidget(),
            ],
          ),
        ),
        
        // Game status
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                _getGameStatusText(multiplayer, room),
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              if (multiplayer.isGameStarted) ...[
                SizedBox(height: 8),
                Text(
                  'Current Player: ${multiplayer.currentPlayer?.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: multiplayer.currentPlayer == 'blue' ? Colors.blue : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Players list
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Players',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              ...players.map((player) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: player['color'] == 'blue' ? Colors.blue : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      player['username'],
                      style: TextStyle(color: Colors.white),
                    ),
                    if (player['isReady']) ...[
                      SizedBox(width: 8),
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ],
                    if (player['isOnline'] == false) ...[
                      SizedBox(width: 8),
                      Icon(Icons.wifi_off, color: Colors.red, size: 16),
                    ],
                  ],
                ),
              )),
            ],
          ),
        ),
        
        // Game board (placeholder)
        if (multiplayer.isGameStarted)
          Expanded(
            child: Center(
              child: Text(
                'Game Board\n(Integration with existing game logic)',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        
        // Ready button
        if (!multiplayer.isGameStarted && !multiplayer.isPlayerReady)
          Container(
            margin: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _setPlayerReady(true),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Ready to Play'),
            ),
          ),
        
        // Chat section
        Container(
          height: 200,
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Chat header
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.chat, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Chat',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _chatScrollController,
                  padding: EdgeInsets.all(8),
                  itemCount: multiplayer.messages.length,
                  itemBuilder: (context, index) {
                    final message = multiplayer.messages[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '${message['player']}: ${message['message']}',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    );
                  },
                ),
              ),
              
              // Message input
              Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: TextStyle(color: Colors.white),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: Icon(Icons.send, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _getGameStatusText(MultiplayerProvider multiplayer, Map<String, dynamic> room) {
    if (multiplayer.isGameStarted) {
      return 'Game in Progress';
    } else if (room['status'] == 'waiting') {
      return 'Waiting for players to be ready...';
    } else if (room['status'] == 'finished') {
      return 'Game Finished';
    } else {
      return 'Room Status: ${room['status']}';
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }
}
