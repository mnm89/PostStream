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
