// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:ui' as ui;
import 'dart:io' show Directory, File, Platform, exit, sleep;
import 'dart:isolate';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import "package:ffi/ffi.dart";
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
//import 'package:flutter_application_1/main.dart';
import 'package:path/path.dart' as path;

import 'package:intl/intl.dart';

// FFI signature of the hello_world C function
typedef AddUserFunc = ffi.Void Function();
// Dart type definition for calling the C foreign function
typedef CppAddUser = void Function();

// FFI signature of the hello_world C function
typedef CreatePubFunc = ffi.Void Function(Pointer<Utf8>);
// Dart type definition for calling the C foreign function
typedef CreatePub = void Function(Pointer<Utf8>);

typedef KillThreadsFunc = ffi.Void Function();
typedef KillThreads = void Function();

typedef SetSendMessageFunc = ffi.Void Function(Pointer<Utf8>, Pointer<Utf8>);
typedef SetSendMessage = void Function(Pointer<Utf8>, Pointer<Utf8>);

typedef SetCurrTabFunc = ffi.Void Function(Pointer<Utf8>);
typedef SetCurrTab = void Function(Pointer<Utf8>);

typedef ReceiveDartFunc = ffi.Void Function(Pointer<Utf8>);
typedef ReceiveDart = void Function(Pointer<Utf8>);

typedef SetDartReceiveCallbackFunc = ffi.Void Function(
    Pointer<
        NativeFunction<
            Void Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Long>)>>);
typedef SetDartReceiveCallback = void Function(
    Pointer<
        NativeFunction<
            Void Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Long>)>>);

typedef StatusReceiveDartFunc = ffi.Void Function(Pointer<Utf8>);
typedef StatusReceiveDart = void Function(Pointer<Utf8>);

typedef SetDartStatusReceiveCallbackFunc = ffi.Void Function(
    Pointer<NativeFunction<Void Function(Pointer<Bool>, Pointer<Int>)>>);
typedef SetDartStatusReceiveCallback = void Function(
    Pointer<NativeFunction<Void Function(Pointer<Bool>, Pointer<Int>)>>);

typedef DartRemoveUserFunc = ffi.Void Function(Int32);
typedef DartRemoveUser = void Function(int);

typedef SetUserFunc = ffi.Void Function(Pointer<Utf8>);
typedef SetUser = void Function(Pointer<Utf8>);

typedef SetPictureFunc = ffi.Void Function(Long);
typedef SetPicture = void Function(int);

typedef GetCurrentUserStatusFunc = ffi.Bool Function(Int32);
typedef GetCurrentUserStatus = bool Function(int);

/*typedef SetDartReceivePortFunc = ffi.Void Function(Pointer<NativeType>);
typedef SetDartReceivePort = void Function(Pointer<NativeType>);*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//var libraryPath = path.join(
//    Directory.current.path, 'lib', 'build', 'Debug', 'FastDDSUser.dll');

//path.join(
//  Directory.current.path, 'lib', 'hello_library', 'libhello_library.dll');

//final dylib = ffi.DynamicLibrary.open(libraryPath);
final dylib = ffi.DynamicLibrary.open("FastDDSUser.dll");

final CppAddUser addUser =
    dylib.lookup<ffi.NativeFunction<AddUserFunc>>('addUser').asFunction();

final CreatePub createPub = dylib
    .lookup<ffi.NativeFunction<CreatePubFunc>>('createPublisher')
    .asFunction();

final KillThreads killThreads =
    dylib.lookup<ffi.NativeFunction<AddUserFunc>>('killThreads').asFunction();

final SetSendMessage setSendMessage = dylib
    .lookup<ffi.NativeFunction<SetSendMessageFunc>>('setSendMessage')
    .asFunction();

final SetCurrTab setCurrTab =
    dylib.lookup<ffi.NativeFunction<SetCurrTabFunc>>('setCurrTab').asFunction();

final ReceiveDart receiveDart = dylib
    .lookup<ffi.NativeFunction<ReceiveDartFunc>>('receiveDart')
    .asFunction();

final SetDartReceiveCallback setDartReceiveCallback = dylib
    .lookup<ffi.NativeFunction<SetDartReceiveCallbackFunc>>(
        'setDartReceiveCallback')
    .asFunction();

final StatusReceiveDart statusReceiveDart = dylib
    .lookup<ffi.NativeFunction<StatusReceiveDartFunc>>('statusReceiveDart')
    .asFunction();

final SetDartStatusReceiveCallback setDartStatusReceiveCallback = dylib
    .lookup<ffi.NativeFunction<SetDartStatusReceiveCallbackFunc>>(
        'setDartStatusReceiveCallback')
    .asFunction();

final DartRemoveUser dartRemoveUser = dylib
    .lookup<ffi.NativeFunction<DartRemoveUserFunc>>('dartRemoveUser')
    .asFunction();

final SetUser _setUser =
    dylib.lookup<ffi.NativeFunction<SetUserFunc>>('setUsername').asFunction();

final SetPicture _setProfilePicture =
    dylib.lookup<ffi.NativeFunction<SetPictureFunc>>('setPicture').asFunction();
/*final SetDartReceivePort setDartReceivePort =
    dylib.lookup<ffi.NativeFunction<SetDartReceivePortFunc>>('setDartReceivePort').asFunction();*/

