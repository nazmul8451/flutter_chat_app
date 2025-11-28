import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late IO.Socket socket;
  TextEditingController controller = TextEditingController();
  List<Map<String, String>> messages = [];   // ekhn Map use korchi
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    socket = IO.io('http://10.10.7.39:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected');
      addMsg("Server e connect hoye gese!", false);
    });

    socket.on('message', (data) {
      addMsg(data, false);
    });
  }

  void addMsg(String msg, bool isMe) {
    setState(() {
      messages.add({"msg": msg, "isMe": isMe.toString()});
    });
    // auto scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void sendMessage() {
    if (controller.text.trim().isNotEmpty) {
      String myMsg = controller.text.trim();
      socket.emit('message', myMsg);     // server e pathay dilam
      addMsg(myMsg, true);               // nijer screen e dekhalam
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(title: Text("Flutter Chat"), backgroundColor: Colors.teal),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  bool isMe = messages[i]["isMe"] == "true";

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.teal : Colors.grey[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        messages[i]["msg"]!,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Message likho...",
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  FloatingActionButton(
                    backgroundColor: Colors.teal,
                    onPressed: sendMessage,
                    child: Icon(Icons.send),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}