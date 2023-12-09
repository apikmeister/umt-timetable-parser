class Semester {
  String semesterName;
  String semesterCode;
  String studyGrade;

  Semester({
    required this.semesterName,
    required this.semesterCode,
    required this.studyGrade,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      semesterName: json['semesterName'],
      semesterCode: json['semesterCode'],
      studyGrade: json['studyGrade'],
    );
  }

  Map<String, dynamic> toJson() => {
        'semesterName': semesterName,
        'semesterCode': semesterCode,
        'studyGrade': studyGrade,
      };

  @override
  String toString() {
    return 'SemesterModel(semesterName: $semesterName, semesterCode: $semesterCode, studyGrade: $studyGrade)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Semester &&
        other.semesterName == semesterName &&
        other.semesterCode == semesterCode &&
        other.studyGrade == studyGrade;
  }

  @override
  int get hashCode {
    return semesterName.hashCode ^ semesterCode.hashCode ^ studyGrade.hashCode;
  }
}
