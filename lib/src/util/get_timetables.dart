import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:umt_timetable_parser/src/model/mariner_schedule.dart';

List<MarineSchedule> extractTimetable(String html) {
  var document = parse(html);
  var headers = document.querySelectorAll('thead tr td');
  var rows = document.querySelectorAll('tbody tr');
  var timetable = <MarineSchedule>[];

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

          timetable.add(MarineSchedule(
            hari: hari,
            tahun: tahun,
            masa: times[i],
            startTime: convertTo24HourFormat(
                times[i], int.parse(times[i].split('.')[0])),
            endTime: convertTo24HourFormat(
                times[times.length - 1],
                int.parse(times[times.length - 1]
                    .split('.')[0])), // Adjust index based on times list
            course: course,
            group: group,
            location: location,
            elektif: elektif,
          ));
        } else if (courseDetails.length > 2) {
          var course = courseDetails[0].trim();

          var courseInfo = courseDetails[1].split(')');
          var group = courseInfo[0].trim();
          var locationSplit =
              courseInfo[1].replaceAll('\u00A0', ' ').split(' ');
          var location = locationSplit[1].trim();
          var elektif = cells[i].querySelector('font[color="blue"]') != null
              ? cells[i]
                  .querySelector('font[color="blue"]')!
                  .innerHtml
                  .contains(course)
              : false;

          timetable.add(MarineSchedule(
            hari: hari,
            tahun: tahun,
            masa: times[i],
            startTime: convertTo24HourFormat(
                times[i], int.parse(times[i].split('.')[0])),
            endTime: convertTo24HourFormat(
                times[times.length - 1],
                int.parse(times[times.length - 1]
                    .split('.')[0])), // Adjust index based on times list
            course: course,
            group: group,
            location: location,
            elektif: elektif,
          ));

          var secondCourse = courseDetails[1].split(' ');
          secondCourse = secondCourse[0].replaceAll('\u00A0', ' ').split(' ');
          var courseCode = secondCourse[2].trim();
          var secondCourseInfo = courseDetails[2].split(')');
          group = secondCourseInfo[0].trim();
          location = secondCourseInfo[1].trim();
          elektif = cells[i].querySelector('font[color="blue"]') != null
              ? cells[i]
                  .querySelector('font[color="blue"]')!
                  .innerHtml
                  .contains(courseCode)
              : false;
          timetable.add(MarineSchedule(
            hari: hari,
            tahun: tahun,
            masa: times[i],
            startTime: convertTo24HourFormat(
                times[i], int.parse(times[i].split('.')[0])),
            endTime: convertTo24HourFormat(
                times[times.length - 1],
                int.parse(times[times.length - 1]
                    .split('.')[0])), // Adjust index based on times list
            course: courseCode,
            group: group,
            location: location,
            elektif: elektif,
          ));
        }
      }
    }
  }

  return timetable;
}

int convertTo24HourFormat(String time, int hour) {
  if (time.contains('pm') && hour != 12) {
    hour += 12;
  }
  return hour;
}

List<MarineSchedule> combineDuplicateEntries(List<MarineSchedule> timetable) {
  var combinedTimetable = <MarineSchedule>[];
  MarineSchedule? lastEntry;

  for (var entry in timetable) {
    var times = entry.masa.split(' - ');
    var startTime = int.parse(times[0].split('.')[0]);
    var endTime = int.parse(times[times.length - 1].split('.')[0]);

    if (times[0].contains('pm') && startTime != 12) {
      startTime += 12;
    }

    if (times[times.length - 1].contains('pm') && endTime != 12) {
      endTime += 12;
    }

    // if (endTime == 12 || endTime == 17) {
    //   endTime += 1;
    // }

    var isDuplicateEntry = combinedTimetable.any((existingEntry) =>
        existingEntry.hari == entry.hari &&
        existingEntry.tahun == entry.tahun &&
        existingEntry.course == entry.course &&
        existingEntry.group == entry.group &&
        existingEntry.location == entry.location &&
        existingEntry.elektif == entry.elektif);

    if (isDuplicateEntry) {
      var existingEntry = combinedTimetable.firstWhere((e) =>
          e.hari == entry.hari &&
          e.tahun == entry.tahun &&
          e.tahun == entry.tahun &&
          e.group == entry.group &&
          e.location == entry.location &&
          e.elektif == entry.elektif);
      existingEntry.endTime = endTime + 1;
      // Extend the end time
      // if (endTime == 12 || endTime == 17) {
      //   endTime += 1;
      // }
      // lastEntry['endTime'] = endTime;
      // lastEntry['endTime'] = endTime + 1;
    } else {
      // Add a new entry
      lastEntry = MarineSchedule(
        hari: entry.hari,
        tahun: entry.tahun,
        masa: entry.masa,
        startTime: entry.startTime,
        endTime: endTime + 1,
        course: entry.course,
        group: entry.group,
        location: entry.location,
        elektif: entry.elektif,
      );
      combinedTimetable.add(lastEntry);
    }
  }

  return combinedTimetable;
}

List<Map<String, String>> extractPrograms(String html) {
  var document = parse(html);
  var rows = document.querySelectorAll('tbody tr').skip(1);
  var programs = <Map<String, String>>[];

  for (var row in rows) {
    var cells = row.querySelectorAll('td');
    var programName = cells[2].text;
    var programCode = cells[3]
        .querySelector('input')!
        .attributes['onclick']!
        .split(",")
        .last
        .split('\'')[1];

    programs.add({
      'name': programName,
      'code': programCode,
    });
  }

  return programs;
}

Future<String> getProgram(String session) async {
  var dio = Dio();

  var data = {"sesi": session};

  try {
    var response = await dio.post(
      "https://pelajar.mynemo.umt.edu.my/eslip/index.php/jadual/loadsenarai_1_",
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (response.statusCode == 200) {
      return response.data;
    }
  } catch (error) {
    print(error);
  }
  return "";
}

Future<String> getTimetable(String session, String programCode) async {
  var url =
      'https://pelajar.mynemo.umt.edu.my/eslip/index.php/jadual/muktmd_jadual_program_/$session/$programCode';
  var response = await http.get(Uri.parse(url));
  var html = response.body;

  return html;
}
