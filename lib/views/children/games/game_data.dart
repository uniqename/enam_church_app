class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}

class GameData {
  /// Returns age-appropriate questions for the given game.
  /// age < 10  → easy questions
  /// age 10-12 → standard questions
  /// age >= 13 → teen/deeper questions
  static List<QuizQuestion> getQuestionsForGame(String gameId, {int age = 10}) {
    switch (gameId) {
      case 'creation':
        return age >= 13 ? _creationTeen : _creationStandard;
      case 'noah':
        return age >= 13 ? _noahTeen : _noahStandard;
      case 'david':
        return age >= 13 ? _davidTeen : _davidStandard;
      case 'jesus':
        return age >= 13 ? _jesusTeen : _jesusStandard;
      case 'moses':
        return age >= 13 ? _mosesTeen : _mosesStandard;
      case 'esther':
        return age >= 13 ? _estherTeen : _estherStandard;
      default:
        return age >= 13 ? _generalTeen : _generalStandard;
    }
  }

  // ──────────────────────────────────────────────────────
  // CREATION
  // ──────────────────────────────────────────────────────
  static const List<QuizQuestion> _creationStandard = [
    QuizQuestion(
      question: 'On what day did God create light?',
      options: ['Day 1', 'Day 2', 'Day 3', 'Day 4'],
      correctIndex: 0,
      explanation: 'God said "Let there be light" on the very first day — Genesis 1:3.',
    ),
    QuizQuestion(
      question: 'What did God create on Day 5?',
      options: ['Land and plants', 'Sun and stars', 'Fish and birds', 'Animals and people'],
      correctIndex: 2,
      explanation: 'Day 5: sea creatures and birds filled the water and sky.',
    ),
    QuizQuestion(
      question: 'On what day did God rest?',
      options: ['Day 5', 'Day 6', 'Day 7', 'Day 8'],
      correctIndex: 2,
      explanation: 'God blessed Day 7 and made it holy — Genesis 2:3.',
    ),
    QuizQuestion(
      question: 'What were the names of the first man and woman?',
      options: ['Moses and Mary', 'Adam and Eve', 'Peter and Paul', 'Abraham and Sarah'],
      correctIndex: 1,
      explanation: 'God created Adam from dust and Eve from Adam\'s rib.',
    ),
    QuizQuestion(
      question: 'What did God use to create Adam?',
      options: ['Water', 'Wood', 'Dust from the ground', 'Stone'],
      correctIndex: 2,
      explanation: '"The Lord formed man from the dust of the ground" — Genesis 2:7.',
    ),
    QuizQuestion(
      question: 'Where did God place Adam and Eve to live?',
      options: ['Mount Sinai', 'Jerusalem', 'The Garden of Eden', 'Canaan'],
      correctIndex: 2,
      explanation: 'God planted a garden in Eden and placed them there to tend it.',
    ),
  ];

