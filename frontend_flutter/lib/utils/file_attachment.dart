import 'file_attachment_stub.dart'
    if (dart.library.html) 'file_attachment_web.dart';
import 'picked_attachment.dart';

Future<PickedAttachment?> pickAttachment() => pickAttachmentFile();
