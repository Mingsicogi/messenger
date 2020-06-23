import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:messenger/global_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:dash_chat/dash_chat.dart';

import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Messenger'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();
//  var channel = IOWebSocketChannel.connect('ws://52.79.130.121:8080/chat/room');
  var channel = IOWebSocketChannel.connect('ws://localhost:8080/chat/room');
  final ChatUser user = ChatUser(
    uid: "1234",
    firstName: "ssogi",
    lastName: "Min",
    avatar: null,
  );

  List<ChatMessage> messages = List<ChatMessage>();
  var m = List<ChatMessage>();

  @override
  void initState() {
    super.initState();
  }

  void onSend(ChatMessage message) {
    channel.sink.add(jsonEncode(message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mins Messenger"),
      ),
      body: StreamBuilder(
          stream: channel.stream,
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              print(snapshot.data);
              var chatMessage = ChatMessage.fromJson(jsonDecode(snapshot.data));
              if(chatMessage.user.avatar == null) {
                chatMessage.user.avatar = defaultAvatar;
              }
              messages.add(chatMessage);
            }
            return DashChat(
                key: _chatViewKey,
                inverted: false,
                onSend: onSend,
                sendOnEnter: true,
                textInputAction: TextInputAction.send,
                user: user,
                inputDecoration: InputDecoration.collapsed(hintText: "메세지를 입력하세요"),
                dateFormat: DateFormat('yyyy-MMM-dd'),
                timeFormat: DateFormat('HH:mm'),
                messages: messages,
                showUserAvatar: false,
                showAvatarForEveryMessage: false,
                scrollToBottom: true,
                onPressAvatar: (ChatUser user) {

                  print("OnPressAvatar: ${user.lastName}");
                },
                onLongPressAvatar: (ChatUser user) {

                  print("OnLongPressAvatar: ${user.lastName} ${user.firstName}");
                },
                inputMaxLines: 5,
                messageContainerPadding: EdgeInsets.only(left: 5.0, right: 5.0),
                alwaysShowSend: true,
                inputTextStyle: TextStyle(fontSize: 16.0),
                inputContainerStyle: BoxDecoration(
                  border: Border.all(width: 0.0),
                  color: Colors.white,
                ),
                onQuickReply: (Reply reply) {
                  setState(() {
                    messages.add(ChatMessage(
                        text: reply.value,
                        createdAt: DateTime.now(),
                        user: user));

                    messages = [...messages];
                  });

                  Timer(Duration(milliseconds: 300), () {
                    _chatViewKey.currentState.scrollController
                      ..animateTo(
                        _chatViewKey.currentState.scrollController.position.maxScrollExtent,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 300),
                      );
                  });
                },
                onLoadEarlier: () {
                  print("laoding...");
                },
                shouldShowLoadEarlier: false,
                showTraillingBeforeSend: true,
                trailing: <Widget>[
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: () {
                      var value = _chatViewKey.currentState.widget.textController.value;
                      print(value);
                    },
                  ),
                ],
              );
          }),
    );
  }
}
