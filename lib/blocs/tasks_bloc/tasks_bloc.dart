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

  void _onRemoveTask(RemoveTask event, Emitter<TasksState> emit) async {
    Task removedTask = event.task.copyWith(isDeleted: true);
    await FirestoreRepository.update(task: removedTask);
  }

  void _onMarkFavoriteOrUnfavoriteTask(
      MarkFavoriteOrUnfavoriteTask event, Emitter<TasksState> emit) async {
    Task task = event.task.copyWith(isFavorite: !event.task.isFavorite!);
    await FirestoreRepository.update(task: task);
  }

  void _onRestoreTask(RestoreTask event, Emitter<TasksState> emit) async {
    Task restoreTask = event.task.copyWith(
        isDeleted: false, isDone: false, date: DateTime.now().toString(), isFavorite: false);
    await FirestoreRepository.update(task: restoreTask);
  }

  void _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    await FirestoreRepository.delete(task: event.task);
  }

  void _onDeleteAllTask(DeleteAllTasks event, Emitter<TasksState> emit) async {
    await FirestoreRepository.deleteAllRemovedTasks(taskList: state.removedTasks);
  }

  void _onEditTask(EditTask event, Emitter<TasksState> emit) async {
    await FirestoreRepository.update(task: event.newTask);
  }
}
