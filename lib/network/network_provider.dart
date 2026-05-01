import 'dart:io';

import 'package:my_packages/my_packages.dart';

/// An abstract class representing a network provider.
abstract class NetworkProvider {
  /// The base URL for the network provider.
  final String baseUrl;

  /// Constructs a [NetworkProvider] with the given [baseUrl].
  NetworkProvider(this.baseUrl);

  /// Sends a GET request to the given [endpoint] with optional [queryParameters].
  Future<Result<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  });

  /// Sends a POST request to the given [endpoint] with optional [body].
  Future<Result<dynamic>> post(String endpoint, {Map<String, dynamic>? body});

  /// Sends a PUT request to the given [endpoint] with optional [body].
  Future<Result<dynamic>> put(String endpoint, {Map<String, dynamic>? body});

  /// Sends a PATCH request to the given [endpoint] with optional [body].
  Future<Result<dynamic>> patch(String endpoint, {Map<String, dynamic>? body});

  /// Sends a DELETE request to the given [endpoint].
  Future<Result<dynamic>> delete(String endpoint);

  /// The localhost URL for the network provider.
  ///
  /// The `'10.0.2.2'` is used when running on an Android emulator.
  /// On other platforms, the local hostname is used instead.
  static String localhost =
      'http://${Platform.isAndroid ? '10.0.2.2' : Platform.localHostname}:3000/api';
}
