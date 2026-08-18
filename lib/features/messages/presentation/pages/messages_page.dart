import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outmed/config/routes/app_routes.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/shared/widgets/glossy_card.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({this.showBack = false, super.key});

  final bool showBack;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String filter = 'all';

  final conversations = const [
    ('HealthCare Supplies', 'Typing...', '10:24', 2),
    ('Marsh Medical', 'Yes, we can do this!', 'Yesterday', 0),
    ('OutMed Support', 'How can we help you today?', 'Mon', 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
          children: [
            Row(
              children: [
                if (widget.showBack)
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                Expanded(
                  child: Text(
                    'messages'.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              decoration: InputDecoration(
                hintText: 'search_messages'.tr,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'all'.tr,
                  selected: filter == 'all',
                  onTap: () => setState(() => filter = 'all'),
                ),
                _FilterChip(
                  label: 'unread'.tr,
                  selected: filter == 'unread',
                  onTap: () => setState(() => filter = 'unread'),
                ),
                _FilterChip(
                  label: 'order_filter'.tr,
                  selected: filter == 'order',
                  onTap: () => setState(() => filter = 'order'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...conversations
                .where((item) {
                  if (filter == 'unread') return item.$4 > 0;
                  return true;
                })
                .map(
                  (conversation) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlossyCard(
                      onTap: () => Get.toNamed(
                        AppRoutes.chat,
                        arguments: conversation.$1,
                      ),
                      padding: const EdgeInsets.all(13),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primarySoft,
                            child: Text(
                              conversation.$1.substring(0, 1),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  conversation.$1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  conversation.$2,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: conversation.$2 == 'Typing...'
                                        ? AppColors.primary
                                        : AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                conversation.$3,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 10,
                                ),
                              ),
                              if (conversation.$4 > 0) ...[
                                const SizedBox(height: 6),
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    '${conversation.$4}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.muted,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
