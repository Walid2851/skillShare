import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatScreen({required this.user});

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
                user['first_name'][0].toUpperCase(),
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
                  '${user['first_name']} ${user['last_name']}',
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
              'You\'ve connected with ${user['first_name']}! Start your conversation about skill swapping.',
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
              itemCount: 1,
              itemBuilder: (context, index) => _buildInitialMessage(),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildInitialMessage() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.purple.shade50,
            child: Text(
              user['first_name'][0].toUpperCase(),
              style: TextStyle(
                color: Colors.purple.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(maxWidth: Get.width * 0.7),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Hi! I\'m excited to exchange skills with you. When would you like to start?',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              onPressed: () {}, // Dummy onPressed
            ),
          ),
        ],
      ),
    );
  }
}