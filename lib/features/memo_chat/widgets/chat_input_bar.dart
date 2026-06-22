import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';

/// The bottom "나에게 보내기" composer: a rounded multiline field plus a send
/// button. Manages its own [TextEditingController] and clears on send.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    this.hintText,
    this.offerClipboard = false,
  });

  final ValueChanged<String> onSend;
  final String? hintText;

  /// Whether to offer a one-tap "paste what you copied" suggestion. Only the
  /// main capture chat enables this; category rooms don't.
  final bool offerClipboard;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  /// Clipboard text offered as a one-tap paste, or null when nothing is offered.
  String? _clipboardSuggestion;

  /// Clipboard text we should NOT offer again — set when the user dismisses the
  /// chip OR accepts the paste — until the clipboard contents change to
  /// something else.
  String? _suppressed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
      // Hide the paste chip the moment the user starts typing.
      if (has && _clipboardSuggestion != null) {
        setState(() => _clipboardSuggestion = null);
      }
    });
    if (widget.offerClipboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferPaste());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check whenever the user returns to the app — they may have just copied
    // something in another app to paste here.
    if (state == AppLifecycleState.resumed) _maybeOfferPaste();
  }

  /// Offers a clipboard paste only when the field is empty. Uses [hasStrings]
  /// (which does NOT trip iOS's "pasted from…" banner) to gate the actual read.
  Future<void> _maybeOfferPaste() async {
    if (!widget.offerClipboard) return;
    if (_controller.text.trim().isNotEmpty) return;
    if (!await Clipboard.hasStrings()) {
      if (mounted && _clipboardSuggestion != null) {
        setState(() => _clipboardSuggestion = null);
      }
      return;
    }
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (!mounted) return;
    if (text == null || text.isEmpty || text == _suppressed) return;
    if (text == _clipboardSuggestion) return;
    setState(() => _clipboardSuggestion = text);
  }

  void _usePaste() {
    final text = _clipboardSuggestion;
    if (text == null) return;
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
    setState(() {
      // Don't re-offer what was just pasted until the clipboard changes.
      _suppressed = text;
      _clipboardSuggestion = null;
    });
    _focusNode.requestFocus();
  }

  void _dismissPaste() {
    setState(() {
      _suppressed = _clipboardSuggestion;
      _clipboardSuggestion = null;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: c.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_clipboardSuggestion != null)
              _ClipboardChip(
                text: _clipboardSuggestion!,
                onTap: _usePaste,
                onDismiss: _dismissPaste,
              ),
            Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? '생각나는 걸 그냥 적어요',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SendButton(enabled: _hasText, onTap: _submit),
            ],
          ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? context.colors.primary : context.appColors.divider;
    return AnimatedContainer(
      duration: AppDurations.fast,
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: IconButton(
        onPressed: enabled ? onTap : null,
        icon: const Icon(Icons.arrow_upward_rounded),
        color: Colors.white,
        iconSize: 22,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// A one-tap "paste what you just copied" suggestion shown above the composer
/// when the clipboard holds text and the field is empty.
class _ClipboardChip extends StatelessWidget {
  const _ClipboardChip({
    required this.text,
    required this.onTap,
    required this.onDismiss,
  });

  final String text;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final preview = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        0,
      ),
      child: Material(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.content_paste_rounded,
                  size: 18,
                  color: context.colors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: context.textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: '붙여넣기  ',
                          style: TextStyle(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: preview,
                          style: TextStyle(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                InkResponse(
                  onTap: onDismiss,
                  radius: 18,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
