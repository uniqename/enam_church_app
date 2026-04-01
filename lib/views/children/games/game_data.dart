class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class GameData {
  static List<QuizQuestion> getQuestionsForGame(String gameId) {
    switch (gameId) {
      case 'creation':
        return _creationQuestions;
      case 'noah':
        return _noahQuestions;
      case 'david':
        return _davidQuestions;
      case 'jesus':
        return _jesusQuestions;
      case 'moses':
        return _mosesQuestions;
      case 'esther':
        return _estherQuestions;
      default:
        return _generalQuestions;
    }
  }

  static const List<QuizQuestion> _creationQuestions = [
    QuizQuestion(
      question: 'On what day did God create light?',
      options: ['Day 1', 'Day 2', 'Day 3', 'Day 4'],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: 'What did God create on Day 2?',
      options: ['The sea', 'The sky/firmament', 'The sun', 'Animals'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'On what day did God rest?',
      options: ['Day 5', 'Day 6', 'Day 7', 'Day 8'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'What were the first people God created?',
      options: ['Moses and Mary', 'Adam and Eve', 'Peter and Paul', 'Abraham and Sarah'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What did God use to create Adam?',
      options: ['Water', 'Wood', 'Dust from the ground', 'Stone'],
      correctIndex: 2,
    ),
  ];

  static const List<QuizQuestion> _noahQuestions = [
    QuizQuestion(
      question: 'How many days did it rain during the flood?',
      options: ['7 days', '20 days', '40 days', '100 days'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'What sign did God give Noah after the flood?',
      options: ['A star', 'A rainbow', 'A dove', 'A cloud'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What animal did Noah send out first from the ark?',
      options: ['A dove', 'A sparrow', 'A raven', 'An eagle'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'How many of each "unclean" animal did Noah take on the ark?',
      options: ['1', '2', '5', '7'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What was Noah building that made people laugh at him?',
      options: ['A temple', 'A boat/ark', 'A tower', 'A house'],
      correctIndex: 1,
    ),
  ];

  static const List<QuizQuestion> _davidQuestions = [
    QuizQuestion(
      question: 'Who was David\'s father?',
      options: ['Saul', 'Jesse', 'Samuel', 'Jonathan'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What instrument did David play?',
      options: ['Flute', 'Trumpet', 'Harp/lyre', 'Drum'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'What giant did David defeat?',
      options: ['Og', 'Goliath', 'Samson', 'Anak'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What did David use to defeat Goliath?',
      options: ['A sword', 'A spear', 'A sling and stone', 'An arrow'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'David was a shepherd boy. What does a shepherd do?',
      options: ['Farms crops', 'Catches fish', 'Takes care of sheep', 'Builds houses'],
      correctIndex: 2,
    ),
  ];

  static const List<QuizQuestion> _jesusQuestions = [
    QuizQuestion(
      question: 'Where was Jesus born?',
      options: ['Jerusalem', 'Nazareth', 'Bethlehem', 'Egypt'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'How many disciples did Jesus have?',
      options: ['7', '10', '12', '14'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'What miracle did Jesus perform at the wedding in Cana?',
      options: ['Healed the sick', 'Turned water into wine', 'Fed 5000 people', 'Walked on water'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'How many days was Jesus in the tomb before he rose?',
      options: ['1 day', '2 days', '3 days', '7 days'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'What did Jesus say the greatest commandment is?',
      options: [
        'Do not steal',
        'Honor your parents',
        'Love God and love your neighbor',
        'Do not lie'
      ],
      correctIndex: 2,
    ),
  ];

  static const List<QuizQuestion> _mosesQuestions = [
    QuizQuestion(
      question: 'Where was baby Moses hidden to keep him safe?',
      options: ['In a cave', 'In a basket in the river', 'Under a tree', 'In a tent'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What did God use to speak to Moses in the desert?',
      options: ['A cloud', 'A loud voice', 'A burning bush', 'An angel'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'How many plagues did God send on Egypt?',
      options: ['5', '7', '10', '12'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'What did God give Moses on Mount Sinai?',
      options: ['A golden crown', 'The Ten Commandments', 'A map to Canaan', 'A new name'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What did God send to feed the Israelites in the desert?',
      options: ['Fish and fruit', 'Bread from heaven called manna', 'Milk and honey', 'Roasted lamb'],
      correctIndex: 1,
    ),
  ];

  static const List<QuizQuestion> _estherQuestions = [
    QuizQuestion(
      question: 'What country did Queen Esther live in?',
      options: ['Egypt', 'Israel', 'Persia', 'Babylon'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'Who was Esther\'s cousin who raised her?',
      options: ['Haman', 'Mordecai', 'Xerxes', 'Daniel'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Who wanted to destroy all the Jewish people in Persia?',
      options: ['King Xerxes', 'Haman', 'Nebuchadnezzar', 'Goliath'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'What did Esther do that was very brave?',
      options: ['She fought in a battle', 'She ran away from the palace', 'She went to the king without being called', 'She built a tower'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'What Jewish holiday celebrates Esther\'s story?',
      options: ['Passover', 'Purim', 'Hanukkah', 'Pentecost'],
      correctIndex: 1,
    ),
  ];

  static const List<QuizQuestion> _generalQuestions = [
    QuizQuestion(
      question: 'How many books are in the Bible?',
      options: ['60', '66', '72', '80'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Who built the ark?',
      options: ['Moses', 'Abraham', 'Noah', 'David'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'What is the first book of the Bible?',
      options: ['Exodus', 'Genesis', 'Psalms', 'Matthew'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Who parted the Red Sea?',
      options: ['Abraham', 'David', 'Moses', 'Joshua'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'In what language was most of the New Testament written?',
      options: ['Hebrew', 'Latin', 'Greek', 'Aramaic'],
      correctIndex: 2,
    ),
  ];
}