//test
typedef CallbackNativeType = Void Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Long>);
typedef StatusCallbackNativeType = Void Function(Pointer<Bool>, Pointer<Int>);
//typedef CallbackNativeTypeFunc = ffi.Void Function(Pointer<Utf8>);

//for user messages
typedef CallbackNativeTypeFunction = void Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Long>);
typedef CallbackNativeTypeNativeFunction = Void Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Long>);

//for user status
typedef StatusCallbackNativeTypeFunction = void Function(
    Pointer<Bool>, Pointer<Utf8>);
typedef StatusCallbackNativeTypeNativeFunction = Void Function(
    Pointer<Bool>, Pointer<Utf8>);

final CallbackNativeTypeFunction callbackNativeType = dylib
    .lookup<ffi.NativeFunction<CallbackNativeTypeNativeFunction>>(
        'callbackNativeType')
    .asFunction();

final CallbackNativeTypeFunction statusCallbackNativeType = dylib
    .lookup<ffi.NativeFunction<CallbackNativeTypeNativeFunction>>(
        'statusCallbackNativeType')
    .asFunction();

final GetCurrentUserStatus getCurrentUserStatus = dylib
    .lookup<ffi.NativeFunction<GetCurrentUserStatusFunc>>(
        'getCurrentUserStatus')
    .asFunction();

var pubs = {};

var _profileIsSelected = 0;

void _onMessageReceived(Pointer<Utf8> message) {
  final dartMessage = message.toDartString();
  print("Message received from C++: $dartMessage");
}

List<Color> Theme = [
  Color.fromARGB(255, 59, 59, 59), //primary
  Color.fromARGB(255, 31, 31, 31), //secondary
  Color.fromARGB(255, 117, 117, 117), //buttons
  Color.fromARGB(255, 101, 146, 182), //usermessage
  Color.fromARGB(255, 116, 116, 116) //othermessage
];

List<Widget> profiles = [
  Image(image: AssetImage('assets/pic1.png'), width: 30, height: 30),
  Image(image: AssetImage('assets/ASRCTransparent.png'), width: 30, height: 30),
  Image(image: AssetImage('assets/ASRCRed.png'), width: 30, height: 30),
  Image(image: AssetImage('assets/ASRCYellow.png'), width: 30, height: 30),
  Image(image: AssetImage('assets/ASRCGreen.png'), width: 30, height: 30),
  Image(image: AssetImage('assets/ASRCPurple.png'), width: 30, height: 30)
];

List<String> profPics = [
  'assets/pic1.png',
  'assets/ASRCTransparent.png',
  'assets/ASRCRed.png',
  'assets/ASRCYellow.png',
  'assets/ASRCGreen.png',
  'assets/ASRCPurple.png',
];

double textSize = 14;

var username;
/*
// Look up the C function 'hello_world'
final HelloWorld hello = dylib
    .lookup<ffi.NativeFunction<HelloWorldFunc>>('hello_world')
    .asFunction();

/*/////////////////////////////////////////
  final returnHello hi = dylib
      .lookup<ffi.NativeFunction<returnHelloFunc>>('returnHello')
      .asFunction();
  // Call the function
  */

final Pointer<Utf8> Function() hi = dylib
    .lookup<NativeFunction<Pointer<Utf8> Function()>>('returnHello')
    .asFunction();
String getString() => hi().toDartString();

final int Function() num =
    dylib.lookup<NativeFunction<Int64 Function()>>('returnX').asFunction();
int retnum() => num().toInt();
*/ /////////////////////////

/*void isolateReceive(SendPort sendPort) {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  port.listen((message) {
    print("Received message from c++: $message");
  });
}*/

