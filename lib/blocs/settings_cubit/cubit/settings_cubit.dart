import 'dart:developer';
import 'package:fyrestream/routes_and_consts/global_str_consts.dart';
import 'package:fyrestream/services/db/fyrestream_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial()) {
    initSettings();
    autoUpdate();
  }

  void initSettings() {
    FyreStreamDBService.getSettingBool(GlobalStrConsts.autoUpdateNotify).then((value) {
      emit(state.copyWith(autoUpdateNotify: value ?? false));
    });

    FyreStreamDBService.getSettingBool(GlobalStrConsts.autoSlideCharts).then((value) {
      emit(state.copyWith(autoSlideCharts: value ?? true));
    });

    // Directory dir = Directory('/storage/emulated/0/Music');
    String? path;

    FyreStreamDBService.getSettingStr(GlobalStrConsts.downPathSetting)
        .then((value) async {
      await getDownloadsDirectory().then((value) {
        if (value != null) {
          path = value.path;
        }
      });
      emit(state.copyWith(
          downPath: (value ?? path) ??
              (await getApplicationDocumentsDirectory()).path));
    });

    FyreStreamDBService.getSettingStr(GlobalStrConsts.downQuality,
        defaultValue: '320 kbps')
        .then((value) {
      emit(state.copyWith(downQuality: value ?? "320 kbps"));
    });

    FyreStreamDBService.getSettingStr(GlobalStrConsts.ytDownQuality).then((value) {
      emit(state.copyWith(ytDownQuality: value ?? "High"));
    });

    FyreStreamDBService.getSettingStr(
      GlobalStrConsts.strmQuality,
    ).then((value) {
      emit(state.copyWith(strmQuality: value ?? "96 kbps"));
    });

    FyreStreamDBService.getSettingStr(GlobalStrConsts.ytStrmQuality).then((value) {
      emit(state.copyWith(ytStrmQuality: value ?? "Low"));
    });

    FyreStreamDBService.getSettingStr(GlobalStrConsts.backupPath)
        .then((value) async {
      if (value == null || value == "") {
        await FyreStreamDBService.putSettingStr(GlobalStrConsts.backupPath,
            (await getApplicationDocumentsDirectory()).path);
        emit(state.copyWith(
            backupPath: (await getApplicationDocumentsDirectory()).path));
      } else {
        emit(state.copyWith(backupPath: value));
      }
    });

    FyreStreamDBService.getSettingBool(GlobalStrConsts.autoBackup).then((value) {
      emit(state.copyWith(autoBackup: value ?? false));
    });
  }

  void autoUpdate() {
    FyreStreamDBService.getSettingBool(GlobalStrConsts.autoBackup).then((value) {
      if (value != null || value == true) {
        FyreStreamDBService.createBackUp();
      }
    });
  }

  void setAutoUpdateNotify(bool value) {
    FyreStreamDBService.putSettingBool(GlobalStrConsts.autoUpdateNotify, value);
    emit(state.copyWith(autoUpdateNotify: value));
  }

  void setAutoSlideCharts(bool value) {
    FyreStreamDBService.putSettingBool(GlobalStrConsts.autoSlideCharts, value);
    emit(state.copyWith(autoSlideCharts: value));
  }

  void setDownPath(String value) {
    FyreStreamDBService.putSettingStr(GlobalStrConsts.downPathSetting, value);
    emit(state.copyWith(downPath: value));
  }

  void setDownQuality(String value) {
    FyreStreamDBService.putSettingStr(GlobalStrConsts.downQuality, value);
    emit(state.copyWith(downQuality: value));
  }

  void setYtDownQuality(String value) {
    FyreStreamDBService.putSettingStr(GlobalStrConsts.ytDownQuality, value);
    emit(state.copyWith(ytDownQuality: value));
  }

  void setStrmQuality(String value) {
    FyreStreamDBService.putSettingStr(GlobalStrConsts.strmQuality, value);
    emit(state.copyWith(strmQuality: value));
  }

  void setYtStrmQuality(String value) {
    FyreStreamDBService.putSettingStr(GlobalStrConsts.ytStrmQuality, value);
    emit(state.copyWith(ytStrmQuality: value));
  }

  void setBackupPath(String value) {
    FyreStreamDBService.putSettingStr(GlobalStrConsts.backupPath, value);
    emit(state.copyWith(backupPath: value));
  }

  void setAutoBackup(bool value) {
    FyreStreamDBService.putSettingBool(GlobalStrConsts.autoBackup, value);
    emit(state.copyWith(autoBackup: value));
  }

  Future<void> resetDownPath() async {
    String? path;

    await getDownloadsDirectory().then((value) {
      if (value != null) {
        path = value.path;
        log(path.toString(), name: 'SettingsCubit');
      }
    });

    if (path != null) {
      FyreStreamDBService.putSettingStr(GlobalStrConsts.downPathSetting, path!);
      emit(state.copyWith(downPath: path));
      log(path.toString(), name: 'SettingsCubit');
    } else {
      log("Path is null", name: 'SettingsCubit');
    }
  }
}