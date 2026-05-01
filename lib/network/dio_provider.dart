// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:hrm_app/core/network/network_provider.dart';
// import 'package:my_packages/my_packages.dart';

// class AppException implements Exception {
//   final String message;

//   AppException(this.message);

//   @override
//   String toString() => message;
// }

// class DioProvider extends NetworkProvider {
//   final FlutterSecureStorage _storage;

//   DioProvider(this._storage) : super(NetworkProvider.localhost) {
//     _init();
//   }

//   void _init() {
//     _dio.interceptors.clear();
//     _dio.interceptors.add(LogInterceptor());
//     _dio.interceptors.add(
//       QueuedInterceptorsWrapper(
//         onRequest: _onRequest,
//         onResponse: _onResponse,
//         onError: _onError,
//       ),
//     );
//   }

//   final Dio _dio = Dio();
//   final Dio _dioRefreshToken = Dio();

//   void _onRequest(
//     RequestOptions options,
//     RequestInterceptorHandler handler,
//   ) async {
//     final token = await _storage.read(key: 'token');
//     if (token != null) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }

//     handler.next(options);
//   }

//   void _onResponse(Response response, ResponseInterceptorHandler handler) {
//     handler.next(response);
//   }

//   void _onError(DioException error, ErrorInterceptorHandler handler) async {
//     final statusCode = error.response?.statusCode;
//     final path = error.requestOptions.path;
//     final isAuthPath =
//         path.contains('/auth/login') || path.contains('/auth/refresh');

//     if (statusCode == 401 && !isAuthPath) {
//       final refreshToken = await _storage.read(key: 'refreshToken');

//       if (refreshToken != null) {
//         try {
//           final refreshResponse = await _dioRefreshToken.post(
//             '$baseUrl/auth/refresh',
//             data: {'refreshToken': refreshToken},
//           );

//           final newToken = refreshResponse.data['accessToken'] as String;
//           final newRefreshToken =
//               refreshResponse.data['refreshToken'] as String?;

//           await _storage.write(key: 'token', value: newToken);
//           if (newRefreshToken != null) {
//             await _storage.write(key: 'refreshToken', value: newRefreshToken);
//           }

//           final opts = error.requestOptions;
//           final retryResponse = await _dio.request<dynamic>(
//             opts.path,
//             data: opts.data,
//             queryParameters: opts.queryParameters,
//             options: Options(
//               method: opts.method,
//               headers: {...opts.headers, 'Authorization': 'Bearer $newToken'},
//             ),
//           );

//           handler.resolve(retryResponse);
//           return;
//         } catch (_) {
//           await _storage.delete(key: 'token');
//           await _storage.delete(key: 'refreshToken');
//         }
//       } else {
//         await _storage.delete(key: 'token');
//       }
//     }

//     handler.next(error);
//   }

//   Future<Result<dynamic>> _execute(Future<Response> Function() call) async {
//     try {
//       final response = await call();
//       return Result.ok(response.data);
//     } on DioException catch (e, st) {
//       return Result.error(_mapDioException(e), st);
//     } catch (e, st) {
//       return Result.error(e, st);
//     }
//   }

//   AppException _mapDioException(DioException e) {
//     return switch (e.type) {
//       DioExceptionType.connectionTimeout ||
//       DioExceptionType.sendTimeout ||
//       DioExceptionType.receiveTimeout => AppException('Request timed out'),
//       DioExceptionType.connectionError => AppException(
//         'No internet connection',
//       ),
//       DioExceptionType.badCertificate => AppException(
//         'Invalid SSL certificate',
//       ),
//       DioExceptionType.cancel => AppException('Request was cancelled'),
//       DioExceptionType.badResponse => _mapHttpError(e.response!),
//       DioExceptionType.unknown =>
//         e.error is AppException
//             ? e.error as AppException
//             : AppException(e.message ?? 'Unknown error'),
//     };
//   }

//   AppException _mapHttpError(Response response) {
//     if (response.data is! Map<String, dynamic>) {
//       return AppException(
//         'Unexpected response format: ${response.data.runtimeType}',
//       );
//     }
//     final message =
//         (response.data?['message'] ?? response.data?['detail']) as String?;
//     return switch (response.statusCode) {
//       400 => AppException(message ?? 'Bad request'),
//       401 => AppException(message ?? 'Unauthorized'),
//       403 => AppException(message ?? 'Forbidden'),
//       404 => AppException(message ?? 'Not found'),
//       422 => AppException(message ?? 'Validation error'),
//       500 => AppException(message ?? 'Internal server error'),
//       _ => AppException(message ?? 'HTTP ${response.statusCode}'),
//     };
//   }

//   @override
//   Future<Result<dynamic>> get(
//     String endpoint, {
//     Map<String, dynamic>? queryParameters,
//   }) => _execute(
//     () => _dio.get('$baseUrl$endpoint', queryParameters: queryParameters),
//   );

//   @override
//   Future<Result<dynamic>> post(String endpoint, {Map<String, dynamic>? body}) =>
//       _execute(() => _dio.post('$baseUrl$endpoint', data: body));

//   @override
//   Future<Result<dynamic>> put(String endpoint, {Map<String, dynamic>? body}) =>
//       _execute(() => _dio.put('$baseUrl$endpoint', data: body));

//   @override
//   Future<Result<dynamic>> patch(
//     String endpoint, {
//     Map<String, dynamic>? body,
//   }) => _execute(() => _dio.patch('$baseUrl$endpoint', data: body));

//   @override
//   Future<Result<dynamic>> delete(String endpoint) =>
//       _execute(() => _dio.delete('$baseUrl$endpoint'));
// }
