// lib/blocs/category/category_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../../category/repository/category_repository.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoad);
  }

  Future<void> _onLoad(LoadCategories event, Emitter<CategoryState> emit) async {
    print('🎯 CategoryBloc received LoadCategories(${event.type})');
    emit(CategoryLoading());
    try {
      final categories = await repository.getCategoriesByType(event.type);
      print('✅ CategoryBloc loaded ${categories.length} categories');
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Ошибка загрузки категорий: $e'));
    }
  }
}
