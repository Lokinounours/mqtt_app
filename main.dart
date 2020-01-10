import 'dart:async';
import 'package:quiver/async.dart';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

enum StatusBlue {
  unavailable,
  available,
  selected,
}

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
  int port = 11494;
  String username = 'ahrmkjfv';
  String password = 'pTHp2VqECR1n';
  String clientIdentifier = 'Pierre';

  MqttClient client;
  MqttConnectionState connectionState;

  bool isActiveConnection = false;

  bool ledOne = true;
  bool ledTwo = true;
  bool ledThree = true;

  StatusBlue one = StatusBlue.unavailable;
  StatusBlue two = StatusBlue.unavailable;
  StatusBlue three = StatusBlue.unavailable;

  int time1 = 5;
  bool act1 = false;
  int time2 = 5;
  bool act2 = false;
  int time3 = 5;
  bool act3 = false;

  void startTimer1() {
    int _start1 = 5;
    act1 = true;
    time1 = _start1;
    CountdownTimer countDownTimer1 = new CountdownTimer(
      new Duration(seconds: _start1),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer1.listen(null);
    sub.onData((duration) {
      setState(() {
        time1 = _start1 - duration.elapsed.inSeconds;
        //print('1: $time1   2: $time2   3: $time3');
      });
    });

    sub.onDone(() {
      //print("Done");
      sub.cancel();
      // time1 = 5;
      // act1 = false;
    });
  }

  void startTimer2() {
    int _start2 = 5;
    act2 = true;
    time2 = _start2;
    CountdownTimer countDownTimer2 = new CountdownTimer(
      new Duration(seconds: _start2),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer2.listen(null);
    sub.onData((duration) {
      setState(() {
        time2 = _start2 - duration.elapsed.inSeconds;
        //print('1: $time1   2: $time2   3: $time3');
      });
    });

    sub.onDone(() {
      //print("Done");
      sub.cancel();
      // time2 = 5;
      // act2 = false;
    });
  }

  void startTimer3() {
    int _start3 = 5;
    act3 = true;
    time3 = _start3;
    CountdownTimer countDownTimer3 = new CountdownTimer(
      new Duration(seconds: _start3),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer3.listen(null);
    sub.onData((duration) {
      setState(() {
        time3 = _start3 - duration.elapsed.inSeconds;
        //print('1: $time1   2: $time2   3: $time3');
      });
    });

    sub.onDone(() {
      //print("Done");
      sub.cancel();
      // time3 = 5;
      // act3 = false;
    });
  }

  double _rating = 0.0;
  double _bri = 0.0;
  double _sat = 0.0;

  StreamSubscription<RangingResult> _streamRanging;
  Map lampMap = Map();

  @override
  void initState() {
    super.initState();
    startScanning();
    connect();
    print("END INITSTATE");
  }

  @override
  Widget build(BuildContext context) {
    // startScanning();
    IconData connectionStateIcon;
    switch (client.connectionStatus.state) {
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
                    Column(
                      children: <Widget>[
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
                                if(one == StatusBlue.available || one == StatusBlue.selected) {
                                  setState(() {
                                    sendMessage(
                                        topicLed, ledOne ? '1 0' : '1 1');
                                    ledOne = !ledOne;
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.lightbulb_outline),
                              color: ledTwo ? Colors.red : Colors.blueGrey[300],
                              iconSize: 50,
                              onPressed: () {
                                if(two == StatusBlue.available || two == StatusBlue.selected) {
                                  setState(() {
                                    sendMessage(topicLed, ledTwo ? '2 0' : '2 1');
                                    ledTwo = !ledTwo;
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.lightbulb_outline),
                              color: ledThree
                                  ? Colors.purple
                                  : Colors.blueGrey[300],
                              iconSize: 50,
                              onPressed: () {
                                if(three == StatusBlue.available || three == StatusBlue.selected) {
                                  setState(() {
                                    sendMessage(
                                        topicLed, ledThree ? '3 0' : '3 1');
                                    ledThree = !ledThree;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                              icon: Icon((one == StatusBlue.unavailable)
                                  ? Icons.check_circle_outline
                                  : Icons.check_circle),
                              color: one == StatusBlue.selected
                                  ? Colors.lightBlue
                                  : Colors.blueGrey[300],
                              iconSize: 20,
                              onPressed: () {
                                setState(() {
                                  if (one == StatusBlue.available)
                                    one = StatusBlue.selected;
                                  else if (one == StatusBlue.selected)
                                    one = StatusBlue.available;
                                  // sendMessage(topicLed, ledOne ? '1 0' : '1 1');
                                  // ledOne = !ledOne;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon((two == StatusBlue.unavailable)
                                  ? Icons.check_circle_outline
                                  : Icons.check_circle),
                              color: two == StatusBlue.selected
                                  ? Colors.red
                                  : Colors.blueGrey[300],
                              iconSize: 20,
                              onPressed: () {
                                setState(() {
                                  if (two == StatusBlue.available)
                                    two = StatusBlue.selected;
                                  else if (two == StatusBlue.selected)
                                    two = StatusBlue.available;
                                  // sendMessage(topicLed, ledOne ? '1 0' : '1 1');
                                  // ledOne = !ledOne;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon((three == StatusBlue.unavailable)
                                  ? Icons.check_circle_outline
                                  : Icons.check_circle),
                              color: three == StatusBlue.selected
                                  ? Colors.purple
                                  : Colors.blueGrey[300],
                              iconSize: 20,
                              onPressed: () {
                                setState(() {
                                  if (three == StatusBlue.available)
                                    three = StatusBlue.selected;
                                  else if (three == StatusBlue.selected)
                                    three = StatusBlue.available;
                                  // sendMessage(topicLed, ledOne ? '1 0' : '1 1');
                                  // ledOne = !ledOne;
                                });
                              },
                            ),
                          ],
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
                        message += ' ';
                        message += (one == StatusBlue.selected) ? '1' : '0';
                        message += (two == StatusBlue.selected) ? '1' : '0';
                        message += (three == StatusBlue.selected) ? '1' : '0';
                        sendMessage(topic, message);
                      },
                      child: Text('Submit Request'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            startTimer1();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            startTimer2();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            startTimer3();
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
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

    try {
      await client.connect(username, password);
    } catch (e) {
      print(e);
      client.disconnect();
    }

    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      setState(() {
        connectionState = client.connectionStatus.state;
      });
    } else {
      print('ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionStatus.state}');
      client.disconnect();
    }
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
    // client.subscribe(pubTopic, MqttQos.atLeastOnce);
    client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload);
    // client.unsubscribe(pubTopic);
  }

  void startScanning() async {
    try {
      await flutterBeacon.initializeAndCheckScanning;
    } catch (e) {}

    final regions = <Region>[];

    regions.add(Region(identifier: 'com.beacon'));

    _streamRanging = flutterBeacon.ranging(regions).listen(
      (RangingResult result) {
        //print(result.beacons.length);
        for (int i = 0; i < result.beacons.length; i++) {
          if (result.beacons[i].proximity != Proximity.unknown) {
            lampMap[result.beacons[i].proximityUUID] =
                result.beacons[i].proximity;
            switch (result.beacons[i].proximityUUID) {
              case "64827394-8273-9483-6294-749297482928":
                {
                  if (one == StatusBlue.unavailable)
                    setState(() {
                      one = StatusBlue.available;
                      // print("First beacon");
                    });
                }
                break;
              case "00000000-0000-0008-4849-300000000000":
                {
                  if (two == StatusBlue.unavailable)
                    setState(() {
                      two = StatusBlue.available;
                      // print("Second beacon");
                    });
                }
                break;
              case "99999999-9999-0000-0000-000000000000":
                {
                  if (three == StatusBlue.unavailable)
                    setState(() {
                      three = StatusBlue.available;
                      // print("Third beacon");
                    });
                }
                break;
            }
          }
        }
        if (!lampMap.containsKey("64827394-8273-9483-6294-749297482928")) {
          if (!act1) startTimer1();
          if (time1 == 0) {
            setState(() {
              // print("Beacon one Lost");
              one = StatusBlue.unavailable;
            });
            time1 = 5;
            act1 = false;
          }
        }
        if (!lampMap.containsKey("00000000-0000-0008-4849-300000000000")) {
          if (!act2) startTimer2();
          if (time2 == 0) {
            setState(() {
              // print("Beacon one Lost");
              two = StatusBlue.unavailable;
            });
            time2 = 5;
            act2 = false;
          }
        }
        if (!lampMap.containsKey("99999999-9999-0000-0000-000000000000")) {
          if (!act3) startTimer3();
          if (time3 == 0) {
            setState(() {
              // print("Beacon one Lost");
              three = StatusBlue.unavailable;
            });
            time3 = 5;
            act3 = false;
          }
        }
        lampMap.clear();
      },
    );
  }

  void printMap() {
    if (lampMap.isNotEmpty)
      lampMap.forEach((i, j) => print('Key: $i and Value: $j'));
  }
}
