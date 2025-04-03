import '../../domain/entities/theme_entity.dart';
import '../../domain/repositories/theme_repository.dart';

class SaveThemeUseCase {
  final ThemeRepository repository;

  SaveThemeUseCase(this.repository);

  Future<void> call(ThemeEntity theme) async {
    await repository.saveTheme(theme);
  }
}