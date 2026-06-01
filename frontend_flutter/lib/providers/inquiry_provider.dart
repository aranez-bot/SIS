import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../models/department.dart';
import '../models/faq_item.dart';
import '../models/inquiry.dart';
import '../services/api_service.dart';

class InquiryProvider extends ChangeNotifier {
  final api = ApiService();

  List<Inquiry> inquiries = [];
  List<Inquiry> recentInquiries = [];
  List<Department> departments = [];
  List<AppNotification> notifications = [];
  List<FaqItem> faqs = [];
  List<FaqItem> departmentFaqs = [];
  Map<String, dynamic> counts = {};
  int unreadNotifications = 0;
  bool isLoading = false;
  String? error;

  static const categories = [
    'enrollment',
    'grades',
    'scholarship',
    'admission',
    'finance',
    'registrar',
  ];

  void setToken(String? token) {
    api.token = token;
    ApiService.sharedToken = token;
  }

  Future<void> loadDashboard() async {
    final response = await api.get('/dashboard');
    counts = response['counts'] ?? {};
    unreadNotifications = response['unread_notifications'] ?? 0;
    notifications = ((response['recent_notifications'] ?? []) as List)
        .map((item) => AppNotification.fromJson(item))
        .toList();
    recentInquiries = ((response['recent'] ?? []) as List)
        .map((item) => Inquiry.fromJson(item))
        .toList();
    notifyListeners();
  }

  Future<void> loadDepartments() async {
    final response = await api.get('/departments');
    departments = ((response['data'] ?? []) as List)
        .map((item) => Department.fromJson(item))
        .toList();
    notifyListeners();
  }

  Future<void> loadInquiries({
    String? search,
    String? status,
    String? category,
    int? departmentId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final params = <String, String>{
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (category != null && category.isNotEmpty) 'category': category,
        if (departmentId != null) 'department_id': '$departmentId',
        if (fromDate != null) 'created_from': _dateParam(fromDate),
        if (toDate != null) 'created_to': _dateParam(toDate),
      };
      final query =
          params.isEmpty ? '' : '?${Uri(queryParameters: params).query}';
      final response = await api.get('/inquiries$query');
      final paginated = response['data']['data'] as List;
      inquiries = paginated.map((item) => Inquiry.fromJson(item)).toList();
    } catch (exception) {
      error = exception.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _dateParam(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<Inquiry> loadInquiry(int id) async {
    final response = await api.get('/inquiries/$id');
    return Inquiry.fromJson(response['data']);
  }

  Future<void> loadNotifications() async {
    final response = await api.get('/notifications');
    final paginated = response['data']['data'] as List;
    notifications =
        paginated.map((item) => AppNotification.fromJson(item)).toList();
    unreadNotifications = notifications.where((item) => item.isUnread).length;
    notifyListeners();
  }

  Future<void> markNotificationRead(int id) async {
    await api.post('/notifications/$id/read', {});
    await loadNotifications();
    await loadDashboard();
  }

  Future<void> loadFaqs() async {
    final response = await api.get('/faqs');
    faqs = ((response['data'] ?? []) as List)
        .map((item) => FaqItem.fromJson(item))
        .toList();
    notifyListeners();
  }

  Future<void> loadDepartmentFaqs() async {
    final response = await api.get('/department/faqs');
    departmentFaqs = ((response['data'] ?? []) as List)
        .map((item) => FaqItem.fromJson(item))
        .toList();
    notifyListeners();
  }

  Future<void> saveDepartmentFaq({
    int? id,
    required String question,
    required String answer,
    String? category,
    required bool isActive,
  }) async {
    final body = {
      'question': question,
      'answer': answer,
      'category': category,
      'is_active': isActive,
    };

    if (id == null) {
      await api.post('/department/faqs', body);
    } else {
      await api.put('/department/faqs/$id', body);
    }

    await loadDepartmentFaqs();
  }

  Future<void> deleteDepartmentFaq(int id) async {
    await api.delete('/department/faqs/$id');
    departmentFaqs.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> saveInquiry({
    int? id,
    required int departmentId,
    required String category,
    required String subject,
    required String description,
    required int priority,
  }) async {
    final body = {
      'department_id': departmentId,
      'category': category,
      'subject': subject,
      'description': description,
      'priority': priority,
    };

    if (id == null) {
      await api.post('/inquiries', body);
    } else {
      await api.put('/inquiries/$id', body);
    }

    await loadInquiries();
    await loadDashboard();
  }

  Future<void> sendMessage(
    int inquiryId,
    String message, {
    Uint8List? attachmentBytes,
    String? attachmentName,
  }) async {
    if (attachmentBytes != null && attachmentName != null) {
      await api.postMultipart(
        '/inquiries/$inquiryId/messages',
        fields: {
          if (message.trim().isNotEmpty) 'message': message.trim(),
        },
        file: ApiUploadFile(
          field: 'attachment',
          filename: attachmentName,
          bytes: attachmentBytes,
        ),
      );
    } else {
      await api.post('/inquiries/$inquiryId/messages', {'message': message});
    }
    await loadDashboard();
  }

  Future<void> updateInquiryStatus({
    required int inquiryId,
    required String status,
    String? resolutionNotes,
  }) async {
    await api.put('/inquiries/$inquiryId', {
      'status': status,
      'resolution_notes': resolutionNotes,
    });
    await loadInquiries();
    await loadDashboard();
  }

  Future<void> forwardInquiry({
    required int inquiryId,
    required int departmentId,
    String? forwardNote,
  }) async {
    await api.put('/inquiries/$inquiryId/forward', {
      'department_id': departmentId,
      'forward_note': forwardNote,
    });
    await loadInquiries();
    await loadDashboard();
  }

  Future<void> deleteInquiry(int id) async {
    await api.delete('/inquiries/$id');
    inquiries.removeWhere((item) => item.id == id);
    notifyListeners();
    await loadDashboard();
  }
}
