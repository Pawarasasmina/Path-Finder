import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class TimeSelector extends StatefulWidget {
  final int selectedTimeOption;
  final Function(int) onTimeSelected;

  TimeSelector({
    required this.selectedTimeOption,
    required this.onTimeSelected,
  });

  @override
  _TimeSelectorState createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now(); // Get current date
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now, // Set initial date to today
      firstDate: now, // Disable all dates before today
      lastDate: DateTime(2101), // You can adjust this as needed
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Time:',
              style: TextStyle(fontSize: 16),
            ),
            Row(
              children: [
                Radio(
                  value: 1,
                  groupValue: widget.selectedTimeOption,
                  onChanged: (value) {
                    widget.onTimeSelected(value as int);
                  },
                ),
                Text('Now'),
                SizedBox(width: 20),
                Radio(
                  value: 2,
                  groupValue: widget.selectedTimeOption,
                  onChanged: (value) {
                    widget.onTimeSelected(value as int);
                  },
                ),
                Text('Schedule Later'),
              ],
            ),
          ],
        ),
        if (widget.selectedTimeOption == 2) ...[
          // Date Picker
          TextField(
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(
              text: selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                  : '',
            ),
          ),
          SizedBox(height: 10),
          // Time Picker
          TextField(
            readOnly: true,
            onTap: () => _selectTime(context),
            decoration: InputDecoration(
              labelText: 'Time',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time),
            ),
            controller: TextEditingController(
              text: selectedTime != null ? selectedTime!.format(context) : '',
            ),
          ),
        ],
      ],
    );
  }
}
