import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // SharedPreferences keys
  static const _kChurchName      = 'church_name';
  static const _kChurchLocation  = 'church_location';
  static const _kChurchHeaderImg = 'church_header_img';
  static const _kAboutUs         = 'about_us';
  static const _kAboutUsImg      = 'about_us_img';
  static const _kMission         = 'about_mission';
  static const _kMissionImg      = 'about_mission_img';
  static const _kVision          = 'about_vision';
  static const _kVisionImg       = 'about_vision_img';
  static const _kYearTitle       = 'year_theme_title';
  static const _kYearScripture   = 'year_theme_scripture';
  static const _kYearRef         = 'year_theme_ref';
  static const _kYearImg         = 'year_theme_img';
  static const _kSpotlight       = 'home_spotlight';
  static const _kSpotlightImg    = 'home_spotlight_img';
  static const _kFollowUs        = 'follow_us';
  static const _kFollowUsImg     = 'follow_us_img';
  static const _kCalendarUrl     = 'church_calendar_url';

  String _churchName     = 'Faith Klinik Ministries';
  String _churchLocation = 'Columbus, Ohio';
  String _churchHeaderImg = '';
  String _aboutUs        = 'Faith Klinik Ministries is a Spirit-filled, Christ-centered church in Columbus, Ohio. '
                           'We are dedicated to building faith, healing lives, and transforming communities through the power of the Gospel.';
  String _aboutUsImg     = '';
  String _mission        = 'To equip every believer to walk in the fullness of God\'s purpose through prayer, the living Word, and genuine community.';
  String _missionImg     = '';
  String _vision         = 'A church where the broken are healed, the lost are found, and every member walks boldly in their divine calling.';
  String _visionImg      = '';
  String _yearTitle      = '2026 — Year of Maximizing our Strengths';
  String _yearScripture  = '"He gives strength to the weary and increases the power of the weak… those who hope in the Lord will renew their strength. They will soar like eagles…"';
  String _yearRef        = 'Isaiah 40:29-31';
  String _yearImg        = '';
  String _spotlight      = '';
  String _spotlightImg   = '';
  String _followUs       = '';
  String _followUsImg    = '';
  String _calendarUrl    = '';

  AppUser? _user;
  bool _isLoading = true;

  bool get _isAdmin => _user?.role == UserRole.admin || _user?.role == UserRole.pastor;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final user  = await AuthService().getCurrentUserProfile();
    if (!mounted) return;
    setState(() {
      _churchName      = prefs.getString(_kChurchName)      ?? _churchName;
      _churchLocation  = prefs.getString(_kChurchLocation)  ?? _churchLocation;
      _churchHeaderImg = prefs.getString(_kChurchHeaderImg) ?? '';
      _aboutUs         = prefs.getString(_kAboutUs)         ?? _aboutUs;
      _aboutUsImg      = prefs.getString(_kAboutUsImg)      ?? '';
      _mission         = prefs.getString(_kMission)         ?? _mission;
      _missionImg      = prefs.getString(_kMissionImg)      ?? '';
      _vision          = prefs.getString(_kVision)          ?? _vision;
      _visionImg       = prefs.getString(_kVisionImg)       ?? '';
      _yearTitle       = prefs.getString(_kYearTitle)       ?? _yearTitle;
      _yearScripture   = prefs.getString(_kYearScripture)   ?? _yearScripture;
      _yearRef         = prefs.getString(_kYearRef)         ?? _yearRef;
      _yearImg         = prefs.getString(_kYearImg)         ?? '';
      _spotlight       = prefs.getString(_kSpotlight)       ?? '';
      _spotlightImg    = prefs.getString(_kSpotlightImg)    ?? '';
      _followUs        = prefs.getString(_kFollowUs)        ?? '';
      _followUsImg     = prefs.getString(_kFollowUsImg)     ?? '';
      _calendarUrl     = prefs.getString(_kCalendarUrl)     ?? '';
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _pref(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Upload image to Supabase, return public URL
  Future<String?> _uploadImage(File file) async {
    final ext  = file.path.split('.').last.toLowerCase();
    final path = 'about/${const Uuid().v4()}.$ext';
    if (!mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading image…'), duration: Duration(seconds: 60)),
    );
    try {
      final url = await SupabaseService().uploadImage('church-media', path, file);
      if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e'), backgroundColor: Colors.red),
        );
      }
      return null;
    }
  }

  Future<File?> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return null;
    return File(picked.path);
  }

  // Generic edit dialog: text field + optional image upload
  void _editWithImage({
    required String sectionTitle,
    required String currentText,
    required String currentImageUrl,
    required String textKey,
    required String imageKey,
    required void Function(String text, String imgUrl) onSave,
    int maxLines = 4,
    String? textHint,
  }) {
    final ctrl = TextEditingController(text: currentText);
    String localImgUrl = currentImageUrl;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Edit $sectionTitle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: ctrl,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    labelText: 'Text content',
                    hintText: textHint ?? 'Leave blank to show image only',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Image (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                if (localImgUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(localImgUrl, height: 120, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48)),
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Remove image', style: TextStyle(color: Colors.red)),
                    onPressed: () => setS(() => localImgUrl = ''),
                  ),
                ],
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(localImgUrl.isEmpty ? 'Upload Image' : 'Replace Image'),
                  onPressed: () async {
                    Navigator.pop(ctx); // close dialog during upload
                    final file = await _pickImage();
                    if (file == null) {
                      // re-open
                      _editWithImage(
                        sectionTitle: sectionTitle,
                        currentText: ctrl.text,
                        currentImageUrl: localImgUrl,
                        textKey: textKey,
                        imageKey: imageKey,
                        onSave: onSave,
                        maxLines: maxLines,
                        textHint: textHint,
                      );
                      return;
                    }
                    final url = await _uploadImage(file);
                    _editWithImage(
                      sectionTitle: sectionTitle,
                      currentText: ctrl.text,
                      currentImageUrl: url ?? localImgUrl,
                      textKey: textKey,
                      imageKey: imageKey,
                      onSave: onSave,
                      maxLines: maxLines,
                      textHint: textHint,
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                final t = ctrl.text.trim();
                await _pref(textKey, t);
                await _pref(imageKey, localImgUrl);
                onSave(t, localImgUrl);
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editYearTheme() {
    final titleCtrl    = TextEditingController(text: _yearTitle);
    final scriptureCtrl = TextEditingController(text: _yearScripture);
    final refCtrl       = TextEditingController(text: _yearRef);
    String localImgUrl  = _yearImg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Edit Year Theme & Focus'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Theme Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: scriptureCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      labelText: 'Scripture Text', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: refCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Scripture Reference', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Background Image (optional)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                if (localImgUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(localImgUrl, height: 100, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40)),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Remove', style: TextStyle(color: Colors.red)),
                    onPressed: () => setS(() => localImgUrl = ''),
                  ),
                ],
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(localImgUrl.isEmpty ? 'Upload Image' : 'Replace Image'),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final file = await _pickImage();
                    if (file != null) {
                      final url = await _uploadImage(file);
                      if (url != null) localImgUrl = url;
                    }
                    _editYearThemeWith(titleCtrl.text, scriptureCtrl.text, refCtrl.text, localImgUrl);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                final t = titleCtrl.text.trim();
                final s = scriptureCtrl.text.trim();
                final r = refCtrl.text.trim();
                await _pref(_kYearTitle, t);
                await _pref(_kYearScripture, s);
                await _pref(_kYearRef, r);
                await _pref(_kYearImg, localImgUrl);
                if (mounted) {
                  setState(() {
                    _yearTitle = t; _yearScripture = s;
                    _yearRef = r;   _yearImg = localImgUrl;
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editYearThemeWith(String title, String scripture, String ref, String imgUrl) {
    final titleCtrl    = TextEditingController(text: title);
    final scriptureCtrl = TextEditingController(text: scripture);
    final refCtrl       = TextEditingController(text: ref);
    String localImgUrl  = imgUrl;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Edit Year Theme & Focus'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Theme Title', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: scriptureCtrl, maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Scripture Text', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: refCtrl,
                  decoration: const InputDecoration(labelText: 'Scripture Reference', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              const Divider(),
              if (localImgUrl.isNotEmpty) ...[
                ClipRRect(borderRadius: BorderRadius.circular(8),
                    child: Image.network(localImgUrl, height: 100, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Remove', style: TextStyle(color: Colors.red)),
                  onPressed: () => setS(() => localImgUrl = ''),
                ),
              ],
              OutlinedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(localImgUrl.isEmpty ? 'Upload Image' : 'Replace Image'),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final file = await _pickImage();
                  if (file != null) {
                    final url = await _uploadImage(file);
                    if (url != null) localImgUrl = url;
                  }
                  _editYearThemeWith(titleCtrl.text, scriptureCtrl.text, refCtrl.text, localImgUrl);
                },
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                final t = titleCtrl.text.trim(); final s = scriptureCtrl.text.trim(); final r = refCtrl.text.trim();
                await _pref(_kYearTitle, t); await _pref(_kYearScripture, s);
                await _pref(_kYearRef, r);   await _pref(_kYearImg, localImgUrl);
                if (mounted) { setState(() { _yearTitle = t; _yearScripture = s; _yearRef = r; _yearImg = localImgUrl; }); Navigator.pop(ctx); }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editHeader() {
    final nameCtrl = TextEditingController(text: _churchName);
    final locCtrl  = TextEditingController(text: _churchLocation);
    String localImg = _churchHeaderImg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Edit Church Info'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Church Name', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: locCtrl,
                  decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              const Divider(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Header Background Image (optional)', style: TextStyle(fontWeight: FontWeight.w600))),
              if (localImg.isNotEmpty) ...[
                ClipRRect(borderRadius: BorderRadius.circular(8),
                    child: Image.network(localImg, height: 80, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Remove', style: TextStyle(color: Colors.red)),
                  onPressed: () => setS(() => localImg = ''),
                ),
              ],
              OutlinedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(localImg.isEmpty ? 'Upload Image' : 'Replace'),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final file = await _pickImage();
                  if (file != null) { final url = await _uploadImage(file); if (url != null) localImg = url; }
                  _editHeaderWith(nameCtrl.text, locCtrl.text, localImg);
                },
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                final n = nameCtrl.text.trim(); final l = locCtrl.text.trim();
                await _pref(_kChurchName, n); await _pref(_kChurchLocation, l); await _pref(_kChurchHeaderImg, localImg);
                if (mounted) { setState(() { _churchName = n; _churchLocation = l; _churchHeaderImg = localImg; }); Navigator.pop(ctx); }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editHeaderWith(String name, String loc, String img) {
    final nameCtrl = TextEditingController(text: name);
    final locCtrl  = TextEditingController(text: loc);
    String localImg = img;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Edit Church Info'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Church Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            if (localImg.isNotEmpty) ...[
              ClipRRect(borderRadius: BorderRadius.circular(8),
                  child: Image.network(localImg, height: 70, fit: BoxFit.cover)),
              TextButton.icon(icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Remove', style: TextStyle(color: Colors.red)),
                  onPressed: () => setS(() => localImg = '')),
            ],
            OutlinedButton.icon(icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(localImg.isEmpty ? 'Upload Image' : 'Replace'),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final file = await _pickImage();
                  if (file != null) { final url = await _uploadImage(file); if (url != null) localImg = url; }
                  _editHeaderWith(nameCtrl.text, locCtrl.text, localImg);
                }),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                final n = nameCtrl.text.trim(); final l = locCtrl.text.trim();
                await _pref(_kChurchName, n); await _pref(_kChurchLocation, l); await _pref(_kChurchHeaderImg, localImg);
                if (mounted) { setState(() { _churchName = n; _churchLocation = l; _churchHeaderImg = localImg; }); Navigator.pop(ctx); }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadCalendar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading calendar…'), duration: Duration(seconds: 60)));
    try {
      final url = await SupabaseService().uploadImage('church-media', 'calendar/church_calendar.pdf', file, contentType: 'application/pdf');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (url != null) {
        await _pref(_kCalendarUrl, url);
        if (mounted) {
          setState(() => _calendarUrl = url);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Calendar uploaded — visible to all members'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('About Faith Klinik'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.info_outline, iconColor: AppColors.purple,
                  title: 'About Us', body: _aboutUs, imageUrl: _aboutUsImg,
                  onEdit: _isAdmin ? () => _editWithImage(
                    sectionTitle: 'About Us', currentText: _aboutUs, currentImageUrl: _aboutUsImg,
                    textKey: _kAboutUs, imageKey: _kAboutUsImg,
                    onSave: (t, i) => setState(() { _aboutUs = t; _aboutUsImg = i; }),
                  ) : null,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.flag_outlined, iconColor: AppColors.success,
                  title: 'Our Mission', body: _mission, imageUrl: _missionImg,
                  onEdit: _isAdmin ? () => _editWithImage(
                    sectionTitle: 'Our Mission', currentText: _mission, currentImageUrl: _missionImg,
                    textKey: _kMission, imageKey: _kMissionImg,
                    onSave: (t, i) => setState(() { _mission = t; _missionImg = i; }),
                  ) : null,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.visibility_outlined, iconColor: AppColors.blue,
                  title: 'Our Vision', body: _vision, imageUrl: _visionImg,
                  onEdit: _isAdmin ? () => _editWithImage(
                    sectionTitle: 'Our Vision', currentText: _vision, currentImageUrl: _visionImg,
                    textKey: _kVision, imageKey: _kVisionImg,
                    onSave: (t, i) => setState(() { _vision = t; _visionImg = i; }),
                  ) : null,
                ),
                const SizedBox(height: 12),
                _buildYearThemeCard(),
                const SizedBox(height: 12),
                _buildSpotlightCard(),
                const SizedBox(height: 12),
                _buildFollowUsCard(),
                const SizedBox(height: 12),
                _buildCalendarCard(),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    final hasImg = _churchHeaderImg.isNotEmpty;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: hasImg ? null : const LinearGradient(
                colors: [Color(0xFF4A0080), Color(0xFF1A3A6B)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: hasImg
                ? Stack(children: [
                    Image.network(_churchHeaderImg, width: double.infinity, height: 160, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(height: 160, color: AppColors.purple)),
                    Container(height: 160, decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                            begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                  ])
                : const SizedBox(height: 0),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: hasImg ? 20 : 32, horizontal: 24),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            if (!hasImg) const Icon(Icons.church, size: 52, color: Colors.white),
            if (!hasImg) const SizedBox(height: 12),
            Text(_churchName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(_churchLocation, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ]),
        ),
        if (_isAdmin)
          Positioned(
            top: 10, right: 10,
            child: GestureDetector(
              onTap: _editHeader,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required String imageUrl,
    VoidCallback? onEdit,
  }) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: iconColor, fontSize: 15)),
              const Spacer(),
              if (onEdit != null)
                GestureDetector(onTap: onEdit,
                    child: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey)),
            ]),
          ),
          if (imageUrl.isNotEmpty)
            Image.network(imageUrl, width: double.infinity, height: 160, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          if (body.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(body, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
            )
          else if (imageUrl.isEmpty)
            const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text('Tap edit to add content.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13))),
          if (body.isEmpty && imageUrl.isNotEmpty) const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildYearThemeCard() {
    final hasImg = _yearImg.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        gradient: hasImg ? null : const LinearGradient(
          colors: [Color(0xFF4A0080), Color(0xFF9B2290)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        color: hasImg ? const Color(0xFF1E1E2E) : null,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (hasImg)
          Stack(children: [
            Image.network(_yearImg, width: double.infinity, height: 140, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            Container(height: 140, decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter))),
          ]),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text('Year Theme & Focus',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
              const Spacer(),
              if (_isAdmin)
                GestureDetector(onTap: _editYearTheme,
                    child: const Icon(Icons.edit_outlined, size: 18, color: Colors.white70)),
            ]),
            const SizedBox(height: 14),
            Text(_yearTitle,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.3)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_yearScripture,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic, height: 1.6)),
                if (_yearRef.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(_yearRef, style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSpotlightCard() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.amber.shade800, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.star, color: Colors.white, size: 16)),
            const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Home Screen Spotlight',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 14)),
              Text('Shows as a featured strip on the home screen',
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
            ])),
            if (_isAdmin)
              GestureDetector(
                onTap: () => _editWithImage(
                  sectionTitle: 'Home Screen Spotlight',
                  currentText: _spotlight, currentImageUrl: _spotlightImg,
                  textKey: _kSpotlight, imageKey: _kSpotlightImg,
                  maxLines: 2,
                  textHint: 'e.g. "Mission Focus: India 🇮🇳" or "Evangelism Sunday — July 13"',
                  onSave: (t, i) => setState(() { _spotlight = t; _spotlightImg = i; }),
                ),
                child: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
              ),
          ]),
        ),
        if (_spotlightImg.isNotEmpty)
          Image.network(_spotlightImg, width: double.infinity, height: 140, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Text(
            _spotlight.isEmpty ? 'No spotlight set. Tap edit to add one.' : _spotlight,
            style: TextStyle(
                color: _spotlight.isEmpty ? Colors.grey : Colors.white70, fontSize: 13,
                fontStyle: _spotlight.isEmpty ? FontStyle.italic : FontStyle.normal),
          ),
        ),
      ]),
    );
  }

  Widget _buildFollowUsCard() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.share, color: AppColors.blue, size: 16)),
            const SizedBox(width: 10),
            const Text('Follow Us', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue, fontSize: 14)),
            const Spacer(),
            if (_isAdmin)
              GestureDetector(
                onTap: () => _editWithImage(
                  sectionTitle: 'Follow Us',
                  currentText: _followUs, currentImageUrl: _followUsImg,
                  textKey: _kFollowUs, imageKey: _kFollowUsImg,
                  maxLines: 5, textHint: 'Add social media links, one per line',
                  onSave: (t, i) => setState(() { _followUs = t; _followUsImg = i; }),
                ),
                child: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
              ),
          ]),
        ),
        if (_followUsImg.isNotEmpty)
          Image.network(_followUsImg, width: double.infinity, height: 140, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: _followUs.isEmpty
              ? const Text('Tap edit to add your social media links.',
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic))
              : Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: _followUs.split('\n').where((l) => l.trim().isNotEmpty).map((line) =>
                    Padding(padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () { final u = line.trim(); if (u.startsWith('http')) launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication); },
                        child: Text(line.trim(), style: TextStyle(
                            color: line.trim().startsWith('http') ? AppColors.blue : Colors.white70,
                            fontSize: 13,
                            decoration: line.trim().startsWith('http') ? TextDecoration.underline : null)),
                      ),
                    ),
                  ).toList()),
        ),
      ]),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.calendar_month, color: AppColors.success, size: 16)),
          const SizedBox(width: 10),
          const Text('Church Calendar', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 14)),
          const Spacer(),
          if (_isAdmin)
            GestureDetector(onTap: _uploadCalendar,
                child: const Icon(Icons.upload_file, size: 20, color: Colors.grey)),
        ]),
        const SizedBox(height: 12),
        Text(_calendarUrl.isEmpty ? 'No calendar uploaded yet.' : 'Calendar PDF available for all members.',
            style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: _calendarUrl.isEmpty ? FontStyle.italic : FontStyle.normal)),
        if (_calendarUrl.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('View Church Calendar'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.success, side: const BorderSide(color: AppColors.success)),
              onPressed: () => launchUrl(Uri.parse(_calendarUrl), mode: LaunchMode.externalApplication),
            ),
          ),
        ],
        if (_isAdmin) ...[
          const SizedBox(height: 8),
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Upload / Update Calendar PDF'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              onPressed: _uploadCalendar,
            ),
          ),
        ],
      ]),
    );
  }
}