  static const List<QuizQuestion> _creationTeen = [
    QuizQuestion(
      question: 'The Hebrew word translated "day" in Genesis 1 is:',
      options: ['Shabbat', 'Yom', 'Bara', 'Ruach'],
      correctIndex: 1,
      explanation: '"Yom" (יוֹם) can mean a 24-hour day, a period, or an era — a point of deep theological debate.',
    ),
    QuizQuestion(
      question: 'What does the Hebrew verb "bara" (used in Genesis 1:1) specifically mean?',
      options: ['To make from existing material', 'To shape with hands', 'To create out of nothing', 'To plant and grow'],
      correctIndex: 2,
      explanation: '"Bara" is only ever used with God as the subject — creation ex nihilo (from nothing).',
    ),
    QuizQuestion(
      question: 'On what day were the sun, moon, and stars created — and why is this theologically striking?',
      options: [
        'Day 1 — light was created before the sun',
        'Day 4 — light existed before the sun, showing God is the source of light',
        'Day 2 — during the separation of waters',
        'Day 6 — alongside humans',
      ],
      correctIndex: 1,
      explanation: 'Light on Day 1, sun on Day 4. God — not the sun — is the ultimate light. The sun is a created object, not a deity (contrast with Egyptian sun worship).',
    ),
    QuizQuestion(
      question: 'The phrase "Let Us make man in Our image" (Genesis 1:26) is often interpreted as referring to:',
      options: [
        'God and the angels',
        'The Trinity — Father, Son, and Holy Spirit',
        'Two gods working together',
        'God talking to himself',
      ],
      correctIndex: 1,
      explanation: 'The plural "Us" is the earliest hint of the Trinity — God, Word (Jesus), and Spirit all present at creation.',
    ),
    QuizQuestion(
      question: 'What was the consequence of eating the forbidden fruit in Genesis 3?',
      options: [
        'Only physical death',
        'Only spiritual separation from God',
        'Both spiritual death (separation from God) and eventual physical death entered the world',
        'Nothing — the serpent lied about consequences',
      ],
      correctIndex: 2,
      explanation: 'Romans 5:12 — "sin entered the world through one man, and death through sin." Both spiritual and physical death resulted.',
    ),
    QuizQuestion(
      question: 'What does the Sabbath rest on Day 7 foreshadow in the New Testament?',
      options: [
        'The church meeting on Sundays',
        'Christ as our Sabbath rest — we rest in His finished work, not our own',
        'Heaven being a place of sleep',
        'Nothing — it was just a physical rest day',
      ],
      correctIndex: 1,
      explanation: 'Hebrews 4:9-11 — the Sabbath rest points to resting in Christ\'s completed work of salvation rather than striving by our own efforts.',
    ),
  ];

  // ──────────────────────────────────────────────────────
  // NOAH
  // ──────────────────────────────────────────────────────
  static const List<QuizQuestion> _noahStandard = [
    QuizQuestion(
      question: 'How many days did it rain during the flood?',
      options: ['7 days', '20 days', '40 days', '100 days'],
      correctIndex: 2,
      explanation: 'It rained 40 days and 40 nights — Genesis 7:12.',
    ),
    QuizQuestion(
      question: 'What sign did God give after the flood as a promise?',
      options: ['A bright star', 'A rainbow', 'A burning bush', 'A white cloud'],
      correctIndex: 1,
      explanation: 'The rainbow is God\'s covenant sign that He will never flood the whole earth again.',
    ),
    QuizQuestion(
      question: 'What was the first bird Noah sent out from the ark?',
      options: ['A dove', 'A sparrow', 'A raven', 'An eagle'],
      correctIndex: 2,
      explanation: 'Noah first sent a raven, then later a dove — Genesis 8:6-8.',
    ),
    QuizQuestion(
      question: 'How many of each "clean" animal did Noah bring onto the ark?',
      options: ['One', 'Two', 'Five', 'Seven pairs'],
      correctIndex: 3,
      explanation: 'Seven pairs (14) of clean animals, two of unclean — Genesis 7:2.',
    ),
    QuizQuestion(
      question: 'How long did the floodwaters stay on the earth?',
      options: ['40 days', '100 days', '150 days', '365 days'],
      correctIndex: 2,
      explanation: 'The waters flooded the earth for 150 days — Genesis 7:24.',
    ),
  ];

