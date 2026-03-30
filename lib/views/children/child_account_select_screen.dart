import 'package:flutter/material.dart';
import '../../models/child_account.dart';
import '../../services/child_account_service.dart';
import '../../utils/colors.dart';

/// Shown when entering the Children's Login tab.
/// Lists all child accounts linked to the current parent session,
/// plus a demo/default account, and lets a child tap to enter their PIN.
class ChildAccountSelectScreen extends StatefulWidget {
  final String parentUserId;
  final VoidCallback? onBack;

  const ChildAccountSelectScreen({
    super.key,
    required this.parentUserId,
    this.onBack,
  });

  @override
  State<ChildAccountSelectScreen> createState() =>
      _ChildAccountSelectScreenState();
}

class _ChildAccountSelectScreenState extends State<ChildAccountSelectScreen> {
  final _service = ChildAccountService();
  List<ChildAccount> _accounts = [];
  bool _isLoading = true;
  ChildAccount? _selectedAccount;
  String _pin = '';
  static const int _pinLength = 4;
  bool _isPinLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    final accounts =
        await _service.getAccountsForParent(widget.parentUserId);
    setState(() {
      _accounts = accounts;
      _isLoading = false;
    });
  }

  void _selectAccount(ChildAccount account) {
    setState(() {
      _selectedAccount = account;
      _pin = '';
    });
  }

  Future<void> _verifyPin() async {
    if (_pin.length < _pinLength || _selectedAccount == null) return;
    setState(() => _isPinLoading = true);
    try {
      final verified =
          await _service.verifyPin(_selectedAccount!.id, _pin);
      if (!mounted) return;
      if (verified != null) {
        await _service.setActiveChildAccount(verified);
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
      if (mounted) setState(() => _isPinLoading = false);
    }
  }

  void _onPinKey(String key) {
    if (key == 'DEL') {
      if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
      return;
    }
    if (_pin.length < _pinLength) {
      setState(() => _pin += key);
      if (_pin.length == _pinLength) {
        Future.delayed(const Duration(milliseconds: 200), _verifyPin);
      }
    }
  }

  Future<void> _showAddAccountDialog() async {
    final nameCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
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
                  labelText: 'Child\'s Name',
                  prefixIcon: Icon(Icons.child_care),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
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
                  if (v == null || v.length != 4) return 'Enter a 4-digit PIN';
                  if (!RegExp(r'^\d{4}$').hasMatch(v)) return 'Digits only';
                  return null;
                },
              ),
              const SizedBox(height: 12),
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
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              try {
                await _service.createAccount(
                  parentUserId: widget.parentUserId,
                  accountName: nameCtrl.text.trim(),
                  pin: pinCtrl.text.trim(),
                  ageYears: int.tryParse(ageCtrl.text.trim()) ?? 0,
                );
                _loadAccounts();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add account: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(ChildAccount account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Account'),
        content: Text('Remove ${account.accountName}\'s account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
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
      await _service.deleteAccount(account.id);
      _loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.childGreen));
    }

    if (_selectedAccount != null) {
      return _buildPinEntry();
    }

    return _buildAccountList();
  }

  Widget _buildAccountList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.childGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.child_care, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Who\'s Reading Today?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap your name to log in!',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_accounts.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.childGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.childGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.childGreen, size: 36),
                  const SizedBox(height: 12),
                  const Text(
                    'No child accounts yet.\nParents can add accounts using the button below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddAccountDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Child Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.childGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: _accounts.length,
              itemBuilder: (_, i) => _buildAccountCard(_accounts[i]),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _showAddAccountDialog,
              icon: const Icon(Icons.add, color: AppColors.childGreen),
              label: const Text(
                'Add Another Child',
                style: TextStyle(color: AppColors.childGreen),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.childGreen),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountCard(ChildAccount account) {
    final colors = [
      AppColors.childGreen,
      AppColors.childBlue,
      AppColors.childPurple,
      AppColors.childOrange,
      AppColors.childPink,
    ];
    final color = colors[_accounts.indexOf(account) % colors.length];

    return GestureDetector(
      onLongPress: () => _deleteAccount(account),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _selectAccount(account),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                account.avatarUrl != null && account.avatarUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 36,
                        backgroundImage:
                            NetworkImage(account.avatarUrl!),
                        backgroundColor: Colors.white24,
                      )
                    : CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white24,
                        child: Text(
                          account.accountName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                const SizedBox(height: 12),
                Text(
                  account.accountName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (account.ageYears > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Age ${account.ageYears}',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinEntry() {
    final account = _selectedAccount!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.childGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                account.avatarUrl != null && account.avatarUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(account.avatarUrl!),
                      )
                    : CircleAvatar(
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
                    color: Colors.white,
                  ),
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
                  color: i < _pin.length
                      ? AppColors.childGreen
                      : Colors.grey.shade300,
                  border: Border.all(
                    color: i < _pin.length
                        ? AppColors.childGreen
                        : Colors.grey.shade400,
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
                    : _buildPinButton(key),
            ],
          ),
          if (_isPinLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(color: AppColors.childGreen),
            ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => setState(() {
              _selectedAccount = null;
              _pin = '';
            }),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to accounts'),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.childGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildPinButton(String key) {
    final isDel = key == 'DEL';
    return Material(
      color: isDel
          ? Colors.red.shade50
          : AppColors.childGreen.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onPinKey(key),
        child: Center(
          child: isDel
              ? const Icon(Icons.backspace, color: Colors.red, size: 22)
              : Text(
                  key,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.childGreen,
                  ),
                ),
        ),
      ),
    );
  }
}
