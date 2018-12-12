import 'package:flutter/cupertino.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

import 'auth_bloc.dart';
import 'bloc_provider.dart';

import 'models/error.dart';
import 'models/user.dart';

import 'projects.dart';

// bg3GzUXMpcvA3tVouy75

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthBloc bloc = BlocProvider.of<AuthBloc>(context);
    final FocusNode focusNode = FocusNode();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: ui.Colors.purple,
        middle: Text(
          'Authorization',
          style: TextStyle(
            color: ui.Colors.white,
          ),
        ),
      ),
      child: Container(
        color: ui.Colors.whiteSmoke,
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: ui.TextField(
                autofocus: true,
                placeholder: 'Personal access token',
                text: 'bg3GzUXMpcvA3tVouy75',
                onChanged: (String token) => bloc.setToken.add(token),
                focusNode: focusNode,
                disabledStream: bloc.authInProgress,
              ),
              margin: const EdgeInsets.only(bottom: 10.0),
            ),
            StreamBuilder(
              stream: bloc.error,
              initialData: null,
              builder: (_, AsyncSnapshot<ApiError> snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    child: Text(
                      'Error: ${snapshot.data.message}',
                      style: TextStyle(fontSize: 12.0, color: ui.Colors.red),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    margin: const EdgeInsets.only(bottom: 10.0),
                  );
                }

                return Container();
              },
            ),
            Container(
              child: Text(
                'To get personal access token:\n\n'
                    '1. Log in to your GitLab account.\n'
                    '2. Go to your Profile settings.\n'
                    '3. Go to Access tokens.\n'
                    '4. Choose a name for the token.\n'
                    '5. Choose all scopes.\n'
                    '6. Click on Create personal access token.\n',
                style: TextStyle(
                  fontSize: 12.0,
                  color: ui.Colors.greyChateau,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
            ),
            Container(
              child: StreamBuilder(
                stream: bloc.authInProgress,
                initialData: false,
                builder: (_, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.data) {
                    return ui.Button(
                      child: CupertinoActivityIndicator(
                        animating: true,
                      ),
                      onPressed: null,
                    );
                  }

                  return StreamBuilder(
                    stream: bloc.tokenIsValid,
                    builder: (_, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.data != false) {
                        return ui.Button(
                          child: ui.ButtonText(text: 'Continue'),
                          onPressed: () {
                            focusNode.unfocus();
                            bloc.signIn.add(null);
                          },
                        );
                      }

                      return ui.Button(
                        child: ui.ButtonText(text: 'Continue'),
                        onPressed: null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