  static const List<QuizQuestion> _noahTeen = [
    QuizQuestion(
      question: 'What does Genesis 6:9 mean when it says Noah was "righteous and blameless in his generation"?',
      options: [
        'Noah never sinned at all',
        'Noah was morally upright and walked faithfully with God relative to his corrupt generation',
        'Noah was sinless like Jesus',
        'Noah was the smartest man alive',
      ],
      correctIndex: 1,
      explanation: 'Scripture elsewhere shows Noah\'s flaws (he got drunk in Gen 9:21). "Blameless" describes covenant faithfulness, not sinless perfection.',
    ),
    QuizQuestion(
      question: 'The flood narrative is often compared to the earlier Mesopotamian Epic of Gilgamesh. What is the key theological difference?',
      options: [
        'The Bible\'s flood is longer',
        'In Genesis, a just, moral God judges sin and saves through covenant; in Gilgamesh, capricious gods act randomly',
        'Only the Bible has a boat',
        'There are no similarities at all',
      ],
      correctIndex: 1,
      explanation: 'The Genesis account reveals God\'s character: holy justice against sin, covenant faithfulness, and redemptive grace — unlike the arbitrary gods of pagan myths.',
    ),
    QuizQuestion(
      question: 'What New Testament event does Noah\'s flood foreshadow, according to 1 Peter 3:20-21?',
      options: [
        'The Last Supper',
        'The Transfiguration',
        'Baptism — saved through water as a symbol of death to the old life',
        'The crucifixion',
      ],
      correctIndex: 2,
      explanation: '1 Peter 3:20-21 explicitly connects the ark (saved through water) with baptism as a symbol of salvation through Christ\'s resurrection.',
    ),
    QuizQuestion(
      question: 'How did Jesus use Noah\'s story as a prophetic warning in Matthew 24?',
      options: [
        'To teach about building arks',
        'People will be caught off guard by judgment just as Noah\'s generation was — life will seem normal before sudden judgment',
        'To explain why rainbows exist',
        'To show that only 8 people will be saved at the end',
      ],
      correctIndex: 1,
      explanation: 'Matthew 24:37-39 — Jesus warns that His return will catch people unprepared, just as the flood caught Noah\'s generation in the middle of ordinary life.',
    ),
    QuizQuestion(
      question: 'What does God\'s covenant with Noah (Genesis 9) reveal about God\'s relationship with all humanity?',
      options: [
        'God only cares about Israel',
        'God makes universal covenants — His protection of human life extends to ALL people, not just believers',
        'God no longer controls nature',
        'All covenants require circumcision',
      ],
      correctIndex: 1,
      explanation: 'The Noahic covenant is with "every living creature" (Gen 9:12) — demonstrating God\'s common grace and the sanctity of human life made in His image.',
    ),
  ];

  // ──────────────────────────────────────────────────────
  // DAVID
  // ──────────────────────────────────────────────────────
  static const List<QuizQuestion> _davidStandard = [
    QuizQuestion(
      question: 'Who was David\'s father?',
      options: ['Saul', 'Jesse', 'Samuel', 'Jonathan'],
      correctIndex: 1,
      explanation: 'David was the youngest son of Jesse of Bethlehem.',
    ),
    QuizQuestion(
      question: 'What instrument did David play?',
      options: ['Flute', 'Trumpet', 'Harp/lyre', 'Drum'],
      correctIndex: 2,
      explanation: 'David\'s harp playing soothed King Saul\'s troubled spirit — 1 Samuel 16:23.',
    ),
    QuizQuestion(
      question: 'What giant did David defeat?',
      options: ['Og of Bashan', 'Goliath', 'Samson', 'Anak'],
      correctIndex: 1,
      explanation: 'Goliath was a Philistine warrior over 9 feet tall from Gath.',
    ),
    QuizQuestion(
      question: 'What did David use to defeat Goliath?',
      options: ['A sword', 'A spear', 'A sling and stone', 'An arrow'],
      correctIndex: 2,
      explanation: 'One smooth stone from the brook + a sling + faith in God = victory.',
    ),
    QuizQuestion(
      question: 'Before becoming king, what was David\'s job?',
      options: ['He farmed crops', 'He caught fish', 'He was a shepherd', 'He built houses'],
      correctIndex: 2,
      explanation: 'David was a young shepherd boy caring for his father\'s sheep.',
    ),
  ];

