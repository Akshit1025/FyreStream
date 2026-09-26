import 'dart:async';
import 'dart:developer';

import 'package:fyrestream/blocs/library/cubit/library_items_cubit.dart';
import 'package:fyrestream/model/songModel.dart';
import 'package:fyrestream/services/db/fyrestream_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'offline_state.dart';

class OfflineCubit extends Cubit<OfflineState> {
  LibraryItemsCubit libraryItemsCubit;
  StreamSubscription? strmSubsDB;
  OfflineCubit({required this.libraryItemsCubit}) : super(OfflineInitial()) {
    strmSubs();
    getSongs();
  }

  @override
  Future<void> close() {
    strmSubsDB?.cancel();
    return super.close();
  }

  Future<void> strmSubs() async {
    strmSubsDB = libraryItemsCubit.stream.listen((event) {
      log("LibraryItemsCubit event: ${event.playlists.length}",
          name: "OfflineCubit");
      getSongs();
    });
  }

  Future<void> getSongs() async {
    final list = await FyreStreamDBService.getDownloadedSongs();
    if (list.isNotEmpty) {
      emit(OfflineState(songs: List<MediaItemModel>.from(list)));
    } else {
      emit(OfflineEmpty());
    }
  }
}