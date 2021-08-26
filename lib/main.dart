import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final fb = FirebaseDatabase.instance.reference();
  final _controller = TextEditingController();
  bool isOnline = false;
  String memoryAvailable = "-1";
  String cpu = "-1";
  String batteryAvailable = "-1";

  void createData() {
    fb.child("1").set("logout");
  }

  void getStatus(bool p) async {
    DataSnapshot datasnapshot = await fb.child("2").once();
    if (p) fb.child("2").remove();
    if (datasnapshot.value != null) {
      isOnline = true;
      setState(() {});
      fb.child("2").remove();
    } else {
      isOnline = false;
      setState(() {});
    }
    await Future.delayed(Duration(seconds: 3));
    getStatus(false);
  }

  void getCpuUsage() async {
    DataSnapshot dataSnapshot = await fb.child("systemInfo").once();
    if (dataSnapshot.value != null) {
      batteryAvailable = dataSnapshot.value["battery"]["percent"];
      memoryAvailable = dataSnapshot.value["memory"]["percent"];
      cpu = dataSnapshot.value["cpu"];
      setState(() {});
    }
    getCpuUsage();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getStatus(true);
    getCpuUsage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isOnline ? "ONLINE" : "OFFLINE",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isOnline ? Colors.green : Colors.red[400]),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "CPU Usage: ",
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      ),
                      Text(
                        cpu == "-1" ? "Loading" : cpu,
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Memory Usage: ",
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      ),
                      Text(
                        memoryAvailable == "-1"
                            ? "Loading"
                            : "$memoryAvailable%",
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Battery Usage: ",
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      ),
                      Text(
                        batteryAvailable == "-1"
                            ? "Loading"
                            : batteryAvailable.substring(0, 2),
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: _controller,
                onChanged: (String text) async {
                  if (text.length > 0) {
                    String p = text;
                    print(p);
                    await fb.child("text").set(p);
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  createData();
                },
                child: Text("Log Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }
}
