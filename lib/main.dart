import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_in_flutter/pages/home_page.dart';
import 'package:google_maps_in_flutter/pages/login_page.dart';
import 'package:google_maps_in_flutter/pages/registration_page.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'env');

  await Parse().initialize(
    dotenv.get('PARSE_APP_ID'),
    dotenv.get('PARSE_SERVER_URL'),
    clientKey: dotenv.get('PARSE_CLIENT_KEY'),
    autoSendSessionId: true,
    debug: dotenv.get('ENV', fallback: 'development') == 'development',
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
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        'login': (context) => const LoginPage(),
        'register': (context) => const RegistrationPage(),
        'home': (context) => const HomePage()
      },
    );
  }
}
