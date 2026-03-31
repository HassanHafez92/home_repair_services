import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tech_theme.dart';
import '../../bloc/tech_wallet_bloc.dart';

/// Wallet Screen — Technician earnings and transaction history
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TechWalletBloc>().add(const TechWalletLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TechWalletBloc, TechWalletState>(
      builder: (context, state) {
        double balance = 0;
        double todayEarnings = 0;
        List<Map<String, dynamic>> transactions = [];

        if (state is TechWalletLoaded) {
          balance = state.balance;
          todayEarnings = state.todayEarnings;
          transactions = state.transactions;
        }

        return Scaffold(
      backgroundColor: TechColors.background,
      appBar: AppBar(
        title: const Text('المحفظة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ─── Balance Card ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B2B4D), Color(0xFF0D1B36)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: TechColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'الرصيد المتاح',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${balance.toInt()} ج.م',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _WalletStat(
                            label: 'أرباح اليوم',
                            value: '${todayEarnings.toInt()} ج.م',
                            icon: Icons.trending_up_rounded,
                            color: TechColors.earningsGreen,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        Expanded(
                          child: _WalletStat(
                            label: 'عمولة المنصة',
                            value: '٧٨٠ ج.م',
                            icon: Icons.receipt_long_rounded,
                            color: TechColors.busy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Withdrawal flow
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: TechColors.primary,
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'سحب الرصيد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Transaction History ───────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'سجل المعاملات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TechColors.textPrimary,
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              if (state is TechWalletLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (state is TechWalletLoaded && transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'لا توجد معاملات سابقة',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              if (state is TechWalletLoaded)
                ...transactions.map((tx) {
                  return _TransactionCard(
                    type: tx['type'] ?? 'credit',
                    title: tx['title'] ?? 'عملية',
                    amount: '${tx['amount']?.toInt() ?? 0} ج.م',
                    subtitle: tx['subtitle'] ?? '',
                    time: 'مؤخراً',
                  );
                }),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _WalletStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _WalletStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String type;
  final String title;
  final String amount;
  final String subtitle;
  final String time;

  const _TransactionCard({
    required this.type,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.time,
  });

  Color get _color {
    switch (type) {
      case 'credit':
        return TechColors.earningsGreen;
      case 'debit':
        return TechColors.offline;
      case 'withdrawal':
        return TechColors.primary;
      default:
        return TechColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (type) {
      case 'credit':
        return Icons.arrow_downward_rounded;
      case 'debit':
        return Icons.arrow_upward_rounded;
      case 'withdrawal':
        return Icons.account_balance_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TechColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TechColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TechColors.textPrimary,
                  ),
                ),
                Text(
                  '$subtitle • $time',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: TechColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