void main() {
  // Open the dynamic library
/*  var libraryPath =
      path.join(Directory.current.path, 'hello_library', 'libhello.so');

  if (Platform.isMacOS) {
    libraryPath =
        path.join(Directory.current.path, 'hello_library', 'libhello.dylib');
  }

  if (Platform.isWindows) {
    libraryPath = path.join(
        Directory.current.path, 'lib', 'hello_library', 'libhello.dll');
  }

 */

  runApp(const MyApp());

  doWhenWindowReady(() {
    var initialSize = ui.Size(600, 450);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.minSize = ui.Size(600, 450);
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 59, 59, 59),
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 59, 59, 59)),

        ///const Color.fromARGB(255, 101, 146, 182)
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _LogInPageState();
}

class WindowButtons extends StatelessWidget {
  var buttonColors = WindowButtonColors(
    iconNormal: Colors.white,
    iconMouseDown: const Color.fromARGB(46, 255, 255, 255),
    mouseDown: const Color.fromARGB(46, 255, 255, 255),
    mouseOver: const Color.fromARGB(46, 255, 255, 255),
    iconMouseOver: const Color.fromARGB(46, 255, 255, 255),
  );

  void _killThreads() {
    killThreads();
    appWindow.close();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(
          colors: buttonColors,
          onPressed: _killThreads,
        )
      ],
    );
  }
}

class _LogInPageState extends State<MyHomePage> {
  TextEditingController usernameController = TextEditingController();

  void _loadNext() {
    if (usernameController.text.length > 2 &&
        usernameController.text != "Notes")
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _ChatPage()),
      );
  }

  void _checks() {
    if (usernameController.text.length > 32) {
      usernameController.text = usernameController.text.substring(0, 32);
    }
    usernameController.text = usernameController.text.trim();
    _setUser(usernameController.text.toNativeUtf8());
    username = usernameController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.values[0],
          children: [
            Stack(
              children: [
                Container(
                  color: const Color.fromARGB(255, 31, 31, 31),
                  width: double.infinity,
                  height: 30,
                ),
                WindowTitleBarBox(
                  child: Row(
                    children: [Expanded(child: MoveWindow()), WindowButtons()],
                  ),
                )
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 525,
                      padding: EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 72, 72, 72)),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15),
                              hintText: "Start Typing...",
                              hintStyle: TextStyle(
                                  color: Color.fromARGB(70, 255, 255, 255))),
                          onChanged: (text) {
                            _checks();
                          },
                          onEditingComplete: _loadNext,
                          //onEditingComplete: _updateText,
                          controller: usernameController,
                        ),
                      )),
                  Container(
                      // color: Color.fromARGB(255, 72, 72, 72),
                      padding: EdgeInsets.all(10),
                      height: 50,
                      width: 100,
                      child: FloatingActionButton(
                        backgroundColor: Color.fromARGB(255, 117, 117, 117),
                        child: const Text('Log In'),
                        onPressed: () {
                          _loadNext();
                        },
                      ))
                ],
              ),
            )
          ],
        ))
      ])),
    );
  }
}

class _ChatPage extends StatefulWidget {
  @override
  State<_ChatPage> createState() => _MyHomePageState();
}

//colors for backgrounds be different themes
//fonts predetermined, have a drop-down
//font colors be sepera

class _MyHomePageState extends State<_ChatPage> {
  var scrollUser = ScrollController();
  var scrollPic = ScrollController();

  var deleteUserBtn = null;
  var chatText = null;
  final textController = TextEditingController();
  final userController = TextEditingController();
  String message = "";
  //String selfUserName = username;

  var profilePictures = Map<String, String>();

  var messageStrings = Map<String, List<String>>(); //the text of each message
  var userMessages =
      Map<String, List<Widget>>(); //the actual widgets for each message

  List<Widget> users = <Widget>[
    Row(children: [
      /* Container(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Image(
              image: AssetImage('assets/ASRCTransparent.png'),
              width: 30,
              height: 30)),*/
      Container(
          width: 258,
          padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
          child: Text(
              textAlign: TextAlign.left,
              "Notes",
              style: TextStyle(color: Color.fromARGB(255, 229, 229, 229))))
    ])
  ];

  List<bool> _selectedUsers = [true]; //for toggle button

  List usernameList = ["Notes"]; //for the user being selected

  List isActiveList = [true];

  int selectedUser = 0;

