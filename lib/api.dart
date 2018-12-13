import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'storage.dart';

import 'models/project.dart';
import 'models/user.dart';
import 'models/error.dart';

const String kApiPrefix = 'torgteam.cf';

class Api {
  static final Api _instance = Api._();

  final Storage _storage = Storage();

  get token => _storage.get('token');
  set token(String token) => _storage.set('token', token);

  factory Api() => _instance;
  Api._();

  String _buildUri(String path, [Map<String, String> queryParams]) {
    final Map<String, String> newQueryParams = Map<String, String>();

    if (queryParams != null) {
      newQueryParams.addAll(queryParams);
    }

    newQueryParams.addAll({'private_token': token});

    return Uri.http(
      kApiPrefix,
      '/api/v4' + path,
      newQueryParams,
    ).toString();
  }

  dynamic _decodeResponse(http.Response res) => json.decode(utf8.decode(res.bodyBytes));

  Future<List<Project>> getProjects() async {
    final String uri = _buildUri('/projects');
    final http.Response res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> rawProjects = _decodeResponse(res);

      return rawProjects.map<Project>((raw) => Project.fromJson(raw)).toList();
    }

    // throw Exception('Failed to fetch projects: '
    //     'status: ${res.statusCode} '
    //     'res: ${_decodeResponse(res)}');
    throw ApiError.fromJson(_decodeResponse(res));
  }

  Future<User> getCurrentlyAuthenticatedUser() async {
    final String uri = _buildUri('/user');
    final http.Response res = await http.get(uri);

    if (res.statusCode == 200) {
      return User.fromJson(_decodeResponse(res));
    }

    // throw Exception('Failed to fetch user: '
    //     'status: ${res.statusCode} '
    //     'res: ${_decodeResponse(res)}');
    throw ApiError.fromJson(_decodeResponse(res));
  }
}
