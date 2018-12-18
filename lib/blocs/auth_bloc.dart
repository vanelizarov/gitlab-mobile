import 'dart:async';

import 'package:torg_gitlab/tools/api.dart';
import 'package:torg_gitlab/tools/bloc_provider.dart';

import 'package:torg_gitlab/models/user.dart';
import 'package:torg_gitlab/models/error.dart';

class AuthBloc implements BlocBase {
  final Api _api = Api();

  StreamController<User> _userController = StreamController<User>.broadcast();
  StreamSink<User> get setUser => _userController.sink;
  Stream<User> get user => _userController.stream;

  StreamController<ApiError> _errorController = StreamController<ApiError>.broadcast();
  Stream<ApiError> get error => _errorController.stream;

  StreamController<String> _tokenController = StreamController<String>.broadcast();
  Stream<bool> get tokenIsValid => _tokenController.stream.transform<bool>(
        StreamTransformer.fromHandlers(handleData: _validateToken),
      );
  StreamSink<String> get setToken => _tokenController.sink;

  StreamController _signInController = StreamController.broadcast();
  StreamSink get signIn => _signInController.sink;

  StreamController _signOutController = StreamController.broadcast();
  StreamSink get signOut => _signOutController.sink;

  StreamController<bool> _authInProgressController = StreamController<bool>.broadcast();
  Stream<bool> get authInProgress => _authInProgressController.stream;

  AuthBloc() {
    _tokenController.stream.listen(_onTokenReceived);
    _signInController.stream.listen(_onSignInActionReceived);
  }

  void dispose() {
    _userController.close();
    _tokenController.close();
    _signInController.close();
    _authInProgressController.close();
    _errorController.close();
    _signOutController.close();
  }

  void _onTokenReceived(String token) {
    _api.token = token;
  }

  Future<void> _onSignInActionReceived(dynamic _) async {
    _authInProgressController.sink.add(true);

    _errorController.sink.add(null);

    try {
      final User user = await _api.getCurrentlyAuthenticatedUser();
      _userController.sink.add(user);
    } on ApiError catch (error) {
      print(error);
      _userController.sink.add(null);
      _errorController.sink.add(error);
    } finally {
      _authInProgressController.sink.add(false);
    }
  }

  _onSignOutActionReceived(dynamic _) {
    _api.token = null;
    _userController.sink.add(null);
  }

  void _validateToken(String token, EventSink sink) => sink.add(token.trim() != '');
}
