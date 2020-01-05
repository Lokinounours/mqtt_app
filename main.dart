import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mqtt Beacon App ',
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String titleBar = 'MQTT';
  String broker = 'farmer.cloudmqtt.com';
  int port = 10934;
  String username = 'sujrylfw';
  String password = 'U8Ojrg_LQbwz';
  String clientIdentifier = 'Pierre';

  MqttClient client;
  MqttConnectionState connectionState;

  bool isActiveConnection = false;

  bool ledOne = false;
  bool ledTwo = false;
  bool ledThree = false;

  double _rating = 0.0;
  double _bri = 0.0;
  double _sat = 0.0;

  StreamSubscription<RangingResult> _streamRanging;

  @override
  Widget build(BuildContext context) {
    IconData connectionStateIcon;
    switch (client?.connectionState) {
      case MqttConnectionState.connected:
        connectionStateIcon = Icons.cloud_done;
        break;
      case MqttConnectionState.disconnected:
        connectionStateIcon = Icons.cloud_off;
        break;
      case MqttConnectionState.connecting:
        connectionStateIcon = Icons.cloud_upload;
        break;
      case MqttConnectionState.disconnecting:
        connectionStateIcon = Icons.cloud_download;
        break;
      case MqttConnectionState.faulted:
        connectionStateIcon = Icons.error;
        break;
      default:
        connectionStateIcon = Icons.cloud_off;
    }

    String topic = "LED";
    String topicLed = "OnOff";
    String message = "";

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(titleBar),
              SizedBox(
                width: 10.0,
              ),
              Icon(connectionStateIcon),
            ],
          ),
        ),
        body: Container(
          color: (connectionStateIcon == Icons.cloud_done)
              ? Colors.blueGrey[100]
              : Colors.blueGrey[300],
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Card(
                margin: EdgeInsets.all(10),
                color: (connectionStateIcon == Icons.cloud_done)
                    ? Colors.blueGrey[00]
                    : Colors.blueGrey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(connectionStateIcon),
                      onPressed: () {
                        setState(
                          () {
                            (connectionStateIcon == Icons.cloud_done)
                                ? disconnect()
                                : connect();
                          },
                        );
                      },
                    ),
                    Text((connectionStateIcon == Icons.cloud_done)
                        ? 'Connected'
                        : 'Disconnected'),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Card(
                  margin: EdgeInsets.all(10),
                  color: (connectionStateIcon == Icons.cloud_done)
                      ? Colors.blueGrey[00]
                      : Colors.blueGrey[100],
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Value',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 240,
                            child: Slider(
                              activeColor: Colors.indigoAccent,
                              min: 0.0,
                              max: 60000.0,
                              onChanged: (newRating) {
                                setState(() => _rating = newRating);
                              },
                              value: _rating,
                            ),
                          ),
                          Expanded(
                            child: Text('${_rating.toInt()}',
                                style: Theme.of(context).textTheme.display1),
                          ),
                        ],
                      ),
                      Text(
                        'Brightness',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 240,
                            child: Slider(
                              activeColor: Colors.indigoAccent,
                              min: 0.0,
                              max: 255.0,
                              onChanged: (newRating) {
                                setState(() => _bri = newRating);
                              },
                              value: _bri,
                            ),
                          ),
                          Expanded(
                            child: Text('${_bri.toInt()}',
                                style: Theme.of(context).textTheme.display1),
                          ),
                        ],
                      ),
                      Text(
                        'Saturation',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 240,
                            child: Slider(
                              activeColor: Colors.indigoAccent,
                              min: 0.0,
                              max: 255.0,
                              onChanged: (newRating) {
                                setState(() => _sat = newRating);
                              },
                              value: _sat,
                            ),
                          ),
                          Expanded(
                            child: Text('${_sat.toInt()}',
                                style: Theme.of(context).textTheme.display1),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.lightbulb_outline),
                            color: ledOne
                                ? Colors.lightBlue
                                : Colors.blueGrey[300],
                            iconSize: 50,
                            onPressed: () {
                              setState(() {
                                sendMessage(topicLed, ledOne ? '1 0' : '1 1');
                                ledOne = !ledOne;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.lightbulb_outline),
                            color: ledTwo ? Colors.red : Colors.blueGrey[300],
                            iconSize: 50,
                            onPressed: () {
                              setState(() {
                                sendMessage(topicLed, ledTwo ? '2 0' : '2 1');
                                ledTwo = !ledTwo;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.lightbulb_outline),
                            color:
                                ledThree ? Colors.purple : Colors.blueGrey[300],
                            iconSize: 50,
                            onPressed: () {
                              setState(() {
                                sendMessage(topicLed, ledThree ? '3 0' : '3 1');
                                ledThree = !ledThree;
                              });
                            },
                          ),
                        ],
                      ),
                      RaisedButton(
                        onPressed: () {
                          message = _rating.toInt().toString();
                          message += ' ';
                          message += _bri.toInt().toString();
                          message += ' ';
                          message += _sat.toInt().toString();
                          sendMessage(topic, message);
                        },
                        child: Text('Submit Request'),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void connect() async {
    client = MqttClient(broker, '');
    client.port = port;

    client.logging(on: true);

    client.keepAlivePeriod = 30;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .keepAliveFor(30)
        .withWillTopic('log')
        .withWillMessage('Connection From Android App - Pierre')
        .withWillQos(MqttQos.atLeastOnce);
    print('MQTT client connecting....');
    client.connectionMessage = connMess;

  //   try {
  //     await client.connect(username, password);
  //   } catch (e) {
  //     print(e);
  //     client.disconnect();
  //   }

  //   if (client.connectionState == MqttConnectionState.connected) {
  //     print('MQTT client connected');
  //     setState(() {
  //       connectionState = client.connectionState;
  //     });
  //   } else {
  //     print('ERROR: MQTT client connection failed - '
  //         'disconnecting, state is ${client.connectionState}');
  //     client.disconnect();
  //   }

  //   try {
  //     await flutterBeacon.initializeScanning;
  //   } catch (e) {}
  //   final regions = <Region>[];

  //   regions.add(Region(identifier: 'com.beacon'));

  //   _streamRanging =
  //       flutterBeacon.ranging(regions).listen((RangingResult result) {
  //         print(result);
  //       });
  }

  void disconnect() {
    const String pubTopic = 'log';
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString('Deconnection From Android App - Pierre');
    client.subscribe(pubTopic, MqttQos.atLeastOnce);
    client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload);
    client.unsubscribe(pubTopic);
    client.disconnect();
  }

  void sendMessage(String topic, String message) {
    String pubTopic = topic;
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.subscribe(pubTopic, MqttQos.atLeastOnce);
    client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload);
    client.unsubscribe(pubTopic);
  }
}
