import 'package:flutter/cupertino.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

import 'auth_bloc.dart';
import 'bloc_provider.dart';

import 'api.dart';
import 'models/project.dart';

class ProjectsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthBloc bloc = BlocProvider.of<AuthBloc>(context);
    final Api api = Api();

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
        navigationBar: CupertinoNavigationBar(
          backgroundColor: ui.Colors.purple,
          middle: Text(
            'Projects',
            style: TextStyle(
              color: ui.Colors.white,
            ),
          ),
        ),
        child: FutureBuilder(
          future: api.getProjects(),
          builder: (_, AsyncSnapshot<List<Project>> snapshot) {
            if (snapshot.hasData) {
              final List<Project> projects = snapshot.data;

              return ListView.builder(
                itemCount: projects.length,
                itemBuilder: (_, int index) {
                  final Project project = projects[index];

                  return Container(
                    padding: const EdgeInsets.all(15.0),
                    color: ui.Colors.white,
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.network(
                              // TODO: refactor to inject private token automatically
                              '${project.avatarUrl}?private_token=${api.token}', //'http://y.delfi.lv/norm/1370/37505_dGxjiR.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          margin: const EdgeInsets.only(right: 15.0),
                          width: 40.0,
                          height: 40.0,
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
                  );
                },
              );
            }

            return loadingView;
          },
        ));
  }
}
