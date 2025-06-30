import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';


class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc(this.repository) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoad);
    on<AddTransaction>(_onAdd);
    on<UpdateTransaction>(_onUpdate);
    on<DeleteTransaction>(_onDelete);
  }

  Future<void> _onLoad(LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await repository.getTransactions(
        type: event.type,
        categoryId: event.categoryId,
      );
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Ошибка загрузки транзакций: $e'));
    }
  }

  Future<void> _onAdd(AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      final result = await repository.create(event.transaction);
      emit(TransactionSuccess(result));
      add(const LoadTransactions()); // перезагрузка
    } catch (e) {
      emit(TransactionError('Ошибка добавления транзакции: $e'));
    }
  }

  Future<void> _onUpdate(UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      await repository.update(event.transaction);
      add(const LoadTransactions()); // перезагрузка
    } catch (e) {
      emit(TransactionError('Ошибка обновления транзакции: $e'));
    }
  }

  Future<void> _onDelete(DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await repository.delete(event.id);
      add(const LoadTransactions()); // перезагрузка
    } catch (e) {
      emit(TransactionError('Ошибка удаления транзакции: $e'));
    }
  }
}
