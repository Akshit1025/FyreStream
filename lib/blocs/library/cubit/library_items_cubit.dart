// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'package:fyrestream/model/MediaPlaylistModel.dart';
import 'package:equatable/equatable.dart';
import 'package:fyrestream/model/songModel.dart';
import 'package:fyrestream/screens/widgets/snackbar.dart';
import 'package:fyrestream/services/db/GlobalDB.dart';
import 'package:fyrestream/services/db/fyrestream_db_service.dart';
import 'package:fyrestream/services/db/cubit/fyrestream_db_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'library_items_state.dart';

class LibraryItemsCubit extends Cubit<LibraryItemsState> {
  Stream<void>? playlistWatcherDB;
  List<PlaylistItemProperties> playlistItems = List.empty();
  FyreStreamDBCubit fyrestreamDBCubit;
  List<MediaPlaylist> mediaPlaylists = [];
  StreamSubscription? strmSubsDB;

  LibraryItemsCubit({
    required this.fyrestreamDBCubit,
  }) : super(LibraryItemsInitial()) {
    getAndEmitPlaylists();
    getDBWatcher();
  }

  @override
  Future<void> close() {
    strmSubsDB?.cancel();
    return super.close();
  }

  Future<void> getDBWatcher() async {
    playlistWatcherDB = await FyreStreamDBService.getPlaylistsWatcher();
    strmSubsDB = playlistWatcherDB?.listen((event) {
      getAndEmitPlaylists();
    });
  }

  Future<void> getAndEmitPlaylists() async {
    mediaPlaylists = await FyreStreamDBService.getPlaylists4Library();
    if (mediaPlaylists.isNotEmpty) {
      playlistItems = mediaPlaylistsDB2ItemProperties(mediaPlaylists);

      emit(LibraryItemsState(playlists: playlistItems));
    } else {
      emit(LibraryItemsInitial());
    }
  }

  List<PlaylistItemProperties> mediaPlaylistsDB2ItemProperties(
      List<MediaPlaylist> _mediaPlaylists) {
    List<PlaylistItemProperties> _playlists = List.empty(growable: true);
    if (_mediaPlaylists.isNotEmpty) {
      for (var element in _mediaPlaylists) {
        log(element.playlistName, name: "LibCubit");
        _playlists.add(
          PlaylistItemProperties(
            playlistName: element.playlistName,
            subTitle: "${element.mediaItems.length} Items",
            coverImgUrl: element.imgUrl ?? (element.mediaItems.isNotEmpty ? element.mediaItems.first.artUri?.toString() : null),
          ),
        );
      }
    }
    return _playlists;
  }

  void removePlaylist(MediaPlaylistDB mediaPlaylistDB) {
    if (mediaPlaylistDB.playlistName != "Null") {
      FyreStreamDBService.removePlaylist(mediaPlaylistDB);
      // getAndEmitPlaylists();
      SnackbarService.showMessage(
          "Playlist ${mediaPlaylistDB.playlistName} removed");
    }
  }

  Future<void> addToPlaylist(
      MediaItemModel mediaItem, MediaPlaylistDB mediaPlaylistDB) async {
    if (mediaPlaylistDB.playlistName != "Null") {
      await fyrestreamDBCubit.addMediaItemToPlaylist(mediaItem, mediaPlaylistDB);
      getAndEmitPlaylists();
      // log("Added to playlist - ${mediaPlaylistDB.playlistName} - $_tempID",
      //     name: "libItemCubit");
      // SnackbarService.showMessage(
      //     "Added ${mediaItem.title} to ${mediaPlaylistDB.playlistName}");
    }
  }

  void removeFromPlaylist(
      MediaItemModel mediaItem, MediaPlaylistDB mediaPlaylistDB) {
    if (mediaPlaylistDB.playlistName != "Null") {
      fyrestreamDBCubit.removeMediaFromPlaylist(mediaItem, mediaPlaylistDB);
      getAndEmitPlaylists();
      SnackbarService.showMessage(
          "Removed ${mediaItem.title} from ${mediaPlaylistDB.playlistName}");
    }
  }

  Future<List<MediaItemModel>?> getPlaylist(String playlistName) async {
    try {
      final _playlist = await FyreStreamDBService.getPlaylistItemsByName(playlistName);

      if (_playlist != null) {
        final mediaItems =
        _playlist.map((e) => MediaItemDB2MediaItem(e)).toList();
        return mediaItems;
      }
    } catch (e) {
      log("Error in getting playlist: $e", name: "libItemCubit");
      return null;
    }
    return null;
  }
}