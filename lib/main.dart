import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_pioneer_command/Commands.dart';

void main() async{
  final socket = await Socket.connect('192.168.1.20', 23);

  print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

  requestStatus(socket, StatusCommand.power);
  socket.listen(
        (Uint8List data) {
      final serverResponse = String.fromCharCodes(data);
      print('Server: $serverResponse');
      handleResponse(serverResponse);
    },

    onError: (error) {
      print(error);
      socket.destroy();
    },

    onDone: () {
      print('Server left.');
      socket.destroy();
    },
  );
  MyApp.socket = socket;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'My Pioneer Command';
  static var socket;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    theme: ThemeData(primarySwatch: Colors.deepOrange),
    home: const MainPage(title: title),
  );
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool value = machinePowerStatus;
  Timer? timer;

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              buildHeader(
                text: 'Power',
                child: buildSwitch(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center, //Center Row contents vertically,
                children: [
                GestureDetector(
                  onTap: () async {setState(() {});await sendCommand(MyApp.socket, Command.AppleTV);},
                  child: Container(
                    height: 120,
                    width: 120,
                    color: Colors.transparent,
                    child: Image.network('https://cdn.valesdedescontos.pt/pt/Vi18zL9Kxr2yyWOEALQZ.png'),
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () async {setState(() {});await sendCommand(MyApp.socket, Command.Meo);},
                  child: Container(
                    height: 120,
                    width: 120,
                    color: Colors.transparent,
                    child: Image.network('https://www.meiosepublicidade.pt/wp-content/uploads/2015/11/MEO-logo-300x204.jpg'),
                  ),
                ),
              ],),
              const SizedBox(height: 120),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center, //Center Row contents vertically,
                children: [
                  GestureDetector(
                    onLongPressStart: (detail) {
                      setState(() {
                        timer = Timer.periodic(const Duration(milliseconds: 150), (t) async{
                          await sendCommand(MyApp.socket, Command.VolDown);
                        });
                      });
                    },
                    onLongPressEnd: (detail) {
                      if (timer != null) {
                        timer!.cancel();
                      }
                    },
                    onTap: () async {setState(() {});await sendCommand(MyApp.socket, Command.VolDown);},
                    child: Container(
                      height: 120,
                      width: 120,
                      color: Colors.transparent,
                      child: Image.network('https://cdn-icons-png.flaticon.com/512/43/43625.png'),
                    ),
                  ),
                  const SizedBox(width: 100),
                  GestureDetector(
                    onLongPressStart: (detail) {
                      setState(() {
                        timer = Timer.periodic(const Duration(milliseconds: 150), (t) async{
                          await sendCommand(MyApp.socket, Command.VolUp);
                        });
                      });
                    },
                    onLongPressEnd: (detail) {
                      if (timer != null) {
                        timer!.cancel();
                      }
                    },
                    onTap: () async {setState(() {});await sendCommand(MyApp.socket, Command.VolUp);},
                    child: Container(
                      height: 120,
                      width: 120,
                      color: Colors.transparent,
                      child: Image.network('https://cdn-icons-png.flaticon.com/512/32/32339.png'),
                    ),
                  ),
                ],),
            ],
          ),
        ),
      );

  Widget buildHeader({
    required Widget child,
    required String text,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      );

  void toggleButton() {
    value = !value;
    sendCommand(MyApp.socket, value ? Command.Standby : Command.On);

  }

  Widget buildSwitch() =>
      Transform.scale(
        scale: 2,
        child: Switch.adaptive(
          thumbColor: MaterialStateProperty.all(Colors.red),
          trackColor: MaterialStateProperty.all(Colors.orange),

          splashRadius: 50,
          value: value,
          onChanged: (value) => setState(toggleButton),
        ),
      );
}


