import 'package:flutter/cupertino.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

import 'package:torg_gitlab/tools/api.dart';
import 'package:torg_gitlab/models/project.dart';

class ProjectPage extends StatelessWidget {
  final Api _api = Api();
  final Project project;

  ProjectPage({this.project});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: ui.Colors.whiteSmoke,
      navigationBar: CupertinoNavigationBar(
        actionsForegroundColor: ui.Colors.white,
        backgroundColor: ui.Colors.purple,
        middle: Row(
          children: <Widget>[
            Hero(
              tag: '${project.id}_image',
              child: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    // TODO: refactor to inject private token automatically
                    '${project.avatarUrl}?private_token=${_api.token}', //'http://y.delfi.lv/norm/1370/37505_dGxjiR.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
                margin: const EdgeInsets.only(right: 10.0),
                width: 20.0,
                height: 20.0,
              ),
            ),
            Hero(
              tag: '${project.id}_name',
              child: Text(
                project.nameWithNamespace,
                style: TextStyle(
                  color: ui.Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        transitionBetweenRoutes: false,
      ),
      child: Container(),
    );
  }
}
