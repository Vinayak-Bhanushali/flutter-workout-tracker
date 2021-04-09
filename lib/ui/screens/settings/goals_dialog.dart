import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GoalDialog extends StatefulWidget {
  final List<int> goals;

  const GoalDialog({Key key, this.goals}) : super(key: key);
  @override
  _GoalDialogState createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  List<int> goals = [];
  @override
  void initState() {
    super.initState();
    widget.goals.forEach((element) {
      goals.add(element);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                goals.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(
                    width: 40,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Set ${index + 1}",
                          style: Theme.of(context).textTheme.caption,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            goals[index] = int.parse(value);
                          },
                          initialValue: index < goals.length
                              ? goals[index].toString()
                              : "0",
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          decoration: new InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                goals.add(0);
                setState(() {});
              },
            ),
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                goals.removeLast();
                setState(() {});
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(goals);
              },
              child: const Text("DONE"),
            ),
          ],
        )
      ],
    );
  }
}
