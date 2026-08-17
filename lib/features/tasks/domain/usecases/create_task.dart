import '../repositories/task_repository.dart';

class CreateTask {
  const CreateTask(this._repository);

  final TaskRepository _repository;

  Future<int> call({
    required String title,
    String? description,
    required int categoryId,
    DateTime? dueDate,
    int? recurrenceRuleId,
  }) {
    return _repository.create(
      title: title,
      description: description,
      categoryId: categoryId,
      dueDate: dueDate,
      recurrenceRuleId: recurrenceRuleId,
    );
  }
}
