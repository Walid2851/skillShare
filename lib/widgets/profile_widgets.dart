// lib/widgets/profile_widgets.dart

import 'package:flutter/material.dart';
import 'package:skill/models/skills.dart';

class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ProfileInfoTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Widget? prefix;

  const ProfileTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.prefix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  final Skill skill;
  final bool isEditing;
  final VoidCallback? onTap;
  final VoidCallback? onSettingsTap;

  const SkillChip({
    Key? key,
    required this.skill,
    required this.isEditing,
    this.onTap,
    this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEditing ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: skill.isSelected
              ? Colors.green.shade50
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: skill.isSelected
                ? Colors.green.shade300
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (skill.isSelected)
              Icon(
                Icons.check_circle,
                size: 18,
                color: Colors.green,
              ),
            if (skill.isSelected) SizedBox(width: 8),
            Text(
              skill.name,
              style: TextStyle(
                color: skill.isSelected
                    ? Colors.green.shade700
                    : Colors.black87,
                fontWeight: skill.isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            if (skill.isSelected && isEditing) ...[
              SizedBox(width: 4),
              Text(
                skill.proficiencyLevel ?? 'Beginner',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  size: 18,
                  color: Colors.green.shade700,
                ),
                onPressed: onSettingsTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}