  static const List<QuizQuestion> _davidTeen = [
    QuizQuestion(
      question: 'Why did God reject Saul and choose David? What does 1 Samuel 16:7 reveal?',
      options: [
        'David was taller and stronger than Saul',
        'God looks at the heart, not outward appearance — David had a heart devoted to God',
        'Saul was not from the right tribe',
        'Samuel preferred David personally',
      ],
      correctIndex: 1,
      explanation: '"Man looks at the outward appearance, but the LORD looks at the heart" — 1 Samuel 16:7. David\'s inner devotion to God was the qualification.',
    ),
    QuizQuestion(
      question: 'David\'s victory over Goliath was ultimately a statement about what?',
      options: [
        'Physical strength and bravery',
        'The superiority of slings as weapons',
        'God\'s power over human might — the battle belongs to the Lord, not to chariots or spears',
        'That youth is always better than experience',
      ],
      correctIndex: 2,
      explanation: '1 Samuel 17:47 — "the battle is the Lord\'s." David\'s victory was a theological statement: God fights for His people, not through superior weapons.',
    ),
    QuizQuestion(
      question: 'David committed serious sins (Bathsheba, Uriah\'s death), yet is called "a man after God\'s own heart." Why?',
      options: [
        'Because his sins were smaller than others\'',
        'God only looks at good deeds, not sins',
        'David genuinely repented — Psalm 51 shows his broken, contrite heart before God',
        'God forgot about David\'s sins',
      ],
      correctIndex: 2,
      explanation: 'Psalm 51 reveals David\'s deep repentance. Being "after God\'s heart" doesn\'t mean perfection — it means pursuing God even after failure, and genuine brokenness over sin.',
    ),
    QuizQuestion(
      question: 'What is the "Davidic Covenant" (2 Samuel 7) and why is it important to Christianity?',
      options: [
        'God promised David eternal youth',
        'God promised a descendant of David would rule forever — fulfilled in Jesus as the eternal King',
        'David promised to build a temple',
        'God promised Israel would never be defeated again',
      ],
      correctIndex: 1,
      explanation: '2 Samuel 7:12-16 — God promised David\'s throne would be established forever. This is fulfilled in Jesus (Luke 1:32-33) who is both Son of David and eternal King.',
    ),
    QuizQuestion(
      question: 'Many of David\'s Psalms are laments — honest cries of pain and doubt to God. What does this teach about prayer?',
      options: [
        'We should never be honest with God about pain',
        'Real faith includes bringing raw emotion, doubt, and suffering directly to God — He can handle it',
        'David\'s Psalms were not really prayers',
        'We should only praise God, never complain',
      ],
      correctIndex: 1,
      explanation: 'Psalms 22, 42, 88 show brutal honesty with God. Lament is a biblical form of prayer — it brings suffering to God rather than away from Him, showing trust even in darkness.',
    ),
  ];

  // ──────────────────────────────────────────────────────
  // JESUS
  // ──────────────────────────────────────────────────────
  static const List<QuizQuestion> _jesusStandard = [
    QuizQuestion(
      question: 'Where was Jesus born?',
      options: ['Jerusalem', 'Nazareth', 'Bethlehem', 'Egypt'],
      correctIndex: 2,
      explanation: 'Jesus was born in Bethlehem, fulfilling the prophecy in Micah 5:2.',
    ),
    QuizQuestion(
      question: 'How many disciples did Jesus choose?',
      options: ['7', '10', '12', '14'],
      correctIndex: 2,
      explanation: 'Jesus chose 12 disciples, mirroring the 12 tribes of Israel.',
    ),
    QuizQuestion(
      question: 'What miracle did Jesus perform at a wedding in Cana?',
      options: ['Healed the sick', 'Turned water into wine', 'Fed 5,000 people', 'Walked on water'],
      correctIndex: 1,
      explanation: 'Jesus turned 6 stone jars of water into wine — his first recorded miracle (John 2).',
    ),
    QuizQuestion(
      question: 'How many days was Jesus in the tomb before he rose?',
      options: ['1 day', '2 days', '3 days', '7 days'],
      correctIndex: 2,
      explanation: 'Jesus rose on the third day, just as He predicted — the foundation of the Christian faith.',
    ),
    QuizQuestion(
      question: 'What did Jesus say the greatest commandment is?',
      options: [
        'Do not steal',
        'Honor your parents',
        'Love God with all your heart, and love your neighbor as yourself',
        'Do not lie'
      ],
      correctIndex: 2,
      explanation: 'Matthew 22:37-40 — all the Law and Prophets hang on these two commands.',
    ),
  ];

