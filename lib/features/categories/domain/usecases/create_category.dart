import '../repositories/category_repository.dart';

class CreateCategory {
  const CreateCategory(this._repository);

  final CategoryRepository _repository;

  Future<int> call({
    required String name,
    required int colorValue,
    required String iconKey,
  }) {
    return _repository.create(
      name: name,
      colorValue: colorValue,
      iconKey: iconKey,
    );
  }
}