  @override
  initState() {
    userMessages["Notes"] = <Widget>[];
    messageStrings["Notes"] = [];
    profilePictures["Notes"] = 'assets/ASRCTransparent.png';

    var tempStr = "Notes";
    setCurrTab(tempStr.toNativeUtf8()); // Sets initial tab to General

    final callback =
        NativeCallable<CallbackNativeType>.listener(callbackFunction);
    setDartReceiveCallback(callback.nativeFunction);

    final statusCallback = NativeCallable<StatusCallbackNativeType>.listener(
        statusCallbackFunction);
    setDartStatusReceiveCallback(statusCallback.nativeFunction);

    scrollPic.addListener(() => _syncScroll(scrollPic, scrollUser));
    scrollUser.addListener(() => _syncScroll(scrollUser, scrollPic));

    /*final callbackPointer = Pointer.fromFunction<Void Function(Pointer<Utf8>)>(callbackFunction);
    setDartReceiveCallback(callbackPointer);*/

    /*final receivePort = ReceivePort();
    Isolate.spawn(isolateReceive, receivePort.sendPort);

    receivePort.listen((sendPort) {
      final isolatePort = sendPort as SendPort;
      final message = "Hello from C++";

      isolatePort.send(message);
    });

    final receivePortPointer = Pointer.fromAddress(receivePort.hashCode);
    setDartReceivePort(receivePortPointer);*/
  }

  var _isSyncingScroll = false;

  void _syncScroll(ScrollController source, ScrollController target) {
    if (_isSyncingScroll) return;

    _isSyncingScroll = true;
    target.jumpTo(source.offset); // Synchronize the scroll position
    _isSyncingScroll = false;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    userController.dispose();

    super.dispose();
  }

  List<Widget> message_list = <Widget>[
    //self_message
  ];

  List<String> messageString_list = [];

  List<Widget> tempList = <Widget>[
    //self_message
  ];

  void _blank() {}

