part of 'project_bloc.dart';

@immutable
abstract class ProjectEvent {}

class SelectedProject extends ProjectEvent {
  final Project project;

  SelectedProject(this.project);
}