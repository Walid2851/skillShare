import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import 'another_chat.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class ConnectScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  ConnectScreen({required this.user});
  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> with SingleTickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  late AnimationController _connectAnimController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  bool _isLongPressed = false;
  bool _isConnecting = false;
  late  Map<String, dynamic> currentUserr;

  @override
  void initState() {
    super.initState();
    _connectAnimController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _connectAnimController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _connectAnimController, curve: Curves.easeInOut),
    );

    _connectAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isLongPressed) {
        setState(() => _isConnecting = true);
        Future.delayed(Duration(milliseconds: 500), () async {
          final current = await _fetchUserData();
          Get.to(() =>
              ChatScreen(
                user: widget.user,
                currentUserId: current[0]["id"]
              ));
        });
      }
    });
  }

  @override
  void dispose() {
    _connectAnimController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchUserData() async {
    try {
      var currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // First get the current user's data to get their Supabase ID
      final response = await _supabase
          .from('users')
          .select()
          .eq('firebase_uid', currentUser.uid)
          .single();

      // Properly cast the response to Map<String, dynamic>
      final currentUserData = Map<String, dynamic>.from(response as Map);
      // Now use the Supabase ID for fetching skills
      final results = await Future.wait<dynamic>([
        Future.value(currentUserData), // Pass the properly casted user data
        _fetchUserSkills(widget.user['id']), // Other user's skills
        _fetchUserSkills(currentUserData['id'], isCurrentUser: true), // Current user's skills using Supabase ID
      ]);

      return results;
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserSkills(String userId, {bool isCurrentUser = false}) async {
    try {
      final response = await _supabase
          .from('user_skills')
          .select('*, skills(*)')
          .eq('user_id', userId);

      // Properly cast the response to List<Map<String, dynamic>>
      return (response as List).map((skill) => Map<String, dynamic>.from({
        ...skill as Map,
        'user_type': isCurrentUser ? 'current' : 'other'
      })).toList();
    } catch (e) {
      print('Error fetching skills: $e');
      return [];
    }
  }

  Widget _buildProfileCard(Map<String, dynamic> user,
      {required bool isCurrentUser}) {
    final firstName = user['first_name'] as String? ?? 'User';
    final lastName = user['last_name'] as String? ?? '';
    final username = user['username'] as String? ?? 'username';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrentUser
              ? [Colors.blue.shade400, Colors.blue.shade600]
              : [Colors.purple.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: isCurrentUser ? Colors.blue.shade600 : Colors
                          .purple.shade600,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '$firstName $lastName',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '@$username',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCards(Map<String, dynamic> currentUser,
      Map<String, dynamic> otherUser) {
    return Row(
      children: [
        Expanded(child: _buildProfileCard(currentUser, isCurrentUser: true)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
              Icons.compare_arrows, color: Colors.blue.shade400, size: 32),
        ),
        Expanded(child: _buildProfileCard(otherUser, isCurrentUser: false)),
      ],
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupSkillsByCategory(
      List<dynamic> skills) {
    final Map<String, List<Map<String, dynamic>>> categories = {};

    for (var skill in skills) {
      final category = skill['skills']['category'] ?? 'Other';
      if (!categories.containsKey(category)) {
        categories[category] = [];
      }
      categories[category]!.add(skill);
    }

    return categories;
  }

  Widget _buildSkillCategory(String category,
      List<Map<String, dynamic>> skills) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.category, size: 20, color: Colors.blue.shade700),
                SizedBox(width: 8),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 16,
              children: skills.map((skill) =>
                  _buildEnhancedSkillChip(
                    skill['skills']['name'],
                    skill['proficiency_level'],
                    skill['is_offering'],
                    skill['user_type'] == 'current',
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSkillChip(String name, String level, bool isOffering,
      bool isCurrentUser) {
    final MaterialColor baseColor = isCurrentUser ? Colors.blue : Colors
        .purple; // Changed to MaterialColor
    final int stars = level == 'Beginner' ? 1 : level == 'Intermediate' ? 2 : 3;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: baseColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOffering ? Icons.workspace_premium : Icons.school,
            size: 16,
            color: baseColor.withOpacity(0.8),
          ),
          SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: baseColor[700], // Changed to use index notation
            ),
          ),
          SizedBox(width: 6),
          Row(
            children: List.generate(
              stars,
                  (index) =>
                  Icon(
                    Icons.star,
                    size: 14,
                    color: baseColor[400], // Changed to use index notation
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsComparison(List<dynamic> currentUserSkills,
      List<dynamic> otherUserSkills) {
    final allSkills = [...currentUserSkills, ...otherUserSkills];
    final skillCategories = _groupSkillsByCategory(allSkills);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare, color: Colors.blue.shade700, size: 28),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skills Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Compare skills and expertise levels',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Blue indicates your skills, purple shows the other person\'s skills',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          ...skillCategories.entries.map((category) =>
              _buildSkillCategory(
                category.key,
                category.value,
              )).toList(),
        ],
      ),
    );
  }

  Widget _buildConnectButton() {
    return Center(
      child: GestureDetector(
        onLongPressStart: (_) {
          setState(() => _isLongPressed = true);
          _connectAnimController.forward();
        },
        onLongPressEnd: (_) {
          setState(() => _isLongPressed = false);
          if (_connectAnimController.value < 1.0) {
            _connectAnimController.reverse();
          }
        },
        child: AnimatedBuilder(
          animation: _connectAnimController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value * 3.14,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _isConnecting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Icon(
                    Icons.connect_without_contact,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null ||
        !widget.user.containsKey('id') ||
        widget.user['id'] == null) {
      return Scaffold(
        body: Center(
          child: Text('Invalid user data'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.black87),
        title: Text(
          'View Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchUserData(),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Error loading data: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[600]!),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading profiles...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final currentUserData = snapshot.data![0] as Map<String, dynamic>?;
          final otherUserSkills = snapshot.data![1] as List;
          final currentUserSkills = snapshot.data![2] as List;


          if (currentUserData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 48, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Unable to load user data',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileCards(currentUserData, widget.user),
                    SizedBox(height: 24),
                    _buildSkillsComparison(currentUserSkills, otherUserSkills),
                    SizedBox(height: 32),
                    _buildConnectButton(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
