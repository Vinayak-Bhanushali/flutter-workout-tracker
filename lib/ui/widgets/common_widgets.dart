import 'package:flutter/material.dart';

class CommonWidget {
  static Dismissible cardDismissible({Widget child, Function onDismissed}) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.red,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        onDismissed();
      },
      child: child,
    );
  }

  static Widget selectableCard(
      {@required String text,
      @required BuildContext context,
      @required bool isSelected,
      @required onSelectionChange(bool selected)}) {
    return InkWell(
      onTap: () {
        if (!isSelected) onSelectionChange(true);
      },
      child: Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).accentColor.withOpacity(0.5)
              : Colors.transparent,
          border: Border.all(color: Theme.of(context).accentColor),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }
}
