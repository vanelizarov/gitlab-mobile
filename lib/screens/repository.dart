import 'package:flutter/cupertino.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

import 'package:torg_gitlab/tools/api.dart';
import 'package:torg_gitlab/tools/icons.dart';
import 'package:torg_gitlab/tools/bloc_provider.dart';

import 'package:torg_gitlab/blocs/repository_bloc.dart';

import 'package:torg_gitlab/models/project.dart';
import 'package:torg_gitlab/models/tree_item.dart';
import 'package:torg_gitlab/models/branch.dart';

import 'file_viewer.dart';

class Breadcrumb {
  final String path;
  final String name;

  const Breadcrumb({this.path, this.name});
}

class RepositoryView extends StatelessWidget {
  final Api _api = Api();
  final Project _project;
  final List<TreeItem> _initialTree;

  RepositoryView({
    Project project,
    List<TreeItem> initialTree,
  })  : _project = project,
        _initialTree = initialTree;

  Future<Branch> _displayBranchPicker({BuildContext context, String prevSelectedBranchName}) async {
    final List<Branch> branches = await _api.getBranchesForProject(projectId: _project.id);

    final int prevSelectedBranchIndex = branches.indexWhere(
      (branch) => branch.name == prevSelectedBranchName,
    );

    FixedExtentScrollController controller = FixedExtentScrollController(
      initialItem: prevSelectedBranchIndex != -1 ? prevSelectedBranchIndex : 0,
    );

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
                      horizontal: 10.0,
                      vertical: 5.0,
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: ui.kPickerSheetHeight,
              color: ui.Colors.white,
              child: CupertinoPicker(
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
              ),
            )
          ],
        );
      },
    );

    return selectedBranch;
  }

  List<Breadcrumb> _buildBreadcrumbs(String path) {
    final List<Breadcrumb> breadcrumbs = [Breadcrumb(path: '', name: '/')];

    if (path == '') {
      return breadcrumbs;
    }

    final List<String> segments = path.split('/');

    for (int index = 0; index < segments.length; index++) {
      final String prevPath = breadcrumbs[breadcrumbs.length - 1].path;

      if (prevPath == '') {
        breadcrumbs.add(Breadcrumb(
          path: segments[index],
          name: segments[index],
        ));
      } else {
        breadcrumbs.add(Breadcrumb(
          path: breadcrumbs[breadcrumbs.length - 1].path + '/' + segments[index],
          name: segments[index],
        ));
      }
    }

    return breadcrumbs;
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
            onRefresh: () async {
              bloc.refresh.add(null);
            },
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
                              style: TextStyle(color: ui.Colors.deepBlue),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            TorgGitlabIcons.arrow_down,
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
                final List<Breadcrumb> breadcrumbs = _buildBreadcrumbs(snapshot.data);

                return SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: breadcrumbs.map<Widget>((breadcrumb) {
                          final bool isLast =
                              breadcrumbs.indexOf(breadcrumb) == breadcrumbs.length - 1;

                          return GestureDetector(
                            child: Container(
                              child: Text(
                                breadcrumb.name,
                                style: TextStyle(
                                  color: !isLast ? ui.Colors.blue : ui.Colors.white,
                                  fontSize: 14.0,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.0,
                              ),
                              margin: !isLast ? const EdgeInsets.only(right: 5.0) : null,
                              decoration: BoxDecoration(
                                color: !isLast
                                    ? Color.fromARGB(
                                        50,
                                        ui.Colors.blue.red,
                                        ui.Colors.blue.green,
                                        ui.Colors.blue.blue,
                                      )
                                    : ui.Colors.blue,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            onTap: !isLast ? () => bloc.setPath.add(breadcrumb.path) : null,
                          );
                        }).toList(),
                      ),
                    ),
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
            builder: (_, AsyncSnapshot<List<TreeItem>> treeSnapshot) {
              return StreamBuilder(
                stream: bloc.isTreeLoading,
                builder: (_, AsyncSnapshot<bool> isTreeLoadingSnapshot) {
                  if (isTreeLoadingSnapshot.data == true) {
                    return sliverLoadingView;
                  }

                  if (treeSnapshot.hasData) {
                    final List<TreeItem> tree = treeSnapshot.data;

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, int index) {
                          final TreeItem blob = tree[index];

                          return _TreeItemRow(
                            blob: blob,
                            onTap: () {
                              if (blob.type == TreeItemType.tree) {
                                bloc.setPath.add(blob.path);
                              } else if (blob.type == TreeItemType.blob) {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) => FileViewer(
                                          projectId: _project.id,
                                          branch: 'develop',
                                          filePath: blob.path,
                                          fileName: blob.name,
                                        ),
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

class _TreeItemRow extends StatefulWidget {
  final TreeItem blob;
  final GestureTapCallback onTap;

  _TreeItemRow({this.blob, this.onTap});

  @override
  __TreeItemRowState createState() => __TreeItemRowState();
}

class __TreeItemRowState extends State<_TreeItemRow> {
  bool _needsHighlight = false;

  _onTapUp(_) {
    setState(() => _needsHighlight = false);
  }

  _onTapDown(_) {
    setState(() => _needsHighlight = true);
  }

  _onTapCancel() {
    setState(() => _needsHighlight = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        child: Container(
          padding: const EdgeInsets.only(
            top: 14.0,
            bottom: 14.0,
            left: 10.0,
          ),
          child: Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: <Widget>[
              Icon(
                widget.blob.type == TreeItemType.blob
                    ? TorgGitlabIcons.file
                    : TorgGitlabIcons.folder,
                size: 16.0,
              ),
              Container(
                margin: const EdgeInsets.only(left: 5.0),
                child: Text(
                  widget.blob.name,
                  style: TextStyle(fontSize: 14.0),
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: _needsHighlight ? Color(0xffb8d6f4) : ui.Colors.linkWater,
                  width: 0.0,
                ),
                bottom: BorderSide(
                  color: _needsHighlight ? Color(0xffb8d6f4) : ui.Colors.linkWater,
                  width: 0.0,
                ),
              ),
              color: _needsHighlight ? Color(0xfff6fafe) : ui.Colors.white),
        ),
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
      ),
    );
  }
}
