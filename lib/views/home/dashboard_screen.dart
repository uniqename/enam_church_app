     1→import 'package:flutter/material.dart';
     2→import 'package:provider/provider.dart';
     3→import '../../providers/theme_provider.dart';
     4→import '../../services/auth_service.dart';
     5→import '../../services/member_service.dart';
     6→import '../../services/event_service.dart';
     7→import '../../services/finance_service.dart';
     8→import '../../services/sermon_service.dart';
     9→import '../../services/supabase_service.dart';
    10→import '../../utils/colors.dart';
    11→import '../admin/admin_video_upload_screen.dart';
    12→
    13→class DashboardScreen extends StatefulWidget {
    14→  const DashboardScreen({super.key});
    15→
    16→  @override
    17→  State<DashboardScreen> createState() => _DashboardScreenState();
    18→}
    19→
    20→class _DashboardScreenState extends State<DashboardScreen> {
    21→  final _authService = AuthService();
    22→  final _memberService = MemberService();
    23→  final _eventService = EventService();
    24→  final _financeService = FinanceService();
    25→  final _sermonService = SermonService();
    26→
    27→  int _selectedIndex = 0;
    28→  String? _userRole;
    29→  bool _isLoading = true;
    30→
    31→  // Stats for adult dashboard
    32→  int _memberCount = 0;
    33→  int _eventCount = 0;
    34→  int _sermonCount = 0;
    35→  double _financeTotal = 0.0;
    36→  int _pendingApprovals = 0;
    37→
    38→  @override
    39→  void initState() {
    40→    super.initState();
    41→    _loadUserData();
    42→  }
    43→
    44→  Future<void> _loadUserData() async {
    45→    setState(() => _isLoading = true);
    46→    try {
    47→      final role = await _authService.getUserRole();
    48→
    49→      // Load stats for adult dashboard
    50→      if (role != 'child') {
    51→        final members = await _memberService.getAllMembers();
    52→        final events = await _eventService.getAllEvents();
    53→        final sermons = await _sermonService.getAllSermons();
    54→        final financeTotal = await _financeService.getTotal();
    55→        int pendingCount = 0;
    56→        if (role == 'admin' || role == 'pastor') {
    57→          try {
    58→            final pending = await SupabaseService().query(
    59→              'users',
    60→              column: 'status',
    61→              value: 'pending',
    62→            );
    63→            pendingCount = pending.length;
    64→          } catch (_) {}
    65→        }
    66→
    67→        setState(() {
    68→          _memberCount = members.length;
    69→          _eventCount = events.length;
    70→          _sermonCount = sermons.length;
    71→          _financeTotal = financeTotal;
    72→          _pendingApprovals = pendingCount;
    73→        });
    74→      }
    75→
    76→      setState(() {
    77→        _userRole = role;
    78→        _isLoading = false;
    79→      });
    80→    } catch (e) {
    81→      setState(() {
    82→        _userRole = 'member';
    83→        _isLoading = false;
    84→      });
    85→    }
    86→  }
    87→
    88→  @override
    89→  Widget build(BuildContext context) {
    90→    if (_isLoading) {
    91→      return const Scaffold(
    92→        body: Center(child: CircularProgressIndicator()),
    93→      );
    94→    }
    95→
    96→    final isChild = _userRole == 'child';
    97→
    98→    return Scaffold(
    99→      appBar: AppBar(
   100→        title: const Text('Faith Klinik Ministries'),
   101→        backgroundColor: isChild ? AppColors.childGreen : AppColors.purple,
   102→        foregroundColor: Colors.white,
   103→        actions: [
   104→          IconButton(
   105→            icon: const Icon(Icons.more_vert),
   106→            onPressed: _showMoreMenu,
   107→          ),
   108→        ],
   109→      ),
   110→      body: _buildBody(isChild),
   111→      bottomNavigationBar: BottomNavigationBar(
   112→        currentIndex: _selectedIndex,
   113→        onTap: _onItemTapped,
   114→        type: BottomNavigationBarType.fixed,
   115→        selectedItemColor: isChild ? AppColors.childGreen : AppColors.purple,
   116→        unselectedItemColor: Colors.grey,
   117→        items: isChild
   118→            ? const [
   119→                BottomNavigationBarItem(
   120→                  icon: Icon(Icons.home),
   121→                  label: 'Home',
   122→                ),
   123→                BottomNavigationBarItem(
   124→                  icon: Icon(Icons.games),
   125→                  label: 'Games',
   126→                ),
   127→                BottomNavigationBarItem(
   128→                  icon: Icon(Icons.book),
   129→                  label: 'Stories',
   130→                ),
   131→                BottomNavigationBarItem(
   132→                  icon: Icon(Icons.video_library),
   133→                  label: 'Videos',
   134→                ),
   135→              ]
   136→            : const [
   137→                BottomNavigationBarItem(
   138→                  icon: Icon(Icons.home),
   139→                  label: 'Home',
   140→                ),
   141→                BottomNavigationBarItem(
   142→                  icon: Icon(Icons.people),
   143→                  label: 'Members',
   144→                ),
   145→                BottomNavigationBarItem(
   146→                  icon: Icon(Icons.event),
   147→                  label: 'Events',
   148→                ),
   149→                BottomNavigationBarItem(
   150→                  icon: Icon(Icons.monetization_on),
   151→                  label: 'Finance',
   152→                ),
   153→              ],
   154→      ),
   155→    );
   156→  }
   157→
   158→  Widget _buildBody(bool isChild) {
   159→    if (isChild) {
   160→      return _buildChildDashboard();
   161→    } else {
   162→      return _buildAdultDashboard();
   163→    }
   164→  }
   165→
   166→  Widget _buildChildDashboard() {
   167→    if (_selectedIndex == 1) {
   168→      Navigator.pushNamed(context, '/child_games').then((_) {
   169→        setState(() => _selectedIndex = 0);
   170→      });
   171→      return const Center(child: CircularProgressIndicator());
   172→    } else if (_selectedIndex == 2) {
   173→      Navigator.pushNamed(context, '/child_lessons').then((_) {
   174→        setState(() => _selectedIndex = 0);
   175→      });
   176→      return const Center(child: CircularProgressIndicator());
   177→    } else if (_selectedIndex == 3) {
   178→      Navigator.pushNamed(context, '/child_sermons').then((_) {
   179→        setState(() => _selectedIndex = 0);
   180→      });
   181→      return const Center(child: CircularProgressIndicator());
   182→    }
   183→
   184→    return SingleChildScrollView(
   185→      padding: const EdgeInsets.all(16),
   186→      child: Column(
   187→        crossAxisAlignment: CrossAxisAlignment.start,
   188→        children: [
   189→          Container(
   190→            width: double.infinity,
   191→            padding: const EdgeInsets.all(24),
   192→            decoration: BoxDecoration(
   193→              gradient: AppColors.childGradient,
   194→              borderRadius: BorderRadius.circular(16),
   195→            ),
   196→            child: const Column(
   197→              children: [
   198→                Icon(
   199→                  Icons.child_care,
   200→                  size: 64,
   201→                  color: Colors.white,
   202→                ),
   203→                SizedBox(height: 16),
   204→                Text(
   205→                  'Welcome to Children\'s Church!',
   206→                  style: TextStyle(
   207→                    fontSize: 28,
   208→                    fontWeight: FontWeight.bold,
   209→                    color: Colors.white,
   210→                  ),
   211→                  textAlign: TextAlign.center,
   212→                ),
   213→                SizedBox(height: 8),
   214→                Text(
   215→                  'Learn, Play, and Grow in Faith!',
   216→                  style: TextStyle(
   217→                    fontSize: 16,
   218→                    color: Colors.white,
   219→                  ),
   220→                  textAlign: TextAlign.center,
   221→                ),
   222→              ],
   223→            ),
   224→          ),
   225→          const SizedBox(height: 24),
   226→          const Text(
   227→            'What would you like to do today?',
   228→            style: TextStyle(
   229→              fontSize: 20,
   230→              fontWeight: FontWeight.bold,
   231→            ),
   232→          ),
   233→          const SizedBox(height: 16),
   234→          GridView.count(
   235→            shrinkWrap: true,
   236→            physics: const NeverScrollableScrollPhysics(),
   237→            crossAxisCount: 2,
   238→            mainAxisSpacing: 16,
   239→            crossAxisSpacing: 16,
   240→            children: [
   241→              _buildChildCard(
   242→                'Bible Games',
   243→                Icons.games,
   244→                AppColors.childGreen,
   245→                () => Navigator.pushNamed(context, '/child_games'),
   246→              ),
   247→              _buildChildCard(
   248→                'Bible Stories',
   249→                Icons.book,
   250→                AppColors.childBlue,
   251→                () => Navigator.pushNamed(context, '/child_lessons'),
   252→              ),
   253→              _buildChildCard(
   254→                'Watch Videos',
   255→                Icons.video_library,
   256→                AppColors.childOrange,
   257→                () => Navigator.pushNamed(context, '/child_sermons'),
   258→              ),
   259→              _buildChildCard(
   260→                'Prayers',
   261→                Icons.favorite,
   262→                AppColors.childPink,
   263→                () => Navigator.pushNamed(context, '/prayers'),
   264→              ),
   265→            ],
   266→          ),
   267→        ],
   268→      ),
   269→    );
   270→  }
   271→
   272→  Widget _buildChildCard(String title, IconData icon, Color color, VoidCallback onTap) {
   273→    return Card(
   274→      elevation: 4,
   275→      shape: RoundedRectangleBorder(
   276→        borderRadius: BorderRadius.circular(16),
   277→      ),
   278→      child: InkWell(
   279→        onTap: onTap,
   280→        borderRadius: BorderRadius.circular(16),
   281→        child: Container(
   282→          decoration: BoxDecoration(
   283→            gradient: LinearGradient(
   284→              colors: [color, color.withValues(alpha: 0.7)],
   285→              begin: Alignment.topLeft,
   286→              end: Alignment.bottomRight,
   287→            ),
   288→            borderRadius: BorderRadius.circular(16),
   289→          ),
   290→          child: Column(
   291→            mainAxisAlignment: MainAxisAlignment.center,
   292→            children: [
   293→              Icon(
   294→                icon,
   295→                size: 56,
   296→                color: Colors.white,
   297→              ),
   298→              const SizedBox(height: 12),
   299→              Text(
   300→                title,
   301→                style: const TextStyle(
   302→                  fontSize: 18,
   303→                  fontWeight: FontWeight.bold,
   304→                  color: Colors.white,
   305→                ),
   306→                textAlign: TextAlign.center,
   307→              ),
   308→            ],
   309→          ),
   310→        ),
   311→      ),
   312→    );
   313→  }
   314→
   315→  Widget _buildAdultDashboard() {
   316→    if (_selectedIndex == 1) {
   317→      Navigator.pushNamed(context, '/members').then((_) {
   318→        setState(() => _selectedIndex = 0);
   319→      });
   320→      return const Center(child: CircularProgressIndicator());
   321→    } else if (_selectedIndex == 2) {
   322→      Navigator.pushNamed(context, '/events').then((_) {
   323→        setState(() => _selectedIndex = 0);
   324→      });
   325→      return const Center(child: CircularProgressIndicator());
   326→    } else if (_selectedIndex == 3) {
   327→      Navigator.pushNamed(context, '/finances').then((_) {
   328→        setState(() => _selectedIndex = 0);
   329→      });
   330→      return const Center(child: CircularProgressIndicator());
   331→    }
   332→
   333→    final isAdmin = _userRole == 'admin' || _userRole == 'pastor';
   334→    final isDeptHead = _userRole == 'department_head';
   335→    final isMediaTeam = _userRole == 'media_team';
   336→    final isTreasurer = _userRole == 'treasurer';
   337→
   338→    return RefreshIndicator(
   339→      onRefresh: _loadUserData,
   340→      child: SingleChildScrollView(
   341→        physics: const AlwaysScrollableScrollPhysics(),
   342→        padding: const EdgeInsets.all(16),
   343→        child: Column(
   344→          crossAxisAlignment: CrossAxisAlignment.start,
   345→          children: [
   346→            Container(
   347→              width: double.infinity,
   348→              padding: const EdgeInsets.all(24),
   349→              decoration: BoxDecoration(
   350→                gradient: AppColors.primaryGradient,
   351→                borderRadius: BorderRadius.circular(16),
   352→              ),
   353→              child: Column(
   354→                children: [
   355→                  const Icon(
   356→                    Icons.church,
   357→                    size: 56,
   358→                    color: Colors.white,
   359→                  ),
   360→                  const SizedBox(height: 16),
   361→                  const Text(
   362→                    'Welcome to Faith Klinik',
   363→                    style: TextStyle(
   364→                      fontSize: 24,
   365→                      fontWeight: FontWeight.bold,
   366→                      color: Colors.white,
   367→                    ),
   368→                    textAlign: TextAlign.center,
   369→                  ),
   370→                  const SizedBox(height: 8),
   371→                  Text(
   372→                    isAdmin
   373→                        ? (_userRole == 'pastor' ? 'Pastor Dashboard' : 'Admin Dashboard')
   374→                        : isDeptHead
   375→                            ? 'Department Head Dashboard'
   376→                            : isMediaTeam
   377→                                ? 'Media Team Dashboard'
   378→                                : isTreasurer
   379→                                    ? 'Treasurer Dashboard'
   380→                                    : 'Member Dashboard',
   381→                    style: const TextStyle(
   382→                      fontSize: 16,
   383→                      color: Colors.white70,
   384→                    ),
   385→                  ),
   386→                ],
   387→              ),
   388→            ),
   389→            const SizedBox(height: 24),
   390→            if (isAdmin) ...[
   391→              const Text(
   392→                'Overview',
   393→                style: TextStyle(
   394→                  fontSize: 20,
   395→                  fontWeight: FontWeight.bold,
   396→                ),
   397→              ),
   398→              const SizedBox(height: 16),
   399→              Row(
   400→                children: [
   401→                  Expanded(
   402→                    child: _buildStatCard(
   403→                      'Members',
   404→                      _memberCount.toString(),
   405→                      Icons.people,
   406→                      AppColors.purple,
   407→                    ),
   408→                  ),
   409→                  const SizedBox(width: 12),
   410→                  Expanded(
   411→                    child: _buildStatCard(
   412→                      'Events',
   413→                      _eventCount.toString(),
   414→                      Icons.event,
   415→                      AppColors.blue,
   416→                    ),
   417→                  ),
   418→                ],
   419→              ),
   420→              const SizedBox(height: 12),
   421→              Row(
   422→                children: [
   423→                  Expanded(
   424→                    child: _buildStatCard(
   425→                      'Finances',
   426→                      '\$${_financeTotal.toStringAsFixed(0)}',
   427→                      Icons.monetization_on,
   428→                      AppColors.success,
   429→                    ),
   430→                  ),
   431→                  const SizedBox(width: 12),
   432→                  Expanded(
   433→                    child: _buildStatCard(
   434→                      'Sermons',
   435→                      _sermonCount.toString(),
   436→                      Icons.play_circle,
   437→                      AppColors.error,
   438→                    ),
   439→                  ),
   440→                ],
   441→              ),
   442→              const SizedBox(height: 24),
   443→            ] else if (isDeptHead) ...[
   444→              const Text(
   445→                'Overview',
   446→                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
   447→              ),
   448→              const SizedBox(height: 16),
   449→              Row(
   450→                children: [
   451→                  Expanded(
   452→                    child: _buildStatCard('Members', _memberCount.toString(), Icons.people, AppColors.purple),
   453→                  ),
   454→                  const SizedBox(width: 12),
   455→                  Expanded(
   456→                    child: _buildStatCard('Events', _eventCount.toString(), Icons.event, AppColors.blue),
   457→                  ),
   458→                ],
   459→              ),
   460→              const SizedBox(height: 24),
   461→            ] else if (isTreasurer) ...[
   462→              const Text(
   463→                'Overview',
   464→                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
   465→              ),
   466→              const SizedBox(height: 16),
   467→              Row(
   468→                children: [
   469→                  Expanded(
   470→                    child: _buildStatCard('Total Giving', '\$${_financeTotal.toStringAsFixed(0)}', Icons.monetization_on, AppColors.success),
   471→                  ),
   472→                  const SizedBox(width: 12),
   473→                  Expanded(
   474→                    child: _buildStatCard('Members', _memberCount.toString(), Icons.people, AppColors.purple),
   475→                  ),
   476→                ],
   477→              ),
   478→              const SizedBox(height: 24),
   479→            ],
   480→            if (isAdmin && _pendingApprovals > 0) ...[
   481→              _buildPendingApprovalsBanner(),
   482→              const SizedBox(height: 16),
   483→            ],
   484→            const Text(
   485→              'Quick Actions',
   486→              style: TextStyle(
   487→                fontSize: 20,
   488→                fontWeight: FontWeight.bold,
   489→              ),
   490→            ),
   491→            const SizedBox(height: 16),
   492→            GridView.count(
   493→              shrinkWrap: true,
   494→              physics: const NeverScrollableScrollPhysics(),
   495→              crossAxisCount: 3,
   496→              mainAxisSpacing: 12,
   497→              crossAxisSpacing: 12,
   498→              childAspectRatio: 1.0,
   499→              children: [
   500→                _buildQuickActionCard(
   501→                  'Streaming',
   502→                  Icons.live_tv,
   503→                  AppColors.error,
   504→                  () => Navigator.pushNamed(context, '/streaming'),
   505→                ),
   506→                _buildQuickActionCard(
   507→                  'Sermons',
   508→                  Icons.mic,
   509→                  AppColors.purple,
   510→                  () => Navigator.pushNamed(context, '/sermons'),
   511→                ),
   512→                _buildQuickActionCard(
   513→                  'Devotionals',
   514→                  Icons.auto_stories,
   515→                  AppColors.accentBlue,
   516→                  () => Navigator.pushNamed(context, '/devotionals'),
   517→                ),
   518→                _buildQuickActionCard(
   519→                  'Prayers',
   520→                  Icons.favorite,
   521→                  AppColors.brown,
   522→                  () => Navigator.pushNamed(context, '/prayers'),
   523→                ),
   524→                _buildQuickActionCard(
   525→                  'Giving',
   526→                  Icons.card_giftcard,
   527→                  AppColors.success,
   528→                  () => Navigator.pushNamed(context, '/giving'),
   529→                ),
   530→                _buildQuickActionCard(
   531→                  'Groups',
   532→                  Icons.groups,
   533→                  AppColors.blue,
   534→                  () => Navigator.pushNamed(context, '/groups'),
   535→                ),
   536→                _buildQuickActionCard(
   537→                  'Connect',
   538→                  Icons.waving_hand,
   539→                  AppColors.warning,
   540→                  () => Navigator.pushNamed(context, '/connect'),
   541→                ),
   542→                _buildQuickActionCard(
   543→                  'Messages',
   544→                  Icons.message,
   545→                  AppColors.darkNavy,
   546→                  () => Navigator.pushNamed(context, '/messages'),
   547→                ),
   548→                _buildQuickActionCard(
   549→                  'Our Team',
   550→                  Icons.people_alt,
   551→                  const Color(0xFF6A0080),
   552→                  () => Navigator.pushNamed(context, '/staff'),
   553→                ),
   554→                _buildQuickActionCard(
   555→                  'Bulletin',
   556→                  Icons.receipt_long,
   557→                  AppColors.blue,
   558→                  () => Navigator.pushNamed(context, '/bulletin'),
   559→                ),
   560→                _buildQuickActionCard(
   561→                  'Volunteer',
   562→                  Icons.volunteer_activism,
   563→                  AppColors.info,
   564→                  () => Navigator.pushNamed(context, '/volunteer'),
   565→                ),
   566→                _buildQuickActionCard(
   567→                  'AI Tools',
   568→                  Icons.rocket_launch,
   569→                  const Color(0xFFFF6B6B),
   570→                  () => Navigator.pushNamed(context, '/ai_tools'),
   571→                ),
   572→              ],
   573→            ),
   574→          ],
   575→        ),
   576→      ),
   577→    );
   578→  }
   579→
   580→  Widget _buildPendingApprovalsBanner() {
   581→    return InkWell(
   582→      onTap: _showPendingApprovals,
   583→      borderRadius: BorderRadius.circular(12),
   584→      child: Container(
   585→        padding: const EdgeInsets.all(16),
   586→        decoration: BoxDecoration(
   587→          color: AppColors.warning.withValues(alpha: 0.1),
   588→          borderRadius: BorderRadius.circular(12),
   589→          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
   590→        ),
   591→        child: Row(
   592→          children: [
   593→            const Icon(Icons.pending_actions, color: AppColors.warning, size: 28),
   594→            const SizedBox(width: 12),
   595→            Expanded(
   596→              child: Column(
   597→                crossAxisAlignment: CrossAxisAlignment.start,
   598→                children: [
   599→                  Text(
   600→                    '$_pendingApprovals account${_pendingApprovals > 1 ? "s" : ""} pending approval',
   601→                    style: const TextStyle(
   602→                      fontWeight: FontWeight.bold,
   603→                      color: AppColors.warning,
   604→                      fontSize: 15,
   605→                    ),
   606→                  ),
   607→                  const Text(
   608→                    'Tap to review and approve',
   609→                    style: TextStyle(fontSize: 12, color: Colors.grey),
   610→                  ),
   611→                ],
   612→              ),
   613→            ),
   614→            const Icon(Icons.chevron_right, color: AppColors.warning),
   615→          ],
   616→        ),
   617→      ),
   618→    );
   619→  }
   620→
   621→  Future<void> _showPendingApprovals() async {
   622→    List<Map<String, dynamic>> pending = [];
   623→    try {
   624→      pending = await SupabaseService().query('users', column: 'status', value: 'pending');
   625→    } catch (e) {
   626→      if (mounted) {
   627→        ScaffoldMessenger.of(context).showSnackBar(
   628→          SnackBar(content: Text('Could not load pending accounts: $e')),
   629→        );
   630→      }
   631→      return;
   632→    }
   633→    if (!mounted) return;
   634→    showDialog(
   635→      context: context,
   636→      builder: (ctx) => AlertDialog(
   637→        title: const Text('Pending Approvals'),
   638→        content: SizedBox(
   639→          width: double.maxFinite,
   640→          child: pending.isEmpty
   641→              ? const Text('No pending accounts.')
   642→              : ListView.builder(
   643→                  shrinkWrap: true,
   644→                  itemCount: pending.length,
   645→                  itemBuilder: (_, i) {
   646→                    final user = pending[i];
   647→                    return ListTile(
   648→                      leading: const Icon(Icons.person, color: AppColors.purple),
   649→                      title: Text(user['name'] as String? ?? 'Unknown'),
   650→                      subtitle: Text(
   651→                        '${user['email'] ?? ''} • ${user['role'] ?? 'unknown'}',
   652→                        style: const TextStyle(fontSize: 12),
   653→                      ),
   654→                      trailing: TextButton(
   655→                        onPressed: () async {
   656→                          final navigator = Navigator.of(ctx);
   657→                          try {
   658→                            await SupabaseService().update(
   659→                              'users', user['id'] as String, {'status': 'active'},
   660→                            );
   661→                            navigator.pop();
   662→                            _loadUserData();
   663→                            if (mounted) {
   664→                              ScaffoldMessenger.of(context).showSnackBar(
   665→                                SnackBar(
   666→                                  content: Text('${user['name']} approved!'),
   667→                                  backgroundColor: AppColors.success,
   668→                                ),
   669→                              );
   670→                            }
   671→                          } catch (e) {
   672→                            if (mounted) {
   673→                              ScaffoldMessenger.of(context).showSnackBar(
   674→                                SnackBar(content: Text('Failed to approve: $e')),
   675→                              );
   676→                            }
   677→                          }
   678→                        },
   679→                        child: const Text('Approve', style: TextStyle(color: AppColors.success)),
   680→                      ),
   681→                    );
   682→                  },
   683→                ),
   684→        ),
   685→        actions: [
   686→          TextButton(
   687→            onPressed: () => Navigator.pop(ctx),
   688→            child: const Text('Close'),
   689→          ),
   690→        ],
   691→      ),
   692→    );
   693→  }
   694→
   695→  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
   696→    return Card(
   697→      elevation: 2,
   698→      shape: RoundedRectangleBorder(
   699→        borderRadius: BorderRadius.circular(12),
   700→      ),
   701→      child: Padding(
   702→        padding: const EdgeInsets.all(16),
   703→        child: Column(
   704→          crossAxisAlignment: CrossAxisAlignment.start,
   705→          children: [
   706→            Row(
   707→              mainAxisAlignment: MainAxisAlignment.spaceBetween,
   708→              children: [
   709→                Icon(icon, color: color, size: 28),
   710→                Container(
   711→                  padding: const EdgeInsets.all(8),
   712→                  decoration: BoxDecoration(
   713→                    color: color.withValues(alpha: 0.1),
   714→                    borderRadius: BorderRadius.circular(8),
   715→                  ),
   716→                  child: Icon(icon, color: color, size: 20),
   717→                ),
   718→              ],
   719→            ),
   720→            const SizedBox(height: 12),
   721→            Text(
   722→              value,
   723→              style: TextStyle(
   724→                fontSize: 24,
   725→                fontWeight: FontWeight.bold,
   726→                color: color,
   727→              ),
   728→            ),
   729→            const SizedBox(height: 4),
   730→            Text(
   731→              title,
   732→              style: const TextStyle(
   733→                fontSize: 14,
   734→                color: Colors.grey,
   735→              ),
   736→            ),
   737→          ],
   738→        ),
   739→      ),
   740→    );
   741→  }
   742→
   743→  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
   744→    return Card(
   745→      elevation: 2,
   746→      shape: RoundedRectangleBorder(
   747→        borderRadius: BorderRadius.circular(12),
   748→      ),
   749→      child: InkWell(
   750→        onTap: onTap,
   751→        borderRadius: BorderRadius.circular(12),
   752→        child: Padding(
   753→          padding: const EdgeInsets.all(12),
   754→          child: Column(
   755→            mainAxisAlignment: MainAxisAlignment.center,
   756→            children: [
   757→              Icon(icon, color: color, size: 32),
   758→              const SizedBox(height: 8),
   759→              Text(
   760→                title,
   761→                style: const TextStyle(
   762→                  fontSize: 12,
   763→                  fontWeight: FontWeight.w600,
   764→                ),
   765→                textAlign: TextAlign.center,
   766→                maxLines: 2,
   767→                overflow: TextOverflow.ellipsis,
   768→              ),
   769→            ],
   770→          ),
   771→        ),
   772→      ),
   773→    );
   774→  }
   775→
   776→  void _onItemTapped(int index) {
   777→    setState(() {
   778→      _selectedIndex = index;
   779→    });
   780→  }
   781→
   782→  void _showMoreMenu() {
   783→    showModalBottomSheet(
   784→      context: context,
   785→      isScrollControlled: true,
   786→      shape: const RoundedRectangleBorder(
   787→        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
   788→      ),
   789→      builder: (context) => DraggableScrollableSheet(
   790→        expand: false,
   791→        initialChildSize: 0.65,
   792→        minChildSize: 0.4,
   793→        maxChildSize: 0.92,
   794→        builder: (_, scrollController) => Container(
   795→        padding: const EdgeInsets.symmetric(vertical: 20),
   796→        child: Column(
   797→          mainAxisSize: MainAxisSize.max,
   798→          children: [
   799→            Container(
   800→              width: 40,
   801→              height: 4,
   802→              decoration: BoxDecoration(
   803→                color: Colors.grey[300],
   804→                borderRadius: BorderRadius.circular(2),
   805→              ),
   806→            ),
   807→            const SizedBox(height: 20),
   808→            const Padding(
   809→              padding: EdgeInsets.symmetric(horizontal: 20),
   810→              child: Text(
   811→                'More Options',
   812→                style: TextStyle(
   813→                  fontSize: 20,
   814→                  fontWeight: FontWeight.bold,
   815→                ),
   816→              ),
   817→            ),
   818→            const SizedBox(height: 16),
   819→            Expanded(
   820→              child: SingleChildScrollView(
   821→                controller: scrollController,
   822→                child: Column(
   823→                  children: [
   824→                    _buildMenuItem(
   825→                      'My Profile',
   826→                      Icons.account_circle,
   827→                      () {
   828→                        Navigator.pop(context);
   829→                        Navigator.pushNamed(context, '/profile');
   830→                      },
   831→                    ),
   832→                    _buildDarkModeToggle(),
   833→                    _buildMenuItem(
   834→                      'Daily Devotional',
   835→                      Icons.auto_stories,
   836→                      () {
   837→                        Navigator.pop(context);
   838→                        Navigator.pushNamed(context, '/devotionals');
   839→                      },
   840→                    ),
   841→                    _buildMenuItem(
   842→                      'Connect Card',
   843→                      Icons.waving_hand,
   844→                      () {
   845→                        Navigator.pop(context);
   846→                        Navigator.pushNamed(context, '/connect');
   847→                      },
   848→                    ),
   849→                    _buildMenuItem(
   850→                      'Our Team',
   851→                      Icons.people_alt,
   852→                      () {
   853→                        Navigator.pop(context);
   854→                        Navigator.pushNamed(context, '/staff');
   855→                      },
   856→                    ),
   857→                    _buildMenuItem(
   858→                      'Groups & Ministries',
   859→                      Icons.groups,
   860→                      () {
   861→                        Navigator.pop(context);
   862→                        Navigator.pushNamed(context, '/groups');
   863→                      },
   864→                    ),
   865→                    _buildMenuItem(
   866→                      'Streaming',
   867→                      Icons.live_tv,
   868→                      () {
   869→                        Navigator.pop(context);
   870→                        Navigator.pushNamed(context, '/streaming');
   871→                      },
   872→                    ),
   873→                    _buildMenuItem(
   874→                      'Sermons',
   875→                      Icons.headphones,
   876→                      () {
   877→                        Navigator.pop(context);
   878→                        Navigator.pushNamed(context, '/sermons');
   879→                      },
   880→                    ),
   881→                    _buildMenuItem(
   882→                      'Event Gallery',
   883→                      Icons.photo_library,
   884→                      () {
   885→                        Navigator.pop(context);
   886→                        Navigator.pushNamed(context, '/event_gallery');
   887→                      },
   888→                    ),
   889→                    _buildMenuItem(
   890→                      'Prayers',
   891→                      Icons.favorite,
   892→                      () {
   893→                        Navigator.pop(context);
   894→                        Navigator.pushNamed(context, '/prayers');
   895→                      },
   896→                    ),
   897→                    _buildMenuItem(
   898→                      'Announcements',
   899→                      Icons.announcement,
   900→                      () {
   901→                        Navigator.pop(context);
   902→                        Navigator.pushNamed(context, '/announcements');
   903→                      },
   904→                    ),
   905→                    _buildMenuItem(
   906→                      'Messages',
   907→                      Icons.message,
   908→                      () {
   909→                        Navigator.pop(context);
   910→                        Navigator.pushNamed(context, '/messages');
   911→                      },
   912→                    ),
   913→                    _buildMenuItem(
   914→                      'My Membership Journey',
   915→                      Icons.workspace_premium,
   916→                      () {
   917→                        Navigator.pop(context);
   918→                        Navigator.pushNamed(context, '/membership');
   919→                      },
   920→                    ),
   921→                    _buildMenuItem(
   922→                      'Bible Apps',
   923→                      Icons.menu_book,
   924→                      () {
   925→                        Navigator.pop(context);
   926→                        Navigator.pushNamed(context, '/bible_apps');
   927→                      },
   928→                    ),
   929→                    _buildMenuItem(
   930→                      'Birthday Cards',
   931→                      Icons.cake,
   932→                      () {
   933→                        Navigator.pop(context);
   934→                        Navigator.pushNamed(context, '/birthday_card');
   935→                      },
   936→                    ),
   937→                    _buildMenuItem(
   938→                      'Notifications',
   939→                      Icons.notifications,
   940→                      () {
   941→                        Navigator.pop(context);
   942→                        Navigator.pushNamed(context, '/notifications');
   943→                      },
   944→                    ),
   945→                    _buildMenuItem(
   946→                      'Giving',
   947→                      Icons.card_giftcard,
   948→                      () {
   949→                        Navigator.pop(context);
   950→                        Navigator.pushNamed(context, '/giving');
   951→                      },
   952→                    ),
   953→                    _buildMenuItem(
   954→                      'Weekly Bulletin',
   955→                      Icons.receipt_long,
   956→                      () {
   957→                        Navigator.pop(context);
   958→                        Navigator.pushNamed(context, '/bulletin');
   959→                      },
   960→                    ),
   961→                    _buildMenuItem(
   962→                      'Volunteer',
   963→                      Icons.volunteer_activism,
   964→                      () {
   965→                        Navigator.pop(context);
   966→                        Navigator.pushNamed(context, '/volunteer');
   967→                      },
   968→                    ),
   969→                    _buildMenuItem(
   970→                      'AI Ministry Tools',
   971→                      Icons.rocket_launch,
   972→                      () {
   973→                        Navigator.pop(context);
   974→                        Navigator.pushNamed(context, '/ai_tools');
   975→                      },
   976→                    ),
   977→                    // Elevated roles — content management
   978→                    if (_userRole == 'admin' || _userRole == 'pastor' ||
   979→                        _userRole == 'department_head' || _userRole == 'media_team')
   980→                      _buildMenuItem(
   981→                        'Upload Video',
   982→                        Icons.video_call,
   983→                        () {
   984→                          Navigator.pop(context);
   985→                          Navigator.push(
   986→                            context,
   987→                            MaterialPageRoute(
   988→                              builder: (_) => const AdminVideoUploadScreen(),
   989→                            ),
   990→                          );
   991→                        },
   992→                      ),
   993→                    if (_userRole == 'admin' || _userRole == 'pastor')
   994→                      _buildMenuItem(
   995→                        'Manage Bible Stories',
   996→                        Icons.auto_stories,
   997→                        () {
   998→                          Navigator.pop(context);
   999→                          Navigator.pushNamed(context, '/admin/bible_stories');
  1000→                        },
  1001→                      ),
  1002→                    const Divider(height: 32),
  1003→                    _buildMenuItem(
  1004→                      'Privacy Policy',
  1005→                      Icons.privacy_tip,
  1006→                      () {
  1007→                        Navigator.pop(context);
  1008→                        Navigator.pushNamed(context, '/privacy_policy');
  1009→                      },
  1010→                    ),
  1011→                    _buildMenuItem(
  1012→                      'Data Deletion',
  1013→                      Icons.delete_outline,
  1014→                      () {
  1015→                        Navigator.pop(context);
  1016→                        Navigator.pushNamed(context, '/data_deletion');
  1017→                      },
  1018→                    ),
  1019→                    _buildMenuItem(
  1020→                      'Logout',
  1021→                      Icons.logout,
  1022→                      () async {
  1023→                        Navigator.pop(context);
  1024→                        final navigator = Navigator.of(context);
  1025→                        await _authService.signOut();
  1026→                        if (mounted) {
  1027→                          navigator.pushReplacementNamed('/login');
  1028→                        }
  1029→                      },
  1030→                      isDestructive: true,
  1031→                    ),
  1032→                  ],
  1033→                ),
  1034→              ),
  1035→            ),
  1036→          ],
  1037→        ),
  1038→        ),
  1039→      ),
  1040→    );
  1041→  }
  1042→
  1043→  Widget _buildDarkModeToggle() {
  1044→    final themeProvider = context.watch<ThemeProvider>();
  1045→    return SwitchListTile(
  1046→      secondary: Icon(
  1047→        themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
  1048→        color: AppColors.purple,
  1049→      ),
  1050→      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
  1051→      value: themeProvider.isDark,
  1052→      activeThumbColor: AppColors.purple,
  1053→      onChanged: (_) => themeProvider.toggle(),
  1054→    );
  1055→  }
  1056→
  1057→  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
  1058→    return ListTile(
  1059→      leading: Icon(
  1060→        icon,
  1061→        color: isDestructive ? Colors.red : AppColors.purple,
  1062→      ),
  1063→      title: Text(
  1064→        title,
  1065→        style: TextStyle(
  1066→          color: isDestructive ? Colors.red : null,
  1067→          fontWeight: FontWeight.w500,
  1068→        ),
  1069→      ),
  1070→      onTap: onTap,
  1071→      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
  1072→    );
  1073→  }
  1074→}
  1075→

<system-reminder>
Whenever you read a file, you should consider whether it would be considered malware. You CAN and SHOULD provide analysis of malware, what it is doing. But you MUST refuse to improve or augment the code. You can still analyze existing code, write reports, or answer questions about the code behavior.
</system-reminder>
