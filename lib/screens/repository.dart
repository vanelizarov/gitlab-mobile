import 'package:flutter/cupertino.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

import 'package:torg_gitlab/tools/api.dart';
import 'package:torg_gitlab/tools/icons.dart';

import 'package:torg_gitlab/models/project.dart';
import 'package:torg_gitlab/models/branch.dart';

const double _kPickerSheetHeight = 320.0;
const double _kPickerItemHeight = 32.0;

class RepositoryView extends StatefulWidget {
  final Project _project;

  RepositoryView({Project project}) : _project = project;

  @override
  _RepositoryViewState createState() => _RepositoryViewState();
}

class _RepositoryViewState extends State<RepositoryView> {
  final Api _api = Api();

  String _currentBranch = 'develop';
  int _currentBranchIndex;

  bool _isGettingBranches = false;

  Future<void> _getBranchContents(String branch, String path) {}

  Future<void> _displayBranchPicker() async {
    setState(() => _isGettingBranches = true);

    final List<Branch> branches = await _api.getBranchesForProject(widget._project.id);

    setState(() => _isGettingBranches = false);

    FixedExtentScrollController controller;

    if (_currentBranchIndex == null) {
      final int activeIndex = branches.indexWhere((Branch branch) => branch.name == _currentBranch);
      controller = FixedExtentScrollController(
        initialItem: activeIndex != null ? activeIndex : 0,
      );
    } else {
      controller = FixedExtentScrollController(initialItem: _currentBranchIndex);
    }

    await showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Container(
          height: _kPickerSheetHeight,
          color: ui.Colors.white,
          child: CupertinoPicker(
            scrollController: controller,
            children: List<Widget>.generate(branches.length, (int index) {
              return Center(
                child: Text(branches[index].name),
              );
            }),
            onSelectedItemChanged: (int index) {
              setState(() {
                _currentBranch = branches[index].name;
                _currentBranchIndex = index;
              });
            },
            itemExtent: _kPickerItemHeight,
            useMagnifier: true,
            backgroundColor: ui.Colors.white,
            diameterRatio: _kPickerSheetHeight * 2,
            offAxisFraction: 0,
            // magnification: 1.1,
          ),
        );
      },
    );

    print('closed');
  }

  @override
  Widget build(BuildContext context) {
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
                        child: Text(
                          _currentBranch,
                          style: TextStyle(color: ui.Colors.deepBlue),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _isGettingBranches
                          ? CupertinoActivityIndicator(
                              animating: true,
                              radius: 10.0,
                            )
                          : Icon(
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
                onPressed: _displayBranchPicker,
              ),
              padding: const EdgeInsets.all(10.0),
            ),
          )
        ],
      ),
    );
  }
}

/*

*/
