import 'package:flutter/cupertino.dart';
import 'package:uikit/uikit.dart' as ui;

import 'package:gitlab_mobile/tools/api.dart';
import 'package:gitlab_mobile/models/project.dart';

import 'package:gitlab_mobile/screens/project.dart';

class ProjectsPage extends StatelessWidget {
  final Api _api = Api();

  Widget _buildProjectRow(Project project, VoidCallback onTap) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(15.0),
        color: ui.Colors.white,
        child: Row(
          children: <Widget>[
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.network(
                  // TODO: refactor to inject private token automatically
                  '${project.avatarUrl}?private_token=${_api.token}', //'http://y.delfi.lv/norm/1370/37505_dGxjiR.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
              margin: const EdgeInsets.only(right: 15.0),
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                border: Border.all(color: ui.Colors.linkWater, width: 0.0),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(
                    project.nameWithNamespace,
                    style: TextStyle(color: ui.Colors.deepBlue),
                  ),
                  margin: const EdgeInsets.only(bottom: 5.0),
                ),
                Text(
                  project.description,
                  style: TextStyle(fontSize: 12.0, color: ui.Colors.greyRaven),
                )
              ],
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget loadingView = Container(
      color: ui.Colors.whiteSmoke,
      child: Center(
        child: CupertinoActivityIndicator(
          animating: true,
        ),
      ),
    );

    return CupertinoPageScaffold(
      backgroundColor: ui.Colors.whiteSmoke,
      child: FutureBuilder<List<Project>>(
        future: _api.getProjects(),
        builder: (_, AsyncSnapshot<List<Project>> snapshot) {
          Widget projectsList;

          if (snapshot.hasData) {
            final List<Project> projects = snapshot.data;

            projectsList = SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, int index) {
                  return _buildProjectRow(projects[index], () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => ProjectPage(project: projects[index]),
                      ),
                    );
                  });
                },
                childCount: projects.length,
              ),
            );
          } else {
            projectsList = SliverFillRemaining(
              child: loadingView,
            );
          }

          return CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                actionsForegroundColor: ui.Colors.white,
                backgroundColor: ui.Colors.purple,
                largeTitle: Text(
                  'Projects',
                  style: TextStyle(color: ui.Colors.white),
                ),
              ),
              projectsList
            ],
          );
        },
      ),
    );
  }
}
