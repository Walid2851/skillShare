import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controller/auth_controller.dart';
import 'another_chat.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String? userId;
  final AuthController authController = Get.find<AuthController>();
  final supabase = Supabase.instance.client;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _chatUsers = [];
  List<Map<String, dynamic>> _filteredChatUsers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _searchController.addListener(_filterChats);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterChats);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUserId() async {
    try {
      final firebaseUid = authController.user.value?.uid;
      if (firebaseUid == null) return;

      final userData = await supabase
          .from('users')
          .select('id')
          .eq('firebase_uid', firebaseUid)
          .single();

      if (userData['id'] != null) {
        setState(() {
          userId = userData['id']?.toString();
        });
        await _fetchChatUsers();
      }
    } catch (e) {
      _showError('Failed to get user ID');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      duration: Duration(seconds: 3),
    );
  }

  Future<void> _fetchChatUsers() async {
    if (userId == null) return;

    try {
      final messages = await supabase
          .from('messages')
          .select('from, to, message, created_at')
          .or('from.eq.$userId, to.eq.$userId')
          .order('created_at', ascending: false);

      final uniqueUserIds = messages
          .map((msg) => msg['from'] == userId ? msg['to'] : msg['from'])
          .toSet()
          .toList();

      if (uniqueUserIds.isNotEmpty) {
        final users = await supabase
            .from('users')
            .select('id, first_name, last_name, profile_image_url')
            .filter('id', 'in', uniqueUserIds);

        setState(() {
          _chatUsers = users;
          _filteredChatUsers = users;
        });
      }
    } catch (e) {
      _showError('Failed to fetch chat users');
    }
  }

  void _filterChats() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredChatUsers = _chatUsers;
      } else {
        _filteredChatUsers = _chatUsers
            .where((user) =>
            '${user['first_name']} ${user['last_name']}'.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Messages',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          userId == null
              ? Center(child: CircularProgressIndicator())
              : _chatUsers.isEmpty
              ? Center(child: Text("No conversations yet."))
              : Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _filteredChatUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredChatUsers[index];
                return _buildChatItem(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Navigate to ChatScreen with the user and currentUserId as parameters
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                user: user,
                currentUserId: userId!,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade50,
                backgroundImage: user['profile_image_url'] != null
                    ? NetworkImage(user['profile_image_url'])
                    : null,
                child: user['profile_image_url'] == null
                    ? Text(
                  user['first_name'][0],
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                )
                    : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user['first_name']} ${user['last_name']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    FutureBuilder<String>(
                      future: _fetchLastMessage(user['id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text("Loading...");
                        }

                        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                          return Text("No messages");
                        }

                        return Text(
                          snapshot.data!,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _fetchLastMessage(String userId) async {
    try {
      final messages = await supabase
          .from('messages')
          .select('message')
          .or('from.eq.$userId, to.eq.$userId')
          .order('created_at', ascending: false)
          .limit(1);

      if (messages.isNotEmpty) {
        return messages[0]['message'] ?? 'No messages';
      } else {
        return 'No messages';
      }
    } catch (e) {
      return 'Failed to load last message';
    }
  }
}
