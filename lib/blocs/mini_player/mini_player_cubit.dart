import 'dart:async';
import 'dart:developer';
import 'package:fyrestream/blocs/mediaPlayer/fyrestream_player_cubit.dart';
import 'package:fyrestream/model/songModel.dart';
import 'package:fyrestream/routes_and_consts/global_consts.dart';
import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
part 'mini_player_state.dart';

class MiniPlayerCubit extends Cubit<MiniPlayerState> {
  FyrestreamPlayerCubit fyrestreamPlayerCubit;
  StreamSubscription? _linkSub;
  StreamSubscription? _playerSub;
  MiniPlayerCubit({required this.fyrestreamPlayerCubit})
      : super(MiniPlayerInitial()) {
    subscribeToPlayer();
    subscribeLinkProc();
  }

  void subscribeLinkProc() async {
    _linkSub =
        fyrestreamPlayerCubit.fyrestreamPlayer.isLinkProcessing.listen((event) {
          if (event) {
            log("MiniPlayerCubit: isLinkProcessing");
            emit(state.copyWith(
              isProcessing: true,
            ));
          }
        });
  }

  void subscribeToPlayer() async {
    _playerSub = fyrestreamPlayerCubit.fyrestreamPlayer.playbackState.listen((value) {
      switch (value.processingState) {
        case AudioProcessingState.idle:
          emit(MiniPlayerInitial());
          break;
        case AudioProcessingState.loading:
          if (fyrestreamPlayerCubit.fyrestreamPlayer.mediaItem.value != null) {
            emit(state.copyWith(
              mediaItem: mediaItem2MediaItemModel(
                  fyrestreamPlayerCubit.fyrestreamPlayer.mediaItem.value!),
              isPlaying: false,
              isBuffering: true,
              isProcessing: true,
              isCompleted: false,
            ));
          }
          break;
        case AudioProcessingState.buffering:
          if (fyrestreamPlayerCubit.fyrestreamPlayer.mediaItem.value != null) {
            emit(state.copyWith(
              mediaItem: mediaItem2MediaItemModel(
                  fyrestreamPlayerCubit.fyrestreamPlayer.mediaItem.value!),
              isPlaying: false,
              isBuffering: true,
              isProcessing: false,
              isCompleted: false,
            ));
          }
          break;
        case AudioProcessingState.ready:
          if (fyrestreamPlayerCubit.fyrestreamPlayer.mediaItem.value != null) {
            emit(state.copyWith(
              mediaItem: mediaItem2MediaItemModel(
                  fyrestreamPlayerCubit.fyrestreamPlayer.mediaItem.value!),
              isPlaying: value.playing,
              isBuffering: false,
              isProcessing: false,
              isCompleted: false,
            ));
          }
          break;

        case AudioProcessingState.completed:
          log("MiniPlayerCubit: completed");
          emit(state.copyWith(isCompleted: true));

          break;
        case AudioProcessingState.error:
          emit(MiniPlayerError());
          break;
      }

      if (value.playing) {
        emit(state.copyWith(
          mediaItem: mediaItem2MediaItemModel(
              fyrestreamPlayerCubit.fyrestreamPlayer.mediaItem.value!),
          isPlaying: true,
          isBuffering: false,
          isProcessing: false,
          isCompleted: false,
        ));
      } else {
        emit(state.copyWith(
          mediaItem: mediaItem2MediaItemModel(
              fyrestreamPlayerCubit.fyrestreamPlayer.mediaItem.value!),
          isPlaying: false,
          isBuffering: false,
          isProcessing: false,
          isCompleted: false,
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _playerSub?.cancel();
    _linkSub?.cancel();
    return super.close();
  }
}