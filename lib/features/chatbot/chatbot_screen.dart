import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers.dart';

TextSpan parseChatText(String text, TextStyle baseStyle) {
  final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
  final List<TextSpan> spans = [];
  int lastIndex = 0;

  for (final match in boldRegex.allMatches(text)) {
    // Add text before the bold
    if (match.start > lastIndex) {
      spans.add(TextSpan(text: text.substring(lastIndex, match.start), style: baseStyle));
    }
    // Add the bold text
    spans.add(TextSpan(
      text: match.group(1),
      style: baseStyle.copyWith(fontWeight: FontWeight.bold),
    ));
    lastIndex = match.end;
  }

  // Add remaining text
  if (lastIndex < text.length) {
    spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
  }

  return TextSpan(children: spans);
}

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;
  bool _isSpeaking = false;
  List<String> _getSuggestedQuestions(AppLocalizations l10n) {
    return [
      l10n.suggestedQuestion1,
      l10n.suggestedQuestion2,
      l10n.suggestedQuestion3,
      l10n.suggestedQuestion4,
    ];
  }

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
            Expanded(
              child: Text(
                l10n.chatbot,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isSpeaking)
            IconButton(
              icon: const Icon(Icons.volume_off_rounded),
              tooltip: l10n.stopTalking,
              onPressed: () {
                ref.read(ttsServiceProvider).stop();
                setState(() => _isSpeaking = false);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
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
                        '\u{1F4A1} ${l10n.quickQuestions}',
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
                          children: _getSuggestedQuestions(l10n).map(_buildQuickChip).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              // Messages area
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
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryLight.withOpacity(0.1)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.05),
                                      blurRadius: 40,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 64,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                l10n.chatPlaceholder,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.chatbotSubtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Messages list
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Extra bottom padding for floating input
                      itemCount: messages.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (isLoading && index == messages.length) {
                          return _buildTypingIndicator();
                        }
                        final msg = messages[index];
                        final isUser = msg['role'] == 'user';
                        
                        return _DriftingBubble(
                          isUser: isUser,
                          content: msg['content'] ?? '',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Floating Input Island
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isListening)
                              _ListeningPulse(color: AppColors.primaryLight),
                            IconButton(
                              onPressed: () async {
                                if (_isSpeaking) {
                                  await ref.read(ttsServiceProvider).stop();
                                  if (mounted) setState(() => _isSpeaking = false);
                                  // After stopping speech, start listening immediately (interrupting)
                                  _startVoiceInput(ref);
                                } else if (_isListening) {
                                  ref.read(sttServiceProvider).stop();
                                  setState(() => _isListening = false);
                                } else {
                                  _startVoiceInput(ref);
                                }
                              },
                              icon: Icon(
                                _isSpeaking 
                                    ? Icons.hearing_rounded 
                                    : (_isListening ? Icons.stop_circle_rounded : Icons.mic_none_rounded),
                                color: (_isListening || _isSpeaking) ? Colors.redAccent : AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: l10n.chatPlaceholder,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onSubmitted: (text) {
                              if (text.trim().isNotEmpty) {
                                _sendMessage(ref, text.trim());
                                _textController.clear();
                              }
                            },
                          ),
                        ),
                        if (_isSpeaking)
                          IconButton(
                            icon: const Icon(Icons.volume_off_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              ref.read(ttsServiceProvider).stop();
                              setState(() => _isSpeaking = false);
                            },
                          ),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            onPressed: () {
                              final text = _textController.text.trim();
                              if (text.isNotEmpty) {
                                _sendMessage(ref, text);
                                _textController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const _DriftingAvatar(isUser: false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
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

    // 1. Gently mask the text JUST for the UI display
    String displayString = text
        .replaceAll(RegExp(r'north korea', caseSensitive: false), 'Nassria')
        .replaceAll(RegExp(r'bendford', caseSensitive: false), 'Bab Bhar')
        .replaceAll(RegExp(r'airport', caseSensitive: false), 'Aéroport');

    debugPrint('Chatbot: Sending message: $text');

    // 2. Add the CLEANED text to the chat UI
    ref.read(chatMessagesProvider.notifier).state = [
      ...ref.read(chatMessagesProvider),
      {'role': 'user', 'content': displayString}, // <-- Use displayString here
    ];
    ref.read(chatIsLoadingProvider.notifier).state = true;
    _scrollToBottom();

    // 3. Send the original or cleaned text to Gemini (it will figure it out using the prompt!)
    final repo = ref.read(chatRepositoryProvider);
    final response = await repo.sendQuery(displayString, langCode);

    debugPrint('Chatbot: Received response: $response');

    if (!mounted) return;

    ref.read(chatMessagesProvider.notifier).state = [
      ...ref.read(chatMessagesProvider),
      {'role': 'assistant', 'content': response},
    ];
    ref.read(chatIsLoadingProvider.notifier).state = false;

    // Read aloud if voice enabled
    if (ref.read(voiceAlertsEnabledProvider)) {
      final tts = ref.read(ttsServiceProvider);
      if (mounted) setState(() => _isSpeaking = true);
      await tts.speak(response, locale: langCode);
      if (mounted) setState(() => _isSpeaking = false);
    }
    _scrollToBottom();
  }

  Future<void> _startVoiceInput(WidgetRef ref) async {
    final stt = ref.read(sttServiceProvider);
    final l10n = AppLocalizations.of(context);

    setState(() => _isListening = true);

    try {
      final result = await stt.startListening(ref.read(localeStringProvider));
      if (!mounted) return;
      
      // If we are still listening (haven't manually stopped), update state
      if (_isListening) {
        setState(() => _isListening = false);

        if (result != null && result.isNotEmpty) {
          _sendMessage(ref, result);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.error),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.redAccent.withOpacity(0.8),
              ),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isListening = false);
    }
  }
}

class _ListeningPulse extends StatefulWidget {
  final Color color;
  const _ListeningPulse({required this.color});

  @override
  State<_ListeningPulse> createState() => _ListeningPulseState();
}

class _ListeningPulseState extends State<_ListeningPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildPulse(_controller.value),
            _buildPulse((_controller.value + 0.5) % 1.0),
          ],
        );
      },
    );
  }

  Widget _buildPulse(double value) {
    return Container(
      width: 44 + (40 * value),
      height: 44 + (40 * value),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.color.withOpacity(1.0 - value),
          width: 2,
        ),
      ),
    );
  }
}

