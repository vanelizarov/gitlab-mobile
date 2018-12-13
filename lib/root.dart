import 'package:flutter/cupertino.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

import 'api.dart';

import 'auth_bloc.dart';
import 'bloc_provider.dart';

import 'models/user.dart';

import 'auth.dart';
import 'projects.dart';

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
