import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skill/screens/chat_screen.dart';
import 'package:skill/screens/profile_screen.dart';
import '../controller/auth_controller.dart';
import 'home_screen.dart';

class SkillDillScreen extends StatefulWidget {
  @override
  _SkillDillState createState() => _SkillDillState();
}

class _SkillDillState extends State<SkillDillScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              Get.off(() => HomeScreen());
              break;
            case 2:
              Get.off(() => ChatScreen());
              break;
            case 3:
              Get.off(() => ProfileScreen());
              break;
          }
        },
        backgroundColor: Colors.white,
        elevation: 0,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.sync_outlined),
            selectedIcon: Icon(Icons.sync),
            label: 'Skill Deals',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outlined),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
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
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('Archived'),
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
                    skillOffered: 'DOG SITTING/TRAINER',
                    skillNeeded: 'ARTS',
                    skillImage: 'assets/',
                  ),
                  SkillDealCard(
                    userName: 'Man Man',
                    userImage: 'assets/walid.jpg',
                    skillOffered: 'WINDOW CLEANING',
                    skillNeeded: 'SCULPTURING',
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
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(userImage),
                radius: 25,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        skillOffered,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.handshake, color: Colors.orange, size: 24),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        skillNeeded,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // SizedBox(width: 10),
          // CircleAvatar(
          //   backgroundImage: skillImage != null ? AssetImage(skillImage!) : null,
          //   backgroundColor: skillImage == null ? Colors.grey.shade300 : Colors.transparent,
          //   radius: 25,
          //   child: skillImage == null
          //       ? Text(
          //     userName[0].toUpperCase(),
          //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          //   )
          //       : null,
          // ),
        ],
      ),
    );
  }
}
