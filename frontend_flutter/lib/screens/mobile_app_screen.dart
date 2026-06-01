import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/apk_download_launcher.dart';

class MobileAppScreen extends StatelessWidget {
  const MobileAppScreen({super.key});

  static final Uri apkUri = Uri.parse(
    '${ApiService.baseUrl.replaceFirst(RegExp(r'/api/?$'), '')}/downloads/student-inquiry.apk',
  );

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 760;

    return Scaffold(
      backgroundColor: const Color(0xfff4f7fb),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfffbfcff), Color(0xfff3f8fb), Color(0xffeef4fb)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(isNarrow ? 16 : 28, 24,
              isNarrow ? 16 : 28, 32),
          children: [
            _DownloadHero(onDownload: () => _download(context)),
            const SizedBox(height: 22),
            if (isNarrow) ...[
              _ApkCard(onDownload: () => _download(context)),
              const SizedBox(height: 16),
              const _InstallGuide(),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _ApkCard(onDownload: () => _download(context)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(flex: 2, child: _InstallGuide()),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context) async {
    final opened = await openApkDownload(apkUri);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          opened
              ? 'Opening APK download...'
              : 'Download is available from the web version only: $apkUri',
        ),
      ),
    );
  }
}

class _DownloadHero extends StatelessWidget {
  const _DownloadHero({required this.onDownload});

  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff596bdd), Color(0xff5db4a8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff596bdd).withValues(alpha: 0.22),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -64, top: -84, child: _HeroGlow(size: 220)),
          Positioned(right: 90, bottom: -94, child: _HeroGlow(size: 170)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroBadge(),
                    const SizedBox(height: 18),
                    Text(
                      'Student Inquiry Android App',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.08,
                              ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Download and install the APK for faster access to inquiries, responses, and activity updates.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.84),
                            height: 1.45,
                          ),
                    ),
                  ],
                );

                final button = FilledButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Download APK'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xff4f67d8),
                  ),
                );

                if (constraints.maxWidth < 760) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [copy, const SizedBox(height: 20), button],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 24),
                    button,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ApkCard extends StatelessWidget {
  const _ApkCard({required this.onDownload});

  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return _SoftPanel(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xffe8f6ef),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.android_outlined,
                    color: Color(0xff4c9a73),
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'student-inquiry.apk',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: const Color(0xff253044),
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Android package installer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xff718096),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _MetaRow(label: 'File path', value: MobileAppScreen.apkUri.path),
            const SizedBox(height: 10),
            _MetaRow(label: 'Install type', value: 'Manual APK install'),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Download APK'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstallGuide extends StatelessWidget {
  const _InstallGuide();

  @override
  Widget build(BuildContext context) {
    return const _SoftPanel(
      child: Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Install Guide',
              style: TextStyle(
                color: Color(0xff253044),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 18),
            _InstallStep(
              number: '1',
              title: 'Download the APK',
              detail: 'Tap Download APK and wait for the file to finish.',
            ),
            SizedBox(height: 16),
            _InstallStep(
              number: '2',
              title: 'Open the file',
              detail: 'Choose the APK from your browser or file manager.',
            ),
            SizedBox(height: 16),
            _InstallStep(
              number: '3',
              title: 'Allow install',
              detail: 'If Android asks, allow this source and tap Install.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InstallStep extends StatelessWidget {
  const _InstallStep({
    required this.number,
    required this.title,
    required this.detail,
  });

  final String number;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xff4f67d8),
          foregroundColor: Colors.white,
          child: Text(number),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xff253044),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: const TextStyle(color: Color(0xff718096)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffdde6f1)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xff718096),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff253044),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftPanel extends StatelessWidget {
  const _SoftPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffdde6f1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff202838).withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.android_outlined, color: Colors.white, size: 17),
            SizedBox(width: 8),
            Text(
              'Android Installer',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroGlow extends StatelessWidget {
  const _HeroGlow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.10),
      ),
    );
  }
}
