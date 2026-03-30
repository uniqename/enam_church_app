import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';

class AiToolsScreen extends StatelessWidget {
  const AiToolsScreen({super.key});

  static const _tools = [
    _AiTool(
      name: 'Lovable',
      description: 'Build ministry apps & websites with AI. Create event pages, registration forms, and ministry landing pages — no coding needed.',
      icon: Icons.auto_awesome,
      color: Color(0xFFFF6B6B),
      url: 'https://lovable.dev',
      category: 'App Builder',
    ),
    _AiTool(
      name: 'Manus',
      description: 'AI agent that handles complex tasks autonomously. Great for research, scheduling, and managing ministry operations.',
      icon: Icons.smart_toy,
      color: Color(0xFF4A90D9),
      url: 'https://manus.im',
      category: 'AI Agent',
    ),
    _AiTool(
      name: 'NotebookLM',
      description: 'Google\'s AI research tool. Perfect for sermon prep, Bible study notes, and summarizing ministry documents.',
      icon: Icons.menu_book,
      color: Color(0xFF4CAF50),
      url: 'https://notebooklm.google.com',
      category: 'Research',
    ),
    _AiTool(
      name: 'ChatGPT',
      description: 'AI assistant for writing sermons, drafting announcements, answering questions, and planning ministry content.',
      icon: Icons.chat_bubble_outline,
      color: Color(0xFF10A37F),
      url: 'https://chat.openai.com',
      category: 'AI Assistant',
    ),
    _AiTool(
      name: 'Canva AI',
      description: 'Design church flyers, social media posts, and event graphics using AI-powered design tools.',
      icon: Icons.palette,
      color: Color(0xFF00C4CC),
      url: 'https://www.canva.com',
      category: 'Design',
    ),
    _AiTool(
      name: 'ElevenLabs',
      description: 'AI voice generation for ministry podcasts, audio devotionals, and accessibility features for the hearing-impaired.',
      icon: Icons.record_voice_over,
      color: Color(0xFF9C27B0),
      url: 'https://elevenlabs.io',
      category: 'Audio AI',
    ),
  ];

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Ministry Tools'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.rocket_launch, color: Colors.white, size: 36),
                  SizedBox(height: 12),
                  Text(
                    'AI Tools for Ministry',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Supercharge your ministry work with cutting-edge AI tools. Build, create, research, and automate.',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recommended Tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...(_tools.map((tool) => _buildToolCard(context, tool))),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, _AiTool tool) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        onTap: () => _launch(context, tool.url),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: tool.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tool.icon, color: tool.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tool.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tool.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tool.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: tool.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.open_in_new, size: 14, color: tool.color),
                        const SizedBox(width: 4),
                        Text(
                          'Open ${tool.name}',
                          style: TextStyle(
                            fontSize: 13,
                            color: tool.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiTool {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String url;
  final String category;

  const _AiTool({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.url,
    required this.category,
  });
}
