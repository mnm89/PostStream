import 'package:parse_server_sdk/parse_server_sdk.dart';

class Post extends ParseObject implements ParseCloneable {
  Post() : super('Post');
  Post.clone() : this();

  Post.from({required title, required description}) : super('Post') {
    this.title = title;
    this.description = description;
  }

  String get title => get<String>("title")!;
  set title(String title) => set<String>("title", title);

  String get description => get<String>("description")!;
  set description(String description) =>
      set<String>("description", description);

  ParseUser get user => get<ParseUser>('user')!;
  set user(ParseUser user) => set<ParseUser>('user', user);

  dynamic get position => get<dynamic>('position')!;
  set position(dynamic position) => set<dynamic>('position', position);

  ParseGeoPoint get location => get<ParseGeoPoint>("location")!;
  set location(ParseGeoPoint location) =>
      set<ParseGeoPoint>("location", location);

  String get address => get<String>("address")!;
  set address(String address) => set<String>("url", address);

  DateTime get date => get<DateTime>('date')!;
  set date(DateTime date) => set<DateTime>('date', date);

  String get url => get<String>("url")!;
  set url(String url) => set<String>("url", url);

  @override
  clone(Map<String, dynamic> map) => Post.clone()..fromJson(map);
}
