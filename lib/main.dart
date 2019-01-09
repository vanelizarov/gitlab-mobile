import 'package:flutter/cupertino.dart';
import 'package:uikit/uikit.dart' as ui;

import 'package:gitlab_mobile/tools/storage.dart';
import 'package:gitlab_mobile/tools/bloc_provider.dart';

import 'package:gitlab_mobile/blocs/auth_bloc.dart';

import 'root.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print('entering app state ${state.toString()}');

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        await Storage().save();
        break;
      case AppLifecycleState.resumed:
        await Storage().load();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: FutureBuilder(
        future: Storage().load(),
        builder: (_, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Container(color: ui.Colors.whiteSmoke);
            default:
              return BlocProvider<AuthBloc>(
                bloc: AuthBloc(),
                child: RootPage(),
              );
          }
        },
      ),
    );
  }
}
