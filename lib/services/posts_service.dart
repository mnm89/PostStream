import 'dart:developer';

import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:post_stream/models/post.dart';

Future<List<Post>> getPosts() async {
  final QueryBuilder<Post> parseQuery = QueryBuilder<Post>(Post());
  final ParseResponse apiResponse = await parseQuery.query<Post>();
  if (!apiResponse.success) return Future.error(apiResponse.error!);
  return apiResponse.results! as List<Post>;
}

Future<void> createPost(Post post) async {
  final ParseResponse apiResponse = await post.save();
  if (!apiResponse.success) return Future.error(apiResponse.error!);
  inspect(apiResponse.results);
}
