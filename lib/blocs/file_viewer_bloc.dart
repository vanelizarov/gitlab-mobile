import 'dart:async';
import 'package:torg_gitlab/tools/bloc_provider.dart';

class FileViewerBloc extends BlocBase {
  StreamController<bool> _isThemeDarkController = StreamController<bool>.broadcast();
  StreamSink<bool> get setThemeIsDark => _isThemeDarkController.sink;
  Stream<bool> get isThemeDark => _isThemeDarkController.stream;

  StreamController<double> _fontSizeController = StreamController<double>.broadcast();
  StreamSink<double> get changeFontSize => _fontSizeController.sink;
  Stream<double> get fontSize => _fontSizeController.stream;

  void dispose() {
    _isThemeDarkController.close();
    _fontSizeController.close();
  }
}
