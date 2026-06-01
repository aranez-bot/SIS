class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.inquiryId,
    this.inquirySubject,
    this.readAt,
    this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final String type;
  final int? inquiryId;
  final String? inquirySubject;
  final String? readAt;
  final String? createdAt;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'],
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        type: json['type'] ?? '',
        inquiryId: json['inquiry_id'],
        inquirySubject: json['inquiry']?['subject'],
        readAt: json['read_at'],
        createdAt: json['created_at'],
      );
}
