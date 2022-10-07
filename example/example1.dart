import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';

EventBus modelBus = EventBus(prefix: 'model', isBusForModel: true);
EventBus logicBus = EventBus(prefix: 'logic');

class MyColorModel {
  final Color color;
  MyColorModel(this.color);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  (logicBus as EventBusHandler).addHandler<int>(
    (event, emit, {bus}) async {
      modelBus.send(MyColorModel(Color(Random().nextInt(0xFFFFFF) + 0xFF000000)));
      modelBus.send(event.data);
    },
  );
  runApp(const Example());
}

class Example extends StatelessWidget {
  const Example({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Timer.periodic(
    //   Duration(seconds: 1),
    //   (timer) {
    //     logicBus.send<int>(Random().nextInt(0xFFFFFF));
    //   },
    // );
    return MaterialApp(
      title: 'EventBus Demo',
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
      ),
      home: const MyHomePage(title: 'EventBus Demo Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            StreamBuilder<int>(
                stream: modelBus.listenEvent<int>(),
                builder: (context, snapshot) {
                  return Text(
                    '${snapshot.data ?? '--'}',
                    style: Theme.of(context).textTheme.headline4,
                  );
                }),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<MyColorModel>(
          stream: modelBus.listenEvent<MyColorModel>(),
          builder: (context, snapshot) {
            return FloatingActionButton(
              onPressed: () {
                logicBus.send((modelBus.lastEvent<int>() ?? 0) + 1);
              },
              tooltip: 'Increment',
              backgroundColor: snapshot.data?.color,
              child: const Icon(Icons.add),
            );
          }), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
