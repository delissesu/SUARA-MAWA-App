import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:suara_mawa/screens/aspirasi/models/report_model.dart';

/// Centralized service for all Report API operations (mahasiswa side).
///
/// Consumes endpoints documented in `SuaraMawaAPI.txt` under the
/// `/mahasiswa/*` and `/report/*` groups.
class ReportService {
  static const String _traceTag = 'ReportService.createReport';

  static const String baseUrl = String.fromEnvironment(
    'SERVER_BASE_URL',
    defaultValue: '',
  );

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {"ngrok-skip-browser-warning": "69420"},
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Auth helpers

  Future<String?> _getToken() => _storage.read(key: "auth_token");

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Lookup data

  /// `GET /report/category/all`
  Future<List<ReportCategory>> getAllCategories() async {
    final options = await _authOptions();
    final response = await _dio.get('/report/category/all', options: options);
    final list = response.data as List;
    return list
        .map((e) => ReportCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /report/department/all`
  Future<List<ReportDepartment>> getAllDepartments() async {
    final options = await _authOptions();
    final response = await _dio.get('/report/department/all', options: options);
    final list = response.data as List;
    return list
        .map((e) => ReportDepartment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /report/status/all` — returns the enum values as `List<String>`.
  Future<List<String>> getAllStatuses() async {
    final options = await _authOptions();
    final response = await _dio.get('/report/status/all', options: options);
    final list = response.data as List;
    return list.map((e) => e.toString()).toList();
  }

  // Mahasiswa reports

  /// `GET /mahasiswa/my-reports?currentPage=`
  ///
  /// Returns a raw list of [ReportListItem]. The backend does not return
  /// pagination metadata on this endpoint, so we infer `hasMore` from
  /// the length of the returned list.
  Future<List<ReportListItem>> getMyReports({int currentPage = 1}) async {
    final options = await _authOptions();
    final response = await _dio.get(
      '/mahasiswa/my-reports',
      queryParameters: {'currentPage': currentPage},
      options: options,
    );
    final list = response.data as List;
    return list
        .map((e) => ReportListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Public reports (paginated)

  /// `GET /report/all?currentPage=`
  Future<PaginatedReports> getAllPublicReports({int currentPage = 1}) async {
    final options = await _authOptions();
    final response = await _dio.get(
      '/report/all',
      queryParameters: {'currentPage': currentPage},
      options: options,
    );
    return PaginatedReports.fromJson(response.data as Map<String, dynamic>);
  }

  // Report detail

  /// `POST /report/detail` — body: `{reportId: int}`
  /// `POST /report/detail` — body: `{reportId: int}`
  Future<ReportDetail?> getReportDetail(int reportId) async {
    final options = await _authOptions();
    try {
      final response = await _dio.post(
        '/report/detail',
        data: {'reportId': reportId},
        options: options,
      );
      debugPrint('[ReportService.getReportDetail] rawResponse: ${response.data}');
      final body = response.data as Map<String, dynamic>;
      if (body['status'] == 'success' && body['data'] != null) {
        final detail = ReportDetail.fromJson(body['data'] as Map<String, dynamic>);
        debugPrint('[ReportService.getReportDetail] parsed detail. ID: ${detail.id}, evidences count: ${detail.evidences.length}');
        for (var ev in detail.evidences) {
          debugPrint('  - Evidence ID: ${ev.id}, File: ${ev.file?.name}, Type: ${ev.file?.filetype}');
        }
        return detail;
      }
    } catch (e, stack) {
      debugPrint('[ReportService.getReportDetail] Error: $e');
      debugPrint('[ReportService.getReportDetail] Stack: $stack');
    }
    return null;
  }

  // Evidence preview URL

  /// Returns the full URL for previewing an evidence attachment.
  String evidencePreviewUrl(int reportEvidenceId) {
    return '$baseUrl/report/evidence/$reportEvidenceId/preview';
  }

  // Feedback

  /// `POST /report/feedback/detail` — body: `{reportStatusId: int}`
  Future<List<ReportFeedback>> getFeedbackDetail(int reportStatusId) async {
    final options = await _authOptions();
    final response = await _dio.post(
      '/report/feedback/detail',
      data: {'reportStatusId': reportStatusId},
      options: options,
    );
    final list = response.data as List;
    return list
        .map((e) => ReportFeedback.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Create report

  void _trace(String message) {
    debugPrint('[$_traceTag] $message');
  }

  DioMediaType _contentTypeForFile(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    return switch (extension) {
      'jpg' || 'jpeg' => DioMediaType('image', 'jpeg'),
      'png' => DioMediaType('image', 'png'),
      'webp' => DioMediaType('image', 'webp'),
      'heic' => DioMediaType('image', 'heic'),
      'heif' => DioMediaType('image', 'heif'),
      'gif' => DioMediaType('image', 'gif'),
      'mp4' => DioMediaType('video', 'mp4'),
      'mov' => DioMediaType('video', 'quicktime'),
      _ => DioMediaType('application', 'octet-stream'),
    };
  }

  String _messageFromResponseData(Object? data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? data['messgae']?.toString() ?? '';
    }

    if (data is Map) {
      return data['message']?.toString() ?? data['messgae']?.toString() ?? '';
    }

    return data?.toString() ?? '';
  }

  String _fileNameFromPath(String path) {
    return path.replaceAll('\\', '/').split('/').last;
  }

  String _extensionFromFileName(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }

    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  String _formatBytes(int bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(2)}MB';
    }
    if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(2)}KB';
    }
    return '${bytes}B';
  }

  String _stringifyForLog(Object? value, {int maxLength = 4000}) {
    final text = value?.toString() ?? 'null';
    if (text.length <= maxLength) {
      return text;
    }

    return '${text.substring(0, maxLength)}... <truncated ${text.length - maxLength} chars>';
  }

  Map<String, Object?> _headersForLog(Map<String, dynamic>? headers) {
    if (headers == null) return {};

    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        final token = value?.toString() ?? '';
        return MapEntry(
          key,
          token.isEmpty ? '<empty>' : '<redacted length=${token.length}>',
        );
      }

      return MapEntry(key, value);
    });
  }

  Map<String, Object?> _fieldLogValue(MapEntry<String, String> field) {
    if (field.key == 'title' || field.key == 'description') {
      return {'key': field.key, 'length': field.value.length};
    }

    return {'key': field.key, 'value': field.value};
  }

  /// `POST /mahasiswa/report/create`
  ///
  /// Uses multipart/form-data for file uploads. [files] is a list of
  /// image/video [File] objects. [names] must have the same length as [files].
  Future<(bool, String)> createReport({
    required String title,
    required String description,
    required double locationLat,
    required double locationLong,
    String? locationDetail,
    required bool isPublic,
    required int departmentId,
    required int categoryId,
    required List<File> files,
  }) async {
    final traceId = DateTime.now().microsecondsSinceEpoch.toString();
    final stopwatch = Stopwatch()..start();

    try {
      _trace(
        '[$traceId] START endpoint=/mahasiswa/report/create baseUrl="$baseUrl"',
      );
      _trace(
        '[$traceId] input '
        'titleLength=${title.length}, '
        'descriptionLength=${description.length}, '
        'locationLat=$locationLat, '
        'locationLong=$locationLong, '
        'locationDetailPresent=${locationDetail != null}, '
        'isPublic=$isPublic, '
        'departmentId=$departmentId, '
        'categoryId=$categoryId, '
        'filesLength=${files.length}',
      );

      final options = await _authOptions();
      options.contentType = 'multipart/form-data';
      _trace(
        '[$traceId] authOptions '
        'contentType=${options.contentType}, '
        'headers=${_headersForLog(options.headers)}',
      );

      final Map<String, dynamic> dataMap = {
        'title': title,
        'description': description,
        'locationLat': locationLat,
        'locationLong': locationLong,
        'isPublic': isPublic.toString(),
        'departmentId': departmentId,
        'categoryId': categoryId,
      };
      if (locationDetail != null) {
        dataMap['locationDetail'] = locationDetail;
      }
      _trace(
        '[$traceId] dataMapPrepared '
        'keys=${dataMap.keys.toList()}, '
        'titleLength=${title.length}, '
        'descriptionLength=${description.length}, '
        'locationLat=${dataMap['locationLat']}, '
        'locationLong=${dataMap['locationLong']}, '
        'isPublic=${dataMap['isPublic']}, '
        'departmentId=${dataMap['departmentId']}, '
        'categoryId=${dataMap['categoryId']}',
      );

      final formData = FormData.fromMap(dataMap);
      _trace(
        '[$traceId] formDataInitial '
        'boundary=${formData.boundary}, '
        'fields=${formData.fields.map(_fieldLogValue).toList()}, '
        'files=${formData.files.length}',
      );

      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        final fileName = _fileNameFromPath(file.path);
        final extension = _extensionFromFileName(fileName);
        final exists = await file.exists();
        final sizeInBytes = exists ? await file.length() : -1;
        final contentType = _contentTypeForFile(fileName);

        _trace(
          '[$traceId] file[$i] beforeMultipart '
          'path="${file.path}", '
          'fileName="$fileName", '
          'extension="$extension", '
          'exists=$exists, '
          'sizeBytes=$sizeInBytes, '
          'size=${exists ? _formatBytes(sizeInBytes) : '<missing>'}, '
          'contentType=$contentType',
        );

        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: contentType,
            ),
          ),
        );
        // Use indexed keys so multipart parsers keep `names` as an array
        // even when only one attachment is uploaded.
        final nameFieldKey = 'names[$i]';
        formData.fields.add(MapEntry(nameFieldKey, fileName));
        _trace(
          '[$traceId] file[$i] addedToFormData '
          'fieldName=files, nameFieldKey=$nameFieldKey, namesField="$fileName"',
        );
      }
      _trace(
        '[$traceId] formDataFinal '
        'fields=${formData.fields.map(_fieldLogValue).toList()}, '
        'files=${formData.files.map((entry) => {'key': entry.key, 'fileName': entry.value.filename, 'contentType': entry.value.contentType.toString(), 'length': entry.value.length}).toList()}',
      );

      _trace('[$traceId] POST start');
      final response = await _dio.post(
        '/mahasiswa/report/create',
        data: formData,
        options: options,
      );
      _trace(
        '[$traceId] POST response '
        'elapsedMs=${stopwatch.elapsedMilliseconds}, '
        'statusCode=${response.statusCode}, '
        'statusMessage=${response.statusMessage}, '
        'responseType=${response.data.runtimeType}, '
        'headers=${response.headers.map}, '
        'data=${_stringifyForLog(response.data)}',
      );

      final body = response.data as Map<String, dynamic>;
      final success = body['status'] == 'success';
      final message = _messageFromResponseData(body);
      _trace('[$traceId] parsedResponse success=$success message="$message"');
      return (success, message);
    } on DioException catch (e) {
      final responseMessage = _messageFromResponseData(e.response?.data);
      _trace(
        '[$traceId] DIO_EXCEPTION '
        'elapsedMs=${stopwatch.elapsedMilliseconds}, '
        'type=${e.type}, '
        'message=${e.message}, '
        'error=${e.error}, '
        'requestMethod=${e.requestOptions.method}, '
        'requestUri=${e.requestOptions.uri}, '
        'requestContentType=${e.requestOptions.contentType}, '
        'requestHeaders=${_headersForLog(e.requestOptions.headers)}, '
        'responseStatusCode=${e.response?.statusCode}, '
        'responseStatusMessage=${e.response?.statusMessage}, '
        'responseHeaders=${e.response?.headers.map}, '
        'responseData=${_stringifyForLog(e.response?.data)}',
      );
      _trace('[$traceId] DIO_STACK ${e.stackTrace}');
      return (
        false,
        responseMessage.isNotEmpty
            ? responseMessage
            : e.message ?? 'Unknown error',
      );
    } catch (e, stackTrace) {
      _trace(
        '[$traceId] CLIENT_EXCEPTION '
        'elapsedMs=${stopwatch.elapsedMilliseconds}, '
        'error=$e',
      );
      _trace('[$traceId] CLIENT_STACK $stackTrace');
      return (false, 'Client error: $e');
    } finally {
      stopwatch.stop();
      _trace('[$traceId] END elapsedMs=${stopwatch.elapsedMilliseconds}');
    }
  }
}
