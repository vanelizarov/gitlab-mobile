import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:torg_gitlab/tools/storage.dart';

import 'package:torg_gitlab/models/project.dart';
import 'package:torg_gitlab/models/user.dart';
import 'package:torg_gitlab/models/error.dart';
import 'package:torg_gitlab/models/branch.dart';
import 'package:torg_gitlab/models/blob.dart';
import 'package:torg_gitlab/models/file.dart';

const String kBaseUrl = 'http://torgteam.cf/api/v4';

class Api {
  static final Api _instance = Api._();

  final Storage _storage = Storage();

  get token => _storage.get('token');
  set token(String token) {
    _storage.set('token', token);
    _storage.save();
  }

  factory Api() => _instance;
  Api._();

  String _buildUri(String path, {Map<String, String> queryParams}) {
    final Map<String, String> newQueryParams = Map<String, String>();

    if (queryParams != null) {
      newQueryParams.addAll(queryParams);
    }

    newQueryParams.addAll({'private_token': token});

    List<String> queryParamsArr = [];
    newQueryParams.forEach((key, value) => queryParamsArr.add('$key=$value'));

    return kBaseUrl + path + '?' + queryParamsArr.join('&');

    // return Uri.http(
    //   kApiPrefix,
    //   '/api/v4' + path,
    //   newQueryParams,
    // ).toString();
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
    final String uri = _buildUri(
      '/projects/$projectId/repository/branches',
      queryParams: <String, String>{'per_page': '100'},
    );
    final http.Response res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> rawBranches = _decodeResponse(res);

      return rawBranches.map<Branch>((raw) => Branch.fromJson(raw)).toList();
    }

    throw ApiError.fromJson(_decodeResponse(res));
  }

  Future<List<Blob>> getRepositoryTree({
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

      return rawTreeItems.map<Blob>((raw) => Blob.fromJson(raw)).toList();
    }

    throw ApiError.fromJson(_decodeResponse(res));
  }

  Future<File> getFile({int projectId, String filePath, String branch}) async {
    final String encodedFilePath = Uri.encodeComponent(filePath);
    final String uri = _buildUri(
      '/projects/$projectId/repository/files/$encodedFilePath/raw',
      queryParams: <String, String>{'ref': branch},
    );

    final http.Response res = await http.get(uri);

    if (res.statusCode == 200) {
      // return File.fromJson(_decodeResponse(res));
      return File(
        name: res.headers['x-gitlab-file-name'],
        blobId: res.headers['x-gitlab-blob-id'],
        commitId: res.headers['x-gitlab-commit-id'],
        contentSha256: res.headers['x-gitlab-content-sha256'],
        lastCommitId: res.headers['x-gitlab-last-commit-id'],
        path: res.headers['x-gitlab-file-path'],
        ref: res.headers['x-gitlab-ref'],
        size: int.parse(res.headers['x-gitlab-size']),
        content: utf8.decode(res.bodyBytes),
        encoding: FileEncoding.base64,
      );
    }

    throw ApiError.fromJson(_decodeResponse(res));
  }
}
