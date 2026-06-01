class Inquiry {
  Inquiry({
    required this.id,
    required this.departmentId,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    this.departmentName,
    this.studentName,
    this.studentEmail,
    this.studentIdentifier,
    this.studentPhone,
    this.studentAddress,
    this.studentBio,
    this.createdAt,
    this.resolutionNotes,
    this.messages = const [],
  });

  final int id;
  final int departmentId;
  final String category;
  final String subject;
  final String description;
  final String status;
  final int priority;
  final String? departmentName;
  final String? studentName;
  final String? studentEmail;
  final String? studentIdentifier;
  final String? studentPhone;
  final String? studentAddress;
  final String? studentBio;
  final String? createdAt;
  final String? resolutionNotes;
  final List<InquiryMessage> messages;

  factory Inquiry.fromJson(Map<String, dynamic> json) => Inquiry(
        id: json['id'],
        departmentId: json['department_id'],
        category: json['category'] ?? 'registrar',
        subject: json['subject'] ?? '',
        description: json['description'] ?? '',
        status: json['status'] ?? 'pending',
        priority: json['priority'] ?? 1,
        departmentName: json['department']?['name'],
        studentName: json['student']?['name'],
        studentEmail: json['student']?['email'],
        studentIdentifier: json['student']?['user_identifier'],
        studentPhone: json['student']?['phone'],
        studentAddress: json['student']?['address'],
        studentBio: json['student']?['bio'],
        createdAt: json['created_at'],
        resolutionNotes: json['resolution_notes'],
        messages: ((json['messages'] ?? []) as List)
            .map((item) => InquiryMessage.fromJson(item))
            .toList(),
      );
}

class InquiryMessage {
  InquiryMessage({
    required this.id,
    required this.message,
    this.senderName,
    this.senderType,
    this.createdAt,
  });

  final int id;
  final String message;
  final String? senderName;
  final String? senderType;
  final String? createdAt;

  bool get isDepartmentResponse =>
      senderType == 'department_admin' || senderType == 'super_admin';

  factory InquiryMessage.fromJson(Map<String, dynamic> json) => InquiryMessage(
        id: json['id'],
        message: json['message'] ?? '',
        senderName: json['user']?['name'],
        senderType: json['user']?['user_type'],
        createdAt: json['created_at'],
      );
}
