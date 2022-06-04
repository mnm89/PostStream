import 'dart:convert';
import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:cli_util/cli_util.dart';
import 'package:args/args.dart';
import 'package:dotenv/dotenv.dart';
import 'package:path/path.dart' as path;

Map<String, String> commands = {'0': ''};
Logger logger = Logger.standard();
String sdkPath = getSdkPath();
File versionFile = File(path.join(sdkPath, 'version'));
String dartRun = 'dart run';
String program = 'post_stream';
String baseCmd = '$dartRun $program';

class EnvCMD {
  static void usage() {
    logger.stdout('- env');
    logger.stdout('Usage: $baseCmd env [options]');
    logger.stdout('Populate assets/keys.json from env\n');
  }

  static void parse(List<String> args) {
    final parser = ArgParser()..addFlag('help', abbr: 'h');
    final argResults = parser.parse(args);
    if (argResults['help']) return EnvCMD.usage();

    EnvCMD cmd = EnvCMD();
    cmd.run();
  }

  Map<String, dynamic> parseAppKeysFromEnv() {
    var env = DotEnv(includePlatformEnvironment: true)..load();
    return {
      'PARSE_APP_ID': env['PARSE_APP_ID'],
      'PARSE_SERVER_URL': env['PARSE_SERVER_URL'],
      'PARSE_CLIENT_KEY': env['PARSE_CLIENT_KEY'],
      'GOOGLE_MAPS_API_KEY': env['GOOGLE_MAPS_API_KEY'],
      'ENV': env['ENV'],
    };
  }

  void run() async {
    Progress progress = logger.progress('Loading app keys from env');
    try {
      var appKeys = parseAppKeysFromEnv();
      File keysFile =
          File(path.join(Directory.current.path, 'assets', 'keys.json'));
      if (!keysFile.existsSync()) {
        keysFile.createSync();
      }
      keysFile.writeAsStringSync(json.encode(appKeys));
      await Future.delayed(const Duration(seconds: 2));
      progress.finish(message: 'Success', showTiming: true);
      logger.stdout('assets/key.json created');
    } catch (e) {
      progress.finish(message: 'EnvCMDError', showTiming: true);
      logger.stderr(e.toString());
    }
  }
}

class CMD {
  static void hello() {
    logger.stdout('');
    logger.stdout('A command-line utility for PostStream development.');
    logger.stdout('');
    logger.stdout('Dart SDK Configuration');
    logger.stdout('  - Path: $sdkPath');
    logger.stdout('  - Version: ${versionFile.readAsStringSync()}');
    logger.stdout('\n');
  }

  static void usage() {
    logger.stdout('Usage: $baseCmd <command> [options]');
    logger.stdout('');
    logger.stdout('Global options:');
    logger.stdout('-h, --help       Print command usage');
    logger.stdout('\n');
    logger.stdout('Commands:');
    EnvCMD.usage();
    logger.stdout(
        'Run "dart run <command> help" for more information about a command usage.');
  }

  static void parse(List<String> args) {
    CMD.hello();
    if (args.isEmpty) return CMD.usage();

    switch (args[0]) {
      case 'env':
        return EnvCMD.parse(args.sublist(1));
      default:
        return CMD.usage();
    }
  }
}
