import 'package:equatable/equatable.dart';
import 'package:fintrack/features/transaction/models/transaction_request.dart';
import 'package:fintrack/features/transaction/models/transaction_type.dart';


abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final TransactionType? type;
  final int? categoryId;

  const LoadTransactions({this.type, this.categoryId});

  @override
  List<Object?> get props => [type, categoryId];
}

class AddTransaction extends TransactionEvent {
  final TransactionRequestDto transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransaction extends TransactionEvent {
  final TransactionRequestDto transaction;

  const UpdateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final int id;

  const DeleteTransaction(this.id);

  @override
  List<Object?> get props => [id];
}
