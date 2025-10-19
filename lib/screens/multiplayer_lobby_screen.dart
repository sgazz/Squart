// Multiplayer Lobby Screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/multiplayer_provider.dart';
import '../widgets/pwa_status_widget.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  @override
  _MultiplayerLobbyScreenState createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isCreatingRoom = false;
  bool _showCreateRoomDialog = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMultiplayer();
    });
  }
  
  Future<void> _initializeMultiplayer() async {
    final multiplayer = Provider.of<MultiplayerProvider>(context, listen: false);
    await multiplayer.initialize();
    
    if (multiplayer.isConnected) {
      await multiplayer.loadPublicRooms();
    }
  }
  
  Future<void> _guestLogin() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a username')),
      );
      return;
    }
    
    final multiplayer = Provider.of<MultiplayerProvider>(context, listen: false);
    final success = await multiplayer.guestLogin(_usernameController.text.trim());
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in as ${multiplayer.username}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
  }
  
  Future<void> _createRoom() async {
    if (_roomNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a room name')),
      );
      return;
    }
    
    setState(() {
      _isCreatingRoom = true;
    });
    
    final multiplayer = Provider.of<MultiplayerProvider>(context, listen: false);
    await multiplayer.createRoom(
      roomName: _roomNameController.text.trim(),
      isPublic: true,
      password: _passwordController.text.trim().isEmpty ? null : _passwordController.text.trim(),
    );
    
    setState(() {
      _isCreatingRoom = false;
      _showCreateRoomDialog = false;
    });
    
    // Clear form
    _roomNameController.clear();
    _passwordController.clear();
  }
  
  Future<void> _joinRoom(String roomId) async {
    final multiplayer = Provider.of<MultiplayerProvider>(context, listen: false);
    await multiplayer.joinRoom(roomId);
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'Multiplayer Lobby',
                        style: TextStyle(
                          fontSize: 24,
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
              
              // Content
              Expanded(
                child: Consumer<MultiplayerProvider>(
                  builder: (context, multiplayer, child) {
                    if (!multiplayer.isConnected) {
                      return _buildConnectionError();
                    }
                    
                    if (!multiplayer.isLoggedIn) {
                      return _buildLoginForm();
                    }
                    
                    return _buildLobbyContent(multiplayer);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildConnectionError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Connection Error',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Unable to connect to server',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final multiplayer = Provider.of<MultiplayerProvider>(context, listen: false);
              multiplayer.initialize();
            },
            child: Text('Retry Connection'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoginForm() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'Enter Your Username',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guestLogin,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Login as Guest'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLobbyContent(MultiplayerProvider multiplayer) {
    return Column(
      children: [
        // Action buttons
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showCreateRoomDialog = true;
                    });
                  },
                  icon: Icon(Icons.add),
                  label: Text('Create Room'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    multiplayer.loadPublicRooms();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Public rooms list
        Expanded(
          child: multiplayer.isLoadingRooms
              ? Center(child: CircularProgressIndicator())
              : multiplayer.publicRooms.isEmpty
                  ? Center(
                      child: Text(
                        'No public rooms available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: multiplayer.publicRooms.length,
                      itemBuilder: (context, index) {
                        final room = multiplayer.publicRooms[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          color: Colors.white.withOpacity(0.1),
                          child: ListTile(
                            title: Text(
                              room['roomName'] ?? 'Squart Game',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${room['players']}/${room['maxPlayers']} players',
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _joinRoom(room['roomId']),
                              child: Text('Join'),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _roomNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
