import 'package:dio/dio.dart';

import '../../../services/api_client.dart';
import '../models/dashboard.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardDto> getDashboard({
    int? year,
    int? month,
    int? day,
    String lang = 'ru',
  }) async {
    final response = await _apiClient.dio.get(
      '/api/dashboard',
      queryParameters: {
        if (year != null) 'year': year,
        if (month != null) 'month': month,
        if (day != null) 'day': day,
      },
      options: Options(headers: {'Accept-Language': lang}),
    );

    return DashboardDto.fromJson(response.data);
  }
}
