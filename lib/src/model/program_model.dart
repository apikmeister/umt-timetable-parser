class Program {
  final String programName;
  final String programCode;

  Program({required this.programName, required this.programCode});

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      programName: json['programName'],
      programCode: json['programCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'programName': programName,
      'programCode': programCode,
    };
  }

  @override
  String toString() {
    return 'Program{programName: $programName, programCode: $programCode}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Program &&
          runtimeType == other.runtimeType &&
          programName == other.programName &&
          programCode == other.programCode;

  @override
  int get hashCode => programName.hashCode ^ programCode.hashCode;
}

class Faculty {
  final String facultyName;
  final List<Program> programs;

  Faculty({required this.facultyName, required this.programs});

  factory Faculty.fromJson(Map<String, dynamic> json) {
    var programJson = json['programs'] as List;
    List<Program> programList =
        programJson.map((i) => Program.fromJson(i)).toList();

    return Faculty(
      facultyName: json['facultyName'],
      programs: programList,
    );
  }

  Map<String, dynamic> toJson() {
    var programJson = programs.map((i) => i.toJson()).toList();

    return {
      'facultyName': facultyName,
      'programs': programJson,
    };
  }

  @override
  String toString() {
    return 'Faculty{facultyName: $facultyName, programs: $programs}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Faculty &&
          runtimeType == other.runtimeType &&
          facultyName == other.facultyName &&
          programs == other.programs;

  @override
  int get hashCode => facultyName.hashCode ^ programs.hashCode;
}
