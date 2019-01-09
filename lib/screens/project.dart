import 'package:flutter/cupertino.dart';
import 'package:uikit/uikit.dart' as ui;

import 'package:gitlab_mobile/tools/icons.dart';
import 'package:gitlab_mobile/tools/api.dart';
import 'package:gitlab_mobile/tools/bloc_provider.dart';

import 'package:gitlab_mobile/models/project.dart';
import 'package:gitlab_mobile/models/blob.dart';

import 'package:gitlab_mobile/blocs/repository_bloc.dart';

import 'repository.dart';

class ProjectPage extends StatelessWidget {
  final Project _project;
  final Api _api = Api();

  ProjectPage({Project project}) : _project = project;

  @override
  Widget build(BuildContext context) {
    final Widget loadingView = Container(
      color: ui.Colors.white,
      child: Center(
        child: CupertinoActivityIndicator(
          animating: true,
        ),
      ),
    );

    return CupertinoPageScaffold(
      backgroundColor: ui.Colors.whiteSmoke,
      navigationBar: CupertinoNavigationBar(
        actionsForegroundColor: ui.Colors.white,
        backgroundColor: ui.Colors.purple,
        middle: Text(
          _project.name,
          style: TextStyle(
            color: ui.Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
        // transitionBetweenRoutes: false,
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          activeColor: ui.Colors.purple,
          inactiveColor: ui.Colors.greyChateau,
          backgroundColor: ui.Colors.white,
          border: Border(
            top: BorderSide(
              color: ui.Colors.linkWater,
              width: 0.0,
            ),
          ),
          items: [
            BottomNavigationBarItem(
              title: Text('Repository'),
              icon: Icon(
                Icons.repository,
                size: 20.0,
              ),
            ),
            BottomNavigationBarItem(
              title: Text('Merge Requests'),
              icon: Icon(
                Icons.merge_requests,
                size: 20.0,
              ),
            ),
          ],
        ),
        tabBuilder: (_, int index) {
          if (index == 0) {
            return BlocProvider<RepositoryBloc>(
              bloc: RepositoryBloc(),
              child: FutureBuilder<List<Blob>>(
                future: _api.getRepositoryTree(
                  projectId: _project.id,
                  branch: _project.defaultBranch,
                  path: '',
                ),
                builder: (_, AsyncSnapshot<List<Blob>> snapshot) {
                  if (snapshot.hasData) {
                    return RepositoryView(
                      project: _project,
                      initialTree: snapshot.data,
                    );
                  }

                  return loadingView;
                },
              ),
            );
          } else {
            return Container(
              child: Text('Not implemented yet'),
            );
          }
        },
      ),
    );
  }
}
