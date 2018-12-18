import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:torg_gitlab/tools/storage.dart';

import 'package:torg_gitlab/models/project.dart';
import 'package:torg_gitlab/models/user.dart';
import 'package:torg_gitlab/models/error.dart';
import 'package:torg_gitlab/models/branch.dart';
import 'package:torg_gitlab/models/tree_item.dart';

const String kApiPrefix = 'torgteam.cf';

class Api {
  static final Api _instance = Api._();

  final Storage _storage = Storage();

  get token => _storage.get('token');
  set token(String token) => _storage.set('token', token);

  factory Api() => _instance;
  Api._();

  String _buildUri(String path, {Map<String, String> queryParams}) {
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

    throw ApiError.fromJson(_decodeResponse(res));
  }

  Future<User> getCurrentlyAuthenticatedUser() async {
    final String uri = _buildUri('/user');
    final http.Response res = await http.get(uri);

    if (res.statusCode == 200) {
      return User.fromJson(_decodeResponse(res));
    }

    throw ApiError.fromJson(_decodeResponse(res));
  }

  Future<List<Branch>> getBranchesForProject({int projectId}) async {
    final String uri = _buildUri('/projects/$projectId/repository/branches');
    final http.Response res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> rawBranches = _decodeResponse(res);

      return rawBranches.map<Branch>((raw) => Branch.fromJson(raw)).toList();
    }

    throw ApiError.fromJson(_decodeResponse(res));
  }

  Future<List<TreeItem>> getRepositoryTree({
    int projectId,
    String path,
    String branch,
    int itemsPerPage = 20,
    int page = 1,
  }) async {
    final String uri = _buildUri(
      '/projects/$projectId/repository/tree',
      queryParams: <String, String>{
        'path': path,
        'ref': branch,
        'per_page': '$itemsPerPage',
        'page': '$page'
      },
    );

    final http.Response res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> rawTreeItems = _decodeResponse(res);

      return rawTreeItems.map<TreeItem>((raw) => TreeItem.fromJson(raw)).toList();
    }

    throw ApiError.fromJson(_decodeResponse(res));
  }
}
