import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../widgets/dashboard_summary.dart';
import 'debt_list_screen.dart';
import 'add_debt_screen.dart';
import 'debt_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final debtProvider = Provider.of<DebtProvider>(context, listen: false);

    await debtProvider.loadDebts();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Debt Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.blue.shade700,
        backgroundColor: Colors.grey.shade900,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDebtScreen()),
          ).then((_) => _loadData());
        },
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade500),
        ),
      );
    }

    return Consumer<DebtProvider>(
      builder: (context, debtProvider, child) {
        if (debtProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  debtProvider.error ?? 'An error occurred',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue.shade600,
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

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            color: Colors.black,
            child: DashboardSummary(
              debts: debtProvider.activeDebts,
              onDebtTap: (debtId) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DebtDetailScreen(debtId: debtId),
                  ),
                ).then((_) => _loadData());
              },
              onViewAllDebts: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DebtListScreen(),
                  ),
                ).then((_) => _loadData());
              },
            ),
          ),
        );
      },
    );
  }
}
