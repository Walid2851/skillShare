import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skill/screens/chat_screen.dart';
import 'package:skill/screens/profile_screen.dart';
import '../controller/auth_controller.dart';
import 'another_chat.dart';
import 'home_screen.dart';

class SkillDillScreen extends StatefulWidget {
  @override
  _SkillDillState createState() => _SkillDillState();
}

class _SkillDillState extends State<SkillDillScreen> {
  int _selectedIndex = 1; // Default selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different screens based on the selected index
    switch (index) {
      case 0:
        Get.off(() => HomeScreen());
        break;
      case 2:
        Get.off(() => MessagesScreen());
        break;
      case 3:
        Get.off(() => ProfileScreen());
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Skill Deals',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 2,
        selectedItemColor: Colors.orange.shade400,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync_outlined),
            label: 'Skill Deals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outlined),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                'MY SKILL DEALS',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Deals',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text('Archived', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  SkillDealCard(
                    userName: 'Manob',
                    userImage: 'assets/manob.jpg',
                    skillOffered: 'PYTHON',
                    skillNeeded: 'MUSIC',
                    skillImage: 'assets/',
                  ),
                  SkillDealCard(
                    userName: 'Man Man',
                    userImage: 'assets/walid.jpg',
                    skillOffered: 'CYBERSECURITY',
                    skillNeeded: 'ML',
                    skillImage: 'assets/sculpturing.jpg',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SkillDealCard extends StatelessWidget {
  final String userName;
  final String userImage;
  final String skillOffered;
  final String skillNeeded;
  final String? skillImage;

  SkillDealCard({
    required this.userName,
    required this.userImage,
    required this.skillOffered,
    required this.skillNeeded,
    this.skillImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(userImage),
            radius: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        skillOffered,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.handshake, color: Colors.orange, size: 22),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        skillNeeded,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
