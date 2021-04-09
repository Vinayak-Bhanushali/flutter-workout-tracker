import 'package:flutter/cupertino.dart';

class WidgetHelper {
  static List<Widget> twoElements(
    List<Widget> widgets, {
    double verticalSpacing = 4.0,
  }) {
    final List<Widget> children = [];
    for (var i = 0; i < widgets.length; i += 2) {
      children.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: widgets[i],
            ),
            if (i < widgets.length - 1)
              Expanded(
                child: widgets[i + 1],
              ),
            if (i == widgets.length - 1 && widgets.length.isOdd)
              Spacer(
                flex: 1,
              ),
          ],
        ),
      );
      if (i < widgets.length - 1)
        children.add(SizedBox(
          height: verticalSpacing,
        ));
    }
    return children;
  }
}