  static const List<QuizQuestion> _jesusTeen = [
    QuizQuestion(
      question: 'John 1:1 says "the Word was God." What does this mean theologically?',
      options: [
        'Jesus was created by God as a lesser being',
        'Jesus is fully God — eternally existent, not created, sharing the divine nature',
        'The Bible itself is God',
        'Jesus became God at His baptism',
      ],
      correctIndex: 1,
      explanation: '"The Word was God" (not "a god") — Jesus is fully divine, co-equal with the Father, eternally existent before creation (John 1:3 confirms He made everything).',
    ),
    QuizQuestion(
      question: 'When Jesus said "I am the way, the truth, and the life" (John 14:6), what was He claiming?',
      options: [
        'That He is one good path among many',
        'Exclusive access to God — salvation comes only through Him, not through multiple religions or self-improvement',
        'That Christians should travel on roads',
        'That He was a good moral teacher',
      ],
      correctIndex: 1,
      explanation: 'John 14:6 is one of the most exclusive claims in history — Jesus is not merely a guide but THE way. "No one comes to the Father except through Me."',
    ),
    QuizQuestion(
      question: 'What is the significance of the Incarnation — God becoming human in Jesus?',
      options: [
        'It shows God felt bad for humans',
        'Jesus had to become fully human to be our substitute, experiencing our temptations yet without sin — making Him the perfect sacrifice',
        'God wanted to see what human life was like',
        'It was just symbolic',
      ],
      correctIndex: 1,
      explanation: 'Hebrews 4:15 — Jesus was "tempted in every way, just as we are — yet without sin." His humanity makes Him a qualified high priest and sacrifice (Hebrews 2:17).',
    ),
    QuizQuestion(
      question: 'Why does the resurrection of Jesus matter so much — what does Paul say in 1 Corinthians 15?',
      options: [
        'It was just a story to inspire people',
        'If Christ was not raised, our faith is useless and we are still in our sins — the resurrection is essential, not optional',
        'It shows that miracles are possible',
        'It proved Jesus was a good person',
      ],
      correctIndex: 1,
      explanation: '1 Corinthians 15:17-19 — "If Christ has not been raised, your faith is futile." The resurrection is not metaphor — it is the historical cornerstone of Christianity.',
    ),
    QuizQuestion(
      question: 'Jesus referred to Himself as "the Son of Man" frequently. Where does this title originate and what does it mean?',
      options: [
        'It means Jesus was only human, not divine',
        'It comes from Daniel 7 — a divine, eternal figure given all authority and dominion who comes on the clouds; Jesus claimed this cosmic authority',
        'It was just a humble way to speak about himself',
        'It refers to Adam as the first man',
      ],
      correctIndex: 1,
      explanation: 'Daniel 7:13-14 describes the "Son of Man" as receiving eternal dominion from the Ancient of Days. When Jesus used this title (Mark 14:62), the Sanhedrin understood it as a divine claim — and charged Him with blasphemy.',
    ),
  ];

  // ──────────────────────────────────────────────────────
  // MOSES
  // ──────────────────────────────────────────────────────
  static const List<QuizQuestion> _mosesStandard = [
    QuizQuestion(
      question: 'Where was baby Moses hidden to keep him safe?',
      options: ['In a cave', 'In a basket in the river Nile', 'Under a tree', 'In a tent'],
      correctIndex: 1,
      explanation: 'Moses\'s mother put him in a papyrus basket coated with tar and set it in the Nile — Exodus 2:3.',
    ),
    QuizQuestion(
      question: 'What did God use to speak to Moses in the desert?',
      options: ['A cloud', 'A loud thunder', 'A burning bush that did not burn up', 'An angel in a dream'],
      correctIndex: 2,
      explanation: 'The burning bush that was not consumed is one of the most famous theophanies (appearances of God) in the Bible — Exodus 3.',
    ),
    QuizQuestion(
      question: 'How many plagues did God send on Egypt?',
      options: ['5', '7', '10', '12'],
      correctIndex: 2,
      explanation: 'Ten plagues — from blood to the death of the firstborn — forced Pharaoh to release Israel.',
    ),
    QuizQuestion(
      question: 'What did God give Moses on Mount Sinai?',
      options: ['A golden crown', 'The Ten Commandments', 'A map to Canaan', 'A new name'],
      correctIndex: 1,
      explanation: 'The Ten Commandments (the Law) were given on Mount Sinai — the foundation of Israel\'s covenant with God.',
    ),
    QuizQuestion(
      question: 'What did God miraculously provide for Israel to eat in the desert?',
      options: ['Fish and fruit', 'Manna — bread from heaven', 'Milk and honey', 'Roasted lamb every day'],
      correctIndex: 1,
      explanation: 'God sent manna (bread from heaven) every morning and quail for meat — Exodus 16.',
    ),
  ];

