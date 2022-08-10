import 'package:fastapi_project/api.dart';
import 'package:fastapi_project/firebase_database/screen/project_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fastapi_project/firebase_database/models/project_model.dart';
import 'package:fastapi_project/widget/alert_dialog_widget.dart';
import 'package:fastapi_project/widget/textfield_widget.dart';
import 'package:fastapi_project/utils/util.dart';

class AddProject extends StatefulWidget {
  const AddProject({Key? key}) : super(key: key);

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  TextEditingController _projectNameController = TextEditingController();
  DateTime _beginDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return AlertDialogWidget(
      title: '프로젝트 추가',
      contentPadding: EdgeInsets.all(10),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldWidget(
              controller: _projectNameController,
              hintText: '프로젝트 이름 입력',
              showBorder: true,
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('시작날짜', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 3),
                InkWell(
                  onTap: () async{
                    Future<DateTime?> selectedDate = showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2007),
                      lastDate: DateTime(2030),
                    );
                    await selectedDate.then((value) {
                      if(value != null){
                        setState((){
                          _beginDate = value;
                        });
                      }
                    });
                  },
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 5),
                          child: const Icon(Icons.calendar_month, size: 20,)
                        ),
                        const SizedBox(width: 5),
                        Text(DateFormat('yyyy-MM-dd').format(_beginDate), style: TextStyle(fontSize: 13),)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('종료날짜', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 3),
                InkWell(
                  onTap: () async{
                    Future<DateTime?> selectedDate = showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2007),
                      lastDate: DateTime(2030),
                    );
                    await selectedDate.then((value) {
                      if(value != null){
                        setState((){
                          _endDate = value;
                        });
                      }
                    });
                  },
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: const EdgeInsets.only(left: 5),
                            child: const Icon(Icons.calendar_month, size: 20,)
                        ),
                        const SizedBox(width: 5),
                        Text(DateFormat('yyyy-MM-dd').format(_endDate), style: TextStyle(fontSize: 13),)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async{
                    if(_projectNameController.text == ''){
                      Util.toastMessage('프로젝트 이름을 입력해주세요.');
                      return;
                    }
                    if(!_beginDate.difference(_endDate).isNegative){
                      Util.toastMessage('시작일이 종료일보다 빠릅니다.');
                      return;
                    }
                    Project project = Project(
                        userId: dbUser.uid,
                        projectName: _projectNameController.text.trim(),
                        dateBegin: DateFormat('yyyy-MM-dd HH:mm:ss').format(_beginDate),
                        dateEnd: DateFormat('yyyy-MM-dd HH:mm:ss').format(_endDate),
                        projectAdmin: dbUser.username
                    );
                    await Api().createProject(project.toJson()).then((value) {
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xff6E9CDB),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: const Center(
                        child: Text('프로젝트 등록', style: TextStyle(fontSize: 13, height: 1, color: Colors.white),),
                      )
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
