import 'package:flutter/cupertino.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

import 'token.dart';
import 'api.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String _token = '';
  TextEditingController _textController =
      TextEditingController(text: 'bg3GzUXMpcvA3tVouy75');

  get _isTokenValid => _token.trim() != '';

  _onTokenTextFieldValueChanged() {
    setState(() => _token = _textController.text);
  }

  _onContinue() {
    Token().value = _token;

    Api().getProjects().then((projects) {
      projects.forEach((project) {
        print(project);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTokenTextFieldValueChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: CupertinoTextField(
                controller: _textController,
                autofocus: true,
                autocorrect: false,
                cursorColor: ui.Colors.blue,
                cursorWidth: 1.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 15.0,
                ),
                placeholder: 'Personal access token',
                decoration: BoxDecoration(
                  color: ui.Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              margin: const EdgeInsets.only(bottom: 10.0),
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
              padding: const EdgeInsets.only(left: 5.0),
            ),
            Container(
              child: ui.Button(
                child: ui.ButtonText(
                  text: 'Continue',
                ),
                onPressed: _isTokenValid ? _onContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
