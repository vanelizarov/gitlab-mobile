import 'package:flutter/cupertino.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

import 'package:torg_gitlab/tools/api.dart';
import 'package:torg_gitlab/tools/icons.dart';
import 'package:torg_gitlab/tools/bloc_provider.dart';

import 'package:torg_gitlab/blocs/repository_bloc.dart';
import 'package:torg_gitlab/blocs/file_viewer_bloc.dart';

import 'package:torg_gitlab/models/project.dart';
import 'package:torg_gitlab/models/blob.dart';
import 'package:torg_gitlab/models/branch.dart';

import 'package:torg_gitlab/views/blob_row.dart';
import 'package:torg_gitlab/views/breadcrumbs.dart';

import 'file_viewer.dart';

class RepositoryView extends StatelessWidget {
  final Api _api = Api();
  final Project _project;
  final List<Blob> _initialTree;

  RepositoryView({
    Project project,
    List<Blob> initialTree,
  })  : _project = project,
        _initialTree = initialTree;

  Future<Branch> _displayBranchPicker({
    BuildContext context,
    String prevSelectedBranchName,
  }) async {
    Branch selectedBranch;

    await showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: ui.Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: ui.Colors.linkWater,
                    width: 0.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CupertinoButton(
                    child: Text(
                      'Done',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 5.0,
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: ui.kPickerSheetHeight,
              color: ui.Colors.whiteSmoke,
              child: FutureBuilder(
                future: _api.getBranchesForProject(projectId: _project.id),
                builder: (_, AsyncSnapshot<List<Branch>> snapshot) {
                  if (snapshot.hasData) {
                    final List<Branch> branches = snapshot.data;

                    final int prevSelectedBranchIndex = branches.indexWhere(
                      (branch) => branch.name == prevSelectedBranchName,
                    );

                    FixedExtentScrollController controller = FixedExtentScrollController(
                      initialItem: prevSelectedBranchIndex != -1 ? prevSelectedBranchIndex : 0,
                    );

                    return CupertinoPicker(
                      scrollController: controller,
                      children: List<Widget>.generate(
                        branches.length,
                        (int index) {
                          return Center(
                            child: Text(branches[index].name),
                          );
                        },
                      ),
                      onSelectedItemChanged: (int index) => selectedBranch = branches[index],
                      itemExtent: ui.kPickerItemHeight,
                      useMagnifier: false,
                      backgroundColor: ui.Colors.whiteSmoke,
                      diameterRatio: ui.kPickerSheetHeight * 2,
                      offAxisFraction: 0,
                    );
                  }

                  return Center(
                    child: CupertinoActivityIndicator(animating: true),
                  );
                },
              ),
            )
          ],
        );
      },
    );

    return selectedBranch;
  }

  @override
  Widget build(BuildContext context) {
    // final Api api = Api();
    final RepositoryBloc bloc = BlocProvider.of<RepositoryBloc>(context);

    bloc.init.add(RepositoryTreeRequest(
      branch: _project.defaultBranch,
      projectId: _project.id,
      path: '',
    ));

    final Widget loadingView = Container(
      color: ui.Colors.white,
      child: Center(
        child: CupertinoActivityIndicator(
          animating: true,
        ),
      ),
    );

    final Widget sliverLoadingView = SliverFillRemaining(child: loadingView);

    return Container(
      color: ui.Colors.white,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverRefreshControl(
            onRefresh: () async => bloc.refresh.add(null),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: bloc.branch,
              initialData: _project.defaultBranch,
              builder: (_, AsyncSnapshot<String> snapshot) {
                return Container(
                  child: ui.Button(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              snapshot.data,
                              style: TextStyle(
                                color: ui.Colors.deepBlue,
                                fontSize: 16.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_down,
                            color: ui.Colors.greyChateau,
                          ),
                        ],
                      ),
                    ),
                    color: ui.Colors.white,
                    border: Border.all(
                      color: ui.Colors.linkWater,
                      style: BorderStyle.solid,
                      width: 1.0,
                    ),
                    onPressed: () async {
                      final Branch selectedBranch = await _displayBranchPicker(
                        context: context,
                        prevSelectedBranchName: snapshot.data,
                      );

                      if (selectedBranch != null && selectedBranch.name != snapshot.data) {
                        bloc.setBranch.add(selectedBranch.name);
                      }
                    },
                  ),
                  padding: const EdgeInsets.all(10.0),
                );
              },
            ),
          ),
          StreamBuilder(
            stream: bloc.path,
            initialData: '',
            builder: (_, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return SliverToBoxAdapter(
                  child: Breadcrumbs(
                    path: snapshot.data,
                    onTap: (path) => bloc.setPath.add(path),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: Container(),
              );
            },
          ),
          StreamBuilder(
            stream: bloc.tree,
            initialData: _initialTree,
            builder: (_, AsyncSnapshot<List<Blob>> treeSnapshot) {
              return StreamBuilder(
                stream: bloc.isTreeLoading,
                builder: (_, AsyncSnapshot<bool> isTreeLoadingSnapshot) {
                  if (isTreeLoadingSnapshot.data == true) {
                    return sliverLoadingView;
                  }

                  if (treeSnapshot.hasData) {
                    final List<Blob> tree = treeSnapshot.data;

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, int index) {
                          final Blob blob = tree[index];

                          return BlobRow(
                            blob: blob,
                            onTap: () {
                              if (blob.type == BlobType.tree) {
                                bloc.setPath.add(blob.path);
                              } else if (blob.type == BlobType.blob) {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) {
                                      return BlocProvider<FileViewerBloc>(
                                        child: FileViewer(
                                          projectId: _project.id,
                                          branch: 'develop',
                                          filePath: blob.path,
                                          fileName: blob.name,
                                        ),
                                        bloc: FileViewerBloc(),
                                      );
                                    },
                                    fullscreenDialog: true,
                                  ),
                                );
                              }
                            },
                          );
                        },
                        childCount: tree.length,
                      ),
                    );
                  }

                  return sliverLoadingView;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
