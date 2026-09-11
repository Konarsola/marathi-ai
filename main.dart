import 'package:flutter/material.dart';

void main() {
  runApp(const MarathiAI());
}

class MarathiAI extends StatelessWidget {
  const MarathiAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Marathi AI',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('🤖', 'AI Chat', 'काहीही विचारा', const ChatPage()),
      ('✍️', 'AI Generator', 'लेखन तयार करा', const GeneratorPage()),
      ('🌐', 'Translation', 'मराठी ↔ English', const TranslationPage()),
      ('📚', 'Study Helper', 'अभ्यासासाठी मदत', const StudyPage()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🇮🇳 Marathi AI'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'नमस्कार! 👋',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'तुमचा मराठी AI सहाय्यक',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final item = cards[index];

                  return Card(
                    elevation: 3,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => item.$4),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.$1,
                              style: const TextStyle(fontSize: 42),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.$2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.$3,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- AI CHAT ----------------

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  final messages = <Map<String, String>>[];

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'user': text});
      messages.add({
        'ai': 'नमस्कार! 😊 तुमचा प्रश्न मिळाला. '
            'खऱ्या AI उत्तरांसाठी आपण पुढे AI API जोडू शकतो.'
      });
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🤖 AI Chat')),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'तुमचा प्रश्न येथे विचारा 👇',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message.containsKey('user');

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            isUser ? message['user']! : message['ai']!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'काहीही विचारा...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- GENERATOR ----------------

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('✍️ AI Generator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'काय तयार करायचे?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _button(context, '📱 Instagram Caption'),
          _button(context, '📝 अर्ज / पत्र'),
          _button(context, '🎤 Speech'),
          _button(context, '📢 Advertisement'),
          _button(context, '💡 Business Idea'),
        ],
      ),
    );
  }

  Widget _button(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton.tonal(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$text निवडले')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(text, style: const TextStyle(fontSize: 17)),
        ),
      ),
    );
  }
}

// ---------------- TRANSLATION ----------------

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final controller = TextEditingController();
  String result = '';

  void translate() {
    setState(() {
      result = controller.text.isEmpty
          ? 'आधी मजकूर लिहा.'
          : 'Translation: ${controller.text}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌐 Translation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'मराठी किंवा English मजकूर लिहा...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: translate,
                child: const Text('Translate'),
              ),
            ),
            const SizedBox(height: 20),
            Text(result, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

// ---------------- STUDY ----------------

class StudyPage extends StatelessWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📚 Study Helper')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Text('📖', style: TextStyle(fontSize: 30)),
              title: Text('Question Solver'),
              subtitle: Text('तुमचा प्रश्न समजून घेण्यासाठी मदत'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Text('🧠', style: TextStyle(fontSize: 30)),
              title: Text('Notes Maker'),
              subtitle: Text('मोठ्या धड्याचे सोपे notes'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Text('❓', style: TextStyle(fontSize: 30)),
              title: Text('Quiz'),
              subtitle: Text('तुमच्या अभ्यासाचा सराव करा'),
            ),
          ),
        ],
      ),
    );
  }
}
