import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outmed/core/constants/app_colors.dart';
import 'package:outmed/core/l10n/tr.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_bloc.dart';
import 'package:outmed/features/messages/presentation/bloc/chat_state.dart';

class ChatTypingLabel extends StatelessWidget {
  const ChatTypingLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ChatBloc, ChatState, bool>(
      selector: (state) => state.peerTyping,
      builder: (context, typing) => typing
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(
                'typing_now'.tr,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
