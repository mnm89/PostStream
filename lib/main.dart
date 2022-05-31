import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:post_stream/pages/home_page.dart';
import 'package:post_stream/pages/login_page.dart';
import 'package:post_stream/pages/registration_page.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, dynamic> config = await rootBundle
      .loadString('assets/configuration.json')
      .then((value) => jsonDecode(value));
  await Parse().initialize(
    config['PARSE_APP_ID'],
    config['PARSE_SERVER_URL'],
    clientKey: config['PARSE_CLIENT_KEY'],
    autoSendSessionId: true,
    debug: config['ENV'],
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      routes: {
        'login': (context) => const LoginPage(),
        'register': (context) => const RegistrationPage(),
        'home': (context) => const HomePage()
      },
    );
  }
}
