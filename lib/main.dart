import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LiveChatApp(), 
  ));
}

class LiveChatApp extends StatefulWidget {
  const LiveChatApp({Key? key}) : super(key: key);
  @override
  State<LiveChatApp> createState() => _LiveChatAppState();
}

class _LiveChatAppState extends State<LiveChatApp> {
  final _msgCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  int _likes = 61400;
  bool _isFirebaseReady = false;

  @override
  void initState() {
    super.initState();
    _setupDatabaseInBackground(); 
  }

  Future<void> _setupDatabaseInBackground() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _isFirebaseReady = true;
      });
    } catch (e) {
      debugPrint("Firebase connection delayed: $e");
      // Fallback state enables user interface buttons to operate locally if remote server lags
      setState(() {
        _isFirebaseReady = true;
      });
    }
  }

  void _startLiveCall(String mode) async {
    // Custom room identifier string configuration
    String callUrl = mode == "video" 
        ? "https://jit.si"
        : "https://jit.si";

    final Uri url = Uri.parse(callUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open live calling portal")),
      );
    }
  }

  void _watchMovie() async {
    final Uri url = Uri.parse("https://youtube.com"); 
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        title: const Text('Vibeshop Active Hub', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🎬 Synced Cinema Widget Box
          GestureDetector(
            onTap: _watchMovie,
            child: Container(
              width: double.infinity,
              height: 140,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_creation, color: Colors.purpleAccent, size: 40),
                  SizedBox(height: 8),
                  Text("🎬 Tap to Watch Family Movies Together", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text("Cinema Mode Synced Stream", style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          ),

          // 📊 Calling & Engagement Interface HUD Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.favorite, color: Colors.red, size: 16),
                  label: Text("Likes: $_likes"),
                  onPressed: () => setState(() => _likes++),
                ),
                ActionChip(
                  backgroundColor: Colors.green,
                  avatar: const Icon(Icons.phone, color: Colors.white, size: 14),
                  label: const Text("Audio Call", style: TextStyle(color: Colors.white, fontSize: 12)),
                  onPressed: () => _startLiveCall("audio"), 
                ),
                ActionChip(
                  backgroundColor: Colors.purpleAccent,
                  avatar: const Icon(Icons.video_call, color: Colors.white, size: 14),
                  label: const Text("Video Call", style: TextStyle(color: Colors.white, fontSize: 12)),
                  onPressed: () => _startLiveCall("video"), 
                ),
              ],
            ),
          ),

          // 💬 Cloud Synchronized Social Stream Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12)),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snap) {
                  // Instant template fallback presentation layout if network database sync is pending
                  if (snap.hasError || !snap.hasData || snap.data!.docs.isEmpty) {
                    return ListView(
                      children: [
                        Card(
                          color: Colors.white.withOpacity(0.05),
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: const ListTile(
                            title: Text('Vibeshop Welcome Bot', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('Welcome to your Active Hub! Post a message below to test your newly configured database connection.', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ),
                        ),
                      ],
                    );
                  }
                  
                  return ListView(
                    children: snap.data!.docs.map((d) {
                      var data = d.data() as Map<String, dynamic>;
                      return Card(
                        color: Colors.white.withOpacity(0.05),
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(data['author'] ?? 'Guest User', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(data['content'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),

          // ✍️ Input Submission Controller Messaging Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: "Enter Your Nickname...", 
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    prefixIcon: Icon(Icons.person, color: Colors.grey, size: 18),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.purpleAccent)),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: "Share live post feed updates...", 
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.purpleAccent),
                      onPressed: () {
                        if (_msgCtrl.text.trim().isNotEmpty) {
                          try {
                            FirebaseFirestore.instance.collection('posts').add({
                              'author': _nameCtrl.text.trim().isEmpty ? 'Anonymous' : _nameCtrl.text.trim(),
                              'content': _msgCtrl.text.trim(),
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                          } catch (e) {
                            debugPrint("Local cache tracking error: $e");
                          }
                          _msgCtrl.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
