import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';
import 'skill_Dill.dart';
import 'profile_screen.dart';
import 'connect_screen.dart';
import 'notifications_screen.dart';
import 'about_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final SupabaseClient _supabase = Supabase.instance.client;
  late AnimationController _searchAnimController;
  late Animation<double> _searchAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (_showSearch) {
        _searchAnimController.forward();
      } else {
        _searchAnimController.reverse();
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildUserGrid(),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: _showSearch
          ? SizeTransition(
        sizeFactor: _searchAnimation,
        axisAlignment: -1,
        child: Container(
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search skills...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
      )
          : Text(
        'Skill Swap',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close : Icons.search,
            color: Colors.black87,
          ),
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.black87),
          onPressed: () => Get.to(() => NotificationsScreen()),
        ),
        if (!_showSearch) _buildProfileAvatar(),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Obx(() {
      final currentUser = authController.user.value;
      if (currentUser == null) return SizedBox();

      return FutureBuilder(
        future: _supabase
            .from('users')
            .select()
            .eq('firebase_uid', currentUser.uid)
            .single(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();

          final userData = snapshot.data as Map;
          return GestureDetector(
            onTap: () => Get.to(() => ProfileScreen()),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Hero(
                tag: 'profile_avatar',
                child: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    userData['first_name'][0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildUserGrid() {
    return StreamBuilder(
      stream: _supabase.from('users').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading users'));
        }

        final allUsers = snapshot.data as List<dynamic>;
        final currentUser = authController.user.value;

        return FutureBuilder(
          future: _filterUsers(allUsers, currentUser?.uid, _searchQuery),
          builder: (context, AsyncSnapshot<List<dynamic>> filteredSnapshot) {
            if (!filteredSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final users = filteredSnapshot.data!;

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: _buildUserCard(users[index]),
                );
              },
            );
          },
        );
      },
    );
  }
  Future<List<dynamic>> _filterUsers(List<dynamic> users, String? currentUserId, String query) async {
    if (query.isEmpty) {
      return users.where((user) => user['firebase_uid'] != currentUserId).toList();
    }

    List<dynamic> filteredUsers = [];
    for (var user in users) {
      if (user['firebase_uid'] == currentUserId) continue;

      final hasMatchingSkill = await _checkUserSkills(user['id'], query);
      if (hasMatchingSkill) {
        filteredUsers.add(user);
      }
    }
    return filteredUsers;
  }
  Future<bool> _checkUserSkills(String userId, String query) async {
    final response = await _supabase
        .from('user_skills')
        .select('skills(*)')
        .eq('user_id', userId);

    final skills = (response as List).map((skill) =>
        skill['skills']['name'].toString().toLowerCase()
    ).toList();

    return skills.any((skill) => skill.contains(query));
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return FutureBuilder(
      future: _supabase
          .from('user_skills')
          .select('*, skills(*)')
          .eq('user_id', user['id']),
      builder: (context, AsyncSnapshot skillsSnapshot) {
        final userSkills = skillsSnapshot.data ?? [];

        return Container(
          width: MediaQuery.of(context).size.width - 32, // Full width minus padding
          child: Card(
            elevation: 3,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: () => Get.to(() => ConnectScreen(user: user)),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserAvatar(user),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUserInfo(user),
                              SizedBox(height: 8),
                              _buildBioSection(user),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildSkillsList(userSkills),
                    SizedBox(height: 20),
                    _buildConnectButton(user),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> fetchSignedProfileUrl(String filePath, int expiresIn) async {
    try {
      // Replace 'profiles' with your bucket name if it's different
      final signedUrl = await Supabase.instance.client.storage
          .from('profiles')
          .createSignedUrl(filePath, expiresIn);

      if (signedUrl != null) {
        print("Signed URL: $signedUrl");
        return signedUrl;
      } else {
        print("Failed to fetch signed URL.");
        return null;
      }
    } catch (e) {
      print("Error fetching signed URL: $e");
      return null;
    }
  }


  Widget _buildUserAvatar(Map<String, dynamic> user) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: user['profile_image_url'] != null && user['profile_image_url'].isNotEmpty
            ? Image.network(
          user['profile_image_url'],
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackAvatar(user);
          },
        )
            : _buildFallbackAvatar(user),
      ),
    );
  }

  Widget _buildFallbackAvatar(Map<String, dynamic> user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Colors.grey.shade900],

        ),
      ),
      child: Center(
        child: Text(
          user['first_name'].isNotEmpty
              ? user['first_name'][0].toUpperCase()
              : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(Map<String, dynamic> user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${user['first_name']} ${user['last_name']}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Text(
          '@${user['username']}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
  Widget _buildBioSection(Map<String, dynamic> user) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserBio(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error loading bio: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _fetchUserBio(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final bio = snapshot.data?['bio'] ?? 'No bio available';

        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bio,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _getCurrentUserId() async {
    try {
      final firebaseUid = authController.user.value?.uid;
      if (firebaseUid == null) return null;

      // Query Supabase for the user record
      final userData = await _supabase
          .from('users')
          .select('id')
          .eq('firebase_uid', firebaseUid)
          .single();

      // Return the ID as a string, handling potential null values
      return userData['id']?.toString();
    } catch (e) {
      _showError('Failed to get user ID');
      return null;
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
  Future<Map<String, dynamic>> _fetchUserBio() async {
    try {
      final currentUserId = await _getCurrentUserId();
      print('Current User ID: $currentUserId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await Supabase.instance.client
          .from('users')
          .select('bio')
          .eq('id', currentUserId)
          .maybeSingle();

      print('Raw Supabase Response: $response');

      // If response is null, return default
      if (response == null) {
        return {'bio': 'No bio available'};
      }

      // Cast response to Map
      final Map<String, dynamic> data = response;
      print('Parsed Data: $data');

      return data.isNotEmpty ? data : {'bio': 'No bio available'};

    } catch (e) {
      print('Error in _fetchUserBio: $e');
      throw Exception('Failed to fetch bio: ${e.toString()}');
    }
  }


  Widget _buildSkillsList(List<dynamic> userSkills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: userSkills.map((skill) => _buildSkillItem(
            skill['skills']['name'],
            skill['proficiency_level'],
            skill['is_offering'],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillItem(String skillName, String proficiency, bool isOffering) {
    int stars = proficiency == 'Beginner' ? 1 :
    proficiency == 'Intermediate' ? 2 : 3;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOffering ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOffering ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skillName,
            style: TextStyle(
              fontSize: 14,
              color: isOffering ? Colors.green.shade700 : Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              stars,
                  (index) => Icon(
                Icons.star,
                size: 14,
                color: isOffering ? Colors.green.shade400 : Colors.orange.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton(Map<String, dynamic> user) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Get.to(() => ConnectScreen(user: user)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade900,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Connect',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 1:
            Get.to(() => SkillDillScreen());
          case 2:
            Get.to(() => ChatScreen());
            break;
          case 3:
            Get.to(() => ProfileScreen());
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
          label: 'Skill Swap',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}