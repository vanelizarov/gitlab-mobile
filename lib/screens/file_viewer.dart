import 'package:flutter/cupertino.dart';

import 'package:torg_gitlab/tools/api.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

class FileViewer extends StatefulWidget {
  final int projectId;
  final String branch;
  final String filePath;

  FileViewer({
    this.projectId,
    this.branch,
    this.filePath,
  });

  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  final Api _api = Api();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: ui.Colors.purple,
        leading: CupertinoButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Icon(CupertinoIcons.clear),
        ),
      ),
      child: FutureBuilder(
        future: _api.getFileContents(
          branch: widget.branch,
          filePath: widget.filePath,
          projectId: widget.projectId,
        ),
        builder: (_, AsyncSnapshot<String> snapshot) {
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

          return Container(
            child: Text(snapshot.data),
          );
        },
      ),
    );
  }
}
