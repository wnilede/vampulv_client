import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

@riverpod
class CurrentSharedPreferences extends _$CurrentSharedPreferences {
  @override
  FutureOr<SharedPreferences> build() async {
    return SharedPreferences.getInstance();
  }
}
