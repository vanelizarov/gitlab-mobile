import 'dart:async';

import 'package:gitlab_mobile/tools/api.dart';
import 'package:gitlab_mobile/tools/bloc_provider.dart';

import 'package:gitlab_mobile/models/blob.dart';
import 'package:gitlab_mobile/models/error.dart';

class RepositoryTreeRequest {
  final int projectId;
  String path;
  String branch;

  RepositoryTreeRequest({this.projectId, this.path, this.branch});
}

class RepositoryBloc implements BlocBase {
  final Api _api = Api();

  RepositoryTreeRequest _currentRepoTree;

  StreamController<RepositoryTreeRequest> _initController =
      StreamController<RepositoryTreeRequest>.broadcast();
  StreamSink<RepositoryTreeRequest> get init => _initController.sink;

  StreamController<String> _pathController = StreamController<String>.broadcast();
  StreamSink<String> get setPath => _pathController.sink;
  Stream<String> get path => _pathController.stream;

  StreamController<String> _branchController = StreamController<String>.broadcast();
  StreamSink<String> get setBranch => _branchController.sink;
  Stream<String> get branch => _branchController.stream;

  StreamController<ApiError> _errorController = StreamController<ApiError>.broadcast();
  Stream<ApiError> get error => _errorController.stream;

  StreamController<bool> _treeLoadingInProgressController = StreamController<bool>.broadcast();
  Stream<bool> get isTreeLoading => _treeLoadingInProgressController.stream;

  StreamController<List<Blob>> _treeController = StreamController.broadcast();
  Stream<List<Blob>> get tree => _treeController.stream;

  StreamController _refreshController = StreamController.broadcast();
  StreamSink get refresh => _refreshController.sink;

  RepositoryBloc() {
    _initController.stream.listen(_onInit);
    _pathController.stream.listen(_onPathChanged);
    _branchController.stream.listen(_onBranchChanged);
    _refreshController.stream.listen(_onRefreshRequested);
  }

  void _onInit(RepositoryTreeRequest tree) {
    _currentRepoTree = tree;
  }

  void _onPathChanged(String path) {
    _currentRepoTree.path = path;
    _getRepoTree();
  }

  void _onBranchChanged(String branch) {
    _currentRepoTree.branch = branch;
    _getRepoTree();
  }

  void _onRefreshRequested(_) => _getRepoTree();

  Future<void> _getRepoTree() async {
    // TODO: add pagination

    _treeLoadingInProgressController.sink.add(true);
    _errorController.sink.add(null);

    try {
      final List<Blob> tree = await _api.getRepositoryTree(
        projectId: _currentRepoTree.projectId,
        branch: _currentRepoTree.branch,
        path: _currentRepoTree.path,
      );

      _treeController.sink.add(tree);
    } on ApiError catch (error) {
      print(error);
      _errorController.sink.add(error);

      _currentRepoTree.path = '';
      _currentRepoTree.branch = 'develop';

      _getRepoTree();
    } finally {
      _treeLoadingInProgressController.sink.add(false);
    }
  }

  void dispose() {
    _initController.close();
    _pathController.close();
    _treeLoadingInProgressController.close();
    _treeController.close();
    _errorController.close();
    _branchController.close();
    _refreshController.close();
  }
}
