part of 'project_bloc.dart';

@immutable
abstract class ProjectState {}

class ProjectInitial extends ProjectState {}

class Selected extends ProjectState {
  final Project project;

  Selected({required this.project});
}