  static const List<QuizQuestion> _mosesTeen = [
    QuizQuestion(
      question: 'When God told Moses "I AM WHO I AM" (Exodus 3:14), what did this reveal about God\'s nature?',
      options: [
        'God\'s name was literally "I AM"',
        'God is eternally self-existent — dependent on nothing, always was and always will be; the basis of the name YHWH',
        'God was being evasive',
        'God was saying He was many gods',
      ],
      correctIndex: 1,
      explanation: '"EHYEH ASHER EHYEH" — the divine name YHWH (Yahweh) comes from "to be." God is pure, uncaused existence — He doesn\'t exist; He IS existence itself. Jesus echoed this in John 8:58: "Before Abraham was, I AM."',
    ),
    QuizQuestion(
      question: 'The 10 Plagues specifically targeted Egyptian gods. What was God communicating?',
      options: [
        'God was punishing random things',
        'Each plague was a direct defeat of an Egyptian deity — the Nile (Hapi), frogs (Heqet), sun (Ra) — proving YHWH alone is God',
        'God was just trying to get Pharaoh\'s attention',
        'Moses chose which plagues would come',
      ],
      correctIndex: 1,
      explanation: 'Exodus 12:12 — "I will bring judgment on all the gods of Egypt." The plagues were a systematic theological battle, exposing Egyptian deities as powerless.',
    ),
    QuizQuestion(
      question: 'The Passover lamb\'s blood on the doorposts (Exodus 12) is a "type" — what does it foreshadow?',
      options: [
        'Animal sacrifice was the only way to worship God',
        'The blood of Jesus — the Lamb of God — applied by faith protects us from spiritual death and judgment',
        'Jewish dietary laws',
        'The future destruction of Jerusalem',
      ],
      correctIndex: 1,
      explanation: '1 Corinthians 5:7 — "Christ, our Passover lamb, has been sacrificed." John 1:29 — "The Lamb of God who takes away the sin of the world." The entire Passover event is a picture of the cross.',
    ),
    QuizQuestion(
      question: 'The Golden Calf incident (Exodus 32) happened while Moses was receiving the Law. What does this reveal?',
      options: [
        'Israelites forgot God quickly when leadership was absent',
        'The deep problem of human nature — Israel broke God\'s law before Moses even came down with it; the Law exposes sin but cannot cure it (Romans 3:20)',
        'Aaron was a poor leader',
        'God\'s law was too difficult to follow',
      ],
      correctIndex: 1,
      explanation: 'Romans 3:20 — "Through the law comes knowledge of sin." The golden calf shows the Law\'s diagnostic role: it reveals how corrupt our hearts are, pointing us to the need for grace.',
    ),
    QuizQuestion(
      question: 'Moses is described as a "mediator" between God and Israel. How does this role connect to Jesus?',
      options: [
        'Moses and Jesus had the same role permanently',
        'Moses was the ultimate mediator of the old covenant; Jesus is the superior mediator of the new covenant — His intercession is eternal and perfect',
        'Jesus was a student of Moses',
        'Mediators are no longer needed after Moses',
      ],
      correctIndex: 1,
      explanation: 'Hebrews 9:15 — "Jesus is the mediator of a new covenant." Moses\' mediation was temporary and imperfect. Christ\'s mediation is perfect and eternal (Hebrews 7:25).',
    ),
  ];

