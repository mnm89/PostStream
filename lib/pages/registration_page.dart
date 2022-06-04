import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:post_stream/helpers/dialog_helper.dart';
import 'package:post_stream/services/user_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerEmail = TextEditingController();

  bool _isLoading = false;
  void _onUser(ParseUser user) {
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
    });
  }

  void _doUserRegistration() async {
    final username = controllerUsername.text.trim();
    final password = controllerPassword.text.trim();
    final email = controllerEmail.text.trim();
    if (username.isEmpty | password.isEmpty | email.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    postUserRegister(username, password, email)
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
        title: const Text('Flutter SignUp'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 200,
                child: Image.asset('images/logo.png'),
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
                    Text('User registration', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(
                height: 16,
              ),
              TextField(
                controller: controllerUsername,
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
                controller: controllerEmail,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    labelText: 'E-mail'),
              ),
              const SizedBox(
                height: 8,
              ),
              TextField(
                controller: controllerPassword,
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
                height: 8,
              ),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.account_circle_outlined),
                  label: Text(
                    _isLoading ? 'Loading...' : 'Sign Up',
                  ),
                  onPressed: _isLoading ? null : _doUserRegistration,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
