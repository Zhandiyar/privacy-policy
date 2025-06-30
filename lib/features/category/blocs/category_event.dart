// lib/blocs/category/category_event.dart
import 'package:equatable/equatable.dart';

import '../../transaction/models/transaction_type.dart' show TransactionType;


abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  final TransactionType type;
  const LoadCategories(this.type);

  @override
  List<Object?> get props => [type];
}
