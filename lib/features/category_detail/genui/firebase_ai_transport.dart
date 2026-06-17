import 'package:firebase_ai/firebase_ai.dart' as fb;
import 'package:genui/genui.dart';

/// A genui [Transport] backed by Firebase AI Logic (Gemini).
///
/// genui is transport-agnostic: it only needs a component that turns a user
/// [ChatMessage] into a stream of text chunks (which encode the A2UI protocol).
/// We stream `generateContentStream` straight into an [A2uiTransportAdapter],
/// which parses the chunks into [A2uiMessage]s that drive the live UI.
class FirebaseAiTransport implements Transport {
  FirebaseAiTransport({
    required String modelName,
    required String systemInstruction,
  }) : _model = fb.FirebaseAI.googleAI().generativeModel(
         model: modelName,
         systemInstruction: fb.Content.system(systemInstruction),
       );

  final fb.GenerativeModel _model;
  final A2uiTransportAdapter _adapter = A2uiTransportAdapter();
  final StringBuffer _captured = StringBuffer();

  @override
  Stream<A2uiMessage> get incomingMessages => _adapter.incomingMessages;

  @override
  Stream<String> get incomingText => _adapter.incomingText;

  /// The full A2UI text produced so far — persisted so the surface can be
  /// replayed later without another LLM call.
  String get capturedOutput => _captured.toString();

  @override
  Future<void> sendRequest(ChatMessage message) async {
    final stream = _model.generateContentStream([
      fb.Content.text(message.text),
    ]);
    await for (final chunk in stream) {
      final text = chunk.text;
      if (text != null && text.isNotEmpty) {
        _captured.write(text);
        _adapter.addChunk(text);
      }
    }
  }

  @override
  void dispose() => _adapter.dispose();
}
