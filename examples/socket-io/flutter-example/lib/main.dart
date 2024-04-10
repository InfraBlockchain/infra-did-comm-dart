import 'package:flutter/material.dart';
import 'package:infra_did_comm_dart/infra_did_comm_dart.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  InfraDIDCommSocketClient client =
      InfraDIDCommSocketClient("http://data-market.test.newnal.com:9000");
  String mnemonic =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  String did = "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z";

  Future<void> connectWebsocket() async {
    client.onConnect();
    client.onMessage(mnemonic, did, null);
    client.connect();
    String? socketId = await client.socketId;
  }

  void disconnectWebsocket() {
    client.disconnect();
  }

  Future<void> sendDIDAuthInitMessage() async {
    String? socketId = await client.socketId;
    if (socketId != null) {
      String toSocketId = "O2kcsMxfKsh5gKFzAAFW"; // Need to set peer socketId
      int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      Context context = Context(
        domain: "d",
        action: "a",
      );
      var uuid = const Uuid();
      var id = uuid.v4();
      DIDAuthInitMessage didAuthInitMessage = DIDAuthInitMessage(
        id: id,
        from: did,
        to: [did],
        createdTime: currentTime,
        expiresTime: currentTime + 30000,
        context: context,
        socketId: socketId,
        peerSocketId: toSocketId,
      );

      await client.sendDIDAuthInitMessage(
        didAuthInitMessage,
        mnemonic,
        did,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: connectWebsocket, child: const Text("Connect")),
            ElevatedButton(
                onPressed: disconnectWebsocket,
                child: const Text("Disconnect")),
            ElevatedButton(
                onPressed: sendDIDAuthInitMessage,
                child: const Text("Send DID-Auth-Init Message")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: connectWebsocket,
        tooltip: 'connect websocket',
        child: const Icon(Icons.connect_without_contact),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
