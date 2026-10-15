import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/core/router/route_args.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/features/messages/data/models/chat_lookup.dart';
import 'package:outmed/features/messages/data/models/chat_message.dart';
import 'package:outmed/features/messages/data/models/chat_thread.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_bloc.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_event.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_state.dart';
import 'package:outmed/features/messages/presentation/pages/widgets/chat_bubble.dart';
import 'package:outmed/features/messages/presentation/pages/widgets/chat_shimmer.dart';
import 'package:outmed/shared/widgets/inline_error_text.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  var _fallbackTitle = '';
  var _opened = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_opened) return;
    _opened = true;
    final extra = RouteArgs.maybe<Object>(context);
    final chat = context.read<ChatBloc>();
    if (extra is ChatLookup) {
      _fallbackTitle = extra.senderName;
      chat.add(ChatNotificationOpened(extra));
      return;
    }
    final thread = switch (extra) {
      final ChatThread value => value,
      final String name => ChatThread(title: name),
      _ => const ChatThread(title: 'OutMed'),
    };
    _fallbackTitle = thread.title;
    chat.add(ChatThreadOpened(thread));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(ChatMessageSent(text));
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: BlocSelector<ChatBloc, ChatState, String>(
          selector: (state) {
            final title = state.active?.title ?? '';
            if (title.isNotEmpty) return title;
            return _fallbackTitle.isNotEmpty ? _fallbackTitle : 'messages'.tr;
          },
          builder: (context, title) => Text(title),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                BlocSelector<
                  ChatBloc,
                  ChatState,
                  (LoadStatus, List<ChatMessage>)
                >(
                  selector: (state) => (state.messagesStatus, state.messages),
                  builder: (context, data) {
                    final (status, messages) = data;
                    if (status == LoadStatus.loading && messages.isEmpty) {
                      return const ChatShimmer();
                    }
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'start_conversation'.tr,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) => ChatBubble(
                        message: messages[messages.length - 1 - index],
                      ),
                    );
                  },
                ),
          ),
          BlocSelector<ChatBloc, ChatState, String>(
            selector: (state) => state.errorMessage,
            builder: (context, error) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InlineErrorText(message: error),
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
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
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
                  BlocSelector<ChatBloc, ChatState, (bool, bool)>(
                    selector: (state) => (
                      state.sending,
                      state.active?.id.isNotEmpty ?? false,
                    ),
                    builder: (context, data) => CircleAvatar(
                      backgroundColor: data.$2
                          ? AppColors.primary
                          : AppColors.muted,
                      child: data.$1
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : IconButton(
                              onPressed: data.$2 ? _send : null,
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                              ),
                            ),
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
