import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:memory_info/memory_info.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Memory? _memory;
  DiskSpace? _diskSpace;

  @override
  void initState() {
    super.initState();
    getMemoryInfo();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getMemoryInfo() async {
    Memory? memory;
    DiskSpace? diskSpace;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      memory = await MemoryInfoPlugin().memoryInfo;
      diskSpace = await MemoryInfoPlugin().diskSpace;
    } on PlatformException catch (e) {
      print('error $e');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (memory != null || diskSpace != null)
      setState(() {
        _memory = memory;
        _diskSpace = diskSpace;
      });
  }

  @override
  Widget build(BuildContext context) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String memInfo = encoder.convert(_memory?.toMap());
    String diskInfo = encoder.convert(_diskSpace?.toMap());
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: getMemoryInfo,
          child: Icon(Icons.update),
        ),
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MemInfo:\n',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text('$memInfo'),
              Text('\n--------------------------------------------\n'),
              Text(
                'DiskInfo:\n',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text('$diskInfo')
            ],
          ),
        ),
      ),
    );
  }
}
