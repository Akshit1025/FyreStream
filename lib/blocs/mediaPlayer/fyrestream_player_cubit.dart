import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import 'package:fyrestream/services/fyrestreamPlayer.dart';
import 'package:fyrestream/theme_data/default.dart';

part 'fyrestream_player_state.dart';

class FyrestreamPlayerCubit extends Cubit<FyreStreamPlayerState> {
  late FyreStreamMusicPlayer fyrestreamPlayer;

  // late AudioSession audioSession;
  late Stream<ProgressBarStreams> progressStreams;

  FyrestreamPlayerCubit() : super(FyreStreamPlayerInitial()) {
    setupPlayer().then((value) => emit(FyreStreamPlayerState(isReady: true)));
  }

  Future<void> setupPlayer() async {
    fyrestreamPlayer = await AudioService.init(
      builder: () => FyreStreamMusicPlayer(),
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: true,
        androidNotificationChannelId: 'com.BloomeePlayer.notification.status',
        androidNotificationChannelName: 'mediaPlayback',
        androidShowNotificationBadge: true,
        notificationColor: Default_Theme.accentColor2,
      ),
    );

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
    fyrestreamPlayer.audioPlayer.dispose();
    fyrestreamPlayer.currentQueueName.close();
    fyrestreamPlayer.stop();
    return super.close();
  }
}
