import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';

import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

import 'package:torg_gitlab/tools/api.dart';
import 'package:torg_gitlab/tools/bidirectional_scroll_view.dart';

import 'package:torg_gitlab/models/file.dart';

enum IndentSize { twoSpaces, fourSpaces }
enum IndentType { spaces, tabs }

final List<String> kGoKeywords = const [
  'break',
  'default',
  'func',
  'interface',
  'select',
  'case',
  'defer',
  'go',
  'map',
  'struct',
  'chan',
  'else',
  'goto',
  'package',
  'switch',
  'const',
  'fallthrough',
  'if',
  'range',
  'type',
  'continue',
  'for',
  'import',
  'return',
  'var',
  'bool',
  'string',
  'int',
  'int8',
  'int16',
  'int32',
  'int64',
  'uint',
  'uint8',
  'uint16',
  'uint32',
  'uint64',
  'uintptr',
  'byte',
  'rune',
  'float32',
  'float64',
  'complex64',
  'complex128'
];

final List<String> kTypescriptKeywords = const [
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'debugger',
  'default',
  'delete',
  'do',
  'else',
  'enum',
  'export',
  'extends',
  'false',
  'finally',
  'for',
  'function',
  'if',
  'import',
  'in',
  'instanceof',
  'new',
  'null',
  'return',
  'super',
  'switch',
  'this',
  'throw',
  'true',
  'try',
  'typeof',
  'var',
  'void',
  'while',
  'with',
  'implements',
  'interface',
  'let',
  'package',
  'private',
  'protected',
  'public',
  'static',
  'yield',
  'any',
  'boolean',
  'number',
  'string',
  'symbol',
  'abstract',
  'as',
  'async',
  'await',
  'constructor',
  'declare',
  'from',
  'get',
  'is',
  'module',
  'namespace',
  'of',
  'require',
  'set',
  'type',
];

class FileViewer extends StatelessWidget {
  final Api _api = Api();
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

  String _indentFileContents({String contents, IndentSize indentSize = IndentSize.twoSpaces}) {
    IndentType indentType = contents.indexOf('\t') != -1 ? IndentType.tabs : IndentType.spaces;
    String indentation = indentSize == IndentSize.twoSpaces ? '  ' : '    ';

    String indentedContents = '';

    if (indentType == IndentType.tabs) {
      indentedContents = contents.replaceAll('\t', indentation);
    } else {
      final RegExp indentationMatcher = RegExp(r'^([ ]*)(.*)', multiLine: true);

      indentationMatcher.allMatches(contents).toList().forEach((match) {
        final List<String> matchGroups = match.groups([1, 2]);

        indentedContents += '\n' +
            List.generate(matchGroups[0].length, (_) => indentation).join('') +
            matchGroups[1];
      });
    }

    return indentedContents;
  }

  List<TextSpan> _highlightKeywords({
    String code,
    List<String> keywords = const [],
  }) {
    final List<String> tokens = [];
    final List<TextSpan> tokenSpans = [];

    final RegExp tokenMatcher = RegExp(r'(\w+)([^\w]*)?', multiLine: true);

    tokenMatcher.allMatches(code).toList().forEach((match) {
      tokens.add(match.group(1));
      tokens.add(match.group(2));
    });

    tokens.forEach((token) {
      tokenSpans.add(TextSpan(
        text: token,
        style: TextStyle(
          color: keywords.indexOf(token) != -1 ? ui.Colors.blue : ui.Colors.deepBlue,
        ),
      ));
    });

    return tokenSpans;
  }

  @override
  Widget build(BuildContext context) {
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
      child: FutureBuilder(
        future: _api.getFile(
          branch: branch,
          filePath: filePath,
          projectId: projectId,
        ),
        builder: (_, AsyncSnapshot<File> snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: ui.Colors.white,
              child: Center(
                child: CupertinoActivityIndicator(
                  animating: true,
                ),
              ),
            );
          }

          final File file = snapshot.data;

          // final Uint8List decodedBytes = base64.decode(file.content);
          // final String decodedContents = String.fromCharCodes(decodedBytes);

          final List<String> filenameSegments = file.name.split('.');
          final String ext = filenameSegments[filenameSegments.length - 1];

          List<TextSpan> highlightedContents;

          if (ext == 'go') {
            highlightedContents = _highlightKeywords(
              code: _indentFileContents(contents: file.content, indentSize: IndentSize.fourSpaces),
              keywords: kGoKeywords,
            );
          } else if (ext == 'ts') {
            highlightedContents = _highlightKeywords(
              code: _indentFileContents(contents: file.content, indentSize: IndentSize.twoSpaces),
              keywords: kTypescriptKeywords,
            );
          } else {
            highlightedContents = _highlightKeywords(
              code: _indentFileContents(contents: file.content, indentSize: IndentSize.twoSpaces),
            );
          }

          return Container(
            color: ui.Colors.white,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: BidirectionalScrollView(
                child: Row(
                  children: <Widget>[
                    Column(
                      children: List.generate(
                        file.content.split('\n').length,
                        (int index) {
                          return Padding(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontFamily: 'MenloRegular',
                                color: ui.Colors.greyRaven,
                              ),
                            ),
                            padding: const EdgeInsets.only(right: 10.0),
                          );
                        },
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: highlightedContents,
                        style: TextStyle(
                          fontSize: 10.0,
                          fontFamily: 'MenloRegular',
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