  void _loadNext() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _SettingsPage()),
    ).then((_) => setState(() {}));
  }

  void _checks() {
    print(usernameList.indexOf("element"));
    if (userController.text.length > 32) {
      userController.text = userController.text.substring(0, 32);
    }
    userController.text = userController.text.trim();
    //_setUser(userController.text.toNativeUtf8());
  }

  void _addUser() {
    if (userController.text.trim() != "" &&
        !usernameList.contains(userController.text) &&
        userController.text.length > 2 &&
        userController.text != "Notes") {
      String newUser = userController.text;
      userController.text = "";

      createPub(newUser.toNativeUtf8()); // To add user to topics

      userMessages[newUser] = <Widget>[];
      messageStrings[newUser] = [];
      profilePictures[newUser] = 'assets/pic1.png';
      //isActiveList[newUser] = ;

      setState(() {
        _selectedUsers.add(false);
        usernameList.add(newUser);
        isActiveList.add(false);

        users.add(
            /* Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Image(
                  image: profilePictures[usernameList.indexOf(newUser)],
                  width: 30,
                  height: 30)),*/

            Container(
                width: 258,
                padding: EdgeInsets.fromLTRB(55, 0, 0, 0),
                child: Text(
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    newUser,
                    style:
                        TextStyle(color: Color.fromARGB(255, 229, 229, 229)))));
      });
    }
  }

  void _removeUser() {
    // Sends index to backend
    dartRemoveUser(selectedUser);

    _selectedUsers[selectedUser] = false;

    _selectedUsers[0] = true;

    // isActiveList[selectedUser] = false;
    if (selectedUser != isActiveList.length) {
      for (int i = selectedUser; i < isActiveList.length - 1; i++) {
        isActiveList[i] = isActiveList[i + 1];
      }
    } else {
      isActiveList[selectedUser] = false;
    }

    setState(() {
      profilePictures.remove(usernameList[selectedUser]);
      users.remove(users[selectedUser]);
      _selectedUsers.remove(_selectedUsers[selectedUser]);
      usernameList.remove(usernameList[selectedUser]);
      //profilePictures.remove(usernameList.indexOf(selectedUser));
      //isActiveList.remove(usernameList[selectedUser]);

      selectedUser = 0;
      if (selectedUser == 0) {
        deleteUserBtn = null;
      } else {
        deleteUserBtn = IconButton(
            alignment: Alignment.centerRight,
            color: Colors.grey,
            onPressed: _removeUser,
            icon: Icon(Icons.person_remove));
      }
      message_list = userMessages[usernameList[selectedUser]]!;
      messageString_list = messageStrings[usernameList[selectedUser]]!;
    });
  }

  void _updateText() {
    //user sending text
    //  killThreads();
    if (textController.text != "" && isActiveList[selectedUser] == true) {
      message = textController.text;
      textController.text = "";

      // Sends Message to Publisher
      final sendMessage = message.toNativeUtf8();
      final sendUsername = usernameList[selectedUser].toString().toNativeUtf8();
      setSendMessage(sendUsername, sendMessage);

      setState(() {
        message_list = [
          Container(
            key: UniqueKey(),
            padding: EdgeInsets.fromLTRB(60, 0, 10, 0),
            alignment: Alignment.centerRight,
            child: Text(
              DateFormat.jm().format(DateTime.now()),
              style: TextStyle(
                  fontSize: textSize - 3, color: getTextColor(Theme[0])),
            ),
          ),
          ...message_list,
        ];
        message_list = [
          Container(
              key: UniqueKey(),
              padding: EdgeInsets.fromLTRB(60, 0, 10, 5),
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: Theme[3]),
                padding: EdgeInsets.all(10),
                child: Container(
                    child: Text(
                  message,
                  style: TextStyle(
                      fontSize: textSize, color: getTextColor(Theme[3])),
                )),
              )),
          ...message_list,
        ];

        messageString_list = [
          username +
              " " +
              DateFormat.jm().format(DateTime.now()) +
              '\n' +
              message,
          ...messageString_list
        ];
      });
    }
  }

  void callbackFunction(
      Pointer<Utf8> message, Pointer<Utf8> other_username, Pointer<Long> pic) {
    String msg = message.toDartString();
    String usr = other_username.toDartString();

    profilePictures[usr] = profPics[pic.value];

    // print(usr);
    // print(msg);

    setState(() {
      _updateTextReceive(msg, usr);
    });
  }

  void statusCallbackFunction(Pointer<Bool> isActive, Pointer<Int> userIndex) {
    if (isActive == nullptr || userIndex == nullptr) {
      print("Received null pointer(s).");
      return;
    }

    bool msg = isActive.value;
    //String usr = other_username.toDartString();
    int usr = userIndex.value;

    //bool active = getCurrentUserStatus(usernameList.indexOf(usr));
    //  print(usr);
    setState(() {
      isActiveList[usr + 1] = msg;
    });

    //_updateTextReceive(msg, usr);
  }

  Color getTextColor(Color color) {
    int d = 0;

    // Counting the perceptive luminance
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    if (luminance > 0.5)
      d = 0; // bright colors - black font
    else
      d = 255; // dark colors - white font

    return Color.fromARGB(255, d, d, d);
  }

  Future<void> _saveChat() async {
    var filename = "./ChatLogs/" +
        usernameList[selectedUser] +
        "-" +
        DateTime.now().toString().split(" ")[0];
    // var chatFile = File(usernameList[selectedUser]);
    var chatFile;

    var allMessages = "";
    for (int i = messageString_list.length - 1; i >= 0; i--) {
      allMessages += messageString_list[i] + '\n';
    }
    chatFile = await File(filename).writeAsString(allMessages);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('Alert Title'),
          content: Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            alignment: Alignment.center,
            width: 40,
            height: 40,
            child: Text(
              'Chat Log Saved.',
              style: TextStyle(fontSize: 15),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // for updating messages when received
  void _updateTextReceive(String message, String other_username) {
    setState(() {
      if (usernameList[selectedUser] == other_username) {
        message_list = [
          Container(
            key: UniqueKey(),
            padding: EdgeInsets.fromLTRB(10, 0, 60, 0),
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat.jm().format(DateTime.now()),
              style: TextStyle(
                  fontSize: textSize - 3, color: getTextColor(Theme[0])),
            ),
          ),
          ...message_list,
        ];
        message_list = [
          Container(
              key: UniqueKey(),
              padding: EdgeInsets.fromLTRB(10, 0, 60, 5),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: Theme[4]),
                padding: EdgeInsets.all(10),
                child: Container(
                    child: Text(message,
                        style: TextStyle(color: getTextColor(Theme[4])))),
              )),
          ...message_list,
        ];

        messageString_list = [
          other_username +
              " " +
              DateFormat.jm().format(DateTime.now()) +
              '\n' +
              message,
          ...messageString_list
        ];
      } else {
        userMessages[other_username] = [
          Container(
            key: UniqueKey(),
            padding: EdgeInsets.fromLTRB(10, 0, 60, 0),
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat.jm().format(DateTime.now()),
              //DateTime.now().hour.toString() +
              //    ":" +
              //    DateTime.now().minute.toString(),
              style: TextStyle(
                  fontSize: textSize - 3, color: getTextColor(Theme[0])),
            ),
          ),
          ...?userMessages[other_username],
        ];
        userMessages[other_username] = [
          Container(
              key: UniqueKey(),
              padding: EdgeInsets.fromLTRB(10, 0, 60, 5),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: Theme[4]),
                padding: EdgeInsets.all(10),
                child: Container(
                    child: Text(
                  message,
                  style: TextStyle(color: getTextColor(Theme[4])),
                )),
              )),
          ...?userMessages[other_username],
        ];

        messageStrings[other_username] = [
          other_username +
              " " +
              DateFormat.jm().format(DateTime.now()) +
              '\n' +
              message,
          ...?messageStrings[other_username]
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      /*appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),*/
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Row(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[
            Container(
                color: Theme[1], //
                width: 260,
                child: Column(children: [
                  Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        Stack(
                          children: [
                            Container(
                              color: const Color.fromARGB(255, 31, 31, 31),
                              width: double.infinity,
                              height: 30,
                            ),
                            Container(
                                padding: EdgeInsets.fromLTRB(5, 8, 0, 0),
                                child: Image(
                                    width: 20,
                                    height: 20,
                                    image: AssetImage(
                                        profPics[_profileIsSelected]))),
                            Container(
                                padding: EdgeInsets.fromLTRB(30, 6, 0, 0),
                                child: Text(
                                  username,
                                  style: TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                )),
                            WindowTitleBarBox(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: MoveWindow(),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Container(
                            color: Theme[1],
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      width: 190,
                                      padding:
                                          EdgeInsets.fromLTRB(0, 15, 10, 15),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Theme[2]),
                                        child: TextFormField(
                                          cursorColor: getTextColor(Theme[2]),
                                          style: TextStyle(
                                              color: getTextColor(Theme[2])),
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  left: 15,
                                                  bottom: 11,
                                                  top: 11,
                                                  right: 15),
                                              hintText: "+ Add User",
                                              hintStyle: TextStyle(
                                                  color: getTextColor(Theme[2])
                                                      .withAlpha(180))),
                                          onEditingComplete: _addUser,
                                          onChanged: (text) {
                                            _checks();
                                          },
                                          controller: userController,
                                        ),
                                      )),
                                  Container(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 15, 0, 15),
                                      child: FloatingActionButton(
                                        heroTag: "tagSettings",
                                        foregroundColor:
                                            Color.fromARGB(255, 36, 36, 36),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40)),
                                        backgroundColor: Theme[2],
                                        onPressed: _loadNext,
                                        child: Icon(
                                          Icons.settings,
                                          color: getTextColor(Theme[2]),
                                        ),
                                      )),
                                ])),
                        Expanded(
                            child: Stack(
                          children: [
                            Container(
                                padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
                                child: ListView.builder(
                                  controller: scrollPic,
                                  itemCount: profilePictures.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      title: Container(
                                          alignment: Alignment.centerLeft,
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 3),
                                          child: Image.asset(
                                              profilePictures[
                                                  usernameList[index]]!,
                                              width: 30,
                                              height: 30)),
                                    );
                                  },
                                )),
                            SingleChildScrollView(
                              controller: scrollUser,
                              child: ToggleButtons(
                                disabledColor: Theme[1],
                                disabledBorderColor: Theme[1],
                                fillColor: Theme[0].withAlpha(200),
                                direction: Axis.vertical,
                                isSelected: _selectedUsers,
                                children: users,
                                onPressed: (int index) {
                                  setState(() {
                                    userMessages[usernameList[selectedUser]] =
                                        message_list;
                                    messageStrings[usernameList[selectedUser]] =
                                        messageString_list;
                                    selectedUser = index;
                                    var strUser =
                                        usernameList[index].toString();
                                    setCurrTab(strUser.toNativeUtf8());
                                    //setCurrTab(usernameList[index].toNativeUtf8());
                                    //print(index);
                                    for (int buttonIndex = 0;
                                        buttonIndex < _selectedUsers.length;
                                        buttonIndex++) {
                                      if (buttonIndex == index) {
                                        _selectedUsers[buttonIndex] = true;
                                      } else {
                                        _selectedUsers[buttonIndex] = false;
                                      }
                                    }
                                    if (selectedUser == 0) {
                                      deleteUserBtn = null;
                                    } else {
                                      deleteUserBtn = IconButton(
                                          alignment: Alignment.centerRight,
                                          color: Theme[2],
                                          onPressed: _removeUser,
                                          icon: Icon(Icons.person_remove));
                                    }
                                    message_list = userMessages[
                                        usernameList[selectedUser]]!;
                                    messageString_list = messageStrings[
                                        usernameList[selectedUser]]!;
                                  });
                                },
                              ),
                            )
                          ],
                        )),
                      ]))
                ])),
            Expanded(
                child: Container(
                    color: Theme[0],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            Container(
                              color: const Color.fromARGB(255, 31, 31, 31),
                              width: double.infinity,
                              height: 30,
                            ),
                            WindowTitleBarBox(
                              child: Row(
                                children: [
                                  Expanded(child: MoveWindow()),
                                  WindowButtons()
                                ],
                              ),
                            )
                          ],
                        ),
                        Container(
                            height: 50,
                            width: double.infinity,
                            color: Theme[1].withAlpha(50),
                            child: Row(
                                //mainAxisAlignment: MainAxisAlignment.values[3],
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: Icon(
                                      Icons.circle,
                                      size: 15,
                                      color: isActiveList[selectedUser] == true
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width - 480,
                                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      usernameList[selectedUser],
                                      style: TextStyle(
                                          color: getTextColor(Theme[0]),
                                          fontSize: 25),
                                    ),
                                  ),
                                  Expanded(
                                      child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.values[1],
                                    children: [
                                      Container(
                                          // color: Color.fromARGB(255, 72, 72, 72),
                                          padding: EdgeInsets.fromLTRB(
                                              10, 10, 0, 10),
                                          height: 50,
                                          width: 100,
                                          child: FloatingActionButton(
                                            heroTag: "tag_save",
                                            backgroundColor: Theme[2],
                                            foregroundColor:
                                                getTextColor(Theme[2]),
                                            child: const Text("Save Chat"),
                                            onPressed: () {
                                              _saveChat();
                                            },
                                          )),
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 30, 0),
                                        alignment: Alignment.centerRight,
                                        child: deleteUserBtn,
                                      ),
                                    ],
                                  ))
                                ])),
                        Expanded(
                            child: ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                reverse: true,
                                children: message_list)),
                        Container(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme[2].withAlpha(
                                      200)), //const Color.fromARGB(255, 72, 72, 72)),
                              child: TextFormField(
                                cursorColor: getTextColor(Theme[2]),
                                style: TextStyle(color: getTextColor(Theme[2])),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 15, bottom: 11, top: 11, right: 15),
                                  hintText: "Start Typing...",
                                  hintStyle:
                                      TextStyle(color: getTextColor(Theme[2])),
                                ),
                                // Color.fromARGB(70, 255, 255, 255))),
                                //onEditingComplete: _updateText,
                                onEditingComplete: _updateText,
                                controller: textController,
                              ),
                            ))
                      ],
                    )))
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _SettingsPage extends StatefulWidget {
  @override
  State<_SettingsPage> createState() => SettingsPage();
}

