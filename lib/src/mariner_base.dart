import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:umt_timetable_parser/src/constants/semester.dart';
import 'package:umt_timetable_parser/src/util/get_timetables.dart';
import 'package:umt_timetable_parser/src/util/timetable_utils.dart';
import 'package:http/http.dart' as http;

class MarinerBase {
  String session;
  int semester;
  String program;
  StudyGrade studyGrade;

  late String sessCode;

  MarinerBase({
    required this.session,
    required this.semester,
    required this.program,
    required this.studyGrade,
  }) : super() {
    sessCode =
        "$studyGrade${session.split('/').first}${session.split('/').last.substring(2)}-${toRoman(semester)}";
  }

  Future<String> getProgram() async {
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
        extractPrograms(jsonDecode(responseData)['q'][0]['a'][0][0]));
  }

  Future<String> getTimetable(String programCode) async {
    var url =
        'https://pelajar.mynemo.umt.edu.my/eslip/index.php/jadual/muktmd_jadual_program_/$session/$programCode';
    var response = await http.get(Uri.parse(url));
    var html = response.body;

    return jsonEncode(extractTimetable(html));
  }
}
