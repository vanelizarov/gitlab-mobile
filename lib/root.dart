import 'package:flutter/cupertino.dart';
import 'package:uikit/uikit.dart' as ui;

import 'package:gitlab_mobile/tools/api.dart';
import 'package:gitlab_mobile/tools/bloc_provider.dart';
import 'package:gitlab_mobile/blocs/auth_bloc.dart';

import 'package:gitlab_mobile/models/user.dart';

import 'package:gitlab_mobile/screens/auth.dart';
import 'package:gitlab_mobile/screens/projects.dart';

class RootPage extends StatelessWidget {
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

    return StreamBuilder(
      stream: bloc.user,
      initialData: null,
      builder: (_, AsyncSnapshot<User> snapshot) {
        if (snapshot.data != null) {
          return ProjectsPage();
        }

        if (api.token != null) {
          return FutureBuilder(
            future: api.getCurrentlyAuthenticatedUser().catchError(() {}),
            builder: (_, AsyncSnapshot<User> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return loadingView;
                default:
                  if (snapshot.hasError) {
                    return AuthPage();
                  } else {
                    bloc.setUser.add(snapshot.data);
                    return loadingView;
                  }
              }
            },
          );
        }

        return AuthPage();
      },
    );
  }
}

/*

*/