class SettingsPage extends State<_SettingsPage> {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  //double textSize = 0;

  var _isSelected;

  var settingSelected;

  List<bool> profileButtons = [false, false, false, false, false, false];

  initState() {
    profileButtons[_profileIsSelected] = true;
    settingSelected = SlidePicker(
      pickerColor: pickerColor,
      onColorChanged: changeColor,
    );
  }

  Color getTextColor(Color color) {
    int d = 0;

    // Counting the perceptive luminance - human eye favors green color...
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    if (luminance > 0.5)
      d = 0; // bright colors - black font
    else
      d = 255; // dark colors - white font

    return Color.fromARGB(color.alpha, d, d, d);
  }

  List<Widget> options = [
    Container(
        width: 260,
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text(
            key: UniqueKey(),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            "Primary Color",
            style: TextStyle(color: Color.fromARGB(255, 229, 229, 229)))),
    Container(
        key: UniqueKey(),
        width: 260,
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text(
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            "Secondary Color",
            style: TextStyle(color: Color.fromARGB(255, 229, 229, 229)))),
    Container(
        key: UniqueKey(),
        width: 260,
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text(
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            "Button Color",
            style: TextStyle(color: Color.fromARGB(255, 229, 229, 229)))),
    Container(
        key: UniqueKey(),
        width: 260,
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text(
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            "Self Message Color",
            style: TextStyle(color: Color.fromARGB(255, 229, 229, 229)))),
    Container(
        key: UniqueKey(),
        width: 260,
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text(
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            "Other Message Color",
            style: TextStyle(color: Color.fromARGB(255, 229, 229, 229)))),
    Container(
        key: UniqueKey(),
        width: 260,
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text(
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            "Font Size",
            style: TextStyle(color: Color.fromARGB(255, 229, 229, 229)))),
    Container(
        key: UniqueKey(),
        width: 260,
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text(
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            "Profile Picture",
            style: TextStyle(color: Color.fromARGB(255, 229, 229, 229))))
  ];

