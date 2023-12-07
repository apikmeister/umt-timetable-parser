import 'package:html/dom.dart';

List<String> extractCourseDetails(String cellText) {
  var details = cellText.trim().split('\n');
  if (details.isNotEmpty && details[0].isNotEmpty) {
    return details[0].split('(');
  }
  return [];
}

Map<String, String> extractCellDetails(List<Element> cells) {
  var cellDetails = {'hari': '', 'tahun': ''};
  if (cells[0].attributes.containsKey('rowspan')) {
    cellDetails['hari'] = cells[0].text.trim();
    cellDetails['tahun'] = cells[1].text.trim();
    cells = cells.skip(2).toList(); // Skip 'hari' and 'tahun' cells
  } else {
    cellDetails['tahun'] = cells[0].text.trim();
    cells = cells.skip(1).toList(); // Skip 'tahun' cell
  }
  return cellDetails;
}

Map<String, dynamic> createTimetableEntry(
    String hari, String tahun, Element cell, String time) {
  var courseDetails = extractCourseDetails(cell.text);
  if (courseDetails.length <= 2) {
    var course = courseDetails[0].trim();
    courseDetails = courseDetails[1].split(')');
    if (courseDetails.length >= 2) {
      var group = courseDetails[0].trim();
      var location = courseDetails[1].trim();
      var elektif = cell.querySelector('font[color="blue"]') != null;

      return {
        'hari': hari,
        'tahun': tahun,
        'masa': time, // Adjust index based on times list
        'course': course,
        'group': group,
        'location': location,
        'elektif': elektif,
      };
    }
  }
  return {};
}

int parseTime(String time) {
  var parsedTime = int.parse(time.split('.')[0]);
  if (time.contains('pm') && parsedTime != 12) {
    parsedTime += 12;
  }
  return parsedTime;
}

bool isSameEntry(Map<String, dynamic> entry1, Map<String, dynamic> entry2) {
  return entry1['hari'] == entry2['hari'] &&
      entry1['tahun'] == entry2['tahun'] &&
      entry1['course'] == entry2['course'] &&
      entry1['group'] == entry2['group'] &&
      entry1['location'] == entry2['location'] &&
      entry1['elektif'] == entry2['elektif'];
}

String toRoman(int number) {
  if (number < 1 || number > 3999)
    return "Invalid. Enter a number between 1 and 3999";

  List<int> values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  List<String> numerals = [
    'M',
    'CM',
    'D',
    'CD',
    'C',
    'XC',
    'L',
    'XL',
    'X',
    'IX',
    'V',
    'IV',
    'I'
  ];

  String result = '';
  for (int i = 0; i < values.length; i++) {
    while (number >= values[i]) {
      number -= values[i];
      result += numerals[i];
    }
  }
  return result;
}
