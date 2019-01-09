import 'package:flutter/cupertino.dart';

import 'package:uikit/uikit.dart' as ui;

import 'package:gitlab_mobile/blocs/file_viewer_bloc.dart';

import 'package:gitlab_mobile/tools/api.dart';
import 'package:gitlab_mobile/tools/bloc_provider.dart';
import 'package:gitlab_mobile/tools/keywords.dart';
import 'package:gitlab_mobile/tools/icons.dart';

import 'package:gitlab_mobile/models/file.dart';

import 'package:gitlab_mobile/views/bidirectional_scroll_view.dart';
import 'package:gitlab_mobile/views/fab.dart';

enum _IndentSize { twoSpaces, fourSpaces }
enum _IndentType { spaces, tabs }

class _CodeFragment {
  final String text;
  final bool isHighlighted;

  _CodeFragment({this.text, this.isHighlighted});
}

class _CodeTheme {
  final Color bgColor;
  final Color plainTextColor;
  final Color highlightedTextColor;

  const _CodeTheme({
    this.bgColor,
    this.plainTextColor,
    this.highlightedTextColor,
  });
}

const _CodeTheme _kLightCodeTheme = _CodeTheme(
  bgColor: ui.Colors.white,
  plainTextColor: ui.Colors.deepBlue,
  highlightedTextColor: ui.Colors.blue,
);

const _CodeTheme _kDarkCodeTheme = _CodeTheme(
  bgColor: const Color(0xff2c292d),
  plainTextColor: ui.Colors.white,
  highlightedTextColor: const Color(0xfffc9867),
);

class FileViewer extends StatelessWidget {
  final Api _api = Api();
  final bool _isThemeDark = true;

  double _fontSize = 10.0;

  final int projectId;
  final String branch;
  final String filePath;
  final String fileName;

  FileViewer({
    this.projectId,
    this.branch,
    this.filePath,
    this.fileName,
  });

  String _indentFileContents({
    String contents,
    _IndentSize indentSize = _IndentSize.twoSpaces,
  }) {
    _IndentType indentType = contents.indexOf('\t') != -1 ? _IndentType.tabs : _IndentType.spaces;
    String indentation = indentSize == _IndentSize.twoSpaces ? '  ' : '    ';

    String indentedContents = '';

    if (indentType == _IndentType.tabs) {
      indentedContents = contents.replaceAll('\t', indentation);
    } else {
      final List<String> lines = contents.split('\n');
      final List<String> indentedLines = [];
      final RegExp indentedLineMatcher = RegExp(r'^(\s+)(.+)', multiLine: true);

      lines.forEach((line) {
        if (indentedLineMatcher.hasMatch(line)) {
          final Match match = indentedLineMatcher.firstMatch(line);

          String indentedLine = List.generate(
                (match.group(1).length / indentation.length).floor(),
                (_) => indentation,
              ).join('') +
              match.group(2);

          indentedLines.add(indentedLine);
        } else {
          indentedLines.add(line);
        }
      });

      indentedContents = indentedLines.join('\n');
    }

    return indentedContents;
  }

  List<_CodeFragment> _highlightKeywords({
    String code,
    List<String> keywords = const [],
  }) {
    final List<String> tokens = [];
    final List<_CodeFragment> fragments = [];

    final RegExp tokenMatcher = RegExp(r'(\w+)?([^\w]*)?', multiLine: true);
    // final RegExp keywordMatcher = RegExp(
    //   keywords.map((keyword) => RegExp.escape(keyword)).join('|'),
    // );

    tokenMatcher.allMatches(code).toList().forEach((match) {
      tokens.add(match.group(1));
      tokens.add(match.group(2));
    });

    tokens.where((token) => token != null).forEach((String token) {
      fragments.add(_CodeFragment(
        text: token,
        isHighlighted: keywords.indexOf(token.toLowerCase()) != -1,
      ));
    });

    return fragments;
  }

  List<_CodeFragment> _indentAndHighlight(File file) {
    // final Uint8List decodedBytes = base64.decode(file.content);
    // final String decodedContents = String.fromCharCodes(decodedBytes);

    final List<String> filenameSegments = file.name.split('.');
    final String ext = filenameSegments[filenameSegments.length - 1];

    List<_CodeFragment> highlightedContents;

    if (ext == 'go') {
      highlightedContents = _highlightKeywords(
        keywords: Keywords.go,
        code: _indentFileContents(
          contents: file.content,
          indentSize: _IndentSize.fourSpaces,
        ),
      );
    } else if (ext == 'ts' || ext == 'js') {
      highlightedContents = _highlightKeywords(
        keywords: Keywords.typescript,
        code: _indentFileContents(
          contents: file.content,
          indentSize: _IndentSize.twoSpaces,
        ),
      );
    } else if (ext == 'json') {
      highlightedContents = _highlightKeywords(
        keywords: Keywords.json,
        code: _indentFileContents(
          contents: file.content,
          indentSize: _IndentSize.twoSpaces,
        ),
      );
    } else if (ext == 'html') {
      highlightedContents = _highlightKeywords(
        keywords: Keywords.html,
        code: _indentFileContents(
          contents: file.content,
          indentSize: _IndentSize.twoSpaces,
        ),
      );
    } else {
      highlightedContents = _highlightKeywords(
        code: _indentFileContents(
          contents: file.content,
          indentSize: _IndentSize.twoSpaces,
        ),
      );
    }

    return highlightedContents;
  }

