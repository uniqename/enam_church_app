import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _supabase = SupabaseService();
  final _picker = ImagePicker();

  String? _name;
  String? _email;
  String? _role;
  String? _department;
  String? _avatarUrl;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final user = await _authService.getCurrentUserProfile();
    setState(() {
      _name = user?.name ?? prefs.getString('user_name') ?? 'Member';
      _email = user?.email ?? prefs.getString('user_email') ?? '';
      _role = user?.role.name ?? prefs.getString('user_role') ?? 'member';
      _department = user?.department ?? prefs.getString('user_department') ?? '';
      _avatarUrl = prefs.getString('user_avatar_url');
      _isLoading = false;
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _isUploading = true);
    try {
      final file = File(picked.path);
      String? uploadedUrl;

      if (SupabaseService.isConfigured) {
        final userId = await _authService.getCurrentUserId();
        if (userId != null) {
          final fileName = 'avatars/$userId.jpg';
          await _supabase.client.storage
              .from('church-media')
              .upload(fileName, file,
                  fileOptions: FileOptions(upsert: true));
          uploadedUrl = _supabase.client.storage
              .from('church-media')
              .getPublicUrl(fileName);

          // Update user record
          await _supabase.client
              .from('users')
              .update({'avatar_url': uploadedUrl}).eq('id', userId);
        }
      } else {
        // Offline: store local path
        uploadedUrl = picked.path;
      }

      if (uploadedUrl != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_avatar_url', uploadedUrl);
        setState(() => _avatarUrl = uploadedUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update Profile Photo',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: AppColors.purple),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadAvatar();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: AppColors.blue),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (picked != null) _pickAndUploadAvatar();
              },
            ),
            if (_avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('user_avatar_url');
                  setState(() => _avatarUrl = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'pastor':
        return 'Pastor';
      case 'admin':
        return 'Administrator';
      case 'departmentHead':
      case 'department_head':
        return 'Department Head';
      case 'child':
        return 'Child Member';
      default:
        return 'Member';
    }
  }

  Color _roleColor(String? role) {
    switch (role) {
      case 'pastor':
        return AppColors.purple;
      case 'admin':
        return AppColors.blue;
      case 'departmentHead':
      case 'department_head':
        return AppColors.accentBlue;
      case 'child':
        return AppColors.childGreen;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _showAvatarOptions,
                          child: _isUploading
                              ? const SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                      color: AppColors.purple),
                                )
                              : CircleAvatar(
                                  radius: 56,
                                  backgroundColor:
                                      AppColors.purple.withValues(alpha: 0.1),
                                  backgroundImage: _avatarUrl != null
                                      ? (_avatarUrl!.startsWith('/')
                                              ? FileImage(File(_avatarUrl!))
                                              : NetworkImage(_avatarUrl!))
                                          as ImageProvider
                                      : null,
                                  child: _avatarUrl == null
                                      ? Text(
                                          (_name?.isNotEmpty == true)
                                              ? _name![0].toUpperCase()
                                              : 'M',
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.purple,
                                          ),
                                        )
                                      : null,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showAvatarOptions,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.purple,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap photo to update',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  // Name
                  Text(
                    _name ?? '',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _roleColor(_role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              _roleColor(_role).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _roleLabel(_role),
                      style: TextStyle(
                          color: _roleColor(_role),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Info cards
                  _InfoTile(
                    icon: Icons.email,
                    label: 'Email',
                    value: _email ?? '',
                  ),
                  if (_department != null && _department!.isNotEmpty)
                    _InfoTile(
                      icon: Icons.group,
                      label: 'Department',
                      value: _department!,
                    ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Tip
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppColors.purple, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your profile photo is visible to church members. To update your name or email, contact your administrator.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.purple, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
