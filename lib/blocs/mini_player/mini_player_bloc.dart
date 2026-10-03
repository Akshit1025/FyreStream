// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fyrestream/blocs/mediaPlayer/fyrestream_player_cubit.dart';
import 'package:fyrestream/model/songModel.dart';
import 'package:fyrestream/routes_and_consts/global_consts.dart';
import 'package:just_audio/just_audio.dart';

part 'mini_player_event.dart';
part 'mini_player_state.dart';

class MiniPlayerBloc extends Bloc<MiniPlayerEvent, MiniPlayerState> {
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<bool>? _linkState;
  FyrestreamPlayerCubit playerCubit;
  MiniPlayerBloc({
    required this.playerCubit,
  }) : super(MiniPlayerInitial()) {
    listenToPlayer();
    on<MiniPlayerPlayedEvent>(played);
    on<MiniPlayerPausedEvent>(paused);
    on<MiniPlayerBufferingEvent>(buffering);
    on<MiniPlayerErrorEvent>(error);
    on<MiniPlayerProcessingEvent>(processing);
    on<MiniPlayerCompletedEvent>(completed);
    on<MiniPlayerInitialEvent>(initial);
  }

  void played(MiniPlayerPlayedEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerWorking(event.song, true, false));
  }

  void paused(MiniPlayerPausedEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerWorking(event.song, false, false));
  }

  void buffering(
      MiniPlayerBufferingEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerWorking(event.song, false, true));
  }

  void error(MiniPlayerErrorEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerError(event.song));
  }

  void processing(
      MiniPlayerProcessingEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerProcessing(event.song));
  }

  void completed(
      MiniPlayerCompletedEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerCompleted(event.song));
  }

  void initial(MiniPlayerInitialEvent event, Emitter<MiniPlayerState> emit) {
    emit(MiniPlayerInitial());
  }

  void listenToPlayer() {
    _linkState = playerCubit.fyrestreamPlayer.isLinkProcessing.listen((value) {
      if (value) {
        try {
          add(MiniPlayerProcessingEvent(
              playerCubit.fyrestreamPlayer.currentMedia));
          log("Processing link...", name: "MiniPlayer");
        } catch (e) {
          log(e.toString(), name: "MiniPlayer");
        }
      }
    });

    _playerStateSubscription =
        playerCubit.fyrestreamPlayer.audioPlayer.playerStateStream.listen((event) {
          switch (event.processingState) {
            case ProcessingState.idle:
              add(MiniPlayerInitialEvent());
              break;
            case ProcessingState.loading:
              try {
                add(MiniPlayerProcessingEvent(
                    playerCubit.fyrestreamPlayer.currentMedia));
              } catch (e) {}
              break;
            case ProcessingState.buffering:
              try {
                add(MiniPlayerBufferingEvent(
                    playerCubit.fyrestreamPlayer.currentMedia));
              } catch (e) {}
              break;
            case ProcessingState.ready:
              try {
                if (event.playing) {
                  add(MiniPlayerPlayedEvent(
                      playerCubit.fyrestreamPlayer.currentMedia));
                } else {
                  add(MiniPlayerPausedEvent(
                      playerCubit.fyrestreamPlayer.currentMedia));
                }
              } catch (e) {}
              break;
            case ProcessingState.completed:
              try {
                add(MiniPlayerCompletedEvent(
                    playerCubit.fyrestreamPlayer.currentMedia));
              } catch (e) {}
              break;
            case AudioProcessingState.error:
              try {
                add(MiniPlayerErrorEvent(playerCubit.fyrestreamPlayer.currentMedia));
              } catch (e) {}
              break;
          }
        });
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _linkState?.cancel();
    return super.close();
  }
}