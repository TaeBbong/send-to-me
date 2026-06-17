import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';

/// A single chat bubble. For the note-to-self timeline every memo is
/// [outgoing]; assistant/system notices use the incoming style.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.outgoing,
    required this.child,
    this.footer,
    this.onTap,
    this.onLongPress,
  });

  final bool outgoing;
  final Widget child;

  /// Small metadata row shown beneath the bubble (e.g. time + status).
  final Widget? footer;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bg = outgoing ? c.outgoingBubble : c.incomingBubble;
    final fg = outgoing ? c.onOutgoingBubble : c.onIncomingBubble;

    final radius = BorderRadius.only(
      topLeft: AppRadius.bubble,
      topRight: AppRadius.bubble,
      bottomLeft: outgoing ? AppRadius.bubble : AppRadius.bubbleTail,
      bottomRight: outgoing ? AppRadius.bubbleTail : AppRadius.bubble,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment:
            outgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            child: Material(
              color: bg,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                onLongPress: onLongPress,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: DefaultTextStyle.merge(
                    style: context.textTheme.bodyLarge?.copyWith(color: fg),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs, left: 2, right: 2),
              child: footer!,
            ),
        ],
      ),
    );
  }
}
