import 'package:dio/dio.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://your-api-endpoint.com/api';
  
  // Authentication token
  String? _token;
  
  // Set token after login
  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $_token';
  }
  
  // EXPENSE ENDPOINTS
  
  // Get all expenses
  Future<List<Expense>> getExpenses() async {
    try {
      final response = await _dio.get('$baseUrl/expenses');
      return (response.data as List)
          .map((json) => Expense.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      final response = await _dio.get(
        '$baseUrl/expenses',
        queryParameters: {
          'startDate': start.toIso8601String(),
          'endDate': end.toIso8601String(),
        },
      );
      return (response.data as List)
          .map((json) => Expense.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Create expense
  Future<Expense> createExpense(Expense expense) async {
    try {
      final response = await _dio.post(
        '$baseUrl/expenses',
        data: expense.toJson(),
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Update expense
  Future<Expense> updateExpense(String id, Expense expense) async {
    try {
      final response = await _dio.put(
        '$baseUrl/expenses/$id',
        data: expense.toJson(),
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Delete expense
  Future<void> deleteExpense(String id) async {
    try {
      await _dio.delete('$baseUrl/expenses/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // CATEGORY ENDPOINTS
  
  // Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('$baseUrl/categories');
      return (response.data as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Create category
  Future<Category> createCategory(Category category) async {
    try {
      final response = await _dio.post(
        '$baseUrl/categories',
        data: category.toJson(),
      );
      return Category.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Update category
  Future<Category> updateCategory(String id, Category category) async {
    try {
      final response = await _dio.put(
        '$baseUrl/categories/$id',
        data: category.toJson(),
      );
      return Category.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Delete category
  Future<void> deleteCategory(String id) async {
    try {
      await _dio.delete('$baseUrl/categories/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return Exception(error.response?.data['message'] ?? 'An error occurred');
      }
      return Exception('Network error: ${error.message}');
    }
    return Exception('Unexpected error: $error');
  }
}