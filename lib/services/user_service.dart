import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

Future<ParseResponse> postUserLogin(String username, String password) async {
  final user = ParseUser(username, password, null);
  return user.login();
}

Future<ParseResponse> postUserRegister(
    String username, String password, String email) async {
  final user = ParseUser.createUser(username, password, email);
  return user.signUp();
}

Future<ParseResponse> getCurrentUser() async {
  final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
  if (currentUser == null) return Future.error('User is disconnected');
  //Checks whether the user's session token is valid
  ParseResponse? response =
      await ParseUser.getCurrentUserFromServer(currentUser.sessionToken!);
  if (response == null || !response.success) {
    return Future.error('User session expired');
  }
  return response;
}

Future<void> postUserLogout() async {
  final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
  if (currentUser == null) return;
  await currentUser.logout();
}
