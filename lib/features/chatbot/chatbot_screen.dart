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
  final ScrollController _scrollController = ScrollController();
  final List<String> _suggestedQuestions = [
    '\u{1F552} When is the next bus?',
    '\u267F Which buses have ramps?',
    '\u{1F3AB} How much is a ticket?',
    '\u{1F4C5} Bus lines schedule',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(chatIsLoadingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final hasMessages = messages.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chat_bubble_rounded, size: 18),
            ),
            const SizedBox(width: 8),
            Text(l10n.chatbot),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Suggested questions bar
          if (!hasMessages)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2A1F) : const Color(0xFFF0EBD8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u{1F4A1} Quick Questions',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF7CA971) : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _suggestedQuestions.map(_buildQuickChip).toList(),
                    ),
                  ),
                ],
              ),
            ),
          // Messages area (single Expanded — messages + empty state via Stack)
          Expanded(
            child: Stack(
              children: [
                // Empty state
                if (!hasMessages && !isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2E20) : const Color(0xFFE8F3E5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.smart_toy_rounded,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.chatPlaceholder,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFB0C4AE) : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ask about bus times, fares, routes and more',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? const Color(0xFF6B8068) : AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Messages list (always takes full space, sits on top)
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isLoading && index == messages.length) {
                      return _buildTypingIndicator();
                    }
                    final msg = messages[index];
                    final isUser = msg['role'] == 'user';
                    return _buildMessageBubble(
                      isUser: isUser,
                      content: msg['content'] ?? '',
                      surfaceColor: surfaceColor,
                    );
                  },
                ),
              ],
            ),
          ),
          // Divider above input
          Container(
            height: 1,
            color: isDark ? const Color(0xFF2A3A2E) : Colors.black.withOpacity(0.06),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151F17) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Mic button
                Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () => _startVoiceInput(ref),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF253528) : const Color(0xFFF5F0D6),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Icon(Icons.mic_rounded, size: 22, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Text field
                Expanded(
                  child: TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: l10n.chatPlaceholder,
                      hintStyle: TextStyle(
                        color: isDark ? const Color(0xFF6B8068) : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF253528) : const Color(0xFFF5F3E8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.volume_up_outlined, size: 20,
                          color: isDark ? const Color(0xFF6B8068) : Colors.grey.shade400,
                        ),
                        tooltip: l10n.voiceOutput,
                        onPressed: () {},
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        _sendMessage(ref, text.trim());
                        _textController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Send button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        final text = _textController.text.trim();
                        if (text.isNotEmpty) {
                          _sendMessage(ref, text);
                          _textController.clear();
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String question) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF253528) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF3A5040) : AppColors.accent.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // remove the emoji prefix before sending
              final text = question.replaceFirst(RegExp(r'^[^\w\s]+\s*'), '');
              _sendMessage(ref, text);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                question,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFFB0C4AE) : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isUser,
    required String content,
    required Color surfaceColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(isUser: false),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : isDark
                        ? const Color(0xFF1E2E20)
                        : const Color(0xFFF7F5ED),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isUser ? Colors.white : (isDark ? const Color(0xFFE0E8DC) : const Color(0xFF1E2820)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUser
            ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight])
            : const LinearGradient(colors: [Color(0xFFE8F3E5), Color(0xFFABCBA2)]),
        boxShadow: [
          BoxShadow(
            color: isUser ? AppColors.primary.withOpacity(0.25) : AppColors.accent.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
        size: 18,
        color: isUser ? Colors.white : AppColors.primary,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _buildAvatar(isUser: false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 6),
                _buildDot(1),
                const SizedBox(width: 6),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + index * 200),
      tween: Tween<double>(begin: 0.4, end: 1.0),
      builder: (context, value, _) {
        return Icon(
          Icons.circle,
          size: 10 * value,
          color: AppColors.primaryLight.withOpacity(0.4 + 0.6 * value),
        );
      },
    );
  }

  Future<void> _sendMessage(WidgetRef ref, String text) async {
    final langCode = ref.read(languageCodeProvider);

    print('Chatbot: Sending message: $text');

    ref.read(chatMessagesProvider.notifier).state = [
      ...ref.read(chatMessagesProvider),
      {'role': 'user', 'content': text},
    ];
    ref.read(chatIsLoadingProvider.notifier).state = true;
    _scrollToBottom();

    final repo = ref.read(chatRepositoryProvider);
    final response = await repo.sendQuery(text, langCode);

    print('Chatbot: Received response: $response');

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