  // ──────────────────────────────────────────────────────
  // ESTHER
  // ──────────────────────────────────────────────────────
  static const List<QuizQuestion> _estherStandard = [
    QuizQuestion(
      question: 'What country did Queen Esther live in?',
      options: ['Egypt', 'Israel', 'Persia', 'Babylon'],
      correctIndex: 2,
      explanation: 'The story of Esther takes place in Susa, the capital of the Persian Empire.',
    ),
    QuizQuestion(
      question: 'Who was Esther\'s older cousin and guardian?',
      options: ['Haman', 'Mordecai', 'Xerxes', 'Daniel'],
      correctIndex: 1,
      explanation: 'Mordecai raised Esther after her parents died and was like a father to her.',
    ),
    QuizQuestion(
      question: 'Who made a plan to destroy all the Jewish people in Persia?',
      options: ['King Ahasuerus', 'Haman the Agagite', 'Nebuchadnezzar', 'Goliath'],
      correctIndex: 1,
      explanation: 'Haman hated Mordecai for refusing to bow to him, so he plotted to kill all Jews — Esther 3.',
    ),
    QuizQuestion(
      question: 'What courageous act did Esther do to save her people?',
      options: [
        'She fought soldiers in battle',
        'She ran away and hid the Jews',
        'She approached the king unsummoned — risking death — to expose Haman\'s plot',
        'She burned down Haman\'s house',
      ],
      correctIndex: 2,
      explanation: 'Approaching the king without being called was punishable by death. Esther\'s bravery — "if I perish, I perish" — saved the Jewish people.',
    ),
    QuizQuestion(
      question: 'What Jewish holiday celebrates Esther\'s victory?',
      options: ['Passover', 'Purim', 'Hanukkah', 'Pentecost'],
      correctIndex: 1,
      explanation: 'Purim is celebrated every year in February/March to remember God\'s deliverance through Esther.',
    ),
  ];

  static const List<QuizQuestion> _estherTeen = [
    QuizQuestion(
      question: 'The book of Esther never mentions God directly. What does this suggest about how God works?',
      options: [
        'God was absent from Persia',
        'God works through ordinary people and "coincidences" — His providence is invisible yet real; the whole story is orchestrated without God being named',
        'The book was not inspired by God',
        'God only speaks directly in the Old Testament',
      ],
      correctIndex: 1,
      explanation: 'The hiddenness of God in Esther is intentional — it illustrates divine providence (God working behind the scenes through people and events to accomplish His purposes).',
    ),
    QuizQuestion(
      question: 'Mordecai told Esther: "Who knows if you have not come to the kingdom for such a time as this?" What principle does this teach?',
      options: [
        'Coincidences control history',
        'God places people in specific positions of influence at specific times for His redemptive purposes — purpose in every season',
        'Royalty always has special destiny',
        'Only queens can serve God',
      ],
      correctIndex: 1,
      explanation: 'Esther 4:14 is a key verse on providential calling — God positions His people strategically. Your background, influence, and circumstances may be preparation for divine assignment.',
    ),
    QuizQuestion(
      question: 'Haman\'s downfall came through the very gallows he built for Mordecai. What literary and theological principle does this illustrate?',
      options: [
        'Coincidences often happen',
        'Poetic justice — those who set traps for the righteous often fall into them themselves (Psalm 7:15-16)',
        'Mordecai was physically stronger',
        'Esther was a very smart planner',
      ],
      correctIndex: 1,
      explanation: 'Psalm 7:15-16 — "He who digs a hole and scoops it out falls into the pit he has made." The reversal of Haman\'s plot is a biblical pattern: oppressors are often undone by their own schemes.',
    ),
    QuizQuestion(
      question: 'Esther fasted for 3 days before approaching the king. Why is this detail significant?',
      options: [
        'She was on a diet',
        'Fasting was preparation — aligning herself with God in prayer before acting. It mirrors Jesus\' 40-day fast before His ministry and shows dependence on God, not human strategy',
        'It was a Persian custom',
        'She forgot to eat',
      ],
      correctIndex: 1,
      explanation: 'Fasting in Scripture is spiritual preparation — turning from self-reliance to God-dependence. Esther\'s fasting before her boldest act shows that courage comes from communion with God.',
    ),
    QuizQuestion(
      question: 'In what way is Esther a "type" (foreshadowing) of Christ?',
      options: [
        'She was perfect and sinless',
        'She interceded for her condemned people at personal risk of death, standing in the gap as their representative — echoing Christ\'s intercession for us',
        'She was a queen just like Jesus was a king',
        'There is no connection to Christ in Esther',
      ],
      correctIndex: 1,
      explanation: 'Esther risked her life to plead for a condemned people. Romans 8:34 — "Christ Jesus is at the right hand of God, interceding for us." Both Esther and Christ stand as mediators for those under sentence of death.',
    ),
  ];

