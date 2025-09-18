// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:fyrestream/model/MediaPlaylistModel.dart';
import 'package:fyrestream/services/db/MediaDB.dart';

import 'package:fyrestream/services/db/cubit/mediadb_cubit.dart';
import 'package:fyrestream/utils/load_Image.dart';

part 'library_items_state.dart';

class LibraryItemsCubit extends Cubit<LibraryItemsState> {
  MediaDBCubit mediaDBCubit;
  List<MediaPlaylist> mediaPlaylist = [];
  LibraryItemsState libraryItemsState = LibraryItemsState(
    playlists: List.empty(growable: true),
  );

  LibraryItemsCubit({required this.mediaDBCubit})
    : super(LibraryItemsInitial()) {
    mediaDBCubit.refreshLibrary.listen((value) {
      print(value);
      if (value) {
        getAndEmitPlaylists();
        print("got refresh command");
      }
    });
    getAndEmitPlaylists();
  }

  Future<void> getAndEmitPlaylists() async {
    libraryItemsState = LibraryItemsState(
      playlists: List.empty(growable: true),
    );
    mediaPlaylist = await mediaDBCubit.getListOfPlaylists2();
    List<String> _playlists = List.empty(growable: true);
    if (libraryItemsState.playlists.isNotEmpty) {
      for (var element in libraryItemsState.playlists) {
        _playlists.add(element.playlistName ?? "Unknown");
      }
      libraryItemsState.playlists = [];
    }
    if (mediaPlaylist.length > 0) {
      for (var element in mediaPlaylist) {
        // if (_playlists.contains(element.albumName)) {
        //   int? _idx = _playlists.indexOf(element.albumName);

        //   libraryItemsState.playlists.removeAt(_idx);
        // }
        ImageProvider _tempProvider;

        if (element.mediaItems.length > 0) {
          _tempProvider = await getImageProvider(
            element.mediaItems[0].artUri.toString(),
          );
        } else {
          _tempProvider = await getImageProvider("");
        }
        PlaylistItemProperties _playlistItem = PlaylistItemProperties(
          playlistName: element.albumName,
          imageProvider: _tempProvider,
          subTitle: "Saavan",
        );
        libraryItemsState.playlists.add(_playlistItem);

        // libraryItemsState.playlistNames?.add(element.albumName);
        // libraryItemsState.subTitles?.add("Saavan");
      }
      emit(state.copyWith(playlists: libraryItemsState.playlists));
      print(
        "emitted from library ${_playlists.toString()} - ${libraryItemsState.playlists.length} - MediaPlaylists ${mediaPlaylist}",
      );
    }
  }

  void removePlaylist(MediaPlaylistDB mediaPlaylistDB) {
    if (mediaPlaylistDB.playlistName != "Null") {
      mediaDBCubit.removePlaylist(mediaPlaylistDB);
      getAndEmitPlaylists();
    }
  }
}
