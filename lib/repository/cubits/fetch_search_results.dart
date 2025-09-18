import 'package:bloc/bloc.dart';
import 'package:fyrestream/model/MediaPlaylistModel.dart';
import 'package:fyrestream/model/yt_music_model.dart';
import 'package:fyrestream/model/youtube_vid_model.dart';
import 'package:fyrestream/model/songModel.dart';
import 'package:fyrestream/repository/Youtube/youtube_api.dart';
import 'package:fyrestream/repository/Youtube/yt_music_api.dart';

enum LoadingState { initial, loading, loaded, noInternet }

class FetchSearchResultsState extends MediaPlaylist {
  LoadingState loadingState = LoadingState.initial;

  FetchSearchResultsState({
    required super.mediaItems,
    required super.albumName,
    required this.loadingState,
  });
}

final class FetchSearchResultsInitial extends FetchSearchResultsState {
  FetchSearchResultsInitial()
    : super(
        mediaItems: [],
        albumName: 'Empty',
        loadingState: LoadingState.initial,
      );
}

final class FetchSearchResultsLoading extends FetchSearchResultsState {
  FetchSearchResultsLoading()
    : super(
        mediaItems: [],
        albumName: 'Empty',
        loadingState: LoadingState.loading,
      );
}
//------------------------------------------------------------------------

class FetchSearchResultsCubit extends Cubit<FetchSearchResultsState> {
  FetchSearchResultsCubit() : super(FetchSearchResultsInitial());
  List<MediaItemModel> _mediaItemList = List.empty(growable: true);

  Future<void> search(String query) async {
    emit(FetchSearchResultsLoading());
    final searchResults = await YtMusicService().search(query, filter: "songs");
    _mediaItemList = fromYtSongMapList2MediaItemList(searchResults[0]['items']);
    emit(
      FetchSearchResultsState(
        mediaItems: _mediaItemList,
        albumName: "Search",
        loadingState: LoadingState.loaded,
      ),
    );
    final searchResults2 = await YouTubeServices().fetchSearchResults(query);
    _mediaItemList.addAll(
      fromYtVidSongMapList2MediaItemList(searchResults2[0]['items']),
    );
    emit(
      FetchSearchResultsState(
        mediaItems: _mediaItemList,
        albumName: "Search",
        loadingState: LoadingState.loaded,
      ),
    );
    print("got all searches ${_mediaItemList.length}");
  }
}
