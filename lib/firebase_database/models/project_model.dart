import 'package:intl/intl.dart';

class Project {
  int projectId;
  dynamic userId;
  String projectName;
  String dateBegin;
  String dateEnd;
  String projectAdmin;

  Project({
    this.projectId = 0,
    this.userId = '',
    this.projectName = '',
    this.dateBegin = '',
    this.dateEnd = '',
    this.projectAdmin = ''
  });

  factory Project.fromJson(Map<String, dynamic> json){
    DateTime dateBegin = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(json['date_begin']);
    DateTime dateEnd = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(json['date_end']);
    return Project(
      projectId: json['cnt'],
      userId: json["uid"]??0,
      projectName: json["project_name"]??'',
      dateBegin: DateFormat('yyyy-MM-dd HH:mm:ss').format(dateBegin),
      dateEnd: DateFormat('yyyy-MM-dd HH:mm:ss').format(dateEnd),
      projectAdmin: json["project_admin"]??'',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "date_begin" : dateBegin,
      "date_end" : dateBegin,
      "project_name" : projectName,
      "project_admin" : projectAdmin,
      "uid": userId,
    };
  }

  static Project getInstance(){
    return Project(projectId: 0, userId: '', projectName: '', dateBegin: '', dateEnd: '', projectAdmin: '');
  }
}