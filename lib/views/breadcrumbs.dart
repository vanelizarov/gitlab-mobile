import 'package:flutter/cupertino.dart';
import 'package:torg_gitlab_uikit/torg_gitlab_uikit.dart' as ui;

class _Breadcrumb {
  final String path;
  final String name;

  const _Breadcrumb({this.path, this.name});
}

typedef void BreadcrumbTapCallback(String path);

class Breadcrumbs extends StatefulWidget {
  final String path;
  final BreadcrumbTapCallback onTap;

  Breadcrumbs({
    @required this.path,
    @required this.onTap,
  })  : assert(path != null),
        assert(onTap != null);

  @override
  _BreadcrumbsState createState() => _BreadcrumbsState();
}

class _BreadcrumbsState extends State<Breadcrumbs> {
  ScrollController _controller;

  List<_Breadcrumb> _createBreadcrumbsFromPath(String path) {
    final List<_Breadcrumb> breadcrumbs = [
      _Breadcrumb(path: '', name: '/'),
    ];

    if (path == '') {
      return breadcrumbs;
    }

    final List<String> segments = path.split('/');

    for (int index = 0; index < segments.length; index++) {
      final String prevPath = breadcrumbs[breadcrumbs.length - 1].path;

      if (prevPath == '') {
        breadcrumbs.add(_Breadcrumb(
          path: segments[index],
          name: segments[index],
        ));
      } else {
        breadcrumbs.add(_Breadcrumb(
          path: breadcrumbs[breadcrumbs.length - 1].path + '/' + segments[index],
          name: segments[index],
        ));
      }
    }

    return breadcrumbs;
  }

  _scrollToTheEnd() async {
    await Future.delayed(Duration(milliseconds: 0));
    await _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<_Breadcrumb> breadcrumbs = _createBreadcrumbsFromPath(widget?.path);

    _scrollToTheEnd();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _controller,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          children: breadcrumbs.map<Widget>((breadcrumb) {
            final bool isLast = breadcrumbs.indexOf(breadcrumb) == breadcrumbs.length - 1;

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
              onTap: !isLast ? () => widget?.onTap(breadcrumb.path) : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}
