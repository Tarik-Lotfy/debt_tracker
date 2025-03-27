import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';
import '../widgets/debt_card.dart';
import 'debt_detail_screen.dart';
import 'add_debt_screen.dart';

class DebtListScreen extends StatefulWidget {
  const DebtListScreen({Key? key}) : super(key: key);

  @override
  State<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen> {
  bool _isLoading = true;
  bool _showActiveOnly = true;
  String? _sortBy = 'name'; // 'name', 'amount', 'progress'

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<DebtProvider>(context, listen: false).loadDebts();
    } catch (e) {
      // Error is handled in the consumer
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFilterAndSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter section
                  Row(
                    children: [
                      const Text(
                        'Show Active Debts Only',
                        style: TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      Switch(
                        value: _showActiveOnly,
                        onChanged: (value) {
                          setModalState(() {
                            _showActiveOnly = value;
                          });
                          setState(() {
                            _showActiveOnly = value;
                          });
                        },
                        activeColor: Colors.blue.shade400,
                      ),
                    ],
                  ),

                  // Sort section
                  const SizedBox(height: 8),
                  const Text(
                    'Sort By:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  RadioListTile<String>(
                    title: const Text(
                      'Name',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: 'name',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setModalState(() {
                        _sortBy = value;
                      });
                      setState(() {
                        _sortBy = value;
                      });
                    },
                    activeColor: Colors.blue.shade400,
                  ),
                  RadioListTile<String>(
                    title: const Text(
                      'Amount (High to Low)',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: 'amount',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setModalState(() {
                        _sortBy = value;
                      });
                      setState(() {
                        _sortBy = value;
                      });
                    },
                    activeColor: Colors.blue.shade400,
                  ),
                  RadioListTile<String>(
                    title: const Text(
                      'Progress (Lowest First)',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: 'progress',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setModalState(() {
                        _sortBy = value;
                      });
                      setState(() {
                        _sortBy = value;
                      });
                    },
                    activeColor: Colors.blue.shade400,
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'All Debts',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterAndSortDialog,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade500,
                  ),
                ),
              )
              : Consumer<DebtProvider>(
                builder: (context, debtProvider, child) {
                  if (debtProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            debtProvider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadDebts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter debts based on active only
                  var filteredDebts =
                      _showActiveOnly
                          ? debtProvider.debts
                              .where((debt) => !debt.isFullyPaid)
                              .toList()
                          : debtProvider.debts;

                  // Sort the debts based on selected option
                  if (_sortBy != null) {
                    switch (_sortBy) {
                      case 'name':
                        filteredDebts.sort(
                          (a, b) => a.name.toLowerCase().compareTo(
                            b.name.toLowerCase(),
                          ),
                        );
                        break;
                      case 'amount':
                        filteredDebts.sort(
                          (a, b) => b.totalAmount.compareTo(a.totalAmount),
                        );
                        break;
                      case 'progress':
                        filteredDebts.sort(
                          (a, b) => a.progressPercentage.compareTo(
                            b.progressPercentage,
                          ),
                        );
                        break;
                    }
                  }

                  if (filteredDebts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showActiveOnly
                                ? 'No active debts found'
                                : 'No debts found',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddDebtScreen(),
                                ),
                              ).then((_) => _loadDebts());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text('Add New Debt'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadDebts,
                    color: Colors.blue.shade600,
                    backgroundColor: Colors.grey.shade900,
                    child: ListView.builder(
                      itemCount: filteredDebts.length,
                      itemBuilder: (context, index) {
                        final debt = filteredDebts[index];
                        return DebtCard(
                          debt: debt,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        DebtDetailScreen(debtId: debt.id!),
                              ),
                            ).then((_) => _loadDebts());
                          },
                          onDelete: () {
                            _showDeleteDialog(context, debt);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDebtScreen()),
          ).then((_) => _loadDebts());
        },
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Debt debt) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Delete Debt',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete ${debt.name}?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final debtProvider = Provider.of<DebtProvider>(
                  context,
                  listen: false,
                );
                debtProvider.deleteDebt(debt.id!).then((_) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${debt.name} deleted')),
                  );
                });
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
