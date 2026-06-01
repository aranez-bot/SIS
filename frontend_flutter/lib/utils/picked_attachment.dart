import 'dart:typed_data';

class PickedAttachment {
  const PickedAttachment({
    required this.name,
    required this.bytes,
    this.mimeType,
  });

  final String name;
  final Uint8List bytes;
  final String? mimeType;
}
