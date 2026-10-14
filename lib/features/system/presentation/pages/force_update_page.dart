import 'package:flutter/material.dart';
import 'package:outmed/core/l10n/tr.dart';

class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('force_update_title'.tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('force_update_body'.tr, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
