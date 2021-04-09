import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDialog {
  static Future inputDialog({
    @required String title,
    @required BuildContext context,
    String defaultText,
    int maxLines,
    String hintText,
    TextInputType textInputType = TextInputType.text,
    RegExp regExp,
    String invalidInputMessage,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    List<TextInputFormatter> inputFormatters,
    bool barrierDismissible = false,
  }) {
    TextEditingController _textFieldController = TextEditingController(
      text: defaultText,
    );
    if (defaultText != null || defaultText != "") {
      _textFieldController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textFieldController.text.length,
      );
    }
    final _formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          FlatButton(
            child: new Text('SUBMIT'),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                Navigator.of(context).pop(_textFieldController.text);
              }
            },
          )
        ],
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _textFieldController,
            autofocus: true,
            decoration: InputDecoration(hintText: hintText),
            keyboardType: textInputType,
            minLines: maxLines == 1 ? null : 1,
            maxLines: maxLines,
            onFieldSubmitted: (value) {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                Navigator.of(context).pop(_textFieldController.text);
              }
            },
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            validator: (String value) {
              if (regExp == null)
                return null;
              else if (regExp.hasMatch(value)) {
                print("valid");
                return null;
              } else
                return invalidInputMessage ?? "Invalid input";
            },
          ),
        ),
      ),
    );
  }

  static Future<bool> yesNoDialog({
    @required String title,
    @required BuildContext context,
    final String description = "",
  }) async {
    var result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No"),
          ),
        ],
      ),
    );
    return result == true;
  }
}
