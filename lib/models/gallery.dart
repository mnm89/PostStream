import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:post_stream/models/post.dart';

class Gallery extends ParseObject implements ParseCloneable {
  Gallery() : super('Gallery');
  Gallery.clone() : this();

  ParseFile get file => get<ParseFile>("file")!;
  set file(ParseFile file) => set<ParseFile>("file", file);

  ParseUser get user => get<ParseUser>('user')!;
  set user(ParseUser user) => set<ParseUser>('user', user);

  Post? get post => get<Post>('post');
  set post(Post? post) => set<Post?>('post', post);

  bool? get isPostCover => get<bool>('isPostCover');
  set isPostCover(bool? isPostCover) => set<bool?>('isPostCover', isPostCover);

  @override
  clone(Map<String, dynamic> map) => Gallery.clone()..fromJson(map);
}
