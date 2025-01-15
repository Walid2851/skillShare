// lib/models/skill.dart

class Skill {
  final int id;
  final String name;
  final String? description;
  bool isSelected;
  String? proficiencyLevel;
  bool isOffering;

  Skill({
    required this.id,
    required this.name,
    this.description,
    this.isSelected = false,
    this.proficiencyLevel = 'Beginner',
    this.isOffering = true,
  });

  // Create a Skill from JSON data
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['skill_id'],
      name: json['name'],
      description: json['description'],
    );
  }

  // Convert Skill to JSON
  Map<String, dynamic> toJson() {
    return {
      'skill_id': id,
      'name': name,
      'description': description,
      'proficiency_level': proficiencyLevel,
      'is_offering': isOffering,
    };
  }
}