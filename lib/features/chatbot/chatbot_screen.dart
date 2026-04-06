import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';
import '../../core/services/stt_service.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(chatIsLoadingProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.chatbot),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Suggested questions
          Padding(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _suggestedChip('When is the next bus?'),
                  _suggestedChip('Which buses have ramps?'),
                  _suggestedChip('How much is a ticket?'),
                  _suggestedChip('Bus lines schedule'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primaryLight : (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          // Input field
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: l10n.chatPlaceholder,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _sendMessage(ref, text.trim());
                        _textController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _startVoiceInput(ref),
                  icon: const Icon(Icons.mic, size: 28),
                  tooltip: l10n.voiceInput,
                  iconSize: 32,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () {
                    // Voice output toggle placeholder
                  },
                  icon: const Icon(Icons.volume_up, size: 28),
                  tooltip: l10n.voiceOutput,
                  iconSize: 32,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      _sendMessage(ref, text);
                      _textController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    minimumSize: const Size(48, 48),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestedChip(String question) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(question),
        selected: false,
        onSelected: (selected) {
          if (selected) {
            final ref = this.ref;
            _sendMessage(ref, question);
          }
        },
      ),
    );
  }

  Future<void> _sendMessage(WidgetRef ref, String text) async {
    final langCode = ref.read(languageCodeProvider);

    ref.read(chatMessagesProvider.notifier).state = [
      ...ref.read(chatMessagesProvider),
      {'role': 'user', 'content': text},
    ];
    ref.read(chatIsLoadingProvider.notifier).state = true;

    final repo = ref.read(chatRepositoryProvider);
    final response = await repo.sendQuery(text, langCode);

    if (!mounted) return;

    ref.read(chatMessagesProvider.notifier).state = [
      ...ref.read(chatMessagesProvider),
      {'role': 'assistant', 'content': response},
    ];
    ref.read(chatIsLoadingProvider.notifier).state = false;

    // Read aloud if voice enabled
    if (ref.read(voiceAlertsEnabledProvider)) {
      final tts = ref.read(ttsServiceProvider);
      await tts.speak(response, locale: langCode);
    }
  }

  Future<void> _startVoiceInput(WidgetRef ref) async {
    final stt = SttService();

    final result = await stt.startListening(ref.read(localeStringProvider));
    if (result != null && result.isNotEmpty) {
      if (!mounted) return;
      _sendMessage(ref, result);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).error)),
      );
    }
  }
}
