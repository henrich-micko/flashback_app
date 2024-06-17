import 'package:flashbacks/utils/time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class DateTimeField extends StatefulWidget {
  final Function(DateTime value)? onChange;
  final String helper;
  final DateTime? defaultDate;

  const DateTimeField({super.key, this.onChange, required this.helper, this.defaultDate});

  @override
  State<DateTimeField> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.defaultDate;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSelectPopup(context),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(12)),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            children: [
              Center(
                  child: Text(
                      _selectedDate != null ? dateFormat.format(_selectedDate!) : widget.helper,
                      style: TextStyle(
                          color: _selectedDate != null ? Colors.white70 : Colors.white54, fontSize: 17),
                      textAlign: TextAlign.left)),
            ],
          ),
        ),
      ),
    );
  }

  Future _showSelectPopup(BuildContext context) async {
    DateTime selectedDateValue = _selectedDate != null ? _selectedDate! : DateTime.now();

    // handle submit
    showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 350,
          color: const Color.fromARGB(255, 30, 30, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: 250,
                  child: CupertinoDatePicker(
                      initialDateTime: selectedDateValue,
                      onDateTimeChanged: (value) {
                        selectedDateValue = value;
                      })),
              CupertinoButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = selectedDateValue;
                    Navigator.of(context).pop();
                    widget.onChange!(selectedDateValue);
                  });
                },
                child: Container(
                  height: 45,
                  width: 150,
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.white54,
                      ),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Text("Submit",
                        style: TextStyle(color: Colors.white54)),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}