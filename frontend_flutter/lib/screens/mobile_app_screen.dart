import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/apk_download_launcher.dart';
import '../widgets/app_ui.dart';

class MobileAppScreen extends StatelessWidget {
  const MobileAppScreen({super.key});

  static const _configuredApkUrl = String.fromEnvironment('APK_DOWNLOAD_URL');

  static final Uri apkUri = Uri.parse(
    _configuredApkUrl.isNotEmpty
        ? _configuredApkUrl
        : '${ApiService.baseUrl.replaceFirst(RegExp(r'/api/?$'), '')}/mobile-app/download',
  );

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      children: [
        AppHeader(
          icon: Icons.android_outlined,
          title: 'Android App',
          subtitle: 'Download the current APK release.',
          trailing: FilledButton.icon(
            onPressed: () => _download(context),
            icon: const Icon(Icons.download_outlined),
            label: const Text('Download APK'),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final apkCard = _ApkPanel(onDownload: () => _download(context));

            if (constraints.maxWidth < 760) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ApkPanel(),
                  SizedBox(height: 12),
                  _InstallGuide(),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: apkCard),
                const SizedBox(width: 12),
                const Expanded(flex: 2, child: _InstallGuide()),
              ],
            );
          },
        ),
      ],
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
              : 'Download from the web app: $apkUri',
        ),
      ),
    );
  }
}

class _ApkPanel extends StatelessWidget {
  const _ApkPanel({this.onDownload});

  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppIconBox(
                icon: Icons.android_outlined,
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'student-inquiry.apk',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Android package installer',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetaRow(label: 'Source', value: MobileAppScreen.apkUri.host),
          const SizedBox(height: 8),
          const _MetaRow(label: 'Install type', value: 'Manual APK'),
          if (onDownload != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Download APK'),
            ),
          ],
        ],
      ),
    );
  }
}

class _InstallGuide extends StatelessWidget {
  const _InstallGuide();

  @override
  Widget build(BuildContext context) {
    return const AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: 'Install Guide'),
          SizedBox(height: 14),
          _InstallStep(
            number: '1',
            title: 'Download',
            detail: 'Save the APK from the web app.',
          ),
          _InstallStep(
            number: '2',
            title: 'Open',
            detail: 'Open the downloaded file on Android.',
          ),
          _InstallStep(
            number: '3',
            title: 'Install',
            detail: 'Allow the source if Android asks.',
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            foregroundColor: AppColors.primary,
            child: Text(
              number,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
