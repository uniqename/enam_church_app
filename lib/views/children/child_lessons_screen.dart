import 'package:flutter/material.dart';
import '../../models/child_lesson.dart';
import '../../services/auth_service.dart';
import '../../services/child_account_service.dart';
import '../../services/child_content_service.dart';
import '../../utils/colors.dart';
import 'lesson_reader_screen.dart';

class ChildLessonsScreen extends StatefulWidget {
  const ChildLessonsScreen({super.key});

  @override
  State<ChildLessonsScreen> createState() => _ChildLessonsScreenState();
}

class _ChildLessonsScreenState extends State<ChildLessonsScreen> {
  final _contentService = ChildContentService();
  final _authService = AuthService();
  List<ChildLesson> _allLessons = [];
  List<ChildLesson> _filteredLessons = [];
  bool _isLoading = true;
  bool _canManage = false;
  int _childAge = 0;
  String _selectedAgeFilter = 'All';

  static const _ageFilters = ['All', '5-8', '9-12', '13+'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final lessons = await _contentService.getAllLessons();
      final role = await _authService.getUserRole();
      final age = await ChildAccountService().getActiveChildAge();
      final canManage = role == 'admin' || role == 'pastor' || role == 'department_head';
      setState(() {
        _allLessons = lessons;
        _canManage = canManage;
        _childAge = age > 0 ? age : 0;
        _isLoading = false;
      });
      _applyFilter(_selectedAgeFilter);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load lessons: $e')),
        );
      }
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedAgeFilter = filter;
      if (filter == 'All') {
        _filteredLessons = _allLessons;
      } else if (filter == '5-8') {
        _filteredLessons = _allLessons.where((l) => _ageInRange(l.ageRange, 5, 8)).toList();
      } else if (filter == '9-12') {
        _filteredLessons = _allLessons.where((l) => _ageInRange(l.ageRange, 9, 12)).toList();
      } else {
        _filteredLessons = _allLessons.where((l) => _ageInRange(l.ageRange, 13, 99)).toList();
      }
    });
  }

  bool _ageInRange(String ageRange, int minAge, int maxAge) {
    // ageRange examples: "5-10", "6-12", "7-12"
    try {
      final parts = ageRange.replaceAll('+', '-99').split('-');
      final low = int.parse(parts[0].trim());
      final high = parts.length > 1 ? int.parse(parts[1].trim()) : low;
      return low <= maxAge && high >= minAge;
    } catch (_) {
      return true;
    }
  }

  void _openLesson(ChildLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonReaderScreen(lesson: lesson)),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Stories'),
        backgroundColor: AppColors.childBlue,
        foregroundColor: Colors.white,
        actions: [
          if (_canManage)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Manage Stories',
              onPressed: () => Navigator.pushNamed(context, '/admin/bible_stories')
                  .then((_) => _loadData()),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Age filter chips
                Container(
                  color: AppColors.childBlue.withValues(alpha: 0.07),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text('Age: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _ageFilters.map((f) {
                              final selected = _selectedAgeFilter == f;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(f),
                                  selected: selected,
                                  onSelected: (_) => _applyFilter(f),
                                  selectedColor: AppColors.childBlue,
                                  labelStyle: TextStyle(
                                    color: selected ? Colors.white : null,
                                    fontWeight: selected ? FontWeight.bold : null,
                                  ),
                                  checkmarkColor: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.childBlue.withValues(alpha: 0.3),
                                AppColors.childPurple.withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.auto_stories, size: 56, color: AppColors.childBlue),
                              const SizedBox(height: 12),
                              Text(
                                _childAge >= 13
                                    ? 'Deep Dive Bible Stories'
                                    : 'Amazing Bible Stories!',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.childBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _childAge >= 13
                                    ? 'Explore Scripture deeply — context, theology, and meaning.'
                                    : "Discover God's love through wonderful stories!",
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _filteredLessons.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 32),
                                  child: Column(
                                    children: [
                                      Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No stories for this age group yet.',
                                        style: TextStyle(color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredLessons.length,
                                itemBuilder: (context, index) {
                                  final lesson = _filteredLessons[index];
                                  return _buildLessonCard(lesson);
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLessonCard(ChildLesson lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: lesson.completed
            ? const BorderSide(color: AppColors.childGreen, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openLesson(lesson),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.childBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_stories, color: AppColors.childBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (lesson.completed)
                    const Icon(Icons.check_circle, color: AppColors.childGreen, size: 22),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                lesson.content.length > 120
                    ? '${lesson.content.substring(0, 120)}...'
                    : lesson.content,
                style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.timer, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(lesson.duration, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  const Icon(Icons.child_care, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Ages ${lesson.ageRange}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openLesson(lesson),
                  icon: Icon(lesson.completed ? Icons.menu_book : Icons.play_arrow, size: 18),
                  label: Text(lesson.completed ? 'Read Again!' : 'Read This Story'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lesson.completed ? AppColors.childGreen : AppColors.childBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
