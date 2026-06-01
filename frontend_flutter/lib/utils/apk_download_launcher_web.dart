// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

Future<bool> openApkDownloadUrl(Uri uri) async {
  html.AnchorElement(href: uri.toString())
    ..download = 'student-inquiry.apk'
    ..target = '_blank'
    ..click();

  return true;
}
