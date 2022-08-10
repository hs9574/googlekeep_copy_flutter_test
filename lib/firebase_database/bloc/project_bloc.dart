import 'package:bloc/bloc.dart';
import 'package:fastapi_project/firebase_database/models/project_model.dart';
import 'package:meta/meta.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectInitial()) {
    on<SelectedProject>((event, emit) async{
      emit(Selected(project: event.project));
    });
  }
}
