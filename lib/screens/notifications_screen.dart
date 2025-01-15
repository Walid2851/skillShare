// TODO Implement this library.

import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'No notifications yet!',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
