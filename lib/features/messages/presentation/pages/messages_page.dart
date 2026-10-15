import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/app_nav.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/messages/data/models/chat_thread.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_bloc.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_event.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_state.dart';
import 'package:outmed/features/messages/presentation/pages/widgets/conversation_list_shimmer.dart';
import 'package:outmed/features/messages/presentation/pages/widgets/conversation_tile.dart';
import 'package:outmed/features/messages/presentation/pages/widgets/messages_filter_chip.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({this.showBack = false, super.key});

  final bool showBack;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async =>
              context.read<ChatBloc>().add(const ChatStarted()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
            children: [
              Row(
                children: [
                  if (widget.showBack)
                    const IconButton(
                      onPressed: AppNav.pop,
                      icon: Icon(Icons.arrow_back_rounded),
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
                onChanged: (value) =>
                    context.read<ChatBloc>().add(ChatSearchChanged(value)),
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
              BlocSelector<ChatBloc, ChatState, String>(
                selector: (state) => state.filter,
                builder: (context, filter) => Wrap(
                  spacing: 8,
                  children: [
                    for (final (key, label) in const [
                      ('all', 'all'),
                      ('unread', 'unread'),
                      ('order', 'order_filter'),
                    ])
                      MessagesFilterChip(
                        label: label.tr,
                        selected: filter == key,
                        onTap: () => context.read<ChatBloc>().add(
                          ChatFilterChanged(key),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              BlocSelector<
                ChatBloc,
                ChatState,
                (LoadStatus, List<ChatThread>, String)
              >(
                selector: (state) => (
                  state.threadsStatus,
                  state.visibleThreads,
                  state.errorMessage,
                ),
                builder: (context, data) {
                  final (status, threads, error) = data;
                  if (status == LoadStatus.loading && threads.isEmpty) {
                    return const ConversationListShimmer();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (status == LoadStatus.failure)
                        InlineErrorText(message: error),
                      if (threads.isEmpty && status != LoadStatus.failure)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              'no_conversations'.tr,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ),
                        ),
                      for (final thread in threads)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ConversationTile(thread: thread),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
