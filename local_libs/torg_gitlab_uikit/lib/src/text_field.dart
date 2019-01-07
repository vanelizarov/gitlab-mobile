import 'package:flutter/cupertino.dart';

import 'colors.dart';
import 'appearance.dart';

/*
CupertinoTextField(
  enabled: false,
  autofocus: true,
  autocorrect: false,
  cursorColor: ui.Colors.blue,
  cursorWidth: 1.0,
  padding: const EdgeInsets.symmetric(
    horizontal: 10.0,
    vertical: 15.0,
  ),
  placeholder: 'Personal access token',
  decoration: BoxDecoration(
    color: ui.Colors.white,
    borderRadius: BorderRadius.circular(5.0),
  ),
  onChanged: (String token) => bloc.setToken.add(token),
)
*/

typedef TextFieldValueChangedCallback = void Function(String text);

class TextField extends StatefulWidget {
  final bool autofocus;
  final bool autocorrect;
  final String placeholder;
  final TextFieldValueChangedCallback onChanged;
  final String text;
  final bool disabled;
  final FocusNode focusNode;
  final Stream<bool> disabledStream;

  TextField({
    @required this.onChanged,
    this.autofocus = false,
    this.autocorrect = false,
    this.placeholder = '',
    this.text = '',
    this.disabled = false,
    this.focusNode,
    this.disabledStream,
  });

  @override
  _TextFieldState createState() => _TextFieldState();
}

class _TextFieldState extends State<TextField> {
  TextEditingController _controller;

  _onTextChanged() => widget.onChanged(_controller.text);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_controller == null) {
      _controller = TextEditingController(text: widget?.text);
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disabledStream != null) {
      return StreamBuilder(
        stream: widget.disabledStream,
        initialData: false,
        builder: (_, AsyncSnapshot<bool> snapshot) {
          return CupertinoTextField(
            controller: _controller,
            enabled: !snapshot.data,
            autofocus: widget.autofocus,
            autocorrect: widget.autocorrect,
            cursorColor: Colors.blue,
            cursorWidth: 1.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 15.0,
            ),
            placeholder: widget.placeholder,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            focusNode: widget.focusNode,
            style: TextStyle(
              color: Colors.deepBlue,
              fontSize: 14.0,
            ),
          );
        },
      );
    }

    return CupertinoTextField(
      controller: _controller,
      enabled: !widget.disabled,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      cursorColor: Colors.blue,
      cursorWidth: 1.0,
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 15.0,
      ),
      placeholder: widget.placeholder,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
      ),
      focusNode: widget.focusNode,
    );
  }
}
