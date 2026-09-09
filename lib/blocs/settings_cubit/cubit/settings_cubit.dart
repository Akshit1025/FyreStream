import 'package:fyrestream/routes_and_consts/global_str_consts.dart';
import 'package:fyrestream/services/db/fyrestream_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial()) {
    initSettings();
  }

  void initSettings() {
    FyreStreamDBService.getSettingBool(GlobalStrConsts.autoUpdateNotify).then((value) {
      emit(state.copyWith(autoUpdateNotify: value ?? false));
    });
  }

  void updateAutoUpdateNotify(bool value) {
    FyreStreamDBService.putSettingBool(GlobalStrConsts.autoUpdateNotify, value);
    emit(state.copyWith(autoUpdateNotify: value));
  }
}