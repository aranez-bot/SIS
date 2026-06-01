// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'picked_attachment.dart';

Future<PickedAttachment?> pickAttachmentFile() {
  final completer = Completer<PickedAttachment?>();
  final input = html.FileUploadInputElement()
    ..accept = '.pdf,.doc,.docx,.xls,.xlsx,.csv,.txt,.jpg,.jpeg,.png'
    ..click();

  input.onChange.first.then((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;

    if (file == null) {
      completer.complete(null);
      return;
    }

    final reader = html.FileReader();
    reader.onError.first.then((_) {
      if (!completer.isCompleted) completer.completeError('Unable to read file.');
    });
    reader.onLoadEnd.first.then((_) {
      final result = reader.result;
      final bytes = result is ByteBuffer ? Uint8List.view(result) : Uint8List(0);
      if (!completer.isCompleted) {
        completer.complete(PickedAttachment(
          name: file.name,
          bytes: bytes,
          mimeType: file.type.isEmpty ? null : file.type,
        ));
      }
    });
    reader.readAsArrayBuffer(file);
  });

  return completer.future;
}
