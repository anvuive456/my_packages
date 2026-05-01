import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_packages/base/base.dart';

import 'network_provider.dart';

/// An implementation of [NetworkProvider] that uses the [http] package to make HTTP requests.
class HttpProvider extends NetworkProvider {
  /// Creates a new [HttpProvider] with the default base URL.
  HttpProvider({String? baseUrl}) : super(baseUrl ?? NetworkProvider.localhost);

  @override
  Future<Result<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      uri = uri.replace(queryParameters: queryParameters);
      final response = await http.get(uri);
      return Result.ok(jsonDecode(response.body));
    } catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(uri, body: body);
      return Result.ok(jsonDecode(response.body));
    } catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(uri, body: body);
      return Result.ok(jsonDecode(response.body));
    } catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.patch(uri, body: body);
      return Result.ok(jsonDecode(response.body));
    } catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(uri);
      return Result.ok(jsonDecode(response.body));
    } catch (e) {
      return Result.error(e);
    }
  }
}
