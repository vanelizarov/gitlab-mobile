import 'package:flutter/cupertino.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

import 'package:torg_gitlab/tools/icons.dart';
import 'package:torg_gitlab/models/project.dart';

import 'repository.dart';

class ProjectPage extends StatelessWidget {
  final Project _project;

  ProjectPage({Project project}) : _project = project;

  @override
  Widget build(BuildContext context) {
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
          items: [
            BottomNavigationBarItem(
              title: Text('Repository'),
              icon: Icon(
                TorgGitlabIcons.repository,
                size: 20.0,
              ),
            ),
            BottomNavigationBarItem(
              title: Text('Merge Requests'),
              icon: Icon(
                TorgGitlabIcons.merge_requests,
                size: 20.0,
              ),
            ),
          ],
        ),
        tabBuilder: (_, int index) {
          if (index == 0) {
            return RepositoryView(project: _project);
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
