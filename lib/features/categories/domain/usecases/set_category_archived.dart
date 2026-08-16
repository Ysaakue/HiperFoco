import '../repositories/category_repository.dart';

class SetCategoryArchived {
  const SetCategoryArchived(this._repository);

  final CategoryRepository _repository;

  Future<void> call(int id, bool archived) =>
      _repository.setArchived(id, archived);
}
