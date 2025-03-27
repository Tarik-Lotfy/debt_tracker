import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';

class DashboardSummary extends StatelessWidget {
  final List<Debt> debts;
  final Function(int) onDebtTap;
  final VoidCallback onViewAllDebts;

  const DashboardSummary({
    Key? key,
    required this.debts,
    required this.onDebtTap,
    required this.onViewAllDebts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Calculate total debt amount and remaining amount
    double totalDebtAmount = 0;
    double totalRemainingAmount = 0;

    for (final debt in debts) {
      totalDebtAmount += debt.totalAmount;
      totalRemainingAmount += debt.remainingAmount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome banner
        Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade700.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Debt Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewItem(
                      label: 'Total',
                      amount: currencyFormat.format(totalDebtAmount),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildOverviewItem(
                      label: 'Remaining',
                      amount: currencyFormat.format(totalRemainingAmount),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Active Debts Section
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Debts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: onViewAllDebts,
                child: Text(
                  'View All',
                  style: TextStyle(color: Colors.blue.shade400),
                ),
              ),
            ],
          ),
        ),

        if (debts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No active debts',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: debts.length > 3 ? 3 : debts.length,
            itemBuilder: (context, index) {
              final debt = debts[index];
              return _buildDebtItem(context, debt);
            },
          ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildOverviewItem({required String label, required String amount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDebtItem(BuildContext context, Debt debt) {
    final progress = debt.progressPercentage / 100;
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.4),
      child: InkWell(
        onTap: () => onDebtTap(debt.id!),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
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
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade800,
                color:
                    debt.isFullyPaid
                        ? Colors.green.shade500
                        : Colors.blue.shade500,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    NumberFormat.currency(
                      symbol: '\$',
                    ).format(debt.remainingAmount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color:
                          debt.isFullyPaid
                              ? Colors.green.shade300
                              : Colors.white,
                    ),
                  ),
                  Text(
                    '/ ${NumberFormat.currency(symbol: '\$').format(debt.totalAmount)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