class _DriftingBubble extends StatefulWidget {
  final bool isUser;
  final String content;

  const _DriftingBubble({required this.isUser, required this.content});

  @override
  State<_DriftingBubble> createState() => _DriftingBubbleState();
}

class _DriftingBubbleState extends State<_DriftingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _controller.value,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isUser) const _DriftingAvatar(isUser: false),
            const SizedBox(width: 12),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: widget.isUser ? AppColors.primaryGradient : null,
                  color: !widget.isUser 
                      ? (isDark ? Colors.white.withOpacity(0.08) : Colors.white)
                      : null,
                  borderRadius: BorderRadius.circular(24).copyWith(
                    bottomLeft: widget.isUser ? const Radius.circular(24) : const Radius.circular(4),
                    bottomRight: widget.isUser ? const Radius.circular(4) : const Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: !widget.isUser ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
                ),
                child: Text.rich(
                  parseChatText(
                    widget.content,
                    TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: widget.isUser ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (widget.isUser) const _DriftingAvatar(isUser: true),
          ],
        ),
      ),
    );
  }
}

class _DriftingAvatar extends StatelessWidget {
  final bool isUser;
  const _DriftingAvatar({required this.isUser, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUser
            ? AppColors.primaryGradient
            : LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.2)]),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: (isUser ? AppColors.primary : Colors.black).withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person_outline_rounded : Icons.auto_awesome_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}
