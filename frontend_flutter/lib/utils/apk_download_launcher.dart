import 'apk_download_launcher_stub.dart'
    if (dart.library.html) 'apk_download_launcher_web.dart';

Future<bool> openApkDownload(Uri uri) => openApkDownloadUrl(uri);
