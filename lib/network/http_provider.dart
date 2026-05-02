import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_packages/base/base.dart';
import 'package:my_packages/my_packages.dart';

import 'network_provider.dart';

/// An implementation of [NetworkProvider] that uses the [http] package to make HTTP requests.
class HttpProvider extends NetworkProvider {
  /// Creates a new [HttpProvider] with the default base URL.
  HttpProvider({String? baseUrl, this.logRequest = false})
    : super(baseUrl ?? NetworkProvider.localhost);

  /// Whether to log the request body for all requests.
  final bool logRequest;

  @override
  Future<Result<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    Map<String, List<String>>? queryParametersList;
    if (queryParameters != null) {
      queryParametersList = queryParameters.map((key, value) {
        if (value is List) {
          return MapEntry(key, value.map((e) => e.toString()).toList());
        }
        return MapEntry(key, [value.toString()]);
      });
    }

    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (logRequest) {
        logger.d('GET Request $uri');
      }
      uri = uri.replace(queryParameters: queryParametersList);
      final response = await http.get(uri);
      if (logRequest) {
        logger.d('GET Response $uri ${response.body}');
      }
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
      if (logRequest) {
        logger.d('POST Request $uri $body');
      }
      final response = await http.post(uri, body: body);
      if (logRequest) {
        logger.d('POST Response $uri ${response.body}');
      }
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
      if (logRequest) {
        logger.d('PUT Request $uri $body');
      }
      final response = await http.put(uri, body: body);
      if (logRequest) {
        logger.d('PUT Response $uri ${response.body}');
      }
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
      if (logRequest) {
        logger.d('PATCH Request $uri $body');
      }
      final response = await http.patch(uri, body: body);
      if (logRequest) {
        logger.d('PATCH Response $uri ${response.body}');
      }
      return Result.ok(jsonDecode(response.body));
    } catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      if (logRequest) {
        logger.d('DELETE Request $uri');
      }
      final response = await http.delete(uri);
      if (logRequest) {
        logger.d('DELETE Response $uri ${response.body}');
      }
      return Result.ok(jsonDecode(response.body));
    } catch (e) {
      return Result.error(e);
    }
  }
}
