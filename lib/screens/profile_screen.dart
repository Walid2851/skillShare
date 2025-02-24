import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skill/models/skills.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'about_screen.dart';
String _bioInput = '';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final SupabaseClient _supabase = Supabase.instance.client;
  bool isEditing = false;
  List<Skill> availableSkills = [];
  List<Skill> userSkills = [];
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.blue),
            title: Text('About Us'),
            onTap: () {
              Navigator.pop(context); // Close the menu
              Get.to(() => AboutScreen()); // Navigate to About Us Page
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
              _showSignOutConfirmation(); // Calls logout function
            },
          ),
        ],
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      // Load all available skills (including custom skills)
      final skillsResponse = await _supabase
          .from('skills')
          .select()
          .order('name');

      final List<Skill> skills = (skillsResponse as List)
          .map((skill) => Skill.fromJson(skill))
          .toList();

      // Load user's selected skills
      final String? userId = await _getCurrentUserId();
      if (userId != null) {
        final userSkillsResponse = await _supabase
            .from('user_skills')
            .select('*, skills(*)')
            .eq('user_id', userId);

        // Mark selected skills and set their properties
        for (var userSkill in userSkillsResponse as List) {
          final skillIndex = skills.indexWhere(
                  (s) => s.id == userSkill['skill_id']);
          if (skillIndex != -1) {
            skills[skillIndex].isSelected = true;
            skills[skillIndex].proficiencyLevel = userSkill['proficiency_level'];
            skills[skillIndex].isOffering = userSkill['is_offering'];
          }
        }
      }

      setState(() {
        availableSkills = skills;
        userSkills = skills.where((s) => s.isSelected).toList();
      });
    } catch (e) {
      _showError('Failed to load skills');
    }
  }

  Future<void> _pickImage() async {
    try {
      // Show a dialog to choose between camera and gallery
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Select Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return; // User canceled the selection

      // Pick the image
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      final File imageFile = File(pickedFile.path);

      // Validate if the file is an image
      if (!(await imageFile.exists())) {
        print("Invalid file selected");
        return;
      }

      // Upload the image to Supabase storage
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = 'profiles/$fileName';

      await _supabase.storage
          .from('profiles') // Bucket name
          .upload(filePath, imageFile);

      // Get the public URL of the uploaded image
      final String imageUrl = _supabase.storage
          .from('profiles')
          .getPublicUrl(filePath);

      // Update the state with the new image
      setState(() {
        _image = imageFile;
      });

      // Save the image URL to the user's profile in the database
      await _updateProfileImage(imageUrl);

    } catch (e) {
      print("Error picking or uploading image: $e");
    }
  }
  Future<void> _updateProfileImage(String imageUrl) async {
    if (imageUrl.isEmpty) {
      print("Invalid image URL");
      return;
    }

    try {
      final String? userId = await _getCurrentUserId();
      if (userId == null) {
        print("No user ID found");
        return;
      }

      // Update the user's profile with the new image URL
      final response = await _supabase
          .from('users')
          .update({'profile_image_url': imageUrl})
          .eq('id', userId);

      if (response.error != null) {
        print("Error updating profile image URL: ${response.error!.message}");
      } else {
        print("Profile image URL updated successfully");
      }
    } catch (e) {
      print("Error updating profile image URL: $e");
    }
  }

  Widget _buildModernHeader(Map<String, dynamic> userData) {
    return Container(
      height: 300,
      child: Stack(
        children: [
          // Background gradient with curved bottom
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF101112),
                  Color(0xFF353B42),
                ],
              ),
            ),
          ),

          // Profile content
          SafeArea(
            child: Column(
              children: [
                // Top bar (unchanged)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings, color: Colors.white),
                        onPressed: () => _showSettingsMenu(), // Call the new settings menu method
                      ),

                    ],
                  ),
                ),

                // Profile picture and Edit Profile button
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.white,
                          image: _getProfileImageDecoration(userData),
                        ),
                        child: _shouldShowInitial(userData)
                            ? Center(
                          child: Text(
                            _getInitial(userData),
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F1F20),
                            ),
                          ),
                        )
                            : null,
                      ),
                    ),
                    // Camera button (unchanged)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                          onPressed: _pickImage,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),

                // Name and username (unchanged)
                SizedBox(height: 16),
                Text(
                  '${userData['first_name']} ${userData['last_name']}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '@${userData['username'] ?? ''}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper methods
  DecorationImage? _getProfileImageDecoration(Map<String, dynamic> userData) {
    if (_image != null) {
      return DecorationImage(
        image: FileImage(_image!),
        fit: BoxFit.cover,
      );
    }

    final imageUrl = userData['profile_image_url']?.toString();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
      );
    }

    return null;
  }

  bool _shouldShowInitial(Map<String, dynamic> userData) {
    return _image == null &&
        (userData['profile_image_url'] == null ||
            userData['profile_image_url'].isEmpty);
  }

  String _getInitial(Map<String, dynamic> userData) {
    final firstName = userData['first_name']?.toString() ?? '';
    return firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
  }

  Widget _buildSkillsSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Skills',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              // TextButton.icon(
              //   onPressed: () => _addNewSkill(),
              //   icon: Icon(Icons.add, size: 20),
              //   label: Text('Add'),
              //   style: TextButton.styleFrom(
              //     foregroundColor: Colors.blue.shade600,
              //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              // ),
              TextButton.icon(
                onPressed: () => _showBioInputDialog(),
                icon: Icon(Icons.edit_outlined, size: 20),
                label: Text('Edit bio'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade900,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showSkillsEditor(),
                icon: Icon(Icons.edit_outlined, size: 20),
                label: Text('Edit Skill'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade900,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: userSkills.map((skill) {
              final isUserSkill = userSkills.contains(skill);
              return Container(
                decoration: BoxDecoration(
                  color: isUserSkill ? Colors.grey.shade900 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isUserSkill ? Colors.grey.shade900 : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  skill.name,
                  style: TextStyle(

                    color: isUserSkill ? Colors.white: Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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

  // Future<String?> _getCurrentUserId() async {
  //   try {
  //     final firebaseUid = authController.user.value?.uid;
  //     if (firebaseUid == null) return null;
  //
  //     final response = await _supabase
  //         .from('users')
  //         .select('id')
  //         .eq('firebase_uid', firebaseUid)
  //         .maybeSingle();  // Changed to maybeSingle to handle null cases
  //
  //     return response?['id']?.toString();
  //   } catch (e) {
  //     _showError('Failed to get user ID: ${e.toString()}');
  //     return null;
  //   }
  // }

  void _showBioInputDialog() async {
    final String? userInput = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Your Bio", style: TextStyle(fontSize: 20)),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: "Write about yourself...",
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, _textController.text),
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );

    if (userInput != null && userInput.isNotEmpty) {
      try {
        // 2. Added await for the Future<String?> return value
        final currentUserId = await _getCurrentUserId();

        if (currentUserId == null) {
          throw Exception('User not authenticated or not found in database');
        }

        // 3. Removed .single() from update operation
        final response = await Supabase.instance.client
            .from('users')
            .update({'bio': userInput.trim()})
            .eq('id', currentUserId)
            .maybeSingle();

        // if (response.error != null) {
        //   throw response.error!;
        // }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bio updated successfully!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }

    _textController.clear();
  }

  void _showSkillsEditor() {
    TextEditingController customSkillController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Skills',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Custom Skill Section
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customSkillController,
                        decoration: InputDecoration(
                          hintText: 'Enter custom skill',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        final customSkill = customSkillController.text.trim();
                        if (customSkill.isNotEmpty) {
                          try {
                            // Insert the custom skill into the database
                            final response = await _supabase.from('skills').insert({
                              'name': customSkill,
                              'description': 'custom skill', // Optionally, provide a description
                            }).select().single();

                            // Get the auto-generated ID
                            final newSkillId = response['skill_id'];

                            // Ensure the ID is not null
                            if (newSkillId != null) {
                              setModalState(() {
                                // Create a new skill object with the inserted ID
                                final newSkill = Skill(
                                  id: newSkillId, // Use the auto-generated ID from Supabase
                                  name: customSkill,
                                  isSelected: false,
                                );

                                availableSkills.add(newSkill); // Add to the list of available skills
                              });

                              customSkillController.clear(); // Clear the input field
                            } else {
                              throw Exception('Failed to get new skill ID');
                            }
                          } catch (e) {
                            print('Error inserting custom skill: $e');
                            // Show a snackbar or alert here
                            Get.snackbar(
                              'Error',
                              'There was an issue adding the skill. Please try again.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      },
                    ),

                  ],
                ),
              ),
              // Skills List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: availableSkills.length,
                  itemBuilder: (context, index) {
                    final skill = availableSkills[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.grey,
                        ),
                        child: CheckboxListTile(
                          value: skill.isSelected,
                          onChanged: (bool? value) {
                            if (value == true && userSkills.length >= 10) {
                              Get.snackbar(
                                'Limit Reached',
                                'You can select up to 10 skills',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }
                            setModalState(() {
                              skill.isSelected = value ?? false;
                              if (skill.isSelected) {
                                skill.proficiencyLevel = 'Beginner';
                                skill.isOffering = true;
                              }
                            });
                          },
                          title: Text(
                            skill.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: skill.isSelected
                              ? Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  skill.proficiencyLevel ?? 'Beginner',
                                  style: TextStyle(
                                    color: Colors.grey.shade900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: skill.isOffering
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  skill.isOffering ? 'Offering' : 'Learning',
                                  style: TextStyle(
                                    color: skill.isOffering
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          )
                              : null,
                          secondary: skill.isSelected
                              ? IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () => _showSkillSettings(
                              skill,
                              setModalState,
                            ),
                          )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    await _updateSkills(availableSkills); // Make sure to save these changes
                    Navigator.pop(context);
                  },
                  child: Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSkillSettings(Skill skill, StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Skill Settings'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Proficiency Level',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Beginner', 'Intermediate', 'Advanced']
                    .map((level) => ChoiceChip(
                  label: Text(level),
                  selected: skill.proficiencyLevel == level,
                  selectedColor: Colors.grey.shade900,
                  onSelected: (selected) {
                    if (selected) {
                      setDialogState(() {
                        skill.proficiencyLevel = level;
                      });
                      setModalState(() {});
                    }
                  },
                ))
                    .toList(),
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Offering this skill'),
                subtitle: Text('Turn off if you want to learn this skill instead'),
                value: skill.isOffering,
                activeColor: Colors.grey.shade900,
                onChanged: (value) {
                  setDialogState(() {
                    skill.isOffering = value;
                  });
                  setModalState(() {});
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSkills(List<Skill> updatedSkills) async {
    try {
      final String? userId = await _getCurrentUserId();
      if (userId == null) return;

      // Delete existing skills
      await _supabase
          .from('user_skills')
          .delete()
          .eq('user_id', userId);

      // Iterate through the updated skills
      final selectedSkills = updatedSkills.where((s) => s.isSelected).toList();
      for (var skill in selectedSkills) {
        if (skill.id == null) {
          // Handle custom skills (if no ID, insert into the skills table)
          final newSkillResponse = await _supabase.from('skills').insert({
            'name': skill.name,
            'description': skill.description ?? 'custom skill', // Insert description, fallback to empty string if null
          }).single();

          // Use the ID of the new custom skill from the skills table
          final newSkillId = newSkillResponse['id'];

          // Now insert the custom skill into the user_skills table
          await _supabase.from('user_skills').insert({
            'user_id': userId,
            'skill_id': newSkillId,  // Insert the new skill's ID
            'is_offering': skill.isOffering,
            'proficiency_level': skill.proficiencyLevel,
          });
        } else {
          // For existing skills, just insert them into user_skills
          await _supabase.from('user_skills').insert({
            'user_id': userId,
            'skill_id': skill.id,  // Use the existing skill's ID
            'is_offering': skill.isOffering,
            'proficiency_level': skill.proficiencyLevel,
          });
        }
      }


      setState(() {
        userSkills = List.from(selectedSkills);
      });

      Get.snackbar(
        'Success',
        'Skills updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
      );
    } catch (e) {
      _showError('Failed to update skills');
    }
  }

// ... [Previous code remains the same until build method] ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        final currentUser = authController.user.value;
        if (currentUser == null) {
          return Center(
            child: Text(
              'Not logged in',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }

        return FutureBuilder<dynamic>(
          future: _supabase
              .from('users')
              .select()
              .eq('firebase_uid', currentUser.uid)
              .single(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Text(
                  'No profile data found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green.shade600,
                  ),
                ),
              );
            }

            final userData = Map<String, dynamic>.from(snapshot.data as Map);

            return Column(
              children: [
                // Modern profile header with gradient and shadow
                _buildModernHeader(userData),

                // Main content area with skills
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Stats section showing total skills and member since
                        Card(
                          margin: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem(
                                  'Skills',
                                  userSkills.length.toString(),
                                  Icons.stars,
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),
                                _buildStatItem(
                                  'Member Since',
                                  _formatDate(userData['created_at']?.toString()),
                                  Icons.calendar_today,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Skills section with modern design
                        _buildSkillsSection(),

                        // Sign out button at the bottom
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: ElevatedButton.icon(
                            onPressed: () => _showSignOutConfirmation(),
                            icon: Icon(Icons.logout),
                            label: Text('Sign Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade900,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade900,
              size: 24,
            ),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Format date helper
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  // Show sign out confirmation
  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authController.signOut();
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

