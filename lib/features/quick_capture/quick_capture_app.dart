import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('app/quick_capture');

/// The UI for the Android translucent "quick capture" activity, run via the
/// `quickCaptureMain` entry point in `lib/main.dart`.
///
/// This runs in a SEPARATE Flutter engine from the main app (launched by the
/// Quick Settings tile or accessibility shortcut), so it deliberately has NO
/// access to Riverpod, the Drift database, or any app state. It is a tiny,
/// self-contained capture surface: a dimmed scrim with a single input. On send
/// it hands the text to the native side ([_channel] `saveCapture`), which
/// appends it to the shared queue; the main app drains and persists that queue
/// on its next launch/resume (see `QuickCaptureListener`). The activity then
/// finishes.
class QuickCaptureApp extends StatelessWidget {
  const QuickCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3D5AFE),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF3D5AFE),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const _QuickCaptureSheet(),
    );
  }
}

class _QuickCaptureSheet extends StatefulWidget {
  const _QuickCaptureSheet();

  @override
  State<_QuickCaptureSheet> createState() => _QuickCaptureSheetState();
}

class _QuickCaptureSheetState extends State<_QuickCaptureSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    await _channel.invokeMethod<void>('close');
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      await _close();
      return;
    }
    if (_closing) return;
    _closing = true;
    await _channel.invokeMethod<void>('saveCapture', {'text': text});
    await _channel.invokeMethod<void>('close');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        // Tap on the dimmed area dismisses without saving.
        behavior: HitTestBehavior.opaque,
        onTap: _close,
        child: Container(
          color: Colors.black54,
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // swallow taps on the card itself
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                  top: 12,
                ),
                child: Material(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '빠른 메모',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: colors.primary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                autofocus: true,
                                minLines: 1,
                                maxLines: 6,
                                textInputAction: TextInputAction.newline,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                  hintText: '생각나는 걸 그냥 적어요',
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _SendButton(enabled: _hasText, onTap: _submit),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: enabled ? colors.primary : colors.surfaceContainerHighest,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? () => onTap() : null,
          child: Icon(
            Icons.arrow_upward_rounded,
            size: 22,
            color: enabled ? colors.onPrimary : colors.outline,
          ),
        ),
      ),
    );
  }
}
