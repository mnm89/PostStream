import 'package:flutter/material.dart';
import 'package:google_maps_in_flutter/helpers/dialog_helper.dart';
import 'package:google_maps_in_flutter/services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkCurrentUser();
  }

  void checkCurrentUser() async {
    try {
      await getCurrentUser();
      Navigator.pushReplacementNamed(context, 'home');
    } catch (e) {
      postUserLogout();
    }
  }

  void doUserLogin() async {
    final username = controllerUsername.text.trim();
    final password = controllerPassword.text.trim();
    if (username.isEmpty | password.isEmpty) return;
    var response = await postUserLogin(username, password);
    if (response.success) {
      Navigator.pushReplacementNamed(context, 'home');
    } else {
      showError(context)(response.error!.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Login/Logout'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: Image.network(
                      'http://blog.back4app.com/wp-content/uploads/2017/11/logo-b4a-1-768x175-1.png'),
                ),
                const Center(
                  child: Text('Flutter on Back4App',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Center(
                  child:
                      Text('User Login/Logout', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: controllerUsername,
                  enabled: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Username'),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: controllerPassword,
                  enabled: true,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Password'),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    child: const Text('Login'),
                    onPressed: () => doUserLogin(),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 50,
                  child: TextButton(
                    child: const Text('Register'),
                    onPressed: () => Navigator.pushNamed(context, 'register'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
