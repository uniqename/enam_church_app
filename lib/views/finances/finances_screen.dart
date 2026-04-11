import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/finance.dart';
import '../../services/finance_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  final _financeService = FinanceService();
  final _authService = AuthService();
  List<Finance> _finances = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String _currentUserName = '';
  double _totalTithes = 0.0;
  double _totalOfferings = 0.0;
  double _totalSpecial = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userRole = await _authService.getUserRole();
      final userName = await _authService.getCurrentUserName();
      final finances = await _financeService.getAllFinances();
      final tithes = await _financeService.getTotalByType('Tithe');
      final offerings = await _financeService.getTotalByType('Offering');
      final special = await _financeService.getTotalByType('Special Gift');

      setState(() {
        _isAdmin = (userRole == 'admin' || userRole == 'pastor');
        _currentUserName = userName ?? '';
        _finances = finances;
        _totalTithes = tithes;
        _totalOfferings = offerings;
        _totalSpecial = special;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load finances: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        _buildFinanceCard(
                          'Tithes',
                          _totalTithes,
                          AppColors.success,
                        ),
                        _buildFinanceCard(
                          'Offerings',
                          _totalOfferings,
                          AppColors.info,
                        ),
                        _buildFinanceCard(
                          'Special',
                          _totalSpecial,
                          AppColors.brown,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (_isAdmin)
                          Text(
                            'Tap to edit',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _finances.isEmpty
                        ? const Center(child: Text('No transactions yet'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _finances.length,
                            itemBuilder: (context, index) {
                              final finance = _finances[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppColors.success.withValues(alpha: 0.2),
                                    child: const Icon(
                                      Icons.attach_money,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  title: Text(finance.type),
                                  subtitle: Text(
                                    '${finance.memberName} • ${finance.method}\n${DateFormat('MMM d, yyyy').format(finance.date)}',
                                  ),
                                  isThreeLine: true,
                                  trailing: Text(
                                    '\$${finance.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  onTap: _isAdmin
                                      ? () => _showEditFinanceDialog(finance)
                                      : null,
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showAddFinanceDialog,
              backgroundColor: AppColors.success,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildFinanceCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFinanceDialog() {
    final amountController = TextEditingController();
    final memberNameController = TextEditingController(text: _currentUserName);
    String selectedType = 'Tithe';
    String selectedMethod = 'Cash';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Finance Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Tithe', 'Offering', 'Special Gift', 'Donation', 'Other']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v ?? 'Tithe'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: memberNameController,
                  decoration: const InputDecoration(
                    labelText: 'Member Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'Method',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Cash', 'Card', 'Bank Transfer', 'Mobile Money', 'Check']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedMethod = v ?? 'Cash'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Date: ${DateFormat('MMM d, yyyy').format(selectedDate)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
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
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }
                if (memberNameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please enter member name')),
                  );
                  return;
                }
                final newFinance = Finance(
                  id: '',
                  type: selectedType,
                  amount: amount,
                  memberName: memberNameController.text.trim(),
                  date: selectedDate,
                  method: selectedMethod,
                  status: 'Completed',
                );
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _financeService.addFinance(newFinance);
                  navigator.pop();
                  _loadData();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Finance record added'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to add record: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFinanceDialog(Finance finance) {
    final amountController =
        TextEditingController(text: finance.amount.toStringAsFixed(2));
    final memberNameController = TextEditingController(text: finance.memberName);
    String selectedType = finance.type;
    String selectedMethod = finance.method;
    DateTime selectedDate = finance.date;

    // Normalize type/method to valid dropdown values
    const validTypes = ['Tithe', 'Offering', 'Special Gift', 'Donation', 'Other'];
    const validMethods = ['Cash', 'Card', 'Bank Transfer', 'Mobile Money', 'Check'];
    if (!validTypes.contains(selectedType)) selectedType = 'Other';
    if (!validMethods.contains(selectedMethod)) selectedMethod = 'Cash';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Finance Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: validTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v ?? 'Tithe'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: memberNameController,
                  decoration: const InputDecoration(
                    labelText: 'Member Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'Method',
                    border: OutlineInputBorder(),
                  ),
                  items: validMethods
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedMethod = v ?? 'Cash'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Date: ${DateFormat('MMM d, yyyy').format(selectedDate)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showDeleteFinanceDialog(finance);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }
                final updated = finance.copyWith(
                  type: selectedType,
                  amount: amount,
                  memberName: memberNameController.text.trim(),
                  date: selectedDate,
                  method: selectedMethod,
                );
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _financeService.updateFinance(updated);
                  navigator.pop();
                  _loadData();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Record updated'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to update: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteFinanceDialog(Finance finance) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Delete \$${finance.amount.toStringAsFixed(2)} ${finance.type} by ${finance.memberName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _financeService.deleteFinance(finance.id);
                navigator.pop();
                _loadData();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Record deleted')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
