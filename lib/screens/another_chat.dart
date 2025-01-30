import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String currentUserId;

  ChatScreen({required this.user, required this.currentUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _listenForRealtimeUpdates();
  }

  /// Fetch chat messages from Supabase
  Future<void> _fetchMessages() async {
    final response = await supabase
        .from('messages')
        .select()
        .or(
        'and(from.eq.${widget.currentUserId},to.eq.${widget.user['id']})'
            ',and(from.eq.${widget.user['id']},to.eq.${widget.currentUserId})'
    )
        .order('created_at', ascending: true);

    setState(() {
      _messages = response;
    });

    _scrollToBottom();
  }

  /// Listen for new messages in real-time
  void _listenForRealtimeUpdates() {
    supabase
        .channel('messages')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        if ((payload.newRecord['from'] == widget.currentUserId &&
            payload.newRecord['to'] == widget.user['id']) ||
            (payload.newRecord['from'] == widget.user['id'] &&
                payload.newRecord['to'] == widget.currentUserId)) {
          setState(() {
            _messages.add(payload.newRecord);
          });
          _scrollToBottom();
        }
      },
    )
        .subscribe();
  }

  /// Scroll to the latest message
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// Send message to Supabase
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await supabase.from('messages').insert({
      'from': widget.currentUserId,
      'to': widget.user['id'],
      'message': text,
      'created_at': DateTime.now().toIso8601String(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.purple.shade50,
              child: Text(
                widget.user['first_name'][0].toUpperCase(),
                style: TextStyle(
                  color: Colors.purple.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.user['first_name']} ${widget.user['last_name']}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Ready to skill swap',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Text(
              'You\'ve connected with ${widget.user['first_name']}! Start your conversation about skill swapping.',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// Chat bubble widget
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isMe = message['from'] == widget.currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade400 : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message['message'],
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  /// Input field with send button
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.black38),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
