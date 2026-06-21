import 'package:fyrestream/services/audio_service_initializer.dart';
import 'package:bloc/bloc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import 'package:fyrestream/services/fyrestreamPlayer.dart';

part 'fyrestream_player_state.dart';

class FyrestreamPlayerCubit extends Cubit<FyreStreamPlayerState> {
  late FyreStreamMusicPlayer fyrestreamPlayer;

  late Stream<ProgressBarStreams> progressStreams;

  FyrestreamPlayerCubit() : super(FyreStreamPlayerInitial()) {
    setupPlayer().then((value) => emit(FyreStreamPlayerState(isReady: true)));
  }

  Future<void> setupPlayer() async {
    fyrestreamPlayer = await PlayerInitializer().getAudioHandler();

    progressStreams = Rx.defer(
      () => Rx.combineLatest3(
        fyrestreamPlayer.audioPlayer.positionStream,
        fyrestreamPlayer.audioPlayer.playbackEventStream,
        fyrestreamPlayer.audioPlayer.playerStateStream,
        (Duration a, PlaybackEvent b, PlayerState c) => ProgressBarStreams(
          currentPos: a,
          currentPlaybackState: b,
          currentPlayerState: c,
        ),
      ),
      reusable: true,
    );

    fyrestreamPlayer.audioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        //Temp solution(Debouncing) to prevent from subsequent gapless 'completed' event
        EasyThrottle.throttle(
          'skipNext',
          const Duration(milliseconds: 7000),
          () async => await fyrestreamPlayer.skipToNext(),
        );
        // print("skipping to next->>");
      }
    });
  }

  @override
  Future<void> close() {
    EasyDebounce.cancelAll();
    fyrestreamPlayer.stop();
    fyrestreamPlayer.currentQueueName.close();
    fyrestreamPlayer.audioPlayer.dispose();
    return super.close();
  }
}
