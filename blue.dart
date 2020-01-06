import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_blue/flutter_blue.dart';
// import 'dart:io';
// import 'package:flutter/services.dart';

void main() => runApp(MaterialApp(
      title: 'Beacon_App',
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription tmp;
  BluetoothDevice test;

  Map<DeviceIdentifier, ScanResult> scanResults = Map();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          icon: Icon(Icons.favorite),
          onPressed: () {
            setState(() {
              _startScan();
            });
          },
        ),
      ),
    );
  }

  _startScan() {
    tmp = flutterBlue.scan(
      timeout: const Duration(seconds: 4),
    ).listen((scanResult) {
      // print('localName ${scanResult.advertisementData.localName}');
      // print('manufactureData ${scanResult.advertisementData.manufacturerData}');
      // print('service ${scanResult.advertisementData.serviceData}');
      test = scanResult.device;
      print('${test.name} found! rssi: ${scanResult.rssi}');

      setState(() {
        scanResults[scanResult.device.id] = scanResult;
      });

      // setState(() {
      //   isScanning = true;
      // });
    });
  }
}
