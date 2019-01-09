import 'package:flutter/cupertino.dart';
import 'package:uikit/uikit.dart' as ui;

import 'package:gitlab_mobile/tools/icons.dart';

import 'package:gitlab_mobile/models/blob.dart';

class BlobRow extends StatefulWidget {
  final Blob blob;
  final GestureTapCallback onTap;

  BlobRow({
    @required this.blob,
    @required this.onTap,
  })  : assert(blob != null),
        assert(onTap != null);

  @override
  _BlobRowState createState() => _BlobRowState();
}

class _BlobRowState extends State<BlobRow> {
  bool _needsHighlight = false;

  _onTapUp(_) => setState(() => _needsHighlight = false);

  _onTapDown(_) => setState(() => _needsHighlight = true);

  _onTapCancel() => setState(() => _needsHighlight = false);

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
                widget.blob.type == BlobType.blob ? Icons.file : Icons.folder,
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
            color: _needsHighlight ? Color(0xfff6fafe) : ui.Colors.white,
          ),
        ),
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
      ),
    );
  }
}
