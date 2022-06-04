import 'package:flutter/material.dart';
void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        splashColor: Colors.red,
            primaryColor: Colors.green,
        brightness: Brightness.light,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('Init called HomePage');
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('disposed called HomePage');
  }
  @override
  Widget build(BuildContext context) {
    return Center(child: ElevatedButton(
      child: Text('screen 1'),
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ScreenOne()));
      },
    ),);
  }
}
class ScreenOne extends StatefulWidget {
  const ScreenOne({Key key}) : super(key: key);
  @override
  _ScreenOneState createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  void initState() {
    // TODO: implement initState
    super.initState();
    print('init called ScreenOne');
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('dispose called ScreenOne');
  }
  @override
  Widget build(BuildContext context) {
    return Center(child: ElevatedButton(
      child: Text('screen 1'),
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ScreenTwo()));
      },
    ),);
  }
}

class ScreenTwo extends StatefulWidget {
  const ScreenTwo({Key key}) : super(key: key);
  @override
  State<ScreenTwo> createState() => _ScreenTwoState();
}

class _ScreenTwoState extends State<ScreenTwo> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('init called ScreenTwo');
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('dispose called ScreenTwo');
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Holo'),
    );
  }
}

