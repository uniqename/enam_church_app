import 'package:flutter/material.dart';
import '../../models/child_account.dart';
import '../../services/auth_service.dart';
import '../../services/child_account_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Child flow
  final _childService = ChildAccountService();
  List<ChildAccount> _childAccounts = [];
  bool _childAccountsLoading = true;
  ChildAccount? _selectedChild;
  String _pin = '';
  static const int _pinLength = 4;
  bool _pinLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadChildAccounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadChildAccounts() async {
    setState(() => _childAccountsLoading = true);
    final accounts = await _childService.getAllLocalAccounts();
    if (mounted) {
      setState(() {
        _childAccounts = accounts;
        _childAccountsLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enter your email above first, then tap Forgot Password.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    try {
      await SupabaseService().client!.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset email sent to $email'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 5),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not send reset email: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 6),
      ));
    }
  }

  void _selectChild(ChildAccount account) {
    setState(() {
      _selectedChild = account;
      _pin = '';
    });
  }

  void _onPinKey(String key) {
    if (key == 'DEL') {
      if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
      return;
    }
    if (_pin.length < _pinLength) {
      setState(() => _pin += key);
      if (_pin.length == _pinLength) {
        Future.delayed(const Duration(milliseconds: 200), _verifyChildPin);
      }
    }
  }

  Future<void> _verifyChildPin() async {
    if (_selectedChild == null || _pin.length < _pinLength) return;
    setState(() => _pinLoading = true);
    try {
      final verified = await _childService.verifyPin(_selectedChild!.id, _pin);
      if (!mounted) return;
      if (verified != null) {
        await _childService.setActiveChildAccount(verified);
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() => _pin = '');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong PIN! Ask your parent or teacher for help.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pinLoading = false);
    }
  }

  void _showAddChildDialog() {
    final nameCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: const Text('Add Child Account',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecor('Child\'s Name', Icons.child_care),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: pinCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecor('4-digit PIN', Icons.lock),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                validator: (v) {
                  if (v == null || v.length != 4) return 'Enter a 4-digit PIN';
                  if (!RegExp(r'^\d{4}$').hasMatch(v)) return 'Digits only';
                  return null;
                },
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: ageCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecor('Age (optional)', Icons.cake),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.childGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              await _childService.createAccount(
                parentUserId: 'manual',
                accountName: nameCtrl.text.trim(),
                pin: pinCtrl.text.trim(),
                ageYears: int.tryParse(ageCtrl.text.trim()) ?? 0,
              );
              _loadChildAccounts();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showRequestDialog() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: const Text('Request a Child Account',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fill in your details and a parent or admin will set up your account.',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecor('Your Name', Icons.person),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: ageCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecor('Your Age', Icons.cake),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your age' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecor('Note to parent/admin (optional)', Icons.note),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              await _childService.submitAccountRequest(
                name: nameCtrl.text.trim(),
                ageYears: int.tryParse(ageCtrl.text.trim()) ?? 0,
                note: noteCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Request sent! A parent or admin will set up your account.'),
                    backgroundColor: AppColors.childGreen,
                  ),
                );
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: AppColors.accentPurple, size: 20),
      filled: true,
      fillColor: AppColors.darkSurface,
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkBorder)),
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentPurple)),
      errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red)),
      focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red)),
      counterStyle: const TextStyle(color: Colors.white38),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentPurple.withValues(alpha: 0.15),
                      boxShadow: AppColors.glowPurple(radius: 20, opacity: 0.3),
                    ),
                    child: const Icon(Icons.church, size: 40, color: AppColors.accentPurple),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Faith Klinik Ministries',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Building faith, healing lives, transforming communities',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.accentPurple,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Tab bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.accentPurple,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 16),
                              SizedBox(width: 6),
                              Text('Adult Login',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.child_care, size: 16),
                              SizedBox(width: 6),
                              Text('Children Login',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAdultLogin(),
                  _buildChildLogin(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdultLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _roleChip('Pastor', Icons.verified, AppColors.accentPurple),
                _roleChip('Admin', Icons.admin_panel_settings, AppColors.accentGold),
                _roleChip('Member', Icons.person, AppColors.accentTeal),
              ],
            ),
            const SizedBox(height: 20),
            _darkField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your email';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _signIn(),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.white54),
                prefixIcon:
                    const Icon(Icons.lock, color: AppColors.accentPurple, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: AppColors.darkSurface,
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.darkBorder)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accentPurple)),
                errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your password';
                if (v.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _forgotPassword,
                child: const Text('Forgot Password?',
                    style: TextStyle(color: AppColors.accentPurple, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Sign In',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? ",
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('Create Account',
                      style: TextStyle(
                          color: AppColors.accentPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.accentPurple.withValues(alpha: 0.25)),
              ),
              child: const Text(
                'Pastors and Admins: create an account and contact church leadership to have your role assigned.',
                style: TextStyle(fontSize: 12, color: AppColors.accentPurple),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildLogin() {
    if (_childAccountsLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.childGreen));
    }

    // If a child account is selected → show PIN entry
    if (_selectedChild != null) {
      return _buildPinEntry();
    }

    // Show account list
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.childGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.child_care, size: 40, color: Colors.white),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Who\'s Logging In?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Tap your name to enter your PIN!',
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_childAccounts.isEmpty)
            _emptyChildCard()
          else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: _childAccounts.length,
              itemBuilder: (_, i) => _childCard(_childAccounts[i], i),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _showAddChildDialog,
              icon: const Icon(Icons.add, color: AppColors.childGreen, size: 18),
              label: const Text('Add Child Account',
                  style: TextStyle(color: AppColors.childGreen, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.childGreen),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _showRequestDialog,
            icon: const Icon(Icons.help_outline,
                color: Colors.white54, size: 16),
            label: const Text('Request an Account',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _emptyChildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.white38, size: 36),
          const SizedBox(height: 12),
          const Text(
            'No child accounts yet.',
            style: TextStyle(
                color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Parents or admins can add an account.\nChildren can also request one below.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddChildDialog,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Child Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.childGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _childCard(ChildAccount account, int index) {
    final colors = [
      AppColors.childGreen,
      AppColors.childBlue,
      AppColors.childPurple,
      AppColors.childOrange,
      AppColors.childPink,
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => _selectChild(account),
      onLongPress: () => _confirmDelete(account),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white24,
              child: Text(
                account.accountName[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              account.accountName,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            if (account.ageYears > 0)
              Text(
                'Age ${account.ageYears}',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinEntry() {
    final account = _selectedChild!;
    final colors = [
      AppColors.childGreen,
      AppColors.childBlue,
      AppColors.childPurple,
      AppColors.childOrange,
      AppColors.childPink,
    ];
    final color =
        colors[_childAccounts.indexOf(account) % colors.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white30,
                  child: Text(
                    account.accountName[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hi, ${account.accountName}!',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter your 4-digit PIN',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pinLength,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length ? color : AppColors.darkSurface2,
                  border: Border.all(
                    color: i < _pin.length ? color : AppColors.darkBorder,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              for (final key in [
                '1', '2', '3',
                '4', '5', '6',
                '7', '8', '9',
                '', '0', 'DEL',
              ])
                key.isEmpty
                    ? const SizedBox()
                    : _pinButton(key, color),
            ],
          ),
          if (_pinLoading)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(color: color),
            ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => setState(() {
              _selectedChild = null;
              _pin = '';
            }),
            icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white54),
            label: const Text('Back to accounts',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _pinButton(String key, Color color) {
    final isDel = key == 'DEL';
    return Material(
      color: isDel
          ? Colors.red.withValues(alpha: 0.15)
          : color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onPinKey(key),
        child: Center(
          child: isDel
              ? const Icon(Icons.backspace, color: Colors.red, size: 22)
              : Text(
                  key,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
        ),
      ),
    );
  }

  Widget _darkField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: AppColors.accentPurple, size: 20),
        filled: true,
        fillColor: AppColors.darkSurface,
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.darkBorder)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.accentPurple)),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red)),
      ),
      validator: validator,
    );
  }

  Widget _roleChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 13, color: color),
      label: Text(label, style: TextStyle(fontSize: 11, color: color)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Future<void> _confirmDelete(ChildAccount account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface2,
        title: const Text('Remove Account',
            style: TextStyle(color: Colors.white)),
        content: Text('Remove ${account.accountName}\'s account?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _childService.deleteAccount(account.id);
      _loadChildAccounts();
    }
  }
}
