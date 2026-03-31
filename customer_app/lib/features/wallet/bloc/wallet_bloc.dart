import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/firestore_service.dart';

// ─── Events ──────────────────────────────────────────

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class WalletLoadRequested extends WalletEvent {
  const WalletLoadRequested();
}

class WalletBalanceUpdated extends WalletEvent {
  final double balance;

  const WalletBalanceUpdated(this.balance);

  @override
  List<Object?> get props => [balance];
}

class WalletTransactionsUpdated extends WalletEvent {
  final List<Map<String, dynamic>> transactions;

  const WalletTransactionsUpdated(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

// ─── States ──────────────────────────────────────────

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final double balance;
  final List<Map<String, dynamic>> transactions;

  const WalletLoaded({
    required this.balance,
    this.transactions = const [],
  });

  @override
  List<Object?> get props => [balance, transactions];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────

/// Wallet BLoC — Real-time balance and transaction history
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  StreamSubscription? _balanceSub;
  StreamSubscription? _transactionsSub;

  double _currentBalance = 0;
  List<Map<String, dynamic>> _currentTransactions = [];

  WalletBloc({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const WalletInitial()) {
    on<WalletLoadRequested>(_onLoad);
    on<WalletBalanceUpdated>(_onBalanceUpdated);
    on<WalletTransactionsUpdated>(_onTransactionsUpdated);
  }

  Future<void> _onLoad(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    final uid = _authService.uid;
    if (uid == null) {
      emit(const WalletError('يجب تسجيل الدخول'));
      return;
    }

    // Stream balance
    await _balanceSub?.cancel();
    _balanceSub = _firestoreService
        .streamWalletBalance(uid)
        .listen((balance) {
      if (!isClosed) {
        add(WalletBalanceUpdated(balance));
      }
    });

    // Stream transactions
    await _transactionsSub?.cancel();
    _transactionsSub = _firestoreService
        .streamTransactions(uid)
        .listen((transactions) {
      if (!isClosed) {
        add(WalletTransactionsUpdated(transactions));
      }
    });
  }

  Future<void> _onBalanceUpdated(
    WalletBalanceUpdated event,
    Emitter<WalletState> emit,
  ) async {
    _currentBalance = event.balance;
    emit(WalletLoaded(
      balance: _currentBalance,
      transactions: _currentTransactions,
    ));
  }

  Future<void> _onTransactionsUpdated(
    WalletTransactionsUpdated event,
    Emitter<WalletState> emit,
  ) async {
    _currentTransactions = event.transactions;
    emit(WalletLoaded(
      balance: _currentBalance,
      transactions: _currentTransactions,
    ));
  }

  @override
  Future<void> close() {
    _balanceSub?.cancel();
    _transactionsSub?.cancel();
    return super.close();
  }
}