  // ──────────────────────────────────────────────────────
  // GENERAL
  // ──────────────────────────────────────────────────────
  static const List<QuizQuestion> _generalStandard = [
    QuizQuestion(
      question: 'How many books are in the Bible?',
      options: ['60', '66', '72', '80'],
      correctIndex: 1,
      explanation: '39 books in the Old Testament + 27 in the New Testament = 66 total.',
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
      explanation: 'Genesis means "beginnings" — it covers creation through the life of Joseph.',
    ),
    QuizQuestion(
      question: 'Who parted the Red Sea?',
      options: ['Abraham', 'David', 'Moses', 'Joshua'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question: 'What is the shortest verse in the Bible?',
      options: ['"Amen."', '"Jesus wept."', '"God is love."', '"Praise God."'],
      correctIndex: 1,
      explanation: '"Jesus wept" (John 11:35) — two words that reveal the deep humanity and compassion of Christ.',
    ),
  ];

  static const List<QuizQuestion> _generalTeen = [
    QuizQuestion(
      question: 'What are the two major divisions of the Bible and what is the theological connection between them?',
      options: [
        'Jewish section and Christian section — they contradict each other',
        'Old Testament and New Testament — the Old is the New concealed; the New is the Old revealed. Both point to Christ',
        'History and poetry sections',
        'They are completely separate and unrelated books',
      ],
      correctIndex: 1,
      explanation: 'Augustine said: "The New Testament is concealed in the Old; the Old Testament is revealed in the New." Jesus said in Luke 24:44 that all of Scripture points to Him.',
    ),
    QuizQuestion(
      question: 'What does "inspiration of Scripture" mean in 2 Timothy 3:16?',
      options: [
        'The Bible is inspiring to read',
        'God breathed out the Scriptures — the human authors wrote exactly what God intended, making it fully authoritative and true',
        'Prophets were in an ecstatic trance when writing',
        'Only Paul\'s letters are inspired',
      ],
      correctIndex: 1,
      explanation: '"All Scripture is God-breathed" (theopneustos). God used human personalities and styles while ensuring the result was exactly what He intended — verbal plenary inspiration.',
    ),
    QuizQuestion(
      question: 'Why is the concept of "grace" central to the entire Bible\'s story?',
      options: [
        'Because humans are basically good and deserve rewards',
        'Because humans are sinful and cannot save themselves — every covenant, sacrifice, and promise points to God\'s unmerited favor ultimately fulfilled in Christ',
        'Grace is only a New Testament concept',
        'God was forced to be gracious',
      ],
      correctIndex: 1,
      explanation: 'From Noah ("found grace in the eyes of the Lord") to Paul ("by grace you have been saved"), grace is the thread of the entire biblical narrative — God\'s undeserved favor to the undeserving.',
    ),
    QuizQuestion(
      question: 'What does the concept of "covenant" mean in the Bible, and why does it matter?',
      options: [
        'A simple business agreement between equals',
        'A binding relationship initiated by God — He commits Himself to His people unconditionally; covenants reveal how God structures His relationship with humanity',
        'A legal contract that can be broken easily',
        'Only the agreement with Abraham matters',
      ],
      correctIndex: 1,
      explanation: 'Covenants (with Noah, Abraham, Moses, David, New Covenant in Christ) are the backbone of Scripture. Each builds on the previous, culminating in the New Covenant (Jeremiah 31:31) — internalized law and forgiveness of sin through Jesus.',
    ),
    QuizQuestion(
      question: 'What is the "metanarrative" (big story) of the Bible in four words?',
      options: [
        'Laws, Prophets, Psalms, Gospels',
        'Creation, Fall, Redemption, Restoration — everything in Scripture fits this storyline',
        'Abraham, Moses, David, Jesus',
        'Sin, punishment, rules, heaven',
      ],
      correctIndex: 1,
      explanation: 'Creation (God makes a good world) → Fall (sin enters, breaking shalom) → Redemption (God rescues through Christ) → Restoration (all things made new in the new creation — Revelation 21-22). This framework unlocks every passage.',
    ),
  ];
}
