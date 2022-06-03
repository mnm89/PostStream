import 'dart:async';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:post_stream/models/gallery.dart';
import 'package:post_stream/models/post.dart';
import 'package:post_stream/services/user_service.dart';

import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:faker/faker.dart';

import 'args_parser.dart';

Future<void> createAppConfiguration() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  print(env['PARSE_APP_ID']);
  print(env['PARSE_SERVER_URL']);
  print(env['PARSE_CLIENT_KEY']);
  print(env['ENV']);
}

Future<void> bootstrapData() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  var faker = Faker();
  await Parse().initialize(
    env['PARSE_APP_ID']!,
    env['PARSE_SERVER_URL']!,
    clientKey: env['PARSE_CLIENT_KEY'],
    autoSendSessionId: true,
    debug: env['ENV'] == 'development',
  );
  String path = '${Directory.current.path}/assets/images/default_bg.jpeg';
  File file = File(path);
  if (!await file.exists()) throw 'File Not Exist $path';
  ParseUser user;
  try {
    user = await postUserRegister('test', '123456', 'test@test.com');
  } catch (e) {
    user = await postUserLogin('test', '123456');
  }

  ParseFile parseFile = ParseFile(file);
  ParseResponse fileResponse = await parseFile.save();
  if (!fileResponse.success) throw fileResponse.error!;
  Gallery gallery = Gallery();
  gallery.file = parseFile;
  gallery.isPostCover = true;
  gallery.user = user;
  ParseResponse galleryResponse = await gallery.save();
  if (!galleryResponse.success) throw galleryResponse.error!;
  Post post = Post();
  post.title = faker.job.title();
  post.description = faker.lorem.sentence();
  post.address = faker.address.streetAddress();
  post.location = ParseGeoPoint(latitude: 0, longitude: 0);
  post.date = faker.date.dateTime();
  post.position = {
    "longitude": faker.randomGenerator.decimal(),
    "latitude": faker.randomGenerator.decimal(),
    "timestamp": faker.date.dateTime(),
    "accuracy": faker.randomGenerator.decimal(),
    "altitude": faker.randomGenerator.decimal(),
    "heading": faker.randomGenerator.decimal(),
    "rspeed": faker.randomGenerator.decimal(),
    "speedAccuracy": faker.randomGenerator.decimal(),
    "floor": faker.randomGenerator.integer(10),
    "isMocked": faker.randomGenerator.boolean(),
  };
  post.user = user;
  post.url = parseFile.url!;
  final ParseResponse postResponse = await post.save();
  if (!postResponse.success) throw postResponse.error!;
  gallery.post = post;
  await gallery.save();
}

void main(List<String> args) => CMD.parse(args);
