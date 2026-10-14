import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/route_args.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  late final List<(bool, String)> messages;
  var _hydrated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;
    final name = RouteArgs.maybe<Object>(context) as String? ?? 'HealthCare Supplies';
    messages = [
      (false, 'Hello, this is $name. How can we help with your order?'),
      (true, 'Can you confirm stock and delivery time?'),
      (false, 'Yes, we can dispatch the requested quantity.'),
    ];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = RouteArgs.maybe<Object>(context) as String? ?? 'HealthCare Supplies';
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text(name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final mine = messages[index].$1;
                return Align(
                  alignment: mine
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: mine ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.glossyShadow,
                    ),
                    child: Text(
                      messages[index].$2,
                      style: TextStyle(
                        color: mine ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'type_message'.tr,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        setState(() => messages.add((true, text)));
                        controller.clear();
                      },
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
