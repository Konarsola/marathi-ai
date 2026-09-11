import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const backendUrl = 'http://10.0.2.2:3000';

void main() => runApp(const MarathiAI());

class MarathiAI extends StatelessWidget {
  const MarathiAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Marathi AI',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepOrange),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('🤖', 'AI Chat', 'मराठीत प्रश्न विचारा', const ChatPage()),
      ('✍️', 'अर्ज Generator', 'तयार अर्ज लिहा', const GeneratorPage(type: 'application')),
      ('🌐', 'Translation', 'मराठी ↔ English', const GeneratorPage(type: 'translation')),
      ('📚', 'Study Helper', 'अभ्यासाचे प्रश्न सोडवा', const GeneratorPage(type: 'study')),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('🇮🇳 Marathi AI')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('तुमचा AI साथीदार 🤖',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('मराठीत विचारा • सोप्या भाषेत उत्तर मिळवा'),
          const SizedBox(height: 22),
          Expanded(
            child: GridView.builder(
              itemCount: cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (_, i) => Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => cards[i].$4)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(cards[i].$1, style: const TextStyle(fontSize: 35)),
                      const SizedBox(height: 10),
                      Text(cards[i].$2,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(cards[i].$3, textAlign: TextAlign.center),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override State<ChatPage> createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final c = TextEditingController();
  final messages = <Map<String,String>>[];
  bool loading = false;

  Future<void> send() async {
    final text = c.text.trim();
    if (text.isEmpty || loading) return;
    setState(() { messages.add({'role':'user','text':text}); c.clear(); loading=true; });
    try {
      final r = await http.post(Uri.parse('$backendUrl/chat'),
        headers: {'Content-Type':'application/json'},
        body: jsonEncode({'message': text}));
      final data = jsonDecode(r.body);
      if (r.statusCode >= 400) throw Exception(data['error'] ?? 'Server error');
      setState(() => messages.add({'role':'assistant','text':data['answer'] ?? ''}));
    } catch (e) {
      setState(() => messages.add({'role':'assistant','text':'त्रुटी: $e'}));
    } finally { setState(() => loading=false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🤖 AI Chat')),
    body: Column(children: [
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: messages.length,
        itemBuilder: (_,i) {
          final m=messages[i]; final user=m['role']=='user';
          return Align(alignment:user?Alignment.centerRight:Alignment.centerLeft,
            child: Container(margin:const EdgeInsets.symmetric(vertical:5),
              padding:const EdgeInsets.all(13),
              constraints:const BoxConstraints(maxWidth:340),
              decoration:BoxDecoration(
                color:user?Theme.of(context).colorScheme.primaryContainer:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius:BorderRadius.circular(16)),
              child:Text(m['text']!)));
        })),
      if (loading) const LinearProgressIndicator(),
      SafeArea(child: Padding(padding:const EdgeInsets.all(10),
        child: Row(children:[
          Expanded(child:TextField(controller:c,
            decoration:const InputDecoration(hintText:'मराठीत प्रश्न विचारा...',
              border:OutlineInputBorder()))),
          const SizedBox(width:8),
          IconButton.filled(onPressed:send, icon:const Icon(Icons.send))
        ])))
    ]));
}

class GeneratorPage extends StatefulWidget {
  final String type;
  const GeneratorPage({super.key, required this.type});
  @override State<GeneratorPage> createState()=>_GeneratorPageState();
}
class _GeneratorPageState extends State<GeneratorPage> {
  final c=TextEditingController(); String result=''; bool loading=false;

  String get title => switch(widget.type) {
    'application'=>'✍️ अर्ज Generator',
    'translation'=>'🌐 Translation',
    _=>'📚 Study Helper'
  };

  Future<void> generate() async {
    if(c.text.trim().isEmpty) return;
    setState(()=>loading=true);
    try {
      final r=await http.post(Uri.parse('$backendUrl/generate'),
        headers:{'Content-Type':'application/json'},
        body:jsonEncode({'type':widget.type,'input':c.text.trim()}));
      final data=jsonDecode(r.body);
      if(r.statusCode>=400) throw Exception(data['error']??'Server error');
      setState(()=>result=data['answer']??'');
    } catch(e) { setState(()=>result='त्रुटी: $e'); }
    finally { setState(()=>loading=false); }
  }

  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text(title)),
    body:Padding(padding:const EdgeInsets.all(18),child:Column(children:[
      TextField(controller:c,maxLines:7,
        decoration:InputDecoration(
          labelText: widget.type=='application'?'माहिती लिहा':
                     widget.type=='translation'?'Text लिहा':'तुमचा प्रश्न लिहा',
          hintText: widget.type=='application'
            ?'उदा. कॉलेजला 2 दिवसांची रजा हवी आहे, कारण...'
            :null,border:const OutlineInputBorder())),
      const SizedBox(height:12),
      SizedBox(width:double.infinity,child:FilledButton(
        onPressed:loading?null:generate,
        child:Text(loading?'तयार होत आहे...':'Generate'))),
      const SizedBox(height:20),
      if(result.isNotEmpty) Expanded(child:Card(
        child:SingleChildScrollView(padding:const EdgeInsets.all(16),
          child:Text(result,style:const TextStyle(fontSize:17)))))
    ])));
}
