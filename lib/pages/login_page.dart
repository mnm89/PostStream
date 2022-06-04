import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:post_stream/helpers/dialog_helper.dart';
import 'package:post_stream/services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await getCurrentUser().then(_onUser);
    } catch (e) {
      await postUserLogout();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _onUser(ParseUser user) {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
    });
  }

  void _doUserLogin() async {
    final username = controllerUsername.text.trim();
    final password = controllerPassword.text.trim();
    if (username.isEmpty | password.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    postUserLogin(username, password)
        .catchError(
          (error) => showError(context)(error),
        )
        .then(_onUser)
        .whenComplete(
          () => setState(() {
            _isLoading = false;
          }),
        );
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
                SizedBox(height: 200, child: Image.asset('images/logo.png')),
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
                  child: ElevatedButton.icon(
                    icon: _isLoading
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.account_circle_outlined),
                    label: Text(
                      _isLoading ? 'Loading...' : 'Login',
                    ),
                    onPressed: _isLoading ? null : _doUserLogin,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 50,
                  child: TextButton(
                    child: const Text('Register'),
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushNamed(context, 'register'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
