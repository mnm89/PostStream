import 'package:parse_server_sdk/parse_server_sdk.dart';

Future<ParseUser> postUserLogin(String username, String password) async {
  final user = ParseUser(username, password, null);

  ParseResponse response = await user.login();
  if (!response.success) return Future.error(response.error!);
  return response.results!.first as ParseUser;
}

Future<ParseUser> postUserRegister(
    String username, String password, String email) async {
  ParseUser user = ParseUser.createUser(username, password, email);
  ParseResponse response = await user.signUp();
  if (!response.success) return Future.error(response.error!);
  return response.results!.first as ParseUser;
}

Future<ParseUser> getCurrentUser() async {
  final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
  if (currentUser == null) return Future.error('User is disconnected');
  //Checks whether the user's session token is valid
  ParseResponse? response =
      await ParseUser.getCurrentUserFromServer(currentUser.sessionToken!);
  if (response == null || !response.success) {
    return Future.error('User session expired');
  }
  return response.results!.first as ParseUser;
}

Future<void> postUserLogout() async {
  final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
  if (currentUser != null) {
    await currentUser.logout();
  }
}
