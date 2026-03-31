import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/tech_auth_service.dart';
import '../../../core/services/tech_firestore_service.dart';
import '../../../core/services/tech_functions_service.dart';

// ─── Events ──────────────────────────────────────────

abstract class TechWalletEvent extends Equatable {
  const TechWalletEvent();
  @override
  List<Object?> get props => [];
}

class TechWalletLoadRequested extends TechWalletEvent {
  const TechWalletLoadRequested();
}

class TechWalletBalanceUpdated extends TechWalletEvent {
  final double balance;
  const TechWalletBalanceUpdated(this.balance);
  @override
  List<Object?> get props => [balance];
}

class TechWalletTransactionsUpdated extends TechWalletEvent {
  final List<Map<String, dynamic>> transactions;
  const TechWalletTransactionsUpdated(this.transactions);
  @override
  List<Object?> get props => [transactions];
}

class TechWalletWithdrawalRequested extends TechWalletEvent {
  final double amount;
  final String method;
  const TechWalletWithdrawalRequested({required this.amount, required this.method});
  @override
  List<Object?> get props => [amount, method];
}

class TechWalletTodayEarningsUpdated extends TechWalletEvent {
  final double earnings;
  const TechWalletTodayEarningsUpdated(this.earnings);
  @override
  List<Object?> get props => [earnings];
}

// ─── States ──────────────────────────────────────────

abstract class TechWalletState extends Equatable {
  const TechWalletState();
  @override
  List<Object?> get props => [];
}

class TechWalletInitial extends TechWalletState {
  const TechWalletInitial();
}

class TechWalletLoading extends TechWalletState {
  const TechWalletLoading();
}

class TechWalletLoaded extends TechWalletState {
  final double balance;
  final double todayEarnings;
  final List<Map<String, dynamic>> transactions;

  const TechWalletLoaded({
    required this.balance,
    this.todayEarnings = 0,
    this.transactions = const [],
  });

  @override
  List<Object?> get props => [balance, todayEarnings, transactions];
}

class TechWalletWithdrawalSuccess extends TechWalletState {
  const TechWalletWithdrawalSuccess();
}

class TechWalletError extends TechWalletState {
  final String message;
  const TechWalletError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────

/// Technician Wallet BLoC — Balance, earnings, transactions, and withdrawal
class TechWalletBloc extends Bloc<TechWalletEvent, TechWalletState> {
  final TechAuthService _authService;
  final TechFirestoreService _firestoreService;
  final TechFunctionsService _functionsService;

  StreamSubscription? _balanceSub;
  StreamSubscription? _transactionsSub;
  StreamSubscription? _earningsSub;

  double _balance = 0;
  double _todayEarnings = 0;
  List<Map<String, dynamic>> _transactions = [];

  TechWalletBloc({
    required TechAuthService authService,
    required TechFirestoreService firestoreService,
    required TechFunctionsService functionsService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _functionsService = functionsService,
        super(const TechWalletInitial()) {
    on<TechWalletLoadRequested>(_onLoad);
    on<TechWalletBalanceUpdated>(_onBalanceUpdated);
    on<TechWalletTransactionsUpdated>(_onTransactionsUpdated);
    on<TechWalletTodayEarningsUpdated>(_onEarningsUpdated);
    on<TechWalletWithdrawalRequested>(_onWithdrawal);
  }

  Future<void> _onLoad(
    TechWalletLoadRequested event,
    Emitter<TechWalletState> emit,
  ) async {
    emit(const TechWalletLoading());

    final uid = _authService.uid;
    if (uid == null) {
      emit(const TechWalletError('يجب تسجيل الدخول'));
      return;
    }

    await _balanceSub?.cancel();
    _balanceSub = _firestoreService.streamWalletBalance(uid).listen((b) {
      if (!isClosed) add(TechWalletBalanceUpdated(b));
    });

    await _transactionsSub?.cancel();
    _transactionsSub = _firestoreService.streamTransactions(uid).listen((t) {
      if (!isClosed) add(TechWalletTransactionsUpdated(t));
    });

    await _earningsSub?.cancel();
    _earningsSub = _firestoreService.streamTodayEarnings(uid).listen((e) {
      if (!isClosed) add(TechWalletTodayEarningsUpdated(e));
    });
  }

  Future<void> _onBalanceUpdated(
    TechWalletBalanceUpdated event,
    Emitter<TechWalletState> emit,
  ) async {
    _balance = event.balance;
    emit(TechWalletLoaded(
      balance: _balance,
      todayEarnings: _todayEarnings,
      transactions: _transactions,
    ));
  }

  Future<void> _onTransactionsUpdated(
    TechWalletTransactionsUpdated event,
    Emitter<TechWalletState> emit,
  ) async {
    _transactions = event.transactions;
    emit(TechWalletLoaded(
      balance: _balance,
      todayEarnings: _todayEarnings,
      transactions: _transactions,
    ));
  }

  Future<void> _onEarningsUpdated(
    TechWalletTodayEarningsUpdated event,
    Emitter<TechWalletState> emit,
  ) async {
    _todayEarnings = event.earnings;
    emit(TechWalletLoaded(
      balance: _balance,
      todayEarnings: _todayEarnings,
      transactions: _transactions,
    ));
  }

  Future<void> _onWithdrawal(
    TechWalletWithdrawalRequested event,
    Emitter<TechWalletState> emit,
  ) async {
    emit(const TechWalletLoading());

    try {
      final token = await _authService.currentUser?.getIdToken();
      if (token == null) return;

      await _functionsService.requestWithdrawal(
        amount: event.amount,
        method: event.method,
        authToken: token,
      );

      emit(const TechWalletWithdrawalSuccess());
    } catch (e) {
      emit(TechWalletError('فشل طلب السحب: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _balanceSub?.cancel();
    _transactionsSub?.cancel();
    _earningsSub?.cancel();
    return super.close();
  }
}
