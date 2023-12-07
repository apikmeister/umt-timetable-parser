class MarineSchedule {
  String hari;
  String tahun;
  String masa;
  int startTime;
  int endTime;
  String course;
  String group;
  String location;
  bool elektif;

  MarineSchedule({
    required this.hari,
    required this.tahun,
    required this.masa,
    required this.startTime,
    required this.endTime,
    required this.course,
    required this.group,
    required this.location,
    required this.elektif,
  });

  set setEndTime(int endTime) {
    endTime = endTime;
  }

  MarineSchedule.fromJson(Map<String, dynamic> json)
      : hari = json['hari'],
        tahun = json['tahun'],
        masa = json['masa'],
        startTime = json['startTime'],
        endTime = json['endTime'],
        course = json['course'],
        group = json['group'],
        location = json['location'],
        elektif = json['elektif'];

  Map<String, dynamic> toJson() => {
        'hari': hari,
        'tahun': tahun,
        'masa': masa,
        'startTime': startTime,
        'endTime': endTime,
        'course': course,
        'group': group,
        'location': location,
        'elektif': elektif,
      };

  @override
  String toString() {
    return 'MarineSchedule{hari: $hari, tahun: $tahun, masa: $masa, startTime: $startTime, endTime: $endTime, course: $course, group: $group, location: $location, elektif: $elektif}';
  }
}
