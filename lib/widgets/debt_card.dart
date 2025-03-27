import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const DebtCard({
    Key? key,
    required this.debt,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final progress = debt.progressPercentage / 100;

    // Determine color based on progress
    Color progressColor = Colors.redAccent;
    if (progress > 0.75) {
      progressColor = Colors.greenAccent;
    } else if (progress > 0.5) {
      progressColor = Colors.orangeAccent;
    } else if (progress > 0.25) {
      progressColor = Colors.amberAccent;
    }

    return Card(
      elevation: 3,
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.blue.withOpacity(0.05),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (debt.isFullyPaid)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade900,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'PAID',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${currencyFormat.format(debt.totalAmount)}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade300),
                  ),
                  Text(
                    'Remaining: ${currencyFormat.format(debt.remainingAmount)}',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          debt.isFullyPaid
                              ? Colors.greenAccent
                              : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade800,
                color: progressColor,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress: ${debt.progressPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 14, color: progressColor),
                  ),
                  Text(
                    'Started: ${DateFormat('MMM d, yyyy').format(debt.createdAt)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
              if (onDelete != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
