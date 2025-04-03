import 'package:remind_me_app/domain/entities/theme_entity.dart';

abstract class ThemeRepository {
  Future<void> saveTheme(ThemeEntity theme);
  Future<ThemeEntity> getTheme();
}