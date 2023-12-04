import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:umt_timetable_parser/src/util/timetable_combiner.dart';
import 'package:umt_timetable_parser/src/util/timetable_parser.dart';
export 'package:umt_timetable_parser/src/util/get_timetables.dart';
export 'src/util/get_timetables.dart';

Future<String> fetchHtml(String url) async {
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception(
        'Failed to load webpage with status code: ${response.statusCode}');
  }
}

void main() async {
  var url =
      'https://pelajar.mynemo.umt.edu.my/eslip/index.php/jadual/muktmd_jadual_program_/S202324-I/GC09';
  try {
    var html = await fetchHtml(url);
    var timetable = TimetableParser.extractTimetable(html);
    var combinedTimetable =
        TimetableCombiner.combineDuplicateEntries(timetable);
    print(jsonEncode(combinedTimetable));
  } catch (e) {
    print('Error occurred: $e');
  }
}
