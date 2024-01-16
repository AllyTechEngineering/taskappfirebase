import 'package:equatable/equatable.dart';
import '../../models/task.dart';
import '../../repository/firestore_repository.dart';
import '../bloc_exports.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc() : super(const TasksState()) {
    on<AddTask>(_onAddTask);
    on<GetAllTasks>(_onGetAllTasks);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<RemoveTask>(_onRemoveTask);
    on<MarkFavoriteOrUnfavoriteTask>(_onMarkFavoriteOrUnfavoriteTask);
    on<EditTask>(_onEditTask);
    on<RestoreTask>(_onRestoreTask);
    on<DeleteAllTasks>(_onDeleteAllTask);
  }

  void _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    await FirestoreRepository.create(task: event.task);
  }

  void _onGetAllTasks(GetAllTasks event, Emitter<TasksState> emit) async {
    List<Task> pendingTasks = [];
    List<Task> completedTasks = [];
    List<Task> favoriteTasks = [];
    List<Task> removedTasks = [];

    await FirestoreRepository.get().then((value) {
      value.forEach((task) {
        if (task.isDeleted == true) {
          removedTasks.add(task);
        } else {
          if (task.isFavorite == true) {
            favoriteTasks.add(task);
          } else {
            if (task.isDone == true) {
              completedTasks.add(task);
            } else {
              pendingTasks.add(task);
            }
          }
        }
      });
      emit(TasksState(
        pendingTasks: pendingTasks,
        completedTasks: completedTasks,
        favoriteTasks: favoriteTasks,
        removedTasks: removedTasks,
      ));
    });
  }

  void _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    Task updateTask = event.task.copyWith(isDone: !event.task.isDone!);
    await FirestoreRepository.update(task: updateTask);
  }

  void _onRemoveTask(RemoveTask event, Emitter<TasksState> emit) {}

  void _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) {}

  void _onMarkFavoriteOrUnfavoriteTask(
      MarkFavoriteOrUnfavoriteTask event, Emitter<TasksState> emit) {}

  void _onEditTask(EditTask event, Emitter<TasksState> emit) {}

  void _onRestoreTask(RestoreTask event, Emitter<TasksState> emit) {}

  void _onDeleteAllTask(DeleteAllTasks event, Emitter<TasksState> emit) {}

  // @override
  // TasksState? fromJson(Map<String, dynamic> json) {
  //   return TasksState.fromMap(json);
  // }
  //
  // @override
  // Map<String, dynamic>? toJson(TasksState state) {
  //   return state.toMap();
  // }
}