  @override
  Widget build(BuildContext context) {
    final FileViewerBloc bloc = BlocProvider.of<FileViewerBloc>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: ui.Colors.purple,
        actionsForegroundColor: ui.Colors.white,
        middle: Text(
          fileName,
          style: TextStyle(
            color: ui.Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      child: FutureBuilder<File>(
        future: _api.getFile(
          branch: branch,
          filePath: filePath,
          projectId: projectId,
        ),
        builder: (_, AsyncSnapshot<File> fileSnapshot) {
          if (!fileSnapshot.hasData) {
            return Container(
              color: ui.Colors.white,
              child: Center(
                child: CupertinoActivityIndicator(
                  animating: true,
                ),
              ),
            );
          }

          return StreamBuilder(
            stream: bloc.isThemeDark,
            initialData: _isThemeDark,
            builder: (_, AsyncSnapshot<bool> snapshot) {
              final bool isDarkThemeEnabled = snapshot.data;
              final _CodeTheme theme = isDarkThemeEnabled ? _kDarkCodeTheme : _kLightCodeTheme;

              return Container(
                color: theme.bgColor,
                child: Stack(
                  children: <Widget>[
                    BidirectionalScrollView(
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: StreamBuilder(
                                stream: bloc.fontSize,
                                initialData: _fontSize,
                                builder: (_, AsyncSnapshot<double> snapshot) {
                                  return Column(
                                    children: List.generate(
                                      fileSnapshot.data.content.split('\n').length,
                                      (int index) {
                                        return Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: snapshot.data,
                                            fontFamily: 'MenloRegular',
                                            color: ui.Colors.greyRaven,
                                          ),
                                          textAlign: TextAlign.right,
                                        );
                                      },
                                    ),
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                  );
                                },
                              ),
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                right: 5.0,
                                left: 10.0,
                                bottom: 10.0,
                              ),
                              margin: const EdgeInsets.only(
                                bottom: 60.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: ui.Colors.linkWater,
                                    width: 0.0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: StreamBuilder(
                                stream: bloc.fontSize,
                                initialData: _fontSize,
                                builder: (_, AsyncSnapshot<double> snapshot) {
                                  final double fontSize = snapshot.data;

                                  return StreamBuilder(
                                    stream: bloc.isThemeDark,
                                    initialData: _isThemeDark,
                                    builder: (_, AsyncSnapshot<bool> snapshot) {
                                      final bool isDarkThemeEnabled = snapshot.data;
                                      final _CodeTheme theme =
                                          isDarkThemeEnabled ? _kDarkCodeTheme : _kLightCodeTheme;

                                      final List<TextSpan> codeSpans = _indentAndHighlight(
                                        fileSnapshot.data,
                                      ).map(
                                        (fragment) {
                                          return TextSpan(
                                            text: fragment.text,
                                            style: TextStyle(
                                              color: fragment.isHighlighted
                                                  ? theme.highlightedTextColor
                                                  : theme.plainTextColor,
                                            ),
                                          );
                                        },
                                      ).toList();

                                      return RichText(
                                        text: TextSpan(
                                          children: codeSpans,
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            fontFamily: 'MenloRegular',
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                right: 10.0,
                                left: 5.0,
                                bottom: 10.0,
                              ),
                              margin: const EdgeInsets.only(
                                bottom: 60.0,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      right: 0.0,
                      left: 0.0,
                      child: SafeArea(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Fab(
                                icon: Icons.dark_mode,
                                iconColor: isDarkThemeEnabled ? ui.Colors.blue : ui.Colors.white,
                                borderRadius: BorderRadius.circular(5.0),
                                onTap: () => bloc.setThemeIsDark.add(!isDarkThemeEnabled),
                              ),
                              //
                              Container(width: 10.0),
                              //
                              Fab(
                                icon: Icons.decrease_font_size,
                                iconColor: ui.Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  bottomLeft: Radius.circular(5.0),
                                ),
                                onTap: () {
                                  if (_fontSize - 1 < 8) {
                                    return;
                                  }

                                  bloc.changeFontSize.add(--_fontSize);
                                },
                              ),
                              //
                              Container(
                                width: 0.5,
                                height: 40,
                                color: ui.Colors.deepBlue,
                                child: Center(
                                  child: Container(
                                    color: ui.Colors.linkWater,
                                    height: 20,
                                  ),
                                ),
                              ),
                              //
                              Fab(
                                icon: Icons.increase_font_size,
                                iconColor: ui.Colors.white,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5.0),
                                  bottomRight: Radius.circular(5.0),
                                ),
                                onTap: () {
                                  if (_fontSize + 1 > 18) {
                                    return;
                                  }

                                  bloc.changeFontSize.add(++_fontSize);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
