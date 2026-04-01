import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/child_account_service.dart';
import '../../models/child_account.dart';
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

  String? _userId;
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
    final userId = await _authService.getCurrentUserId();
    setState(() {
      _userId = userId ?? prefs.getString('user_id');
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

      final hasSession = SupabaseService.isConfigured && _authService.currentUser != null;
      if (hasSession) {
        final userId = _authService.currentUser!.id;
        final fileName = 'avatars/$userId.jpg';
        try {
          await _supabase.client.storage
              .from('church-media')
              .upload(fileName, file, fileOptions: FileOptions(upsert: true));
          final remoteUrl = _supabase.client.storage
              .from('church-media')
              .getPublicUrl(fileName);
          // Update user record with remote URL
          try {
            await _supabase.client
                .from('users')
                .update({'avatar_url': remoteUrl}).eq('id', userId);
          } catch (_) {}
          uploadedUrl = remoteUrl;
        } catch (_) {
          // Storage bucket not configured or policy missing — save locally.
          uploadedUrl = picked.path;
        }
      } else {
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
                        fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.48)),
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
                  // Child accounts section (for non-child users)
                  if (_role != 'child') ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    _ChildAccountsTile(parentUserId: _userId ?? _email ?? 'profile_user', role: _role ?? 'member'),
                    const SizedBox(height: 8),
                  ],
                  const Divider(),
                  const SizedBox(height: 16),
                  // Tip
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.purple, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your profile photo is visible to church members. To update your name or email, contact your administrator.',
                            style: TextStyle(
                                fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
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
                  style: TextStyle(
                      fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
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

/// Expandable tile on the profile screen for managing child accounts.
class _ChildAccountsTile extends StatefulWidget {
  final String parentUserId;
  final String role;
  const _ChildAccountsTile({required this.parentUserId, required this.role});

  @override
  State<_ChildAccountsTile> createState() => _ChildAccountsTileState();
}

class _ChildAccountsTileState extends State<_ChildAccountsTile> {
  final _service = ChildAccountService();
  List<ChildAccount> _accounts = [];
  List<Map<String, dynamic>> _requests = [];
  bool _expanded = false;
  bool _loading = false;

  bool get _isAdmin =>
      widget.role == 'admin' || widget.role == 'pastor';

  Future<void> _load() async {
    setState(() => _loading = true);
    final accounts = _isAdmin
        ? await _service.getAllLocalAccounts()
        : await _service.getAccountsForParent(widget.parentUserId);
    final requests = _isAdmin ? await _service.getPendingRequests() : <Map<String,dynamic>>[];
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _requests = requests;
        _loading = false;
      });
    }
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Child Account'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Child's Name",
                  prefixIcon: Icon(Icons.child_care),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: pinCtrl,
                decoration: const InputDecoration(
                  labelText: '4-digit PIN',
                  prefixIcon: Icon(Icons.lock),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                validator: (v) {
                  if (v == null || v.length != 4) return '4 digits required';
                  if (!RegExp(r'^\d{4}$').hasMatch(v)) return 'Digits only';
                  return null;
                },
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: ageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Age (optional)',
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.childGreen,
                foregroundColor: Colors.white),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              await _service.createAccount(
                parentUserId: widget.parentUserId,
                accountName: nameCtrl.text.trim(),
                pin: pinCtrl.text.trim(),
                ageYears: int.tryParse(ageCtrl.text.trim()) ?? 0,
              );
              _load();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _approveRequest(Map<String, dynamic> req) {
    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Approve ${req['name']}'s Request"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Age: ${req['age_years']}  •  Note: ${req['note'] ?? ''}'),
            const SizedBox(height: 12),
            TextField(
              controller: pinCtrl,
              decoration: const InputDecoration(
                labelText: 'Assign a 4-digit PIN',
                prefixIcon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.childGreen,
                foregroundColor: Colors.white),
            onPressed: () async {
              if (pinCtrl.text.length != 4) return;
              Navigator.pop(ctx);
              await _service.approveRequest(req['id'] as String, pinCtrl.text);
              _load();
            },
            child: const Text('Approve & Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() => _expanded = !_expanded);
            if (_expanded) _load();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.childGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.childGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.child_care,
                    color: AppColors.childGreen, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Child Accounts',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.childGreen)),
                      Text(
                        _isAdmin
                            ? 'Manage all child accounts & approve requests'
                            : "Manage your children's app accounts",
                        style:
                            TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.childGreen,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          if (_loading)
            const Center(
                child: CircularProgressIndicator(color: AppColors.childGreen))
          else ...[
            if (_requests.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Requests (${_requests.length})',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    ..._requests.map((req) => ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          title: Text(req['name'] as String),
                          subtitle: Text(
                              'Age ${req['age_years']}  •  ${req['note'] ?? ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: AppColors.childGreen, size: 22),
                                onPressed: () => _approveRequest(req),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel,
                                    color: Colors.red, size: 22),
                                onPressed: () async {
                                  await _service
                                      .deleteRequest(req['id'] as String);
                                  _load();
                                },
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (_accounts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('No child accounts yet.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
              )
            else
              ..._accounts.map((a) => ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.childGreen.withValues(alpha: 0.2),
                      child: Text(a.accountName[0].toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.childGreen,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(a.accountName),
                    subtitle:
                        a.ageYears > 0 ? Text('Age ${a.ageYears}') : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                      onPressed: () async {
                        await _service.deleteAccount(a.id);
                        _load();
                      },
                    ),
                  )),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Child Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.childGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