  List<bool> optionsButtons = [true, false, false, false, false, false, false];

  List<Widget> ColorWheels = [];

  late var pickerColor = Theme[0];

  void changeSetting() {
    if (_isSelected == 5) {
      settingSelected =
          Column(mainAxisAlignment: MainAxisAlignment.values[4], children: [
        Slider(
            value: textSize,
            max: 35,
            onChanged: (newNum) {
              setState(() {
                textSize = newNum;
                changeSetting();
              });
            }),
        SizedBox(
            height: 60,
            child: Text(
              "Sample Text",
              style:
                  TextStyle(fontSize: textSize, color: getTextColor(Theme[0])),
            ))
      ]);
    } else if (_isSelected == 6) {
      settingSelected = Container(
          child: Column(
        children: [
          ToggleButtons(
            //selectedColor: Theme[1],
            selectedBorderColor: Theme[1],
            disabledColor: Theme[0],
            disabledBorderColor: Theme[0],
            //fillColor: Theme[0].withAlpha(200),
            direction: Axis.horizontal,
            isSelected: profileButtons,
            children: profiles,
            onPressed: (int index) {
              setState(() {
                _profileIsSelected = index;

                for (int buttonIndex = 0;
                    buttonIndex < profileButtons.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    profileButtons[buttonIndex] = true;
                  } else {
                    profileButtons[buttonIndex] = false;
                  }
                  changeSetting();
                }
              });
            },
          ),
        ],
      ));
    } else {
      pickerColor = Theme[_isSelected];
      settingSelected = SlidePicker(
        pickerColor: pickerColor,
        onColorChanged: changeColor,
        sliderTextStyle: TextStyle(color: getTextColor(Theme[0])),
      );
    }
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
    setState(() {
      if (optionsButtons[0] == true)
        Theme[0] = color;
      else if (optionsButtons[1] == true)
        Theme[1] = color;
      else if (optionsButtons[2] == true)
        Theme[2] = color;
      else if (optionsButtons[3] == true)
        Theme[3] = color;
      else if (optionsButtons[4] == true) Theme[4] = color;
    });
    changeSetting();
  }

  void _goBack() {
    _setProfilePicture(_profileIsSelected);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Expanded(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                color: Theme[1], //
                width: 260,
                child: Column(children: [
                  Stack(
                    children: [
                      Container(
                        color: const Color.fromARGB(255, 31, 31, 31),
                        width: double.infinity,
                        height: 30,
                      ),
                      WindowTitleBarBox(
                        child: Row(
                          children: [
                            Expanded(child: MoveWindow()),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                      child: FloatingActionButton(
                        key: UniqueKey(),
                        foregroundColor: Color.fromARGB(255, 36, 36, 36),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: Theme[2],
                        onPressed: _goBack,
                        child: const Icon(Icons.arrow_back_rounded),
                      )),
                  Container(
                    child: ToggleButtons(
                      disabledColor: Theme[1],
                      disabledBorderColor: Theme[1],
                      fillColor: Theme[0].withAlpha(200),
                      direction: Axis.vertical,
                      isSelected: optionsButtons,
                      children: options,
                      onPressed: (int index) {
                        setState(() {
                          _isSelected = index;

                          for (int buttonIndex = 0;
                              buttonIndex < optionsButtons.length;
                              buttonIndex++) {
                            if (buttonIndex == index) {
                              optionsButtons[buttonIndex] = true;
                            } else {
                              optionsButtons[buttonIndex] = false;
                            }
                            changeSetting();
                          }
                        });
                      },
                    ),
                  ),
                ])),
            Expanded(
              child: Container(
                  color: Theme[0],
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            color: const Color.fromARGB(255, 31, 31, 31),
                            width: double.infinity,
                            height: 30,
                          ),
                          WindowTitleBarBox(
                            child: Row(
                              children: [
                                Expanded(child: MoveWindow()),
                                WindowButtons()
                              ],
                            ),
                          )
                        ],
                      ),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(

                              //height: 70,
                              padding: EdgeInsets.all(20),
                              child: settingSelected)
                        ],
                      ))
                    ],
                  )),
            ),
          ],
        ))
      ])),
    );
  }
}
