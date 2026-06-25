import 'package:fyrestream/services/db/fyrestream_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial()) {
    initSettings();
  }

  void initSettings() {
    FyreStreamDBService.getSettingBool("auto_update_notify").then((value) {
      emit(state.copyWith(autoUpdateNotify: value ?? false));
    });
  }

  void updateAutoUpdateNotify(bool value) {
    FyreStreamDBService.putSettingBool("auto_update_notify", value);
    emit(state.copyWith(autoUpdateNotify: value));
  }
}