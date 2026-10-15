import 'package:equatable/equatable.dart';
import 'package:outmed/core/network/api_json.dart';

class FaqItem extends Equatable {
  const FaqItem({
    required this.question,
    required this.answer,
    this.category = '',
  });

  final String question;
  final String answer;
  final String category;

  static FaqItem? tryParse(Map<String, Object?> json) {
    final question = ApiJson.text(json, const ['question', 'title']);
    final answer = ApiJson.text(json, const ['answer', 'content', 'body']);
    if (question == null || answer == null) return null;
    return FaqItem(
      question: question,
      answer: answer,
      category: ApiJson.text(json, const ['category']) ?? '',
    );
  }

  @override
  List<Object?> get props => [question, answer, category];
}
