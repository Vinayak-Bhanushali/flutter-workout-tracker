import 'package:flutter/material.dart';

class CustomChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool selected) onSelected;
  const CustomChoiceChip({
    Key key,
    @required this.label,
    @required this.selected,
    @required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected
              ? Colors.white
              : Theme.of(context).textTheme.bodyText1.color,
        ),
      ),
      selected: selected,
      selectedColor: Theme.of(context).accentColor,
      onSelected: onSelected,
    );
  }
}
