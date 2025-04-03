import '../../domain/entities/theme_entity.dart';
import '../../domain/repositories/theme_repository.dart';

class GetThemeUseCase {
  final ThemeRepository repository;

  GetThemeUseCase(this.repository);

  Future<ThemeEntity> call() async {
    return await repository.getTheme();
  }
}