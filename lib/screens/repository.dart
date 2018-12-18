import 'package:flutter/cupertino.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

import 'package:torg_gitlab/tools/api.dart';
import 'package:torg_gitlab/tools/icons.dart';
import 'package:torg_gitlab/tools/bloc_provider.dart';

import 'package:torg_gitlab/blocs/repository_bloc.dart';

import 'package:torg_gitlab/models/project.dart';
import 'package:torg_gitlab/models/tree_item.dart';
import 'package:torg_gitlab/models/branch.dart';

class RepositoryView extends StatelessWidget {
  final Project _project;

  // String _currentBranch = 'develop';
  // int _currentBranchIndex;
  // bool _isGettingBranches = false;

  RepositoryView({Project project}) : _project = project;

  // Future<void> _displayBranchPicker() async {
  //   setState(() => _isGettingBranches = true);

  //   final List<Branch> branches = await _api.getBranchesForProject(projectId: widget._project.id);

  //   setState(() => _isGettingBranches = false);

  //   FixedExtentScrollController controller;

  //   if (_currentBranchIndex == null) {
  //     final int activeIndex = branches.indexWhere((Branch branch) => branch.name == _currentBranch);
  //     controller = FixedExtentScrollController(
  //       initialItem: activeIndex != null ? activeIndex : 0,
  //     );
  //   } else {
  //     controller = FixedExtentScrollController(initialItem: _currentBranchIndex);
  //   }

  //   await showCupertinoModalPopup(
  //     context: context,
  //     builder: (_) {
  //       return Container(
  //         height: _kPickerSheetHeight,
  //         color: ui.Colors.white,
  //         child: CupertinoPicker(
  //           scrollController: controller,
  //           children: List<Widget>.generate(branches.length, (int index) {
  //             return Center(
  //               child: Text(branches[index].name),
  //             );
  //           }),
  //           onSelectedItemChanged: (int index) {
  //             setState(() {
  //               _currentBranch = branches[index].name;
  //               _currentBranchIndex = index;
  //             });
  //           },
  //           itemExtent: _kPickerItemHeight,
  //           useMagnifier: true,
  //           backgroundColor: ui.Colors.white,
  //           diameterRatio: _kPickerSheetHeight * 2,
  //           offAxisFraction: 0,
  //           // magnification: 1.1,
  //         ),
  //       );
  //     },
  //   );

  //   print('closed');
  // }

  @override
  Widget build(BuildContext context) {
    final Api api = Api();
    final RepositoryBloc bloc = BlocProvider.of<RepositoryBloc>(context);

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
          SliverToBoxAdapter(
            child: Container(
              child: ui.Button(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: StreamBuilder(
                          stream: bloc.branch,
                          initialData: _project.defaultBranch,
                          builder: (_, AsyncSnapshot<String> snapshot) {
                            return Text(
                              snapshot.data,
                              style: TextStyle(color: ui.Colors.deepBlue),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
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
                onPressed: () {
                  // TODO: add branch switching through picker
                  bloc.setBranch.add('master');
                },
              ),
              padding: const EdgeInsets.all(10.0),
            ),
          ),
          FutureBuilder(
            future: api.getRepositoryTree(
              projectId: _project.id,
              branch: _project.defaultBranch,
              path: '',
            ),
            builder: (_, AsyncSnapshot<List<TreeItem>> snapshot) {
              if (snapshot.hasData) {
                bloc.init.add(
                  new RepositoryTreeRequest(
                    path: '',
                    branch: _project.defaultBranch,
                    projectId: _project.id,
                  ),
                );

                List<TreeItem> initialTree = snapshot.data;

                // return StreamBuilder(
                //   stream: bloc.isTreeLoading,
                //   initialData: false,
                //   builder: (_, AsyncSnapshot<bool> snapshot) {
                //     if (snapshot.data) {
                //       return sliverLoadingView;
                //     }
                //   );
                // },

                return StreamBuilder(
                  stream: bloc.tree,
                  initialData: initialTree,
                  builder: (_, AsyncSnapshot<List<TreeItem>> snapshot) {
                    if (snapshot.hasData) {
                      final List<TreeItem> tree = snapshot.data;

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, int index) {
                            final TreeItem blob = tree[index];

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
                                        blob.type == TreeItemType.blob
                                            ? TorgGitlabIcons.file
                                            : TorgGitlabIcons.folder,
                                        size: 16.0,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 5.0),
                                        child: Text(
                                          blob.name,
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: ui.Colors.linkWater, width: 0.0),
                                      bottom: BorderSide(color: ui.Colors.linkWater, width: 0.0),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  if (blob.type == TreeItemType.tree) {
                                    bloc.setPath.add(blob.path);
                                  }
                                },
                              ),
                            );
                          },
                          childCount: tree.length,
                        ),
                      );
                    }

                    return sliverLoadingView;
                  },
                );
              }

              return sliverLoadingView;
            },
          )
        ],
      ),
    );
  }
}
