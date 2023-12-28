import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:umt_timetable_parser/src/util/get_timetables.dart';
import 'package:http/http.dart' as http;

class MarinerBase {
  String session;
  String program;

  late String schedCode;

  MarinerBase({
    required this.session,
    required this.program,
  }) : super() {
    schedCode = "$session/$program";
  }

  Future<String> getTimetable() async {
    var url =
        'https://pelajar.mynemo.umt.edu.my/eslip/index.php/jadual/muktmd_jadual_program_/$schedCode';
    var response = await http.get(Uri.parse(url));
    var html = response.body;

    return jsonEncode(combineDuplicateEntries(extractTimetable(html)));
  }
}

Future<String> getSemester() async {
  var url =
      'https://pelajar.mynemo.umt.edu.my/eslip/index.php/jadual/muktmd_jadual_program';
  var response = await http.get(Uri.parse(url));
  var html = response.body;

  return jsonEncode(extractSemesters(html));
}

Future<String> getProgram(String sessCode) async {
  var dio = Dio();
  late dynamic responseData;

  var data = {
    "sesi": sessCode,
  };

  try {
    var response = await dio.post(
      "https://pelajar.mynemo.umt.edu.my/eslip/index.php/jadual/loadsenarai_1_",
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (response.statusCode == 200) {
      responseData = await response.data;
    }
  } catch (error) {
    print(error);
  }
  return jsonEncode(
      extractProgramsByFaculty(jsonDecode(responseData)['q'][0]['a'][0][0]));
}
