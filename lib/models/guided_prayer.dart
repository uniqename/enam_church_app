class GuidedPrayer {
  final String id;
  final String title;
  final String category; // e.g. 'Morning', 'Bedtime', 'Gratitude', 'Healing'
  final String emoji;
  final List<GuidedPrayerStep> steps;

  const GuidedPrayer({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.steps,
  });

  static List<GuidedPrayer> get defaults => [
        GuidedPrayer(
          id: 'morning',
          title: 'Good Morning Prayer',
          category: 'Morning',
          emoji: '☀️',
          steps: [
            GuidedPrayerStep(
              instruction: 'Take a deep breath and be still.',
              prompt: 'Dear God, thank You for this brand new day...',
            ),
            GuidedPrayerStep(
              instruction: 'Think of 3 things you are thankful for today.',
              prompt: 'I am thankful for...',
            ),
            GuidedPrayerStep(
              instruction: 'Ask God to guide your day.',
              prompt: 'Please help me to be kind and to follow Your ways today...',
            ),
            GuidedPrayerStep(
              instruction: 'Close with praise.',
              prompt: 'You are amazing God and I love You! In Jesus\' name, Amen.',
            ),
          ],
        ),
        GuidedPrayer(
          id: 'bedtime',
          title: 'Bedtime Prayer',
          category: 'Bedtime',
          emoji: '🌙',
          steps: [
            GuidedPrayerStep(
              instruction: 'Lie down and close your eyes.',
              prompt: 'Dear God, thank You for keeping me safe today...',
            ),
            GuidedPrayerStep(
              instruction: 'Think about something good that happened today.',
              prompt: 'Today I am grateful that...',
            ),
            GuidedPrayerStep(
              instruction: 'Say sorry if you did something wrong today.',
              prompt: 'God please forgive me for...',
            ),
            GuidedPrayerStep(
              instruction: 'Ask God to watch over you while you sleep.',
              prompt: 'Please keep me and my family safe tonight. In Jesus\' name, Amen.',
            ),
          ],
        ),
        GuidedPrayer(
          id: 'gratitude',
          title: 'Thankful Heart Prayer',
          category: 'Gratitude',
          emoji: '🙏',
          steps: [
            GuidedPrayerStep(
              instruction: 'Think about your family and friends.',
              prompt: 'Thank You God for the people who love me...',
            ),
            GuidedPrayerStep(
              instruction: 'Think about food, home, and health.',
              prompt: 'Thank You for giving me everything I need...',
            ),
            GuidedPrayerStep(
              instruction: 'Thank God for His love.',
              prompt: 'Most of all, thank You for loving me so much that You sent Jesus...',
            ),
          ],
        ),
        GuidedPrayer(
          id: 'courage',
          title: 'Prayer for Courage',
          category: 'Courage',
          emoji: '🦁',
          steps: [
            GuidedPrayerStep(
              instruction: 'Think about something that feels scary or hard.',
              prompt: 'God, sometimes I feel afraid when...',
            ),
            GuidedPrayerStep(
              instruction: 'Remember God is always with you.',
              prompt: 'But I know You are always with me, and Your word says "I can do all things through Christ"...',
            ),
            GuidedPrayerStep(
              instruction: 'Ask God for strength.',
              prompt: 'Please give me courage and strength to face today. In Jesus\' name, Amen.',
            ),
          ],
        ),
        GuidedPrayer(
          id: 'others',
          title: 'Prayer for Others',
          category: 'Intercession',
          emoji: '❤️',
          steps: [
            GuidedPrayerStep(
              instruction: 'Think of someone who needs prayer today.',
              prompt: 'God, I want to pray for...',
            ),
            GuidedPrayerStep(
              instruction: 'Ask God to help them.',
              prompt: 'Please help them with... and let them feel Your love...',
            ),
            GuidedPrayerStep(
              instruction: 'Pray for people around the world.',
              prompt: 'God, please also bless children everywhere who need food, safety, and love. Amen.',
            ),
          ],
        ),
      ];
}

class GuidedPrayerStep {
  final String instruction;
  final String prompt;

  const GuidedPrayerStep({
    required this.instruction,
    required this.prompt,
  });
}
