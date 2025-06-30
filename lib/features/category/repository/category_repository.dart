// lib/repository/category_repository.dart
import '../../transaction/models/transaction_type.dart';
import '../models/transaction_category.dart';
import '/../../services/api_client.dart';

class CategoryRepository {
  final ApiClient apiClient;

  CategoryRepository(this.apiClient);

  Future<List<TransactionCategory>> getCategoriesByType(TransactionType type) async {
    final response = await apiClient.dio.get('/api/categories', queryParameters: {
      'type': type.name,
    });
    final data = response.data as List<dynamic>;
    return data.map((json) => TransactionCategory.fromJson(json)).toList();
  }
}
