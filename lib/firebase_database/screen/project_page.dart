import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fastapi_project/api.dart';
import 'package:fastapi_project/firebase_database/bloc/project_bloc.dart';
import 'package:fastapi_project/firebase_database/models/project_model.dart';
import 'package:fastapi_project/firebase_database/screen/add_project.dart';
import 'package:fastapi_project/firebase_login/model/user_model.dart';
import 'package:fastapi_project/main_page.dart';
import 'package:fastapi_project/utils/util.dart';
import 'package:fastapi_project/widget/appbar_widget.dart';
import 'package:fastapi_project/widget/confirm_dialog_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

DBUser dbUser = DBUser();
class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  Project _selectedProject = Project.getInstance();
  TextEditingController searchController = TextEditingController();
  bool isGridView = false;
  StreamController<List<Project>> _projectStream = StreamController();

  List<Project> searchList(List<Project> list){
    return list.where((element) => element.projectName.contains(searchController.text.trim())).toList();
  }

  void projectAddDialog(){
    showDialog(
      context: context,
      builder: (context) {
        return const AddProject();
      }
    ).whenComplete(() async{
      loadProject();
    });
  }

  Future setUser() async{
    await Api().getUser().then((value) async{
      if(value != null){
        dbUser.email = value['email'];
        dbUser.userdept = value['userdept'];
        dbUser.usergrade = value['usergrade'];
        dbUser.username = value['username'];
        dbUser.usage = value['usage'].toDouble();
        dbUser.uid = value['uid'];
      }
    });
  }

  @override
  void dispose() {
    _projectStream.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadProject();
  }

  Future loadProject() async{
    if(dbUser.uid != '') {
      await Api().getProjects(dbUser.uid).then((value) {
        List<Project> projectList = [];
        for (var item in value) {
          projectList.add(Project.fromJson(item));
        }
        _projectStream.add(projectList);
      });
    }else{
      await setUser();
      await loadProject();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
          child: Column(
            children: [
              TextFieldAppBarWidget(
                controller: searchController,
                prefixIcon: [
                  Tooltip(
                    message: '프로젝트 추가',
                    child: InkWell(
                      onTap: () async{
                        projectAddDialog();
                      },
                      child: Icon(Icons.add_circle)
                    )
                  ),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: (){
                      setState((){
                        isGridView = !isGridView;
                      });
                    },
                    child: Icon(isGridView ? Icons.splitscreen : Icons.grid_view)
                  ),
                ],
                hintText: '프로젝트 검색',
                onSubmitted: (val){
                  setState((){
                    searchController.text = val;
                  });
                },
              ),
              StreamBuilder<List<Project>>(
                stream: _projectStream.stream,
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    var projectList = snapshot.data!;
                    projectList = searchList(projectList);
                    return Expanded(
                      child: projectList.isNotEmpty ? MasonryGridView.count(
                        crossAxisCount: isGridView ? 2 : 1,
                        padding: EdgeInsets.only(top: 10),
                        crossAxisSpacing: 10,
                        itemCount: projectList.length,
                        itemBuilder: (context, index){
                          Project project = projectList[index];
                          return InkWell(
                            onTap: () async{
                              if(_selectedProject.projectId != project.projectId){
                                setState((){
                                  _selectedProject = project;
                                });
                                context.read<ProjectBloc>().add(SelectedProject(_selectedProject));
                              }
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const MainPage()));
                            },
                            onLongPress: project.userId == dbUser.uid ? (){
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return ConfirmDialogWidget(
                                    text: '프로젝트를 삭제하시겠습니까?',
                                    applyOnTap: () async{
                                      await Api().deleteProject(project.projectId).then((value) {
                                        Util.toastMessage('해당 프로젝트가 삭제되었습니다.');
                                        Navigator.pop(context);
                                      });
                                    },
                                    cancelOnTap: (){
                                      Navigator.pop(context);
                                    },
                                  );
                                }
                              ).whenComplete(() async{
                                await loadProject();
                              });
                            } : null,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xfff5f5f5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(project.projectName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 3),
                                      Text("${project.dateBegin.split(' ')[0]} ~ ${project.dateEnd.split(' ')[0]}"),
                                      const SizedBox(height: 3),
                                      Text(project.projectAdmin),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ) : Center(child: Text('프로젝트를 생성해주세요.')),
                    );
                  }else{
                    return CircularProgressIndicator();
                  }
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}
