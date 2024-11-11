import 'package:flutter/material.dart';

class FilterDropdown extends StatefulWidget {
  final ValueChanged<String?> onFilterChanged; // Callback to notify parent

  const FilterDropdown({Key? key, required this.onFilterChanged})
      : super(key: key);

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4ECDC4), width: 1.5),
          color: const Color(0xFF1C3D3F),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  hint: const Center(
                    child: Text(
                      'Filter By',
                      style: TextStyle(
                        color: Color(0xFFFAFAFA),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down_circle,
                    color: Color(0xFF4ECDC4),
                    size: 16,
                  ),
                  elevation: 8,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1C3D3F),
                  borderRadius: BorderRadius.circular(15),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue;
                      widget.onFilterChanged(newValue); // Notify parent
                    });
                  },
                  items: <String>['Price', 'Rating']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Color(0xFFFAFAFA),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
