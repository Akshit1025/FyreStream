import 'dart:async';
import 'dart:developer';
import 'package:fyrestream/services/db/fyrestream_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:fyrestream/model/MediaPlaylistModel.dart';
part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  StreamSubscription<void>? watcher;
  HistoryCubit() : super(HistoryInitial()) {
    getRecentlyPlayed();
    watchRecentlyPlayed();
  }
  Future<void> watchRecentlyPlayed() async {
    watcher = (await FyreStreamDBService.watchRecentlyPlayed()).listen((event) {
      getRecentlyPlayed();
      log("History Updated");
    });
  }

  void getRecentlyPlayed() async {
    final mediaPlaylist = await FyreStreamDBService.getRecentlyPlayed();
    emit(state.copyWith(mediaPlaylist: mediaPlaylist));
  }

  @override
  Future<void> close() {
    watcher?.cancel();
    return super.close();
  }
}