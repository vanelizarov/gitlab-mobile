import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token.dart';

import 'models/project.dart';

const String kApiPrefix = 'torgteam.cf';

class Api {
  static final Api _instance = Api._();

  factory Api() => _instance;
  Api._();

  String _buildUri(String path, [Map<String, String> queryParams]) {
    final Map<String, String> newQueryParams = Map<String, String>();

    if (queryParams != null) {
      newQueryParams.addAll(queryParams);
    }

    newQueryParams.addAll({'private_token': Token().value});

    return Uri.http(
      kApiPrefix,
      '/api/v4' + path,
      newQueryParams,
    ).toString();
  }

  dynamic _decodeResponse(http.Response res) =>
      json.decode(utf8.decode(res.bodyBytes));

  Future<List<Project>> getProjects() async {
    final String uri = _buildUri('/projects');
    final http.Response res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> rawProjects = _decodeResponse(res);

      return rawProjects.map<Project>((raw) => Project.fromJson(raw)).toList();
    }

    throw Exception('Failed to fetch projects:\n'
        '\tstatus: ${res.statusCode}'
        '\tres: ${_decodeResponse(res)}');
  }
}
