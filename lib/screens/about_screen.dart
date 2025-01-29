import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'About Skill Swap',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Skill Swap is a dynamic platform that enables users to share and learn new skills from one another. "
                    "The app connects users who wish to teach a skill with those who want to learn, creating a collaborative learning environment.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                'Our Mission',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Our mission is to make skill-sharing accessible, engaging, and rewarding. We aim to create a "
                    "community where knowledge is exchanged freely and efficiently, benefiting learners and teachers alike.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                'Meet the Team - Team_KukiChin',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                    "Marufur Rahman Mithu\n"
                    "Manobendra Biswas\n"
                    "Mahmud Hasan Walid\n"
                    "Amio Rashid",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),

              Text(
                'Thank you for being a part of our journey!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
