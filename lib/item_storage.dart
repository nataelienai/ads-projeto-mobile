import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class ItemStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/list.json');
  }

  Future<File> writeLists(Map<String, List> list) async {
    final file = await _localFile;

    return file.writeAsString(json.encode(list));
  }

  Future<Map<String, dynamic>> readLists() async { 
    try {
      final file = await _localFile;
      final content = await file.readAsString();
      return json.decode(content);
    } catch (e) {
      return {};
    }
  }
}
