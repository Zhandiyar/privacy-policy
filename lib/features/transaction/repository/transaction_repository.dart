import 'package:fintrack/features/transaction/models/transaction_type.dart';

import '../models/transaction_request.dart';
import '../models/transaction_response.dart';
import '../../../services/api_client.dart';

class TransactionRepository {
  final ApiClient _apiClient;

  TransactionRepository(this._apiClient);

  Future<List<TransactionResponseDto>> getTransactions({
    TransactionType? type,
    int? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = {
      if (type != null) 'type': transactionTypeToString(type),
      if (categoryId != null) 'categoryId': categoryId.toString(),
      'page': page.toString(),
      'size': size.toString(),
    };

    final response = await _apiClient.dio.get('/transactions', queryParameters: queryParams);

    final data = response.data['content'] as List;
    return data.map((e) => TransactionResponseDto.fromJson(e)).toList();
  }

  Future<TransactionResponseDto> getById(int id) async {
    final response = await _apiClient.dio.get('/transactions/$id');
    return TransactionResponseDto.fromJson(response.data);
  }

  Future<TransactionResponseDto> create(TransactionRequestDto dto) async {
    final response = await _apiClient.dio.post('/transactions', data: dto.toJson());
    return TransactionResponseDto.fromJson(response.data);
  }

  Future<TransactionResponseDto> update(TransactionRequestDto dto) async {
    final response = await _apiClient.dio.put('/transactions', data: dto.toJson());
    return TransactionResponseDto.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    await _apiClient.dio.delete('/transactions/$id');
  }
}
