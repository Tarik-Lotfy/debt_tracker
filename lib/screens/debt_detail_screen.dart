import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../models/payment.dart';
import '../providers/debt_provider.dart';
import '../providers/payment_provider.dart';

import '../widgets/payment_item.dart';

class DebtDetailScreen extends StatefulWidget {
  final int debtId;

  const DebtDetailScreen({super.key, required this.debtId});

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {
  late Debt debt;
  bool isLoading = true;
  List<Payment> payments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final debtProvider = Provider.of<DebtProvider>(context, listen: false);
      final loadedDebt = await debtProvider.getDebtById(widget.debtId);
      if (loadedDebt != null) {
        setState(() {
          debt = loadedDebt;
        });
      }

      final paymentProvider = Provider.of<PaymentProvider>(
        context,
        listen: false,
      );
      final loadedPayments = await paymentProvider.getPaymentsForDebt(
        widget.debtId,
      );
      setState(() {
        payments = loadedPayments;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addPayment() async {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: Text('Add Payment', style: TextStyle(color: Colors.white)),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      if (amount > debt.remainingAmount) {
                        return 'Amount cannot exceed remaining balance';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'Payment Date',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(Icons.calendar_today, color: Colors.blue),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        selectedDate = date;
                      }
                    },
                  ),
                  TextFormField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final amount = double.parse(amountController.text);
                    final payment = Payment(
                      id: 0,
                      debtId: debt.id ?? 0,
                      amount: amount,
                      paymentDate: selectedDate,
                      notes: notesController.text,
                    );

                    try {
                      await context.read<PaymentProvider>().addPayment(payment);
                      // Update the debt's paid amount in the provider
                      final updatedDebt = debt.copyWith(
                        paidAmount: debt.paidAmount + amount,
                      );
                      await context.read<DebtProvider>().updateDebt(
                        updatedDebt,
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add payment: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text('Add Payment'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(debt.name, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmationDialog(),
          ),
        ],
      ),
      body: Consumer2<DebtProvider, PaymentProvider>(
        builder: (context, debtProvider, paymentProvider, child) {
          final debt = debtProvider.getDebtById(widget.debtId);
          if (debt == null) {
            return const Center(
              child: Text(
                'Debt not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final payments = paymentProvider.getPaymentsForDebt(widget.debtId);

          return Column(
            children: [
              // Debt summary
              _buildDebtSummary(debt),

              // Payment header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payments (${payments.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Payments list
              Expanded(
                child:
                    isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade500,
                            ),
                          ),
                        )
                        : payments.isEmpty
                        ? const Center(
                          child: Text(
                            'No payments found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            final payment = payments[index];
                            return PaymentItem(
                              payment: payment,
                              onDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.grey.shade900,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      title: const Text(
                                        'Delete Payment',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete this payment?',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.grey,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            paymentProvider
                                                .deletePayment(
                                                  payment.id!,
                                                  widget.debtId,
                                                )
                                                .then((_) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Payment deleted',
                                                      ),
                                                    ),
                                                  );
                                                });
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final debt = Provider.of<DebtProvider>(
            context,
            listen: false,
          ).getDebtById(widget.debtId);
          if (debt != null) {
            _addPayment();
          }
        },
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: Text('Delete Debt', style: TextStyle(color: Colors.white)),
            content: Text(
              'Are you sure you want to delete this debt? This action cannot be undone.',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await context.read<DebtProvider>().deleteDebt(debt.id ?? 0);
                    if (mounted) {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to previous screen
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete debt: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Widget _buildDebtSummary(Debt debt) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    debt.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        debt.isFullyPaid
                            ? Colors.green.shade900
                            : Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${debt.progressPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            if (debt.description.isNotEmpty) const SizedBox(height: 8),
            if (debt.description.isNotEmpty)
              Text(
                debt.description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  'Total',
                  '\$${debt.totalAmount.toStringAsFixed(2)}',
                ),
                _buildInfoItem(
                  'Paid',
                  '\$${debt.paidAmount.toStringAsFixed(2)}',
                ),
                _buildInfoItem(
                  'Remaining',
                  '\$${debt.remainingAmount.toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: debt.progressPercentage / 100,
              backgroundColor: Colors.grey.shade800,
              color:
                  debt.isFullyPaid
                      ? Colors.green.shade500
                      : Colors.blue.shade500,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Text(
              'Started on: ${DateFormat('MMM d, yyyy').format(debt.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
