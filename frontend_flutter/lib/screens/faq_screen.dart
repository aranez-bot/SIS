import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inquiry_provider.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<InquiryProvider>().loadFaqs());
  }

  @override
  Widget build(BuildContext context) {
    final faqs = context.watch<InquiryProvider>().faqs;

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ / Help')),
      body: faqs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: faqs
                  .map(
                    (faq) => Card(
                      child: ExpansionTile(
                        title: Text(faq.question),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [Text(faq.answer)],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
