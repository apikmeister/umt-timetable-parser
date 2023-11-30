import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'dart:convert';

List<Map<String, dynamic>> extractTimetable(String html) {
  var document = parse(html);
  var headers = document.querySelectorAll('thead tr td');
  var rows = document.querySelectorAll('tbody tr');
  var timetable = <Map<String, dynamic>>[];

  // Skip the first two headers as they are "HARI" and "MASA/TAHUN"
  var times = headers.skip(2).map((header) => header.text.trim()).toList();

  var hari = '';
  var tahun = '';

  for (var row in rows) {
    var cells = row.querySelectorAll('td');
    if (cells[0].attributes.containsKey('rowspan')) {
      hari = cells[0].text.trim();
      tahun = cells[1].text.trim();
      cells = cells.skip(2).toList(); // Skip 'hari' and 'tahun' cells
    } else {
      tahun = cells[0].text.trim();
      cells = cells.skip(1).toList(); // Skip 'tahun' cell
    }

    for (var i = 0; i < cells.length; i++) {
      var details = cells[i].text.trim().split('\n');
      if (details.isNotEmpty && details[0].isNotEmpty) {
        var courseDetails = details[0].split('(');
        if (courseDetails.length <= 2) {
          var course = courseDetails[0].trim();
          courseDetails = courseDetails[1].split(')');
          var group = courseDetails[0].trim();
          var location = courseDetails[1].trim();
          var elektif = cells[i].querySelector('font[color="blue"]') != null;

          timetable.add({
            'hari': hari,
            'tahun': tahun,
            'masa': times[i], // Adjust index based on times list
            'course': course,
            'group': group,
            'location': location,
            'elektif': elektif,
          });
        } else if (courseDetails.length > 2) {
          var course = courseDetails[0].trim();
          var courseInfo = courseDetails[1].split(')');
          var group = courseInfo[0].trim();
          var locationSplit =
              courseInfo[1].replaceAll('\u00A0', ' ').split(' ');
          var location = locationSplit[1].trim();
          var elektif = cells[i].querySelector('font[color="blue"]') != null;

          timetable.add({
            'hari': hari,
            'tahun': tahun,
            'masa': times[i], // Adjust index based on times list
            'course': course,
            'group': group,
            'location': location,
            'elektif': elektif,
          });

          var secondCourse = courseDetails[1].split(' ');
          secondCourse = secondCourse[0].replaceAll('\u00A0', ' ').split(' ');
          var courseCode = secondCourse[2].trim();
          var secondCourseInfo = courseDetails[2].split(')');
          group = secondCourseInfo[0].trim();
          location = secondCourseInfo[1].trim();
          timetable.add({
            'hari': hari,
            'tahun': tahun,
            'masa': times[i], // Adjust index based on times list
            'course': courseCode,
            'group': group,
            'location': location,
            'elektif': elektif,
          });
        }
      }
    }
  }

  return timetable;
}

List<Map<String, dynamic>> combineDuplicateEntries(
    List<Map<String, dynamic>> timetable) {
  var combinedTimetable = <Map<String, dynamic>>[];
  Map<String, dynamic> lastEntry = {};

  for (var entry in timetable) {
    var times = entry['masa'].split(' - ');
    var startTime = int.parse(times[0].split('.')[0]);
    var endTime = int.parse(times[times.length - 1].split('.')[0]);

    if (times[0].contains('pm') && startTime != 12) {
      startTime += 12;
    }

    if (times[times.length - 1].contains('pm') && endTime != 12) {
      endTime += 12;
    }

    if (endTime == 12 || endTime == 17) {
      endTime += 1;
    }

    if (lastEntry != null &&
        lastEntry['hari'] == entry['hari'] &&
        lastEntry['tahun'] == entry['tahun'] &&
        lastEntry['course'] == entry['course'] &&
        lastEntry['group'] == entry['group'] &&
        lastEntry['location'] == entry['location'] &&
        lastEntry['elektif'] == entry['elektif']) {
      // Extend the end time
      lastEntry['endTime'] = endTime;
    } else {
      // Add a new entry
      lastEntry = {
        'hari': entry['hari'],
        'tahun': entry['tahun'],
        'startTime': startTime,
        'endTime': endTime + 1,
        'course': entry['course'],
        'group': entry['group'],
        'location': entry['location'],
        'elektif': entry['elektif'],
      };
      combinedTimetable.add(lastEntry);
    }
  }

  return combinedTimetable;
}

void main() async {
  var url =
      'https://pelajar.mynemo.umt.edu.my/eslip/index.php/jadual/muktmd_jadual_program_/S202324-I/GC09';
  var response = await http.get(Uri.parse(url));
  var html = response.body;

  var coursesJson = extractTimetable(html);
  coursesJson = combineDuplicateEntries(coursesJson);

  print(jsonEncode(coursesJson));
}
